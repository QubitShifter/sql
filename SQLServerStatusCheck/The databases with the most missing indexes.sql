set transaction isolation level read uncommitted;

select
	db_name() as [DatbaseName],
	schema_name([O].Schema_ID) as [SchemaName],
	object_name([I].object_id) as [TableName],
	[I].[name] as [IndexName]
into [#TempNeverUsedIndexes]
from sys.indexes as I
	join sys.objects as O on I.object_id = O.object_id
where 1 = 2;

exec sp_MSForEachDB 'use [?];                           
insert into #TempNeverUsedIndexes
select
	db_name() as [DatbaseName],
	schema_name([O].Schema_ID) as [SchemaName],
	object_name([I].object_id) as [TableName],
	[I].[NAME] as [IndexName]
from sys.indexes as I
	join sys.objects as O on I.object_id = O.object_id
	left join sys.dm_db_index_usage_stats as S on S.object_id = I.object_id and I.index_id = S.index_id and database_id = db_id()
where objectproperty([O].object_id, '' [IsMsShipped] '') = 0
			and [I].[name] is not null
			and [S].object_id is null;';

select *
from #TempNeverUsedIndexes
order by
	[DatbaseName],
	[SchemaName],
	[TableName],
	[IndexName];

drop table #TempNeverUsedIndexes;