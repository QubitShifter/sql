select w.session_id,
       w.wait_duration_ms,
       w.wait_type,
       DB_NAME(exr.database_id) as DatabaseName
from sys.dm_os_waiting_tasks w
	inner join sys.dm_exec_sessions exs on w.session_id = exs.session_id
	inner join sys.dm_exec_requests exr on exr.session_id = w.session_id
option(Recompile);