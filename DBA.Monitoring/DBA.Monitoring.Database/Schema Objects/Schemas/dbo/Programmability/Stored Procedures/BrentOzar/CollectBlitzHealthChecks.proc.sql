create procedure [dbo].[CollectBlitzHealthChecks]
    @IgnorePrioritiesAbove int = 250,
    @CheckUserDatabaseObjects tinyint = 1,
    @CheckProcedureCache tinyint = 0
as
begin
    set nocount on;
    set xact_abort on;

    declare
        @StartedAt datetime2(0) = sysdatetime(),
        @CompletedAt datetime2(0),
        @RowsBefore int,
        @RowsAfter int,
        @RowsInserted int,
        @ErrorMessage nvarchar(max);

    select
        @RowsBefore = count(*)
    from [dbo].[BlitzHealthCheckHistory];

    begin try
        exec sys.sp_executesql
            N'exec [dbo].[sp_Blitz]
                @CheckUserDatabaseObjects = @CheckUserDatabaseObjects,
                @CheckProcedureCache = @CheckProcedureCache,
                @IgnorePrioritiesAbove = @IgnorePrioritiesAbove,
                @OutputDatabaseName = N''DBA_Monitoring'',
                @OutputSchemaName = N''dbo'',
                @OutputTableName = N''BlitzHealthCheckHistory'',
                @OutputXMLasNVARCHAR = 1;',
            N'@CheckUserDatabaseObjects tinyint,
              @CheckProcedureCache tinyint,
              @IgnorePrioritiesAbove int',
            @CheckUserDatabaseObjects = @CheckUserDatabaseObjects,
            @CheckProcedureCache = @CheckProcedureCache,
            @IgnorePrioritiesAbove = @IgnorePrioritiesAbove;

        select
            @RowsAfter = count(*)
        from [dbo].[BlitzHealthCheckHistory];

        set @RowsInserted = isnull(@RowsAfter, 0) - isnull(@RowsBefore, 0);
        set @CompletedAt = sysdatetime();

        exec sys.sp_executesql
            N'insert into [dbo].[MonitoringRun]
              (
                  [RunType],
                  [StartedAt],
                  [CompletedAt],
                  [Status],
                  [RowsAffected],
                  [ErrorMessage]
              )
              values
              (
                  @RunType,
                  @StartedAt,
                  @CompletedAt,
                  @Status,
                  @RowsAffected,
                  @ErrorMessage
              );',
            N'@RunType nvarchar(100),
              @StartedAt datetime2(0),
              @CompletedAt datetime2(0),
              @Status nvarchar(50),
              @RowsAffected int,
              @ErrorMessage nvarchar(max)',
            @RunType = N'CollectBlitzHealthChecks',
            @StartedAt = @StartedAt,
            @CompletedAt = @CompletedAt,
            @Status = N'Succeeded',
            @RowsAffected = @RowsInserted,
            @ErrorMessage = null;
    end try
    begin catch
        set @CompletedAt = sysdatetime();
        set @ErrorMessage = error_message();

        exec sys.sp_executesql
            N'insert into [dbo].[MonitoringRun]
              (
                  [RunType],
                  [StartedAt],
                  [CompletedAt],
                  [Status],
                  [RowsAffected],
                  [ErrorMessage]
              )
              values
              (
                  @RunType,
                  @StartedAt,
                  @CompletedAt,
                  @Status,
                  @RowsAffected,
                  @ErrorMessage
              );',
            N'@RunType nvarchar(100),
              @StartedAt datetime2(0),
              @CompletedAt datetime2(0),
              @Status nvarchar(50),
              @RowsAffected int,
              @ErrorMessage nvarchar(max)',
            @RunType = N'CollectBlitzHealthChecks',
            @StartedAt = @StartedAt,
            @CompletedAt = @CompletedAt,
            @Status = N'Failed',
            @RowsAffected = 0,
            @ErrorMessage = @ErrorMessage;

        throw;
    end catch
end;
go