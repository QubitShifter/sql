
select
    [w].[session_id],
    [w].[wait_duration_ms],
    [w].[wait_type],
    [w].[blocking_session_id],
    [w].[resource_description],
    [s].[program_name],
    [t].[text],
    [t].[dbid],
    [s].[cpu_time],
    [s].[memory_usage]
from sys.dm_os_waiting_tasks as w
   join sys.dm_exec_sessions as s on w.session_id = s.session_id
   join sys.dm_exec_requests as r on s.session_id = r.session_id
   outer apply sys.dm_exec_sql_text ( r.sql_handle ) as t
where [s].[is_user_process] = 1;