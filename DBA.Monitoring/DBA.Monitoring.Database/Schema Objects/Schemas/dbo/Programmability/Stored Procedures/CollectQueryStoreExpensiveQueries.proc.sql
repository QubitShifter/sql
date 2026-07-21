create procedure [dbo].[CollectQueryStoreExpensiveQueries]
    @TopPerDatabase int = 20,
    @OrderBy nvarchar(30) = N'cpu'
as
begin
    set nocount on;
    set xact_abort on;

    declare
        @RunID bigint,
        @ServerName sysname = cast(serverproperty(N'ServerName') as sysname),
        @DatabaseName sysname,
        @Sql nvarchar(max),
        @OrderBySql nvarchar(200),
        @RowsInserted int = 0;

    if @TopPerDatabase <= 0
    begin
        set @TopPerDatabase = 20;
    end;

    if @TopPerDatabase > 200
    begin
        set @TopPerDatabase = 200;
    end;

    set @OrderBySql =
        case lower(@OrderBy)
            when N'duration' then N'[TotalDurationMs] desc'
            when N'reads' then N'[TotalLogicalReads] desc'
            when N'executions' then N'[ExecutionCount] desc'
            else N'[TotalCpuMs] desc'
        end;

    insert into [dbo].[MonitoringRun]
    (
        [RunType],
        [ServerName],
        [StartTime],
        [Status]
    )
    values
    (
        N'QueryStoreExpensiveQueries',
        @ServerName,
        sysdatetime(),
        N'Running'
    );

    set @RunID = scope_identity();

    begin try
        declare DatabaseCursor cursor local fast_forward for
        select
            [name]
        from [sys].[databases]
        where
            [database_id] > 4
            and [state_desc] = N'ONLINE'
            and [is_read_only] = 0
            and [is_query_store_on] = 1
            and [name] <> N'DBA_Monitoring';

        open DatabaseCursor;

        fetch next from DatabaseCursor into @DatabaseName;

        while @@fetch_status = 0
        begin
            set @Sql = N'
                insert into [dbo].[QueryStoreExpensiveQueryHistory]
                (
                    [CollectionTime],
                    [ServerName],
                    [DatabaseName],
                    [QueryID],
                    [PlanID],
                    [QueryTextID],
                    [ExecutionCount],
                    [TotalDurationMs],
                    [AvgDurationMs],
                    [TotalCpuMs],
                    [AvgCpuMs],
                    [TotalLogicalReads],
                    [AvgLogicalReads],
                    [TotalPhysicalReads],
                    [AvgPhysicalReads],
                    [LastExecutionTime],
                    [QuerySqlText]
                )
                select top (@TopPerDatabase)
                    [CollectionTime] = sysdatetime(),
                    [ServerName] = @ServerName,
                    [DatabaseName] = @DatabaseName,
                    [QueryID] = q.[query_id],
                    [PlanID] = p.[plan_id],
                    [QueryTextID] = qt.[query_text_id],

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
                from ' + quotename(@DatabaseName) + N'.[sys].[query_store_query_text] qt
                inner join ' + quotename(@DatabaseName) + N'.[sys].[query_store_query] q
                    on qt.[query_text_id] = q.[query_text_id]
                inner join ' + quotename(@DatabaseName) + N'.[sys].[query_store_plan] p
                    on q.[query_id] = p.[query_id]
                inner join ' + quotename(@DatabaseName) + N'.[sys].[query_store_runtime_stats] rs
                    on p.[plan_id] = rs.[plan_id]
                inner join ' + quotename(@DatabaseName) + N'.[sys].[query_store_runtime_stats_interval] rsi
                    on rs.[runtime_stats_interval_id] = rsi.[runtime_stats_interval_id]
                where
                    rs.[count_executions] > 0
                group by
                    q.[query_id],
                    p.[plan_id],
                    qt.[query_text_id],
                    qt.[query_sql_text]
                order by
                    ' + @OrderBySql + N';';

            exec sys.sp_executesql
                @Sql,
                N'@TopPerDatabase int,
                  @ServerName sysname,
                  @DatabaseName sysname',
                @TopPerDatabase = @TopPerDatabase,
                @ServerName = @ServerName,
                @DatabaseName = @DatabaseName;

            set @RowsInserted += @@rowcount;

            fetch next from DatabaseCursor into @DatabaseName;
        end;

        close DatabaseCursor;
        deallocate DatabaseCursor;

        update [dbo].[MonitoringRun]
        set
            [EndTime] = sysdatetime(),
            [Status] = N'Succeeded',
            [ErrorMessage] = concat(N'Rows inserted: ', @RowsInserted)
        where
            [MonitoringRunID] = @RunID;
    end try
    begin catch
        if cursor_status('local', 'DatabaseCursor') >= -1
        begin
            close DatabaseCursor;
            deallocate DatabaseCursor;
        end;

        update [dbo].[MonitoringRun]
        set
            [EndTime] = sysdatetime(),
            [Status] = N'Failed',
            [ErrorMessage] = error_message()
        where
            [MonitoringRunID] = @RunID;

        throw;
    end catch;
end;
go