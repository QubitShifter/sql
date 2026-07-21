create view [dbo].[vBlitzFindingSummary]
as
select
    [CheckDate],

    CriticalFindings =
        sum(case when [Priority] between 1 and 50 then 1 else 0 end),

    WarningFindings =
        sum(case when [Priority] between 51 and 200 then 1 else 0 end),

    InformationalFindings =
        sum(case when [Priority] between 201 and 250 then 1 else 0 end),

    TotalFindings =
        count_big(*)
from [dbo].[vBlitzLatestFindings]
where
    isnull([CheckID], 0) <> -1
    and isnull([Priority], 0) < 254
group by
    [CheckDate];
go