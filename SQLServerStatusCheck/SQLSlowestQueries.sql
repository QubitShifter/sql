set transaction isolation level read uncommitted;
select top 20
	cast([qs].[total_elapsed_time] / 1000000.0 as decimal(28, 2)) as [Total Elapsed Duration (s)],
	[qs].[execution_count],
	substring([qt].text, ([qs].[statement_start_offset]/2)+1, ((
		case
			when [qs].[statement_end_offset] = -1
			then len(convert(nvarchar(max), [qt].text))*2
			else [qs].[statement_end_offset]
		end-[qs].[statement_start_offset])/2)+1) as [Individual Query],
	[qt].text as [Parent Query],
	db_name([qt].[dbid]) as [DatabaseName],
	[qp].[query_plan]
from sys.dm_exec_query_stats as qs
	cross apply sys.dm_exec_sql_text ( qs.sql_handle ) as qt
	cross apply sys.dm_exec_query_plan ( qs.plan_handle ) as qp
order by [total_elapsed_time] desc;