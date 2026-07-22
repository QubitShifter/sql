create table [dbo].[DatabaseFileSizeHistory]
(
	[DatabaseFileSizeHistoryID]		bigint identity(1,1)	not null,
	[MonitoringRunID]				bigint					null,
	[CaptureTime]					datetime2(3)			not null constraint [DF_DatabaseFileSizeHistory_CaptureTime] default (sysdatetime()),
	[ServerName]					sysname					not null,
	[DatabaseName]					sysname					not null,
	[LogicalFileName]				sysname					not null,
	[FileID]						int						not null,
	[FileType]						nvarchar(60)			not null,
	[PhysicalFileName]				nvarchar(260)			not null,
	[SizeMB]						decimal(18, 2)			not null,
	[UsedSpaceMB]					decimal(18, 2)			null,
	[FreeSpaceMB]					decimal(18, 2)			null,
	[FreeSpacePercent]				decimal(9, 2)			null,
	[Growth]						bigint					not null,
	[GrowthMB]						decimal(18, 2)			null,
	[IsPercentGrowth]				bit						not null,
	[MaxSize]						bigint					not null,
	[MaxSizeMB]						decimal(18, 2)			null,

	constraint [PK_DatabaseFileSizeHistory]	primary key clustered ([DatabaseFileSizeHistoryID] asc),
	constraint [FK_DatabaseFileSizeHistory_MonitoringRun] foreign key ([MonitoringRunID]) references [dbo].[MonitoringRun] ([MonitoringRunID])
);
go

create index [IX_DatabaseFileSizeHistory_CaptureTime]
on [dbo].[DatabaseFileSizeHistory] ([CaptureTime] desc);
go

create index [IX_DatabaseFileSizeHistory_DatabaseName_CaptureTime]
on [dbo].[DatabaseFileSizeHistory] ([DatabaseName], [CaptureTime] desc)
include
(
	[LogicalFileName],
	[FileType],
	[SizeMB],
	[UsedSpaceMB],
	[FreeSpaceMB],
	[FreeSpacePercent],
	[GrowthMB],
	[IsPercentGrowth],
	[MaxSizeMB]
);
go