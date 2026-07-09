create table [dbo].[DatabaseSizeHistory] (
	[DatabaseSizeHistoryID]		bigint identity(1,1)	not null,
	[MonitoringRunID]			bigint					not null,
	[CaptureTime]				datetime2(0)			not null constraint [DF_DatabaseSizeHistory_CaptureTime] default (sysdatetime()),
	[ServerName]				sysname					not null constraint [DF_DatabaseSizeHistory_ServerName] default (@@servername),

	[DatabaseName]				sysname					not null,
	[DataSizeMB]				decimal(18,2)			not null,
	[LogSizeMB]					decimal(18,2)			not null,
	[TotalSizeMB] as ( [DataSizeMB] + [LogSizeMB] ) persisted

constraint [PK_DatabaseSizeHistory_DatabaseSizeHistoryID] primary key clustered ( [DatabaseSizeHistoryID] ),
constraint [FK_DatabaseSizeHistory_MonitoringRun_MonitoringRunID] foreign key ( [MonitoringRunID] )
	references [dbo].[MonitoringRun] ( [MonitoringRunID] )
);
go

create index [IX_DatabaseSizeHistory_CaptureTime_DatabaseName]
	on [dbo].[DatabaseSizeHistory] ([CaptureTime], [DatabaseName])
go