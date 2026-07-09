create view [dbo].[vMonitorWaitStatsDelta]
as
with [WaitStatsWithPrevious] as (
	select
		cs.[counter_snapshot_id],
		cs.[datestamp],
		ws.[wait_type],
		ws.[waiting_tasks_count],
		ws.[wait_time_ms],
		ws.[max_wait_time_ms],
		ws.[signal_wait_time_ms],

		[previous_counter_snapshot_id] = lag(cs.[counter_snapshot_id]) over (
			partition by ws.[wait_type]
			order by cs.[counter_snapshot_id]
		),

		[previous_datestamp] = lag(cs.[datestamp]) over (
			partition by ws.[wait_type]
			order by cs.[counter_snapshot_id]
		),

		[previous_waiting_tasks_count] = lag(ws.[waiting_tasks_count]) over (
			partition by ws.[wait_type]
			order by cs.[counter_snapshot_id]
		),

		[previous_wait_time_ms] = lag(ws.[wait_time_ms]) over (
			partition by ws.[wait_type]
			order by cs.[counter_snapshot_id]
		),

		[previous_signal_wait_time_ms] = lag(ws.[signal_wait_time_ms]) over (
			partition by ws.[wait_type]
			order by cs.[counter_snapshot_id]
		)
	from [dbo].[WaitStats] as ws
	inner join [dbo].[CounterSnapshots] as cs
		on cs.[counter_snapshot_id] = ws.[counter_snapshot_id]
	where cs.[counter_snapshot_type_id] = 1
),
[WaitStatsDelta] as (
	select
		[counter_snapshot_id],
		[datestamp],
		[previous_counter_snapshot_id],
		[previous_datestamp],
		[wait_type],

		[waiting_tasks_delta] = case
			when [previous_waiting_tasks_count] is null then null
			when [waiting_tasks_count] >= [previous_waiting_tasks_count]
				then [waiting_tasks_count] - [previous_waiting_tasks_count]
			else null
		end,

		[wait_time_ms_delta] = case
			when [previous_wait_time_ms] is null then null
			when [wait_time_ms] >= [previous_wait_time_ms]
				then [wait_time_ms] - [previous_wait_time_ms]
			else null
		end,

		[signal_wait_time_ms_delta] = case
			when [previous_signal_wait_time_ms] is null then null
			when [signal_wait_time_ms] >= [previous_signal_wait_time_ms]
				then [signal_wait_time_ms] - [previous_signal_wait_time_ms]
			else null
		end,

		[max_wait_time_ms],
		[wait_time_ms],
		[waiting_tasks_count],
		[signal_wait_time_ms]
	from [WaitStatsWithPrevious]
),
[WaitStatsWithTotals] as (
	select
		*,
		[wait_time_ms_delta_total] = sum([wait_time_ms_delta]) over (
			partition by [counter_snapshot_id]
		)
	from [WaitStatsDelta]
)
select
	[counter_snapshot_id],
	[datestamp],
	[previous_counter_snapshot_id],
	[previous_datestamp],
	[wait_type],
	[waiting_tasks_delta],
	[wait_time_ms_delta],
	[signal_wait_time_ms_delta],
	[resource_wait_time_ms_delta] = [wait_time_ms_delta] - isnull([signal_wait_time_ms_delta], 0),
	[avg_wait_time_ms_delta] = case
		when [waiting_tasks_delta] > 0
			then cast(cast([wait_time_ms_delta] as decimal(19, 2)) / [waiting_tasks_delta] as decimal(19, 2))
		else null
	end,
	[wait_time_pct] = case
		when [wait_time_ms_delta_total] > 0
			then cast(100.00 * [wait_time_ms_delta] / [wait_time_ms_delta_total] as decimal(5, 2))
		else null
	end,
	[max_wait_time_ms],
	[wait_time_ms],
	[waiting_tasks_count],
	[signal_wait_time_ms]
from [WaitStatsWithTotals]
where [previous_counter_snapshot_id] is not null
go