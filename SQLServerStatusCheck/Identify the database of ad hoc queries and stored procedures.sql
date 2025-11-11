set transaction isolation level read uncommitted;

select top 20
	[st].text as [SQL],
	[cp].[cacheobjtype],
	[cp].[objtype],
	coalesce(db_name([st].[dbid]), db_name(cast([pa].value as int))+'*', 'Resource') as [DatabaseName],
	[cp].[usecounts] as [Plan usage],
	[qp].[query_plan]
from sys.dm_exec_cached_plans as cp
	cross apply sys.dm_exec_sql_text ( cp.plan_handle ) as st
	cross apply sys.dm_exec_query_plan ( cp.plan_handle ) as qp
	outer apply sys.dm_exec_plan_attributes ( cp.plan_handle ) as pa
where [pa].[attribute] = 'dbid'
order by [cp].[usecounts] desc;