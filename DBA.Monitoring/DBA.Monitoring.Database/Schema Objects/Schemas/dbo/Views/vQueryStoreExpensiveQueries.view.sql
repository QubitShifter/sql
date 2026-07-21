create view [dbo].[vQueryStoreExpensiveQueries]
as
select top (100)
    [DatabaseName] =
        db_name(),

    [QueryId] =
        q.[query_id],

    [PlanId] =
        p.[plan_id],

    [QueryTextId] =
        qt.[query_text_id],

    [ExecutionCount] =
        sum(rs.[count_executions]),

    [TotalDurationMs] =
        convert(decimal(18, 2), sum(rs.[avg_duration] * rs.[count_executions]) / 1000.0),

    [AvgDurationMs] =
        convert(decimal(18, 2), avg(rs.[avg_duration]) / 1000.0),

    [TotalCpuMs] =
        convert(decimal(18, 2), sum(rs.[avg_cpu_time] * rs.[count_executions]) / 1000.0),

    [AvgCpuMs] =
        convert(decimal(18, 2), avg(rs.[avg_cpu_time]) / 1000.0),

    [TotalLogicalReads] =
        convert(decimal(18, 2), sum(rs.[avg_logical_io_reads] * rs.[count_executions])),

    [AvgLogicalReads] =
        convert(decimal(18, 2), avg(rs.[avg_logical_io_reads])),

    [TotalPhysicalReads] =
        convert(decimal(18, 2), sum(rs.[avg_physical_io_reads] * rs.[count_executions])),

    [AvgPhysicalReads] =
        convert(decimal(18, 2), avg(rs.[avg_physical_io_reads])),

    [LastExecutionTime] =
        max(rs.[last_execution_time]),

    [QuerySqlText] =
        qt.[query_sql_text]
from [sys].[query_store_query_text] qt
inner join [sys].[query_store_query] q
    on qt.[query_text_id] = q.[query_text_id]
inner join [sys].[query_store_plan] p
    on q.[query_id] = p.[query_id]
inner join [sys].[query_store_runtime_stats] rs
    on p.[plan_id] = rs.[plan_id]
inner join [sys].[query_store_runtime_stats_interval] rsi
    on rs.[runtime_stats_interval_id] = rsi.[runtime_stats_interval_id]
where
    rs.[count_executions] > 0
group by
    q.[query_id],
    p.[plan_id],
    qt.[query_text_id],
    qt.[query_sql_text]
order by
    [TotalCpuMs] desc;
go