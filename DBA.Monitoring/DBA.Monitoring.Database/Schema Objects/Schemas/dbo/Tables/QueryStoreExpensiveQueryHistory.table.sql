create table [dbo].[QueryStoreExpensiveQueryHistory]
(
    [QueryStoreExpensiveQueryHistoryID] bigint identity(1,1) not null,

    [CollectionTime] datetime2(3) not null
        constraint [DF_QueryStoreExpensiveQueryHistory_CollectionTime]
        default (sysdatetime()),

    [ServerName]            sysname             not null,
    [DatabaseName]          sysname             not null,
    [QueryID]               bigint              not null,
    [PlanID]                bigint              not null,
    [QueryTextID]           bigint              not null,
    [ExecutionCount]        bigint              not null,
    [TotalDurationMs]       decimal(18, 2)      not null,
    [AvgDurationMs]         decimal(18, 2)      not null,
    [TotalCpuMs]            decimal(18, 2)      not null,
    [AvgCpuMs]              decimal(18, 2)      not null,
    [TotalLogicalReads]     decimal(18, 2)      not null,
    [AvgLogicalReads]       decimal(18, 2)      not null,
    [TotalPhysicalReads]    decimal(18, 2)      not null,
    [AvgPhysicalReads]      decimal(18, 2)      not null,
    [LastExecutionTime]     datetimeoffset      null,
    [QuerySqlText]          nvarchar(max)       null,

    constraint [PK_QueryStoreExpensiveQueryHistory]
        primary key clustered ([QueryStoreExpensiveQueryHistoryID] asc)
);
go

create index [IX_QueryStoreExpensiveQueryHistory_CollectionTime]
on [dbo].[QueryStoreExpensiveQueryHistory] ([CollectionTime] desc);
go

create index [IX_QueryStoreExpensiveQueryHistory_DatabaseName_CollectionTime]
on [dbo].[QueryStoreExpensiveQueryHistory] ([DatabaseName], [CollectionTime] desc)
include
(
    [QueryID],
    [PlanID],
    [ExecutionCount],
    [TotalCpuMs],
    [TotalDurationMs],
    [TotalLogicalReads],
    [LastExecutionTime]
);
go

create index [IX_QueryStoreExpensiveQueryHistory_TotalCpuMs]
on [dbo].[QueryStoreExpensiveQueryHistory] ([CollectionTime] desc, [TotalCpuMs] desc);
go