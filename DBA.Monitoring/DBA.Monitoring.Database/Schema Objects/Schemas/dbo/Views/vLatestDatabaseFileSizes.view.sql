create view [dbo].[vLatestDatabaseFileSizes]
as
with LatestRun as
(
	select
		[LatestMonitoringRunID] = max([MonitoringRunID])
	from [dbo].[DatabaseFileSizeHistory]
)
select
	h.[DatabaseFileSizeHistoryID],
	h.[MonitoringRunID],
	h.[CaptureTime],
	h.[ServerName],
	h.[DatabaseName],
	h.[LogicalFileName],
	h.[FileID],
	h.[FileType],
	h.[PhysicalFileName],
	h.[SizeMB],
	h.[UsedSpaceMB],
	h.[FreeSpaceMB],
	h.[FreeSpacePercent],
	h.[Growth],
	h.[GrowthMB],
	h.[IsPercentGrowth],
	h.[MaxSize],
	h.[MaxSizeMB],

	[UsedSpacePercent] =
		case
			when h.[SizeMB] = 0 then null
			when h.[UsedSpaceMB] is null then null
			else convert(decimal(9, 2), h.[UsedSpaceMB] / h.[SizeMB] * 100.0)
		end,

	[GrowthDescription] =
		case
			when h.[IsPercentGrowth] = 1
				then concat(h.[Growth], N'%')
			when h.[GrowthMB] is not null
				then concat(h.[GrowthMB], N' MB')
			else N'-'
		end,

	[MaxSizeDescription] =
		case
			when h.[MaxSize] = -1
				then N'Unlimited'
			when h.[MaxSize] = 0
				then N'No growth'
			when h.[MaxSizeMB] is not null
				then concat(h.[MaxSizeMB], N' MB')
			else N'-'
		end,

	[FileCategory] =
		case
			when h.[DatabaseName] in (N'master', N'model', N'msdb', N'tempdb')
				then N'System'
			else N'User'
		end,

	[SpaceStatus] =
		case
			when h.[FreeSpacePercent] is null then N'Unknown'
			when h.[FreeSpacePercent] < 10 then N'Critical'
			when h.[FreeSpacePercent] < 20 then N'Warning'
			else N'OK'
		end
from [dbo].[DatabaseFileSizeHistory] h
inner join LatestRun lr
	on h.[MonitoringRunID] = lr.[LatestMonitoringRunID];
go