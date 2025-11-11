set transaction isolation level read uncommitted;
select
	[er].[session_Id] as [Spid],
	[sp].[ecid],
	db_name([sp].[dbid]) as [Database],
	[sp].[nt_username],
	[er].[status],
	[er].[wait_type],
	substring([qt].text, ([er].[statement_start_offset]/2)+1, ((case
																																when [er].[statement_end_offset] = -1
																																then len(convert(nvarchar(max), [qt].text))*2
																																else [er].[statement_end_offset]
																															end-[er].[statement_start_offset])/2)+1) as [Individual Query],
	[qt].text as [Parent Query],
	[sp].[program_name],
	[sp].[Hostname],
	[sp].[nt_domain],
	[er].[start_time]
from sys.dm_exec_requests as er
	inner join sys.sysprocesses as sp on er.session_id = sp.spid
	cross apply sys.dm_exec_sql_text ( er.sql_handle ) as qt
where [session_Id] > 50
			and [session_Id] not in ( @@SPID )
order by
	[session_Id],
	[ecid];