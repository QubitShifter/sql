use [msdb]
go

declare @JobName sysname = N'DBA Monitoring - Get Agent Job Failures'
declare @ScheduleName sysname = N'DBA Monitoring - Get Agent Job Failures - Every 30 Minutes'

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
	@job_name = N'DBA Monitoring - Get Agent Job Failures',
	@enabled = 1,
	@description = N'Collects failed SQL Agent job history into DBA_Monitoring.',
	@category_name = N'Database Maintenance',
	@owner_login_name = N'sa'
go

exec [dbo].[sp_add_jobstep]
	@job_name = N'DBA Monitoring - Get Agent Job Failures',
	@step_name = N'Run GetAgentJobFailures',
	@subsystem = N'TSQL',
	@database_name = N'DBA_Monitoring',
	@command = N'exec [dbo].[GetAgentJobFailures] @LookbackHours = 24',
	@on_success_action = 1,
	@on_fail_action = 2
go

exec [dbo].[sp_add_schedule]
	@schedule_name = N'DBA Monitoring - Get Agent Job Failures - Every 30 Minutes',
	@enabled = 1,
	@freq_type = 4,
	@freq_interval = 1,
	@freq_subday_type = 4,
	@freq_subday_interval = 30,
	@active_start_time = 000000
go

exec [dbo].[sp_attach_schedule]
	@job_name = N'DBA Monitoring - Get Agent Job Failures',
	@schedule_name = N'DBA Monitoring - Get Agent Job Failures - Every 30 Minutes'
go

exec [dbo].[sp_add_jobserver]
	@job_name = N'DBA Monitoring - Get Agent Job Failures'
go