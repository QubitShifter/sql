use [msdb]
go

declare @JobName sysname = N'DBA Monitoring - Cleanup History'
declare @ScheduleName sysname = N'DBA Monitoring - Cleanup History - Daily 02:00'

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
	@job_name = N'DBA Monitoring - Cleanup History',
	@enabled = 1,
	@description = N'Cleans old history rows from DBA_Monitoring tables according to retention settings.',
	@category_name = N'Database Maintenance',
	@owner_login_name = N'sa'
go

exec [dbo].[sp_add_jobstep]
	@job_name = N'DBA Monitoring - Cleanup History',
	@step_name = N'Run CleanupMonitoringHistory',
	@subsystem = N'TSQL',
	@database_name = N'$(DatabaseName)',
	@command = N'
exec [dbo].[CleanupMonitoringHistory]
	@BackupStatusRetentionDays = 90,
	@AgentJobFailureRetentionDays = 180,
	@OlaCommandLogRetentionDays = 180,
	@DatabaseSizeRetentionDays = 365,
	@WaitStatsSnapshotRetentionDays = 30,
	@MonitorWaitStatsRetentionDays = 30,
	@MonitorProcStatsRetentionDays = 30,
	@MonitorFileStatsRetentionDays = 90,
	@MonitorTableStatsRetentionDays = 90,
	@MonitorTempDBStatsRetentionDays = 30,
	@MonitoringRunRetentionDays = 365,
	@BatchSize = 10000
',
	@on_success_action = 1,
	@on_fail_action = 2
go

exec [dbo].[sp_add_schedule]
	@schedule_name = N'DBA Monitoring - Cleanup History - Daily 02:00',
	@enabled = 1,
	@freq_type = 4,
	@freq_interval = 1,
	@freq_subday_type = 1,
	@freq_subday_interval = 0,
	@active_start_time = 020000
go

exec [dbo].[sp_attach_schedule]
	@job_name = N'DBA Monitoring - Cleanup History',
	@schedule_name = N'DBA Monitoring - Cleanup History - Daily 02:00'
go

exec [dbo].[sp_add_jobserver]
	@job_name = N'DBA Monitoring - Cleanup History'
go