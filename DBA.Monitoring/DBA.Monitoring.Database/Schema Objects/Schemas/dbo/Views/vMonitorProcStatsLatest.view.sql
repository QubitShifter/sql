create view [dbo].[vMonitorProcStatsLatest]
as
with [LatestSnapshot] as (
	select
		[counter_snapshot_id] = max([counter_snapshot_id])
	from [dbo].[CounterSnapshots]
	where [counter_snapshot_type_id] = 2
)
select
	ps.[counter_snapshot_id],
	cs.[datestamp],
	ps.[database_id],
	[database_name] = db_name(ps.[database_id]),
	ps.[object_id],
	[schema_name] = object_schema_name(ps.[object_id], ps.[database_id]),
	[object_name] = object_name(ps.[object_id], ps.[database_id]),
	ps.[plan_handle],
	ps.[last_execution_time],
	ps.[execution_count],
	ps.[total_worker_time],
	ps.[last_worker_time],
	ps.[min_worker_time],
	ps.[max_worker_time],
	ps.[total_physical_reads],
	ps.[last_physical_reads],
	ps.[total_logical_writes],
	ps.[last_logical_writes],
	ps.[total_logical_reads],
	ps.[last_logical_reads],
	ps.[total_elapsed_time],
	ps.[last_elapsed_time],

	[avg_worker_time] = case
		when ps.[execution_count] > 0
			then cast(cast(ps.[total_worker_time] as decimal(19, 2)) / ps.[execution_count] as decimal(19, 2))
		else null
	end,

	[avg_elapsed_time] = case
		when ps.[execution_count] > 0
			then cast(cast(ps.[total_elapsed_time] as decimal(19, 2)) / ps.[execution_count] as decimal(19, 2))
		else null
	end,

	[avg_logical_reads] = case
		when ps.[execution_count] > 0
			then cast(cast(ps.[total_logical_reads] as decimal(19, 2)) / ps.[execution_count] as decimal(19, 2))
		else null
	end
from [dbo].[ProcStats] as ps
inner join [dbo].[CounterSnapshots] as cs
	on cs.[counter_snapshot_id] = ps.[counter_snapshot_id]
inner join [LatestSnapshot] as ls
	on ls.[counter_snapshot_id] = ps.[counter_snapshot_id]
go