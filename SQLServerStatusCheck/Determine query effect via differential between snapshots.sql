set transaction isolation level read uncommitted;

select
	[sql_handle],
	[plan_handle],
	[total_elapsed_time],
	[execution_count],
	[statement_start_offset],
	[statement_end_offset]
into #PreWorkSnapShot
from sys.dm_exec_query_stats;

--exec dbo.IWSR

--select * from dbo.appdate;

select
	[sql_handle],
	[plan_handle],
	[total_elapsed_time],
	[execution_count],
	[statement_start_offset],
	[statement_end_offset]
into #PostWorkSnapShot
from sys.dm_exec_query_stats;

select
	[p2].[total_elapsed_time] - ISNULL([p1].[total_elapsed_time], 0) as [Duration],
	substring([qt].text, [p2].[statement_start_offset]/2+1, ((case
																															when [p2].[statement_end_offset] = -1
																															then len(convert(nvarchar(max), [qt].text))*2
																															else [p2].[statement_end_offset]
																														end-[p2].[statement_start_offset])/2)+1) as [Individual Query],
	[qt].text as [Parent Query],
	db_name([qt].[dbid]) as [DatabaseName]
from #PreWorkSnapShot as p1
	right join #PostWorkSnapShot as p2 on p2.sql_handle = ISNULL(p1.sql_handle, p2.sql_handle)
																							and p2.plan_handle = ISNULL(p1.plan_handle, p2.plan_handle)
																							and p2.statement_start_offset = ISNULL(p1.statement_start_offset, p2.statement_start_offset)
																							and p2.statement_end_offset = ISNULL(p1.statement_end_offset, p2.statement_end_offset)
	cross apply sys.dm_exec_sql_text ( p2.sql_handle ) as qt
where [p2].[execution_count] != ISNULL([p1].[execution_count], 0)
order by [Duration] desc;
drop table #PreWorkSnapShot;
drop table #PostWorkSnapShot;