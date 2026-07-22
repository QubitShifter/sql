use [msdb];
go

declare
	@JobName sysname = N'DBA Monitoring - Collect Database File Sizes',
	@ScheduleName sysname = N'DBA Monitoring - Collect Database File Sizes - Every 30 Minutes';

if not exists
(
	select 1
	from [msdb].[dbo].[sysjobs]
	where [name] = @JobName
)
begin
	exec [msdb].[dbo].[sp_add_job]
		@job_name = @JobName,
		@enabled = 1,
		@description = N'Collects database file size, used space, free space, and growth settings into DBA_Monitoring.',
		@category_name = N'Database Maintenance';
end;
go

declare
	@JobName sysname = N'DBA Monitoring - Collect Database File Sizes';

if not exists
(
	select 1
	from [msdb].[dbo].[sysjobsteps] s
	inner join [msdb].[dbo].[sysjobs] j
		on s.[job_id] = j.[job_id]
	where
		j.[name] = @JobName
		and s.[step_name] = N'Collect Database File Sizes'
)
begin
	exec [msdb].[dbo].[sp_add_jobstep]
		@job_name = @JobName,
		@step_name = N'Collect Database File Sizes',
		@subsystem = N'TSQL',
		@database_name = N'DBA_Monitoring',
		@command = N'
exec [dbo].[CollectDatabaseFileSizes];
',
		@retry_attempts = 1,
		@retry_interval = 5;
end;
go

declare
	@ScheduleName sysname = N'DBA Monitoring - Collect Database File Sizes - Every 30 Minutes';

if not exists
(
	select 1
	from [msdb].[dbo].[sysschedules]
	where [name] = @ScheduleName
)
begin
	exec [msdb].[dbo].[sp_add_schedule]
		@schedule_name = @ScheduleName,
		@enabled = 1,
		@freq_type = 4,
		@freq_interval = 1,
		@freq_subday_type = 4,
		@freq_subday_interval = 30,
		@active_start_time = 000000;
end;
go

declare
	@JobName sysname = N'DBA Monitoring - Collect Database File Sizes',
	@ScheduleName sysname = N'DBA Monitoring - Collect Database File Sizes - Every 30 Minutes';

if not exists
(
	select 1
	from [msdb].[dbo].[sysjobschedules] js
	inner join [msdb].[dbo].[sysjobs] j
		on js.[job_id] = j.[job_id]
	inner join [msdb].[dbo].[sysschedules] s
		on js.[schedule_id] = s.[schedule_id]
	where
		j.[name] = @JobName
		and s.[name] = @ScheduleName
)
begin
	exec [msdb].[dbo].[sp_attach_schedule]
		@job_name = @JobName,
		@schedule_name = @ScheduleName;
end;
go

declare
	@JobName sysname = N'DBA Monitoring - Collect Database File Sizes';

if not exists
(
	select 1
	from [msdb].[dbo].[sysjobservers] js
	inner join [msdb].[dbo].[sysjobs] j
		on js.[job_id] = j.[job_id]
	where
		j.[name] = @JobName
)
begin
	exec [msdb].[dbo].[sp_add_jobserver]
		@job_name = @JobName,
		@server_name = N'(local)';
end;
go