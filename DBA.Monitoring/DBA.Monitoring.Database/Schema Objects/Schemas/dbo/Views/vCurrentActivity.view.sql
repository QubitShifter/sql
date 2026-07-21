create view [dbo].[vCurrentActivity]
as
select
    [SessionID] =
        s.[session_id],

    [LoginName] =
        s.[login_name],

    [HostName] =
        s.[host_name],

    [ProgramName] =
        s.[program_name],

    [DatabaseName] =
        db_name(coalesce(r.[database_id], s.[database_id])),

    [SessionStatus] =
        s.[status],

    [RequestStatus] =
        r.[status],

    [Command] =
        r.[command],

    [StartTime] =
        r.[start_time],

    [LastRequestStartTime] =
        s.[last_request_start_time],

    [CpuTimeMs] =
        r.[cpu_time],

    [TotalElapsedTimeMs] =
        r.[total_elapsed_time],

    [Reads] =
        r.[reads],

    [Writes] =
        r.[writes],

    [LogicalReads] =
        r.[logical_reads],

    [WaitType] =
        r.[wait_type],

    [WaitTimeMs] =
        r.[wait_time],

    [LastWaitType] =
        r.[last_wait_type],

    [BlockingSessionID] =
        r.[blocking_session_id],

    [IsBlocked] =
        convert(bit, case when isnull(r.[blocking_session_id], 0) > 0 then 1 else 0 end),

    [IsBlocking] =
        convert
        (
            bit,
            case
                when exists
                (
                    select 1
                    from [sys].[dm_exec_requests] blocked
                    where blocked.[blocking_session_id] = s.[session_id]
                )
                then 1
                else 0
            end
        ),

    [OpenTransactionCount] =
        s.[open_transaction_count],

    [PercentComplete] =
        r.[percent_complete],

    [SqlText] =
        st.[text]
from [sys].[dm_exec_sessions] s
left join [sys].[dm_exec_requests] r
    on s.[session_id] = r.[session_id]
outer apply [sys].[dm_exec_sql_text](r.[sql_handle]) st
where
    s.[is_user_process] = 1;
go