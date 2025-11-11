set transaction isolation level read uncommitted;

select
	db_name() as [DatabaseName],
	schema_name([o].Schema_ID) as [SchemaName],
	object_name([s].[object_id]) as [TableName],
	[i].[name] as [IndexName],
	[s].[user_updates],
	[s].[system_seeks] + [s].[system_scans] + [s].[system_lookups] as [System usage]
into #TempUnusedIndexes
from sys.dm_db_index_usage_stats as s
	join sys.indexes as i on s.[object_id] = i.[object_id] and s.index_id = i.index_id
	join sys.objects as o on i.object_id = o.object_id
where 1 = 2;

exec sp_MSForEachDB 'use [?];                           

insert into #TempUnusedIndexes
select top 20
	db_name() as [DatabaseName],
	schema_name([o].Schema_ID) as [SchemaName],
	object_name([s].[object_id]) as [TableName],
	[i].[name] as [IndexName],
	[s].[user_updates],
	[s].[system_seeks] + [s].[system_scans] + [s].[system_lookups] as [System usage]
from sys.dm_db_index_usage_stats as s
	join sys.indexes as i on s.[object_id] = i.[object_id] and s.index_id = i.index_id
	join sys.objects as o on i.object_id = o.object_id
where [s].[database_id] = db_id()
			and objectproperty([s].[object_id], ''IsMsShipped'') = 0
			and [s].[user_seeks] = 0
			and [s].[user_scans] = 0
			and [s].[user_lookups] = 0
			and [i].[name] is not null
order by [s].[user_updates] desc;';

select top 20 *
from #TempUnusedIndexes
order by [user_updates] desc;

drop table #TempUnusedIndexes;

