create procedure [dbo].[CleanupMonitoringHistory] (
	@BackupStatusRetentionDays int = 90,
	@AgentJobFailureRetentionDays int = 180,
	@OlaCommandLogRetentionDays int = 180,
	@DatabaseSizeRetentionDays int = 365,
	@WaitStatsSnapshotRetentionDays int = 30,

	@MonitorWaitStatsRetentionDays int = 30,
	@MonitorProcStatsRetentionDays int = 30,
	@MonitorFileStatsRetentionDays int = 90,
	@MonitorTableStatsRetentionDays int = 90,
	@MonitorTempDBStatsRetentionDays int = 30,

	@QueryStoreExpensiveQueryRetentionDays int = 30,

	@MonitoringRunRetentionDays int = 365,
	@BatchSize int = 10000
)
as
begin
	set nocount on
	set xact_abort on

	declare @MonitoringRunID bigint
	declare @DeletedRows int
	declare @TotalDeletedRows int = 0

	insert into [dbo].[MonitoringRun] (
		[RunType]
	)
	values (
		N'CleanupMonitoringHistory'
	)

	set @MonitoringRunID = scope_identity()

	begin try

		/* Original DBA_Monitoring history tables */

		while 1 = 1
		begin
			delete top (@BatchSize)
			from [dbo].[BackupStatusHistory]
			where [CaptureTime] < dateadd(day, -@BackupStatusRetentionDays, sysdatetime())

			set @DeletedRows = @@rowcount
			set @TotalDeletedRows += @DeletedRows

			if @DeletedRows = 0
				break
		end

		while 1 = 1
		begin
			delete top (@BatchSize)
			from [dbo].[AgentJobFailureHistory]
			where [CaptureTime] < dateadd(day, -@AgentJobFailureRetentionDays, sysdatetime())

			set @DeletedRows = @@rowcount
			set @TotalDeletedRows += @DeletedRows

			if @DeletedRows = 0
				break
		end

		while 1 = 1
		begin
			delete top (@BatchSize)
			from [dbo].[OlaCommandLogHistory]
			where [CaptureTime] < dateadd(day, -@OlaCommandLogRetentionDays, sysdatetime())

			set @DeletedRows = @@rowcount
			set @TotalDeletedRows += @DeletedRows

			if @DeletedRows = 0
				break
		end

		while 1 = 1
		begin
			delete top (@BatchSize)
			from [dbo].[DatabaseSizeHistory]
			where [CaptureTime] < dateadd(day, -@DatabaseSizeRetentionDays, sysdatetime())

			set @DeletedRows = @@rowcount
			set @TotalDeletedRows += @DeletedRows

			if @DeletedRows = 0
				break
		end

		while 1 = 1
		begin
			delete top (@BatchSize)
			from [dbo].[WaitStatsSnapshot]
			where [Timestamp] < dateadd(day, -@WaitStatsSnapshotRetentionDays, sysdatetime())

			set @DeletedRows = @@rowcount
			set @TotalDeletedRows += @DeletedRows

			if @DeletedRows = 0
				break
		end


		/* Query Store expensive query history */

		while 1 = 1
		begin
			delete top (@BatchSize)
			from [dbo].[QueryStoreExpensiveQueryHistory]
			where [CollectionTime] < dateadd(day, -@QueryStoreExpensiveQueryRetentionDays, sysdatetime())

			set @DeletedRows = @@rowcount
			set @TotalDeletedRows += @DeletedRows

			if @DeletedRows = 0
				break
		end


		/* Imported Monitor snapshot detail tables */

		while 1 = 1
		begin
			delete top (@BatchSize) ws
			from [dbo].[WaitStats] as ws
			inner join [dbo].[CounterSnapshots] as cs
				on cs.[counter_snapshot_id] = ws.[counter_snapshot_id]
			where cs.[counter_snapshot_type_id] = 1
			  and cs.[datestamp] < dateadd(day, -@MonitorWaitStatsRetentionDays, sysdatetime())

			set @DeletedRows = @@rowcount
			set @TotalDeletedRows += @DeletedRows

			if @DeletedRows = 0
				break
		end

		while 1 = 1
		begin
			delete top (@BatchSize) ps
			from [dbo].[ProcStats] as ps
			inner join [dbo].[CounterSnapshots] as cs
				on cs.[counter_snapshot_id] = ps.[counter_snapshot_id]
			where cs.[counter_snapshot_type_id] = 2
			  and cs.[datestamp] < dateadd(day, -@MonitorProcStatsRetentionDays, sysdatetime())

			set @DeletedRows = @@rowcount
			set @TotalDeletedRows += @DeletedRows

			if @DeletedRows = 0
				break
		end

		while 1 = 1
		begin
			delete top (@BatchSize) fs
			from [dbo].[FileStats] as fs
			inner join [dbo].[CounterSnapshots] as cs
				on cs.[counter_snapshot_id] = fs.[counter_snapshot_id]
			where cs.[counter_snapshot_type_id] = 3
			  and cs.[datestamp] < dateadd(day, -@MonitorFileStatsRetentionDays, sysdatetime())

			set @DeletedRows = @@rowcount
			set @TotalDeletedRows += @DeletedRows

			if @DeletedRows = 0
				break
		end

		while 1 = 1
		begin
			delete top (@BatchSize) ts
			from [dbo].[TableStats] as ts
			inner join [dbo].[CounterSnapshots] as cs
				on cs.[counter_snapshot_id] = ts.[counter_snapshot_id]
			where cs.[counter_snapshot_type_id] = 4
			  and cs.[datestamp] < dateadd(day, -@MonitorTableStatsRetentionDays, sysdatetime())

			set @DeletedRows = @@rowcount
			set @TotalDeletedRows += @DeletedRows

			if @DeletedRows = 0
				break
		end

		while 1 = 1
		begin
			delete top (@BatchSize) tds
			from [dbo].[TempDBStats] as tds
			inner join [dbo].[CounterSnapshots] as cs
				on cs.[counter_snapshot_id] = tds.[counter_snapshot_id]
			where cs.[counter_snapshot_type_id] = 5
			  and cs.[datestamp] < dateadd(day, -@MonitorTempDBStatsRetentionDays, sysdatetime())

			set @DeletedRows = @@rowcount
			set @TotalDeletedRows += @DeletedRows

			if @DeletedRows = 0
				break
		end


		/* Delete old/orphan Monitor snapshot headers */

		while 1 = 1
		begin
			delete top (@BatchSize) cs
			from [dbo].[CounterSnapshots] as cs
			where (
					(cs.[counter_snapshot_type_id] = 1 and cs.[datestamp] < dateadd(day, -@MonitorWaitStatsRetentionDays, sysdatetime()))
					or (cs.[counter_snapshot_type_id] = 2 and cs.[datestamp] < dateadd(day, -@MonitorProcStatsRetentionDays, sysdatetime()))
					or (cs.[counter_snapshot_type_id] = 3 and cs.[datestamp] < dateadd(day, -@MonitorFileStatsRetentionDays, sysdatetime()))
					or (cs.[counter_snapshot_type_id] = 4 and cs.[datestamp] < dateadd(day, -@MonitorTableStatsRetentionDays, sysdatetime()))
					or (cs.[counter_snapshot_type_id] = 5 and cs.[datestamp] < dateadd(day, -@MonitorTempDBStatsRetentionDays, sysdatetime()))
				)
			  and not exists (
					select 1
					from [dbo].[WaitStats] as ws
					where ws.[counter_snapshot_id] = cs.[counter_snapshot_id]
				)
			  and not exists (
					select 1
					from [dbo].[ProcStats] as ps
					where ps.[counter_snapshot_id] = cs.[counter_snapshot_id]
				)
			  and not exists (
					select 1
					from [dbo].[FileStats] as fs
					where fs.[counter_snapshot_id] = cs.[counter_snapshot_id]
				)
			  and not exists (
					select 1
					from [dbo].[TableStats] as ts
					where ts.[counter_snapshot_id] = cs.[counter_snapshot_id]
				)
			  and not exists (
					select 1
					from [dbo].[TempDBStats] as tds
					where tds.[counter_snapshot_id] = cs.[counter_snapshot_id]
				)

			set @DeletedRows = @@rowcount
			set @TotalDeletedRows += @DeletedRows

			if @DeletedRows = 0
				break
		end


		/* Delete old MonitoringRun rows only when no child history rows remain */

		while 1 = 1
		begin
			delete top (@BatchSize) mr
			from [dbo].[MonitoringRun] as mr
			where mr.[StartTime] < dateadd(day, -@MonitoringRunRetentionDays, sysdatetime())
			  and mr.[MonitoringRunID] <> @MonitoringRunID
			  and not exists (
					select 1
					from [dbo].[BackupStatusHistory] as h
					where h.[MonitoringRunID] = mr.[MonitoringRunID]
				)
			  and not exists (
					select 1
					from [dbo].[AgentJobFailureHistory] as h
					where h.[MonitoringRunID] = mr.[MonitoringRunID]
				)
			  and not exists (
					select 1
					from [dbo].[OlaCommandLogHistory] as h
					where h.[MonitoringRunID] = mr.[MonitoringRunID]
				)
			  and not exists (
					select 1
					from [dbo].[DatabaseSizeHistory] as h
					where h.[MonitoringRunID] = mr.[MonitoringRunID]
				)

			set @DeletedRows = @@rowcount
			set @TotalDeletedRows += @DeletedRows

			if @DeletedRows = 0
				break
		end


		update [dbo].[MonitoringRun]
		set
			[EndTime] = sysdatetime(),
			[Status] = N'Succeeded',
			[ErrorMessage] = null
		where [MonitoringRunID] = @MonitoringRunID

		select
			[Status] = N'Succeeded',
			[TotalDeletedRows] = @TotalDeletedRows

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