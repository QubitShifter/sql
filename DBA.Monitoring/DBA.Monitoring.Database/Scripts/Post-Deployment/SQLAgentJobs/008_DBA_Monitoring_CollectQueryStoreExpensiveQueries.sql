use [msdb];
go

declare
    @JobName sysname = N'DBA Monitoring - Collect Query Store Expensive Queries',
    @ScheduleName sysname = N'DBA Monitoring - Collect Query Store Expensive Queries - Every 30 Minutes';

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
        @description = N'Collects top Query Store expensive queries from all Query Store-enabled user databases into DBA_Monitoring.',
        @category_name = N'Database Maintenance';
end;
go

declare
    @JobName sysname = N'DBA Monitoring - Collect Query Store Expensive Queries';

if not exists
(
    select 1
    from [msdb].[dbo].[sysjobsteps] s
    inner join [msdb].[dbo].[sysjobs] j
        on s.[job_id] = j.[job_id]
    where
        j.[name] = @JobName
        and s.[step_name] = N'Collect Query Store Expensive Queries'
)
begin
    exec [msdb].[dbo].[sp_add_jobstep]
        @job_name = @JobName,
        @step_name = N'Collect Query Store Expensive Queries',
        @subsystem = N'TSQL',
        @database_name = N'DBA_Monitoring',
        @command = N'
exec [dbo].[CollectQueryStoreExpensiveQueries]
    @TopPerDatabase = 20,
    @OrderBy = N''cpu'';
',
        @retry_attempts = 1,
        @retry_interval = 5;
end;
go

declare
    @ScheduleName sysname = N'DBA Monitoring - Collect Query Store Expensive Queries - Every 30 Minutes';

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
        @freq_type = 4,              -- daily
        @freq_interval = 1,
        @freq_subday_type = 4,       -- minutes
        @freq_subday_interval = 30,
        @active_start_time = 000000;
end;
go

declare
    @JobName sysname = N'DBA Monitoring - Collect Query Store Expensive Queries',
    @ScheduleName sysname = N'DBA Monitoring - Collect Query Store Expensive Queries - Every 30 Minutes';

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
    @JobName sysname = N'DBA Monitoring - Collect Query Store Expensive Queries';

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