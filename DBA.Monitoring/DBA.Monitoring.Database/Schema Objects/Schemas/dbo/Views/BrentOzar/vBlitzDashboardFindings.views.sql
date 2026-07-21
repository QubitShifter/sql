create view [dbo].[vBlitzDashboardFindings]
as
select
    [ID],
    [ServerName],
    [CheckDate],

    [Severity] =
        case
            when [Priority] between 1 and 50 then N'Critical'
            when [Priority] between 51 and 200 then N'Warning'
            when [Priority] between 201 and 250 then N'Info'
            else N'Ignore'
        end,

    [Priority],
    [FindingsGroup],
    [Finding],
    [DatabaseName],
    [URL],
    [Details],
    [CheckID]
from [dbo].[vBlitzLatestFindings]
where
    isnull([CheckID], 0) <> -1
    and isnull([Priority], 0) < 254;
go