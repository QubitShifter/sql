create view [dbo].[vMonitorTableStatsLatest]
as
with [LatestSnapshot] as (
	select
		[counter_snapshot_id] = max([counter_snapshot_id])
	from [dbo].[CounterSnapshots]
	where [counter_snapshot_type_id] = 4
)
select
	ts.[counter_snapshot_id],
	cs.[datestamp],
	ts.[database_id],
	[database_name] = db_name(ts.[database_id]),
	ts.[object_id],
	[schema_name] = object_schema_name(ts.[object_id], ts.[database_id]),
	[object_name] = object_name(ts.[object_id], ts.[database_id]),
	ts.[index_id],
	ts.[partition_number],
	ts.[rows],
	ts.[SizeMb]
from [dbo].[TableStats] as ts
inner join [dbo].[CounterSnapshots] as cs
	on cs.[counter_snapshot_id] = ts.[counter_snapshot_id]
inner join [LatestSnapshot] as ls
	on ls.[counter_snapshot_id] = ts.[counter_snapshot_id]
go