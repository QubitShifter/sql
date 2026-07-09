CREATE FUNCTION [dbo].[GetProcStatsByPeriod] (
	@DateFrom	date,
	@DateTo date
)
RETURNS TABLE 
AS 
RETURN (
	select
		[database_id],
		[object_id],
		[nbr_snapshots],
		[execution_count],
		[elapsed_time],
		[elapsed_time_ttl]	= sum( [elapsed_time] ) over( partition by [database_id] ),
		[worker_time],
		[avg_exec_count]		= AVRG.[AvgNbrExec],
		[avg_worker_time]		= AVRG.[AvgCPUTime],
		[avg_elapsed_time]	= AVRG.[AvgElapsedTime]
	from ( 
		select
			[database_id],
			[object_id],
			[execution_count]	= max( [execution_count] ) - min( [execution_count] ),
			[worker_time]			= ( max( [worker_time] ) - min( [worker_time] ) ) / 1000.00,
			[elapsed_time]		= ( max( [elapsed_time] ) - min( [elapsed_time] ) ) / 1000.00,
			[nbr_snapshots]		= cast( count([counter_snapshot_id]) as float )
		from ( 
			select
				[database_id]					= STS.[database_id],
				[object_id]						= STS.[object_id],
				[counter_snapshot_id]	= SNP.[counter_snapshot_id],
				[execution_count]			= sum( STS.[execution_count] ),
				[worker_time]					= sum( STS.[total_worker_time] ),
				[elapsed_time]				= sum( STS.[total_elapsed_time] )
			from dbo.ProcStats as STS
				join dbo.CounterSnapshots as SNP on SNP.[counter_snapshot_id] = STS.[counter_snapshot_id]
			where ( SNP.[datestamp] between @DateFrom and @DateTo )
			group by
				STS.[database_id],
				STS.[object_id],
				SNP.[counter_snapshot_id]
		) as Q
		group by
			[database_id],
			[object_id]
	) as Q
		cross apply dbo.CalcAvgProcStats( [execution_count], [worker_time], [elapsed_time], [nbr_snapshots] ) as AVRG
	where ( Q.[execution_count] > 0 )
)
