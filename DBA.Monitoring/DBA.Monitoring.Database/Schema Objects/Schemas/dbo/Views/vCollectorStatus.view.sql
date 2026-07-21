create view [dbo].[vCollectorStatus]
as
with LatestRuns as
(
    select
        [MonitoringRunID],
        [RunType],
        [ServerName],
        [StartTime],
        [EndTime],
        [Status],
        [ErrorMessage],
        [DurationSeconds] =
            datediff(second, [StartTime], isnull([EndTime], sysdatetime())),
        [RowNumber] =
            row_number() over
            (
                partition by [RunType], [ServerName]
                order by [StartTime] desc, [MonitoringRunID] desc
            )
    from [dbo].[MonitoringRun]
)
select
    [MonitoringRunID],
    [RunType],
    [ServerName],
    [StartTime],
    [EndTime],
    [Status],
    [DurationSeconds],
    [ErrorMessage]
from LatestRuns
where [RowNumber] = 1;
go