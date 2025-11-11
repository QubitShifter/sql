set transaction isolation level read uncommitted;
select top 20
	round([s].[avg_total_user_cost] * [s].[avg_user_impact] * ([s].[user_seeks] + [s].[user_scans]), 0) as [Total Cost],
	[d].[statement] as [Table Name],
	[equality_columns],
	[inequality_columns],
	[included_columns]
from sys.dm_db_missing_index_groups as g
	join sys.dm_db_missing_index_group_stats as s on s.group_handle = g.index_group_handle
	join sys.dm_db_missing_index_details as d on d.index_handle = g.index_handle
order by [Total Cost] desc;