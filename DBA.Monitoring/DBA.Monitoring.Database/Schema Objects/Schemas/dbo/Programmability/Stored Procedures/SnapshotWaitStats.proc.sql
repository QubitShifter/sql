create procedure [dbo].[SnapshotWaitStats] (
	@Context varchar(64),
	@Duration time = '00:00:00.003',
	@Interval time = '00:00:00.003'
)
as
begin
	set nocount on

	declare @TimeLimit datetime
	declare @SQLCommand nvarchar(max)

	set @TimeLimit = getdate() + convert(datetime, @Duration)

	while getdate() < @TimeLimit
	begin

		insert into [dbo].[WaitStatsSnapshot] (
			[SPID],
			[Context],
			[WaitType],
			[WaitTime],
			[NbrWaits]
		)
		select
			[SPID] = @@spid,
			[Context] = @Context,
			[WaitType] = [wait_type],
			[WaitTime] = [wait_time_ms],
			[NbrWaits] = [waiting_tasks_count]
		from [sys].[dm_os_wait_stats]
		where [wait_type] in (
				N'CXPACKET',
				N'OLEDB',
				N'SEQUENCE_GENERATION',
				N'THREADPOOL',
				N'TRANSACTION_MUTEX',
				N'WRITE_COMPLETION',
				N'WRITELOG'
			)
			or [wait_type] like N'ASYNC[_]%'
			or [wait_type] like N'BACKUP%'
			or [wait_type] like N'CLR[_]%'
			or [wait_type] like N'DTC%'
			or [wait_type] like N'DTC[_]%'
			or [wait_type] like N'IO[_]%'
			or [wait_type] like N'LATCH[_]%'
			or [wait_type] like N'LCK[_]%'
			or [wait_type] like N'LOG%'
			or [wait_type] like N'%MEMORY[_]%'
			or [wait_type] like N'MSQL[_]%'
			or [wait_type] like N'PAGEIOLATCH[_]%'
			or [wait_type] like N'PAGELATCH[_]%'
			or [wait_type] like N'SOS[_]%'

		set @SQLCommand = N'waitfor delay ' + quotename(convert(varchar(12), @Interval, 121), '''')

		exec (@SQLCommand)

	end

	return 0
end
go