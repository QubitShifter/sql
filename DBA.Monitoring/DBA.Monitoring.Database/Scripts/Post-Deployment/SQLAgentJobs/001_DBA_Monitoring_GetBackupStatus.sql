use [msdb]
go

declare @JobName sysname = N'DBA Monitoring - Get Backup Status'
declare @ScheduleName sysname = N'DBA Monitoring - Get Backup Status - Every 1 Hour'

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
	@job_name = N'DBA Monitoring - Get Backup Status',
	@enabled = 1,
	@description = N'Collects backup status into DBA_Monitoring.',
	@category_name = N'Database Maintenance',
	@owner_login_name = N'sa'
go

exec [dbo].[sp_add_jobstep]
	@job_name = N'DBA Monitoring - Get Backup Status',
	@step_name = N'Run GetBackupStatus',
	@subsystem = N'TSQL',
	@database_name = N'DBA_Monitoring',
	@command = N'exec [dbo].[GetBackupStatus]',
	@on_success_action = 1,
	@on_fail_action = 2
go

exec [dbo].[sp_add_schedule]
	@schedule_name = N'DBA Monitoring - Get Backup Status - Every 1 Hour',
	@enabled = 1,
	@freq_type = 4,
	@freq_interval = 1,
	@freq_subday_type = 8,
	@freq_subday_interval = 1,
	@active_start_time = 000000
go

exec [dbo].[sp_attach_schedule]
	@job_name = N'DBA Monitoring - Get Backup Status',
	@schedule_name = N'DBA Monitoring - Get Backup Status - Every 1 Hour'
go

exec [dbo].[sp_add_jobserver]
	@job_name = N'DBA Monitoring - Get Backup Status'
go