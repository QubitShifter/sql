create table [dbo].[DatabaseFileAutogrowHistory]
(
	[DatabaseFileAutogrowHistoryID] bigint identity(1,1)	not null,
	[MonitoringRunID]				bigint					null,
	[CaptureTime]					datetime2(3)			not null constraint [DF_DatabaseFileAutogrowHistory_CaptureTime] default (sysdatetime()),
	[ServerName]					sysname					not null,
	[DatabaseName]					sysname					null,
	[LogicalFileName]				sysname					null,
	[FileType]						nvarchar(60)			null,
	[GrowthTime]					datetime2(3)			not null,
	[DurationMs]					bigint					null,
	[GrowthSizeMB]					decimal(18, 2)			null,
	[PhysicalFileName]				nvarchar(260)			null,
	[EventSource]					nvarchar(60)			not null,
	[EventClass]					int						null,
	[EventName]						nvarchar(200)			null,

	constraint [PK_DatabaseFileAutogrowHistory] primary key clustered ([DatabaseFileAutogrowHistoryID] asc),
	constraint [FK_DatabaseFileAutogrowHistory_MonitoringRun] foreign key ([MonitoringRunID]) references [dbo].[MonitoringRun] ([MonitoringRunID])
);
go

create unique index [UX_DatabaseFileAutogrowHistory_Event]
on [dbo].[DatabaseFileAutogrowHistory]
(
	[ServerName],
	[DatabaseName],
	[LogicalFileName],
	[GrowthTime],
	[EventSource],
	[EventClass]
)
where
	[DatabaseName] is not null
	and [LogicalFileName] is not null
	and [EventClass] is not null;
go

create index [IX_DatabaseFileAutogrowHistory_GrowthTime]
on [dbo].[DatabaseFileAutogrowHistory] ([GrowthTime] desc);
go

create index [IX_DatabaseFileAutogrowHistory_DatabaseName_GrowthTime]
on [dbo].[DatabaseFileAutogrowHistory] ([DatabaseName], [GrowthTime] desc)
include
(
	[LogicalFileName],
	[FileType],
	[DurationMs],
	[GrowthSizeMB],
	[PhysicalFileName],
	[EventSource],
	[EventName]
);
go