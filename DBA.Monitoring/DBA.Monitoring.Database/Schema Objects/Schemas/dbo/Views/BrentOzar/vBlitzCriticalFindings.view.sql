create view [dbo].[vBlitzCriticalFindings]
as
select
    [ID],
    [ServerName],
    [CheckDate],
    [Priority],
    [FindingsGroup],
    [Finding],
    [DatabaseName],
    [URL],
    [Details],
    [CheckID]
from [dbo].[vBlitzLatestFindings]
where [Priority] between 1 and 50;
go