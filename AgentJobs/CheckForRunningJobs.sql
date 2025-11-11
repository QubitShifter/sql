set nocount on
declare @sqlcmd        nvarchar(max)
declare  @rowcount		int
declare @counter			int

set @counter = 5
set @sqlcmd = '
		SELECT	' +
			'ja.job_id,	'+
			'j.name AS job_name,	'+
			'ja.start_execution_date,	'+    
			'ja.last_executed_step_id	'+
		'FROM msdb.dbo.sysjobactivity ja	'+
		'LEFT JOIN msdb.dbo.sysjobhistory jh	'+
			'ON ja.job_history_id = jh.instance_id	'+
		'JOIN msdb.dbo.sysjobs j	'+
			'ON ja.job_id = j.job_id	'+
		'WHERE ja.session_id = (SELECT TOP 1 session_id FROM msdb.dbo.syssessions ORDER BY agent_start_date DESC)	'+
		'AND start_execution_date is not null	'+
		'AND stop_execution_date is null;	'

select		@counter
while			@counter > 0
begin 
exec (@sqlcmd) 
set @rowcount = @@rowcount 
if (@rowcount) > 0 begin
print N'There are running SQL Agent Jobs'
waitfor delay '00:00:02';
set @counter = @counter -1
select  @counter
		    if @counter = 0 begin 
							print N'SQL Agent Checked for running jobs passed 5 times'
							print N'There are still running SQL AgentJobs, but they will be disabled'
							select TOP (1) [version_number]
							from [ReportDB].[dbo].[VERSION_NUMBER]
							end
				END
				ELSE
				IF (@rowcount) = 0 BEGIN
PRINT N'There aren''t'' any SQL Agentjobs'
PRINT N'All SQL Jobs will be disabled and Snaphost of current state will be taken'
SELECT TOP (2) [Name]
FROM [ReportDB].dbo.[Feaffiliates]
BREAK
END
END
