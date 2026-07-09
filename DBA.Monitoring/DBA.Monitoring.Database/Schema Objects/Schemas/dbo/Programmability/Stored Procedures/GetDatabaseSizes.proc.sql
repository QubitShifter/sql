create procedure [dbo].[GetDatabaseSizes]
as
begin
	set nocount on
	set xact_abort on

	declare @MonitoringRunID bigint

	insert into [dbo].[MonitoringRun] (
		[RunType]
	)
	values (
		N'DatabaseSizes'
	)

	set @MonitoringRunID = scope_identity()

	begin try

		insert into [dbo].[DatabaseSizeHistory] (
			[MonitoringRunID],
			[DatabaseName],
			[DataSizeMB],
			[LogSizeMB]
		)
		select
			@MonitoringRunID,
			d.[name] as [DatabaseName],
			cast(sum(case when mf.[type] = 0 then mf.[size] else 0 end) * 8.0 / 1024.0 as decimal(18,2)) as [DataSizeMB],
			cast(sum(case when mf.[type] = 1 then mf.[size] else 0 end) * 8.0 / 1024.0 as decimal(18,2)) as [LogSizeMB]
		from [sys].[databases] as d
		inner join [sys].[master_files] as mf
			on mf.[database_id] = d.[database_id]
		where d.[source_database_id] is null
		group by
			d.[name]

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