create view [dbo].[WaitStatsByContext] (
	[SPID],
	[Context],
	[DateFrom],
	[DateTo],
	[WaitType],
	[WaitTime],
	[NbrWaits],
	[AvgWaitTime],
	[WaitTimeTtl],
	[WaitTimePct]
)
as
select
	[SPID],
	[Context],
	[DateFrom],
	[DateTo],
	[WaitType],
	[WaitTime],
	[NbrWaits],
	[AvgWaitTime],
	[WaitTimeTtl],
	[WaitTimePct] = case
		when [WaitTimeTtl] > 0 then cast(100.00 * [WaitTime] / [WaitTimeTtl] as decimal(5,2))
		else 0.00
	end
from (
	select
		[SPID],
		[Context],
		[DateFrom],
		[DateTo],
		[WaitType],
		[WaitTime],
		[NbrWaits],
		[AvgWaitTime] = case
			when [NbrWaits] > 0 then cast(cast([WaitTime] as float) / [NbrWaits] as decimal(19,2))
			when [NbrWaits] is null then null
			when [NbrWaits] = 0 then 0.00
		end,
		[WaitTimeTtl] = sum([WaitTime]) over (
			partition by
				[SPID],
				[Context],
				[DateFrom]
		)
	from (
		select
			[SPID] = PRV.[SPID],
			[Context] = PRV.[Context],
			[DateFrom] = PRV.[Timestamp],
			[DateTo] = NXT.[Timestamp],
			[WaitType] = PRV.[WaitType],
			[WaitTime] = NXT.[WaitTime] - PRV.[WaitTime],
			[NbrWaits] = NXT.[NbrWaits] - PRV.[NbrWaits]
		from [dbo].[WaitStatsSnapshot] as PRV
		outer apply (
			select top (1)
				NXT.[SPID],
				NXT.[Timestamp],
				NXT.[Context],
				NXT.[WaitType],
				NXT.[WaitTime],
				NXT.[NbrWaits]
			from [dbo].[WaitStatsSnapshot] as NXT
			where NXT.[SPID] = PRV.[SPID]
				and NXT.[Context] = PRV.[Context]
				and NXT.[WaitType] = PRV.[WaitType]
				and NXT.[Timestamp] > PRV.[Timestamp]
			order by
				NXT.[Timestamp] asc
		) as NXT
	) as Q
	where [DateTo] is not null
) as Q
go