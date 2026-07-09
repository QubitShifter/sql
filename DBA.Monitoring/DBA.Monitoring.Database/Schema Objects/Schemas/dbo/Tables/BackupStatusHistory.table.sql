create table [dbo].[BackupStatusHistory] (
	[BackupStatusHistoryID]		bigint identity(1,1)	not null,
	[MonitoringRunID]			bigint					not null,
	[CaptureTime]				datetime2(0)			not null constraint [DF_BackupStatusHistory_CaptureTime] default (sysdatetime()),
	[ServerName]				sysname					not null constraint [DF_BackupStatusHistory_ServerName] default (@@servername),

	[DatabaseName]				sysname					not null,
	[RecoveryModel]				nvarchar(60)			null,
	[DatabaseState]				nvarchar(60)			null,

	[LastFullBackupTime]		datetime				null,
	[LastDiffBackupTime]		datetime				null,
	[LastLogBackupTime]			datetime				null,

	[HoursSinceFullBackup]		decimal(10,2)			null,
	[HoursSinceDiffBackup]		decimal(10,2)			null,
	[HoursSinceLogBackup]		decimal(10,2)			null,

	[FullBackupStatus]			nvarchar(30)			null,
	[DiffBackupStatus]			nvarchar(30)			null,
	[LogBackupStatus]			nvarchar(30)			null

constraint [PK_BackupStatusHistory_BackupStatusHistoryID] primary key clustered ( [BackupStatusHistoryID] ),
constraint [FK_BackupStatusHistory_MonitoringRun_MonitoringRunID] foreign key ( [MonitoringRunID] )
	references [dbo].[MonitoringRun] ( [MonitoringRunID] )
);
go

create index [IX_BackupStatusHistory_CaptureTime_DatabaseName]
	on [dbo].[BackupStatusHistory] ([CaptureTime], [DatabaseName])
go