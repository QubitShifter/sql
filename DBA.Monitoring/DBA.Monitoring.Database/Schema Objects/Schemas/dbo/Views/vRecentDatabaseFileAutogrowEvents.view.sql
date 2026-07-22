create view [dbo].[vRecentDatabaseFileAutogrowEvents]
as
select
	[DatabaseFileAutogrowHistoryID],
	[MonitoringRunID],
	[CaptureTime],
	[ServerName],
	[DatabaseName],
	[LogicalFileName],
	[FileType],
	[GrowthTime],
	[DurationMs],
	[GrowthSizeMB],
	[PhysicalFileName],
	[EventSource],
	[EventClass],
	[EventName],

	[FileCategory] =
		case
			when [DatabaseName] in (N'master', N'model', N'msdb', N'tempdb')
				then N'System'
			else N'User'
		end,

	[DurationStatus] =
		case
			when [DurationMs] is null then N'Unknown'
			when [DurationMs] >= 10000 then N'Critical'
			when [DurationMs] >= 3000 then N'Warning'
			else N'OK'
		end,

	[GrowthSizeStatus] =
		case
			when [GrowthSizeMB] is null then N'Unknown'
			when [GrowthSizeMB] >= 1024 then N'Critical'
			when [GrowthSizeMB] >= 512 then N'Warning'
			else N'OK'
		end
from [dbo].[DatabaseFileAutogrowHistory];
go