
set transaction isolation level read uncommitted;

select
	db_name() as [DatabaseName],
	schema_name([o].Schema_ID) as [SchemaName],
	object_name([s].[object_id]) as [TableName],
	[i].[name] as [IndexName],
	([s].[user_updates]) as [update usage],
	([s].[user_seeks] + [s].[user_scans] + [s].[user_lookups]) as [Retrieval usage],
	([s].[user_updates]) - ([s].[user_seeks] + [s].[user_scans] + [s].[user_lookups]) as [Maintenance cost],
	[s].[system_seeks] + [s].[system_scans] + [s].[system_lookups] as [System usage],
	[s].[last_user_seek],
	[s].[last_user_scan],
	[s].[last_user_lookup]
into #TempMaintenanceCost
from sys.dm_db_index_usage_stats as s
	join sys.indexes as i on s.[object_id] = i.[object_id]
													 and s.index_id = i.index_id
	join sys.objects as o on i.object_id = o.object_id
where 1 = 2;

exec sp_MSForEachDB 'USE [?];                              

insert into #TempMaintenanceCost
select top 20
	db_name() as [DatabaseName],
	schema_name([o].Schema_ID) as [SchemaName],
	object_name([s].[object_id]) as [TableName],
	[i].[name] as [IndexName],
	([s].[user_updates]) as [update usage],
	([s].[user_seeks] + [s].[user_scans] + [s].[user_lookups]) as [Retrieval usage],
	([s].[user_updates]) - ([s].[user_seeks] + [user_scans] + [s].[user_lookups]) as [Maintenance cost],
	[s].[system_seeks] + [s].[system_scans] + [s].[system_lookups] as [System usage],
	[s].[last_user_seek],
	[s].[last_user_scan],
	[s].[last_user_lookup]
from sys.dm_db_index_usage_stats as s
	join sys.indexes as i on s.[object_id] = i.[object_id] and s.index_id = i.index_id
	join sys.objects as o on i.object_id = o.object_id
where [s].[database_id] = db_id()
			and [i].[name] is not null
			and objectproperty([s].[object_id], ''IsMsShipped'') = 0
			and ([s].[user_seeks] + [s].[user_scans] + [s].[user_lookups]) > 0
order by [Maintenance cost] desc;';

select top 20 *
from #TempMaintenanceCost
order by [Maintenance cost] desc;

drop table #TempMaintenanceCost;