create procedure [dbo].[GetAgentJobFailures]
	@LookbackHours int = 24
as
begin
	set nocount on
	set xact_abort on

	declare @MonitoringRunID bigint
	declare @Sql nvarchar(max)

	insert into [dbo].[MonitoringRun] (
		[RunType]
	)
	values (
		N'AgentJobFailures'
	)

	set @MonitoringRunID = scope_identity()

	begin try

		set @Sql = N'
			;with [JobHistory] as (
				select
					j.[job_id] as [SourceJobID],
					h.[instance_id] as [SourceInstanceID],
					j.[name] as [JobName],
					h.[step_id] as [StepID],
					h.[step_name] as [StepName],
					[msdb].[dbo].[agent_datetime](h.[run_date], h.[run_time]) as [RunDateTime],
					h.[run_duration],
					h.[run_status],
					h.[message]
				from [msdb].[dbo].[sysjobhistory] as h
				inner join [msdb].[dbo].[sysjobs] as j
					on j.[job_id] = h.[job_id]
				where h.[run_status] = 0
				  and h.[step_id] >= 0
				  and [msdb].[dbo].[agent_datetime](h.[run_date], h.[run_time]) >= dateadd(hour, -@LookbackHours, getdate())
			)
			insert into [dbo].[AgentJobFailureHistory] (
				[MonitoringRunID],
				[SourceJobID],
				[SourceInstanceID],
				[JobName],
				[StepID],
				[StepName],
				[RunDateTime],
				[RunDurationSeconds],
				[RunStatus],
				[RunStatusDescription],
				[Message]
			)
			select
				@MonitoringRunID,
				jh.[SourceJobID],
				jh.[SourceInstanceID],
				jh.[JobName],
				jh.[StepID],
				jh.[StepName],
				jh.[RunDateTime],
				((jh.[run_duration] / 10000) * 3600)
					+ (((jh.[run_duration] % 10000) / 100) * 60)
					+ (jh.[run_duration] % 100) as [RunDurationSeconds],
				jh.[run_status],
				N''Failed'',
				left(jh.[message], 4000)
			from [JobHistory] as jh
			where not exists (
				select 1
				from [dbo].[AgentJobFailureHistory] as h
				where h.[SourceJobID] = jh.[SourceJobID]
				  and h.[SourceInstanceID] = jh.[SourceInstanceID]
			)
		'

		exec [sys].[sp_executesql]
			@Sql,
			N'@MonitoringRunID bigint, @LookbackHours int',
			@MonitoringRunID = @MonitoringRunID,
			@LookbackHours = @LookbackHours

		update [dbo].[MonitoringRun]
		set
			[EndTime] = sysdatetime(),
			[Status] = N'Succeeded'
		where [MonitoringRunID] = @MonitoringRunID

	end try
	begin catch

		update [dbo].[MonitoringRun]
		set
			[EndTime] = sysdatetime(),
			[Status] = N'Failed',
			[ErrorMessage] = error_message()
		where [MonitoringRunID] = @MonitoringRunID

		;throw

	end catch
end
go