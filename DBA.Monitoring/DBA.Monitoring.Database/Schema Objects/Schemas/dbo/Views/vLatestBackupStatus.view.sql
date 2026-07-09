create view [dbo].[vLatestBackupStatus]
as
with [RankedBackupStatus] as (
	select
		bsh.[BackupStatusHistoryID],
		bsh.[ServerName],
		bsh.[CaptureTime],
		bsh.[DatabaseName],
		bsh.[RecoveryModel],
		bsh.[DatabaseState],
		bsh.[LastFullBackupTime],
		bsh.[LastDiffBackupTime],
		bsh.[LastLogBackupTime],
		bsh.[HoursSinceFullBackup],
		bsh.[HoursSinceDiffBackup],
		bsh.[HoursSinceLogBackup],
		bsh.[FullBackupStatus],
		bsh.[DiffBackupStatus],
		bsh.[LogBackupStatus],
		row_number() over (
			partition by bsh.[DatabaseName]
			order by bsh.[CaptureTime] desc, bsh.[BackupStatusHistoryID] desc
		) as [RowNumber]
	from [dbo].[BackupStatusHistory] as bsh
)
select
	[ServerName],
	[CaptureTime],
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
from [RankedBackupStatus]
where [RowNumber] = 1
go