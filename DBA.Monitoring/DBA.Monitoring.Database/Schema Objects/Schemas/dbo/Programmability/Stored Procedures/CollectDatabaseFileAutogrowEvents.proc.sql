create procedure [dbo].[CollectDatabaseFileAutogrowEvents]
	@LookbackHours int = 48
as
begin
	set nocount on
	set xact_abort on

	declare
		@MonitoringRunID bigint,
		@ServerName sysname = cast(serverproperty(N'ServerName') as sysname),
		@TracePath nvarchar(260),
		@RowsInserted int = 0

	if @LookbackHours <= 0
	begin
		set @LookbackHours = 48
	end

	insert into [dbo].[MonitoringRun]
	(
		[RunType],
		[ServerName],
		[StartTime],
		[Status]
	)
	values
	(
		N'DatabaseFileAutogrowEvents',
		@ServerName,
		sysdatetime(),
		N'Running'
	)

	set @MonitoringRunID = scope_identity()

	begin try

		select
			@TracePath = [path]
		from [sys].[traces]
		where
			[is_default] = 1

		if @TracePath is null
		begin
			update [dbo].[MonitoringRun]
			set
				[EndTime] = sysdatetime(),
				[Status] = N'Succeeded',
				[ErrorMessage] = N'Default trace is not enabled. Rows inserted: 0'
			where
				[MonitoringRunID] = @MonitoringRunID

			return
		end

		;with AutogrowEvents as
		(
			select
				[ServerName] =
					@ServerName,

				[DatabaseName] =
					trace_data.[DatabaseName],

				[LogicalFileName] =
					coalesce
					(
						mf.[name],
						trace_data.[ObjectName],
						trace_data.[FileName]
					),

				[FileType] =
					case trace_data.[EventClass]
						when 92 then N'ROWS'
						when 93 then N'LOG'
						else null
					end,

				[GrowthTime] =
					convert(datetime2(3), trace_data.[StartTime]),

				[DurationMs] =
					case
						when trace_data.[Duration] is null then null
						else convert(bigint, trace_data.[Duration] / 1000)
					end,

				[GrowthSizeMB] =
					case
						when trace_data.[IntegerData] is null then null
						else convert(decimal(18, 2), trace_data.[IntegerData] * 8.0 / 1024.0)
					end,

				[PhysicalFileName] =
					coalesce
					(
						mf.[physical_name],
						trace_data.[FileName]
					),

				[EventSource] =
					N'DefaultTrace',

				[EventClass] =
					trace_data.[EventClass],

				[EventName] =
					te.[name]
			from sys.fn_trace_gettable(@TracePath, default) trace_data
			left join [sys].[trace_events] te
				on trace_data.[EventClass] = te.[trace_event_id]
			left join [sys].[master_files] mf
				on mf.[database_id] = db_id(trace_data.[DatabaseName])
				and
				(
					mf.[physical_name] = trace_data.[FileName]
					or mf.[name] = trace_data.[FileName]
					or mf.[name] = trace_data.[ObjectName]
				)
			where
				trace_data.[EventClass] in
				(
					92, -- Data File Auto Grow
					93  -- Log File Auto Grow
				)
				and trace_data.[StartTime] >= dateadd(hour, -@LookbackHours, sysdatetime())
				and trace_data.[DatabaseName] is not null
				and trace_data.[StartTime] is not null
		)
		insert into [dbo].[DatabaseFileAutogrowHistory]
		(
			[MonitoringRunID],
			[CaptureTime],
			[ServerName],
			[DatabaseName],
			[LogicalFileName],
			[FileType],
			[GrowthTime],
			[DurationMs],
			[GrowthSizeMB],
			[PhysicalFileName],
			[EventSource],
			[EventClass],
			[EventName]
		)
		select
			[MonitoringRunID] = @MonitoringRunID,
			[CaptureTime] = sysdatetime(),
			[ServerName],
			[DatabaseName],
			[LogicalFileName],
			[FileType],
			[GrowthTime],
			[DurationMs],
			[GrowthSizeMB],
			[PhysicalFileName],
			[EventSource],
			[EventClass],
			[EventName]
		from AutogrowEvents ae
		where not exists
		(
			select 1
			from [dbo].[DatabaseFileAutogrowHistory] h
			where
				h.[ServerName] = ae.[ServerName]
				and isnull(h.[DatabaseName], N'') = isnull(ae.[DatabaseName], N'')
				and isnull(h.[LogicalFileName], N'') = isnull(ae.[LogicalFileName], N'')
				and h.[GrowthTime] = ae.[GrowthTime]
				and h.[EventSource] = ae.[EventSource]
				and isnull(h.[EventClass], -1) = isnull(ae.[EventClass], -1)
		)

		set @RowsInserted = @@rowcount

		update [dbo].[MonitoringRun]
		set
			[EndTime] = sysdatetime(),
			[Status] = N'Succeeded',
			[ErrorMessage] = concat(N'Rows inserted: ', @RowsInserted)
		where
			[MonitoringRunID] = @MonitoringRunID

	end try
	begin catch

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