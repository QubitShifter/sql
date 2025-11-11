use [msdb]
declare @name  sysname,
		@enable tinyint

DECLARE RestoreAgentJobs CURSOR for
	select	[name], [enabled]
	from [dbo].[TempAgentJobs]

OPEN RestoreAgentJobs
	while ( 1 = 1 ) begin
		fetch next from RestoreAgentJobs into @name, @enable
	IF (@@fetch_status = 0)
		BEGIN
		EXEC msdb..sp_update_job @job_name = @name, @enabled = @enable
		print @name+' ('+str(@enable)+')'
		END
	ELSE BEGIN 
	BREAK
	END
	END

CLOSE RestoreAgentJobs
DEALLOCATE RestoreAgentJobs