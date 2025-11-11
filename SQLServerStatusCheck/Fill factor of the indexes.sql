select
	db_name() as [DatabaseName],
	schema_name([o].Schema_ID) as [SchemaName],
	object_name([s].[object_id]) as [TableName],
	[i].[name] as [IndexName],
	[i].[fill_factor]
from sys.dm_db_index_usage_stats as s
	join sys.indexes as i on s.[object_id] = i.[object_id]
													 and s.index_id = i.index_id
	join sys.objects as o on i.object_id = O.object_id
where [s].[database_id] = db_id()
			and [i].[name] is not null
			and objectproperty([s].[object_id], 'IsMsShipped') = 0
order by
	[fill_factor] desc;