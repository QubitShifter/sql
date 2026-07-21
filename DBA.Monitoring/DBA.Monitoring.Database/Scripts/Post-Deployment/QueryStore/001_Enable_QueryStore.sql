use [master];
go

set nocount on;
go

declare
    @DatabaseName sysname,
    @Sql nvarchar(max),
    @Message nvarchar(4000);

declare DatabaseCursor cursor local fast_forward for
select
    [name]
from [sys].[databases]
where
    [database_id] > 4
    and [state_desc] = N'ONLINE'
    and [is_read_only] = 0
    and [source_database_id] is null
order by
    [name];

open DatabaseCursor;

fetch next from DatabaseCursor into @DatabaseName;

while @@fetch_status = 0
begin
    begin try
        if exists
        (
            select 1
            from [sys].[databases]
            where
                [name] = @DatabaseName
                and [is_query_store_on] = 0
        )
        begin
            set @Sql =
                N'alter database ' + quotename(@DatabaseName) + N'
                  set query_store = on;';

            exec sys.sp_executesql @Sql;
        end;

        set @Sql =
            N'alter database ' + quotename(@DatabaseName) + N'
              set query_store
              (
                  operation_mode = read_write,
                  query_capture_mode = auto
              );';

        exec sys.sp_executesql @Sql;

        set @Message =
            N'Query Store enabled/configured for database: ' + quotename(@DatabaseName);

        print @Message;
    end try
    begin catch
        set @Message =
            N'Query Store configuration failed for database '
            + quotename(@DatabaseName)
            + N'. Error: '
            + error_message();

        print @Message;
    end catch;

    fetch next from DatabaseCursor into @DatabaseName;
end;

close DatabaseCursor;
deallocate DatabaseCursor;
go