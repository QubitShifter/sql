create procedure [dbo].[GetBackupStatus]
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
		N'BackupStatus'
	)

	set @MonitoringRunID = scope_identity()

	begin try

		set @Sql = N'
			;with [LastBackups] as (
				select
					bs.[database_name],
					max(case when bs.[type] = ''D'' then bs.[backup_finish_date] end) as [LastFullBackupTime],
					max(case when bs.[type] = ''I'' then bs.[backup_finish_date] end) as [LastDiffBackupTime],
					max(case when bs.[type] = ''L'' then bs.[backup_finish_date] end) as [LastLogBackupTime]
				from [msdb].[dbo].[backupset] as bs
				group by
					bs.[database_name]
			)
			insert into [dbo].[BackupStatusHistory] (
				[MonitoringRunID],
				[DatabaseName],
				[RecoveryModel],
				[DatabaseState],
				[LastFullBackupTime],
				[LastDiffBackupTime],
				[LastLogBackupTime],
				[HoursSinceFullBackup],
				[HoursSinceDiffBackup],
				[HoursSinceLogBackup],
				[FullBackupStatus],
				[DiffBackupStatus],
				[LogBackupStatus]
			)
			select
				@MonitoringRunID,
				d.[name] as [DatabaseName],
				d.[recovery_model_desc] as [RecoveryModel],
				d.[state_desc] as [DatabaseState],
				lb.[LastFullBackupTime],
				lb.[LastDiffBackupTime],
				lb.[LastLogBackupTime],

				case
					when lb.[LastFullBackupTime] is null then null
					else datediff(minute, lb.[LastFullBackupTime], getdate()) / 60.0
				end as [HoursSinceFullBackup],

				case
					when lb.[LastDiffBackupTime] is null then null
					else datediff(minute, lb.[LastDiffBackupTime], getdate()) / 60.0
				end as [HoursSinceDiffBackup],

				case
					when lb.[LastLogBackupTime] is null then null
					else datediff(minute, lb.[LastLogBackupTime], getdate()) / 60.0
				end as [HoursSinceLogBackup],

				case
					when d.[name] = ''tempdb'' then ''NotRequired''
					when lb.[LastFullBackupTime] is null then ''Missing''
					when datediff(hour, lb.[LastFullBackupTime], getdate()) > 24 then ''Old''
					else ''OK''
				end as [FullBackupStatus],

				case
					when d.[name] = ''tempdb'' then ''NotRequired''
					when lb.[LastDiffBackupTime] is null then ''Missing''
					when datediff(hour, lb.[LastDiffBackupTime], getdate()) > 24 then ''Old''
					else ''OK''
				end as [DiffBackupStatus],

				case
					when d.[name] = ''tempdb'' then ''NotRequired''
					when d.[recovery_model_desc] = ''SIMPLE'' then ''NotRequired''
					when lb.[LastLogBackupTime] is null then ''Missing''
					when datediff(hour, lb.[LastLogBackupTime], getdate()) > 2 then ''Old''
					else ''OK''
				end as [LogBackupStatus]

			from [sys].[databases] as d
			left join [LastBackups] as lb
				on lb.[database_name] = d.[name]
			where d.[source_database_id] is null
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