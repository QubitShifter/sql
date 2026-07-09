use [msdb]
go

declare @JobName sysname = N'DBA Monitoring - Collect Basic Stats'
declare @ScheduleName sysname = N'DBA Monitoring - Collect Basic Stats - Every 30 Minutes'

if exists (
	select 1
	from [dbo].[sysjobs]
	where [name] = @JobName
)
begin
	exec [dbo].[sp_delete_job]
		@job_name = @JobName,
		@delete_unused_schedule = 1
end
go

use [msdb]
go

exec [dbo].[sp_add_job]
	@job_name = N'DBA Monitoring - Collect Basic Stats',
	@enabled = 1,
	@description = N'Collects Monitor core snapshot data: wait stats, procedure stats, file stats, and table stats.',
	@category_name = N'Database Maintenance',
	@owner_login_name = N'sa'
go

exec [dbo].[sp_add_jobstep]
	@job_name = N'DBA Monitoring - Collect Basic Stats',
	@step_name = N'Run CollectBasicStats',
	@subsystem = N'TSQL',
	@database_name = N'$(DatabaseName)',
	@command = N'exec [dbo].[CollectBasicStats]',
	@on_success_action = 1,
	@on_fail_action = 2
go

exec [dbo].[sp_add_schedule]
	@schedule_name = N'DBA Monitoring - Collect Basic Stats - Every 30 Minutes',
	@enabled = 1,
	@freq_type = 4,
	@freq_interval = 1,
	@freq_subday_type = 4,
	@freq_subday_interval = 30,
	@active_start_time = 000000
go

exec [dbo].[sp_attach_schedule]
	@job_name = N'DBA Monitoring - Collect Basic Stats',
	@schedule_name = N'DBA Monitoring - Collect Basic Stats - Every 30 Minutes'
go

exec [dbo].[sp_add_jobserver]
	@job_name = N'DBA Monitoring - Collect Basic Stats'
go