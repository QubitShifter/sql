set transaction isolation level read uncommitted;
/******************************
put your query there 
*******************************/
declare @query nvarchar(max) = 'select top 100 [UserID], count(*) from dbo.MoneyTransaction where [UserID] > 100 group by [UserID]';

select 
	SchemaName=ss.[name], 
	TableName=st.[name], 
	IndexName=isnull(si.[name], ''), 
	IndexType=si.[type_desc], 
	user_updates=isnull(ius.[user_updates], 0), 
	user_seeks=isnull(ius.[user_seeks], 0), 
	user_scans=isnull(ius.[user_scans], 0), 
	user_lookups=isnull(ius.[user_lookups], 0), 
	ssi.[rowcnt], 
	ssi.[rowmodctr], 
	si.[fill_factor]
into #IndexStatsPre 
from sys.dm_db_index_usage_stats as ius 
	right join sys.indexes as si on ius.[object_id]=si.[object_id] and ius.index_id=si.index_id 
	join sys.sysindexes as ssi on si.object_id=ssi.id and si.name=ssi.name 
	join sys.tables as st on st.[object_id]=si.[object_id] 
	join sys.schemas as ss on ss.[schema_id]=st.[schema_id] 
where 
ius.database_id=db_id() 
and objectproperty(ius.[object_id], 'IsMsShipped') = 0;


exec sp_executesql @query;


select 
	SchemaName=ss.[name], 
	TableName=st.[name], 
	IndexName=isnull(si.[name], ''), 
	IndexType=si.[type_desc], 
	user_updates=isnull(ius.[user_updates], 0), 
	user_seeks=isnull(ius.[user_seeks], 0), 
	user_scans=isnull(ius.[user_scans], 0), 
	user_lookups=isnull(ius.[user_lookups], 0), 
	ssi.[rowcnt], 
	ssi.[rowmodctr], 
	si.[fill_factor]
into #IndexStatsPost 
from sys.dm_db_index_usage_stats as ius 
	right join sys.indexes as si on ius.[object_id]=si.[object_id] and ius.index_id=si.index_id 
	join sys.sysindexes as ssi on si.object_id=ssi.id and si.name=ssi.name 
	join sys.tables as st on st.[object_id]=si.[object_id] 
	join sys.schemas as ss on ss.[schema_id]=st.[schema_id] 
where ius.database_id=DB_ID() and OBJECTPROPERTY(ius.[object_id], 'IsMsShipped') = 0;

select 
	db_name() as DatabaseName, 
	po.[SchemaName], 
	po.[TableName], 
	po.[IndexName], 
	po.[IndexType], 
	po.user_updates-isnull(pr.user_updates, 0) as [User Updates], 
	po.user_seeks-isnull(pr.user_seeks, 0) as [User Seeks], 
	po.user_scans-isnull(pr.user_scans, 0) as [User Scans], 
	po.user_lookups-isnull(pr.user_lookups, 0) as [User Lookups], 
	po.rowcnt-pr.rowcnt as [Rows Inserted], 
	po.rowmodctr-pr.rowmodctr as [Updates I/U/D], 
	po.fill_factor 
from #IndexStatsPost as po 
	left join #IndexStatsPre as pr 
		on pr.SchemaName=po.SchemaName 
			and pr.TableName=po.TableName 
			and pr.IndexName=po.IndexName 
			and pr.IndexType=po.IndexType 
where 
	isnull(pr.user_updates, 0)!=po.user_updates 
	or isnull(pr.user_seeks, 0)!=po.user_seeks 
	or isnull(pr.user_scans, 0)!=po.user_scans 
	or isnull(pr.user_lookups, 0)!=po.user_lookups 
order by po.[SchemaName], po.[TableName], po.[IndexName];

drop table #IndexStatsPre;
drop table #IndexStatsPost;