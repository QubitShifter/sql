create view [dbo].[vBlitzLatestFindings]
as
with LatestRun as
(
    select
        LatestCheckDate = max([CheckDate])
    from [dbo].[BlitzHealthCheckHistory]
)
select
    h.[ID],
    h.[ServerName],
    h.[CheckDate],
    h.[Priority],
    h.[FindingsGroup],
    h.[Finding],
    h.[DatabaseName],
    h.[URL],
    h.[Details],
    h.[CheckID]
from [dbo].[BlitzHealthCheckHistory] h
inner join LatestRun lr
    on h.[CheckDate] = lr.[LatestCheckDate];
go