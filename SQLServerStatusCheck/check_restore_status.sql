use [master];
go
set ansi_nulls on;
go
set quoted_identifier on;
go
select
	[servername] = @@servername,
	[command],
	[s].text,
	[start_time],
	[percent_complete],
	[running_time] = 
	cast( ( ( datediff([s], [start_time], getdate()) ) / 3600 ) as varchar)+
	' hour(s), '+
	cast( ( datediff([s], [start_time], getdate()) % 3600 ) / 60 as varchar)+
	' min, '+
	cast( ( datediff([s], [start_time], getdate()) % 60 ) as varchar)+
	' sec',
	[est_completion_time]=
	cast( ( [estimated_completion_time] / 3600000 ) as varchar)+
	' hour(s), '+
	cast( ( [estimated_completion_time] % 3600000 ) / 60000 as varchar)+
	' min, '+
	cast( ( [estimated_completion_time] % 60000 ) / 1000 as varchar)+
	' sec',
	[est_time_to_go]= dateadd([second], [estimated_completion_time] / 1000, getdate())
from sys.dm_exec_requests as r
	cross apply sys.dm_exec_sql_text ( r.sql_handle ) as s
where [r].[command] in ('RESTORE DATABASE', 'BACKUP DATABASE', 'RESTORE LOG', 'BACKUP LOG');