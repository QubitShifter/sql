create view [dbo].[vMonitorLatestSnapshots]
as
select
	cs.[counter_snapshot_id],
	cs.[datestamp],
	cs.[counter_snapshot_type_id],
	cst.[counter_snapshot_type_name]
from [dbo].[CounterSnapshots] as cs
inner join [dbo].[CounterSnapshotTypes] as cst
	on cst.[counter_snapshot_type_id] = cs.[counter_snapshot_type_id]
where cs.[counter_snapshot_id] in (
	select
		max(cs2.[counter_snapshot_id])
	from [dbo].[CounterSnapshots] as cs2
	group by
		cs2.[counter_snapshot_type_id]
)
go