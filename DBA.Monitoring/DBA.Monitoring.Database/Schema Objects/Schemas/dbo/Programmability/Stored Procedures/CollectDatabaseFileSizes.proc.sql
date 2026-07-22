create procedure [dbo].[CollectDatabaseFileSizes]
as
begin
	set nocount on
	set xact_abort on

	declare
		@MonitoringRunID bigint,
		@ServerName sysname = cast(serverproperty(N'ServerName') as sysname),
		@DatabaseName sysname,
		@Sql nvarchar(max),
		@RowsInserted int = 0,
		@RowsInsertedCurrentDatabase int = 0

	insert into [dbo].[MonitoringRun]
	(
		[RunType],
		[ServerName],
		[StartTime],
		[Status]
	)
	values
	(
		N'DatabaseFileSizes',
		@ServerName,
		sysdatetime(),
		N'Running'
	)

	set @MonitoringRunID = scope_identity()

	begin try

		declare DatabaseCursor cursor local fast_forward for
		select
			[name]
		from [sys].[databases]
		where
			[state_desc] = N'ONLINE'
			and [is_read_only] = 0
			and [source_database_id] is null
		order by
			[name]

		open DatabaseCursor

		fetch next from DatabaseCursor into @DatabaseName

		while @@fetch_status = 0
		begin
			set @RowsInsertedCurrentDatabase = 0

			set @Sql = N'
use ' + quotename(@DatabaseName) + N';

declare @InsertedRows int = 0;

with FileInfo as
(
	select
		[DatabaseName] = db_name(),
		[LogicalFileName] = df.[name],
		[FileID] = df.[file_id],
		[FileType] = df.[type_desc],
		[PhysicalFileName] = df.[physical_name],
		[SizeMB] = convert(decimal(18, 2), df.[size] * 8.0 / 1024.0),
		[UsedSpaceMB] =
			case
				when df.[type_desc] = N''ROWS''
					then convert(decimal(18, 2), fileproperty(df.[name], ''SpaceUsed'') * 8.0 / 1024.0)
				when df.[type_desc] = N''LOG''
					 and count(case when df.[type_desc] = N''LOG'' then 1 end) over () = 1
					then convert(decimal(18, 2), ls.[used_log_space_in_bytes] / 1024.0 / 1024.0)
				else null
			end,
		[Growth] = convert(bigint, df.[growth]),
		[GrowthMB] =
			case
				when df.[is_percent_growth] = 0
					then convert(decimal(18, 2), df.[growth] * 8.0 / 1024.0)
				else null
			end,
		[IsPercentGrowth] = convert(bit, df.[is_percent_growth]),
		[MaxSize] = convert(bigint, df.[max_size]),
		[MaxSizeMB] =
			case
				when df.[max_size] = -1 then null
				when df.[max_size] = 0 then convert(decimal(18, 2), 0)
				else convert(decimal(18, 2), df.[max_size] * 8.0 / 1024.0)
			end
	from [sys].[database_files] df
	cross join [sys].[dm_db_log_space_usage] ls
)
insert into [DBA_Monitoring].[dbo].[DatabaseFileSizeHistory]
(
	[MonitoringRunID],
	[CaptureTime],
	[ServerName],
	[DatabaseName],
	[LogicalFileName],
	[FileID],
	[FileType],
	[PhysicalFileName],
	[SizeMB],
	[UsedSpaceMB],
	[FreeSpaceMB],
	[FreeSpacePercent],
	[Growth],
	[GrowthMB],
	[IsPercentGrowth],
	[MaxSize],
	[MaxSizeMB]
)
select
	[MonitoringRunID] = @MonitoringRunID,
	[CaptureTime] = sysdatetime(),
	[ServerName] = @ServerName,
	[DatabaseName],
	[LogicalFileName],
	[FileID],
	[FileType],
	[PhysicalFileName],
	[SizeMB],
	[UsedSpaceMB],
	[FreeSpaceMB] =
		case
			when [UsedSpaceMB] is null then null
			else [SizeMB] - [UsedSpaceMB]
		end,
	[FreeSpacePercent] =
		case
			when [UsedSpaceMB] is null or [SizeMB] = 0 then null
			else convert(decimal(9, 2), (([SizeMB] - [UsedSpaceMB]) / [SizeMB]) * 100.0)
		end,
	[Growth],
	[GrowthMB],
	[IsPercentGrowth],
	[MaxSize],
	[MaxSizeMB]
from FileInfo;

set @InsertedRows = @@rowcount;

select @RowsInsertedCurrentDatabase = @InsertedRows;
'

			exec sys.sp_executesql
				@Sql,
				N'@MonitoringRunID bigint,
				  @ServerName sysname,
				  @RowsInsertedCurrentDatabase int output',
				@MonitoringRunID = @MonitoringRunID,
				@ServerName = @ServerName,
				@RowsInsertedCurrentDatabase = @RowsInsertedCurrentDatabase output

			set @RowsInserted += @RowsInsertedCurrentDatabase

			fetch next from DatabaseCursor into @DatabaseName
		end

		close DatabaseCursor
		deallocate DatabaseCursor

		update [dbo].[MonitoringRun]
		set
			[EndTime] = sysdatetime(),
			[Status] = N'Succeeded',
			[ErrorMessage] = concat(N'Rows inserted: ', @RowsInserted)
		where
			[MonitoringRunID] = @MonitoringRunID

	end try
	begin catch

		if cursor_status('local', 'DatabaseCursor') >= -1
		begin
			close DatabaseCursor
			deallocate DatabaseCursor
		end

		update [dbo].[MonitoringRun]
		set
			[EndTime] = sysdatetime(),
			[Status] = N'Failed',
			[ErrorMessage] = error_message()
		where
			[MonitoringRunID] = @MonitoringRunID

		;throw

	end catch
end
go