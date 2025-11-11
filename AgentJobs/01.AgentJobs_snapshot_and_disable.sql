use [msdb]

/* Save current SQL Agent Jobs state*/
IF NOT EXISTS ( 
	select * 
	from sys.dm_db_index_usage_stats
	where database_id = DB_ID('msdb')
		and OBJECT_ID=OBJECT_ID('TempAgentJobs') 
		and cast(last_user_update as date) = cast(getdate() as date)
)

BEGIN
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='TempAgentJobs' AND xtype='U')
	BEGIN
	CREATE TABLE TempAgentJobs	(
    [job_id] uniqueidentifier, 
    [name] sysname, 
    [enabled] tinyint
	)
	END

		merge into [msdb].[dbo].[TempAgentJobs] as TRG
		using [msdb].[dbo].[SysJobs] as SRC on TRG.[name] = SRC.[name]
		when matched then
			update
			set TRG.[enabled] = SRC.[enabled]
		when not matched by target then 
			Insert ([job_id], [name], [enabled])
			Values (SRC.[job_id], 
					SRC.[name], 
					SRC.[enabled])
		;
-----------------------------------------------------
/* Disable all jobs */

DECLARE @name  sysname
DECLARE DisableAgentJobs CURSOR for
	select	[name]
	from [dbo].[TempAgentJobs]

OPEN DisableAgentJobs
while ( 1 = 1 ) begin
	fetch next from DisableAgentJobs into @name
	IF (@@fetch_status = 0)
		BEGIN
				IF (
						select [name]
						from msdb.dbo.sysjobs_view job  
						inner join msdb.dbo.sysjobactivity activity on job.job_id = activity.job_id 
						where  
            activity.run_Requested_date is not null  
						and activity.stop_execution_date is null  
						and job.name = @JOB_NAME 
						) 
					BEGIN      
					PRINT N'There are no running sql Agent Jobs'; 
					PRINT @JOB_NAME + '' + 'is going to be disabled'; 
					EXEC msdb..sp_update_job @job_name = @name, @enabled = 0
					print 'Disable '+@name
		ELSE 
		print N'There are runnign jobs at that moment';
		print N'There will be delay'
		
	END
	ELSE BEGIN 
	BREAK
	END
	END

CLOSE DisableAgentJobs
DEALLOCATE DisableAgentJobs
END