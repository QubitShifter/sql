create view [dbo].[vQueryStoreExpensiveQueriesLatest]
as
with LatestCollection as
(
    select
        [LatestCollectionTime] = max([CollectionTime])
    from [dbo].[QueryStoreExpensiveQueryHistory]
)
select
    h.[DatabaseName],
    h.[QueryID],
    h.[PlanID],
    h.[QueryTextID],
    h.[ExecutionCount],
    h.[TotalDurationMs],
    h.[AvgDurationMs],
    h.[TotalCpuMs],
    h.[AvgCpuMs],
    h.[TotalLogicalReads],
    h.[AvgLogicalReads],
    h.[TotalPhysicalReads],
    h.[AvgPhysicalReads],
    h.[LastExecutionTime],
    h.[QuerySqlText]
from [dbo].[QueryStoreExpensiveQueryHistory] as h
inner join LatestCollection lc
    on h.[CollectionTime] = lc.[LatestCollectionTime];
go