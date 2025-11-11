
set transaction isolation level read uncommitted;

select
	db_name() as [DatbaseName],
	schema_name([o].Schema_ID) as [SchemaName],
	object_name([s].[object_id]) as [TableName],
	[i].[name] as [IndexName],
	round([s].[avg_fragmentation_in_percent], 2) as [Fragmentation %]
into
	[#TempFragmentation]
from sys.dm_db_index_physical_stats ( db_id(), null, null, null, null ) as s
	join sys.indexes as i on s.[object_id] = i.[object_id] and s.index_id = i.index_id
	join sys.objects as o on i.object_id = o.object_id
where 1 = 2;

exec sp_MSForEachDB '
use [?];

insert into #TempFragmentation
select top 20
	db_name() as [DatbaseName],
	schema_name([o].Schema_ID) as [SchemaName],
	object_name([s].[object_id]) as [TableName],
	[i].[name] as [IndexName],
	round([s].[avg_fragmentation_in_percent], 2) as [Fragmentation %]
from sys.dm_db_index_physical_stats ( db_id(), null, null, null, null ) as s
	inner join sys.indexes as i on s.[object_id] = i.[object_id] and s.index_id = i.index_id
	inner join sys.objects as o on i.object_id = o.object_id
where [s].[database_id] = db_id()
			and [i].[name] is not null
			and objectproperty([s].[object_id], ''IsMsShipped'') = 0
order by [Fragmentation %] desc;';

select top 20 *
from #TempFragmentation
order by [Fragmentation %] desc;

drop table #TempFragmentation;