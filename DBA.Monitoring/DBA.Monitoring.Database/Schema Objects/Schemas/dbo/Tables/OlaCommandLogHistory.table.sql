create table [dbo].[OlaCommandLogHistory] (
	[OlaCommandLogHistoryID]	bigint identity(1,1)	not null,
	[MonitoringRunID]			bigint					not null,
	[CaptureTime]				datetime2(0)			not null constraint [DF_OlaCommandLogHistory_CaptureTime] default (sysdatetime()),
	[ServerName]				sysname					not null constraint [DF_OlaCommandLogHistory_ServerName] default (@@servername),

	[SourceCommandLogID]		int						not null,
	[DatabaseName]				sysname					null,
	[ObjectName]				sysname					null,
	[CommandType]				nvarchar(60)			null,
	[StartTime]					datetime2(7)			null,
	[EndTime]					datetime2(7)			null,
	[ErrorNumber]				int						null,
	[ErrorMessage]				nvarchar(max)			null,
	[Command]					nvarchar(max)			null

	constraint [PK_OlaCommandLogHistory_OlaCommandLogHistoryID] primary key clustered ( [OlaCommandLogHistoryID] ),

	constraint [FK_OlaCommandLogHistory_MonitoringRun_MonitoringRunID] foreign key ( [MonitoringRunID] )
		references [dbo].[MonitoringRun] ( [MonitoringRunID] ),

	constraint [UQ_OlaCommandLogHistory_SourceCommandLogID] unique ( [SourceCommandLogID] )
);
go

create index [IX_OlaCommandLogHistory_StartTime_CommandType_DatabaseName]
	on	[dbo].[OlaCommandLogHistory] ([StartTime], [CommandType], [DatabaseName])
go