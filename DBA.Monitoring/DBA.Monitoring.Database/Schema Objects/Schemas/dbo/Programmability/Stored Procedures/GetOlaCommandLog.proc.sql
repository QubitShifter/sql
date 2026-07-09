create procedure [dbo].[GetOlaCommandLog]
as
begin
	set nocount on
	set xact_abort on

	declare @MonitoringRunID bigint
	declare @Sql nvarchar(max)
	declare @CommandLogExists bit

	insert into [dbo].[MonitoringRun] (
		[RunType]
	)
	values (
		N'OlaCommandLog'
	)

	set @MonitoringRunID = scope_identity()

	begin try

		set @CommandLogExists = 0

		set @Sql = N'
			if exists (
				select 1
				from [master].[sys].[tables] as t
				inner join [master].[sys].[schemas] as s
					on s.[schema_id] = t.[schema_id]
				where s.[name] = N''dbo''
				  and t.[name] = N''CommandLog''
			)
			begin
				set @CommandLogExists = 1
			end
		'

		exec [sys].[sp_executesql]
			@Sql,
			N'@CommandLogExists bit output',
			@CommandLogExists = @CommandLogExists output

		if @CommandLogExists = 0
		begin
			;throw 50001, 'master.dbo.CommandLog does not exist. Ola Hallengren Maintenance Solution may not be installed.', 1
		end

		set @Sql = N'
			insert into [dbo].[OlaCommandLogHistory] (
				[MonitoringRunID],
				[SourceCommandLogID],
				[DatabaseName],
				[ObjectName],
				[CommandType],
				[StartTime],
				[EndTime],
				[ErrorNumber],
				[ErrorMessage],
				[Command]
			)
			select
				@MonitoringRunID,
				cl.[ID],
				cl.[DatabaseName],
				cl.[ObjectName],
				cl.[CommandType],
				cl.[StartTime],
				cl.[EndTime],
				cl.[ErrorNumber],
				cl.[ErrorMessage],
				cl.[Command]
			from [master].[dbo].[CommandLog] as cl
			where not exists (
				select 1
				from [dbo].[OlaCommandLogHistory] as h
				where h.[SourceCommandLogID] = cl.[ID]
			)
		'

		exec [sys].[sp_executesql]
			@Sql,
			N'@MonitoringRunID bigint',
			@MonitoringRunID = @MonitoringRunID

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