use [master];
go

if suser_id(N'$(ApiSqlLogin)') is not null
begin
    declare @sql nvarchar(max);

    set @sql =
        N'grant view server state to ' + quotename(N'$(ApiSqlLogin)') + N';';

    exec sys.sp_executesql @sql;
end
else
begin
    print N'ApiSqlLogin was not found. VIEW SERVER STATE was not granted.';
end
go