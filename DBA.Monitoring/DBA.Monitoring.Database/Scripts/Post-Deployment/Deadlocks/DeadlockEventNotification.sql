use [master]
go

if exists (
	select 1
	from [sys].[server_event_notifications]
	where [name] = N'DBA_Monitoring_DeadlockEvent'
)
begin
	drop event notification [DBA_Monitoring_DeadlockEvent]
	on server
end
go

use [$(DatabaseName)]
go

if not exists (
	select 1
	from [sys].[databases]
	where [name] = N'$(DatabaseName)'
	  and [is_broker_enabled] = 1
)
begin
	alter database [$(DatabaseName)]
	set enable_broker
	with rollback immediate
end
go

create event notification [DBA_Monitoring_DeadlockEvent]
on server
for deadlock_graph
to service N'DeadlockNotificationService', N'current database'
go