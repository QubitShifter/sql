create view [dbo].[vMonitorTempDBStatsLatest]
as
with [LatestSnapshot] as (
	select
		[counter_snapshot_id] = max([counter_snapshot_id])
	from [dbo].[CounterSnapshots]
	where [counter_snapshot_type_id] = 5
)
select
	tds.[counter_snapshot_id],
	cs.[datestamp],
	tds.[file_id],
	[unallocated_extent_mb] = cast(tds.[unallocated_extent_page_count] * 8.0 / 1024.0 as decimal(19, 2)),
	[version_store_reserved_mb] = cast(isnull(tds.[version_store_reserved_page_count], 0) * 8.0 / 1024.0 as decimal(19, 2)),
	[user_object_reserved_mb] = cast(isnull(tds.[user_object_reserved_page_count], 0) * 8.0 / 1024.0 as decimal(19, 2)),
	[internal_object_reserved_mb] = cast(isnull(tds.[internal_object_reserved_page_count], 0) * 8.0 / 1024.0 as decimal(19, 2)),
	[mixed_extent_mb] = cast(tds.[mixed_extent_page_count] * 8.0 / 1024.0 as decimal(19, 2)),
	tds.[unallocated_extent_page_count],
	tds.[version_store_reserved_page_count],
	tds.[user_object_reserved_page_count],
	tds.[internal_object_reserved_page_count],
	tds.[mixed_extent_page_count]
from [dbo].[TempDBStats] as tds
inner join [dbo].[CounterSnapshots] as cs
	on cs.[counter_snapshot_id] = tds.[counter_snapshot_id]
inner join [LatestSnapshot] as ls
	on ls.[counter_snapshot_id] = tds.[counter_snapshot_id]
go