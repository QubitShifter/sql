create function dbo.GetProcStatsByTwoPeriods (
	@DateFromBase		date,
	@DateToBase			date,
	@DateFromTarget	date,
	@DateToTarget		date 
)
returns table 
as
return (
	with 
		BaseProcStats as (
			select *
			from dbo.GetProcStatsByPeriod( @DateFromBase, @DateToBase )
		),

		TargetProcStats as (
			select *
			from dbo.GetProcStatsByPeriod( @DateFromTarget, @DateToTarget )
		)

	select
		[DatabaseID]							= BASE.[database_id],
		[ProcID]									= BASE.[object_id],
		[NbrSnapshotsBase]				= BASE.[nbr_snapshots],
		[NbrExecBase]							= BASE.[execution_count],
		[AvgNbrExecBase]					= BASE.[avg_exec_count],
		[CPUTimeBase]							= BASE.[worker_time],
		[AvgCPUTimeBase]					= BASE.[avg_worker_time],
		[ElapsedTimeBase]					= BASE.[elapsed_time],
		[ElapsedTimeTtlBase]			= BASE.[elapsed_time_ttl],
		[AvgElapsedTimeBase]			= BASE.[avg_elapsed_time],
		[NbrSnapshotsTrg]					= TRG.[nbr_snapshots],
		[NbrExecTrg]							= TRG.[execution_count],
		[AvgNbrExecTrg]						= TRG.[avg_exec_count],
		[CPUTimeTrg]							= TRG.[worker_time],
		[AvgCPUTimeTrg]						= TRG.[avg_worker_time],
		[ElapsedTimeTrg]					= TRG.[elapsed_time],
		[ElapsedTimeTtlTrg]				= TRG.[elapsed_time_ttl],
		[AvgElapsedTimeTrg]				= TRG.[avg_elapsed_time],
		[WeightElapsedTimeBase]		= WBASE.[RelativeWeight],
		[WeightElapsedTimeTrg]		= WTRG.[RelativeWeight],
		[RatioNbrExec]						= R.[RatioNbrExec],
		[RatioElapsedTime]				= R.[RatioElapsedTime],
		[RatioCPUTime]						= R.[RatioCPUTime],
		[RatioWeightElapsedTime]	= R.[RatioWeightElapsedTime]
	from BaseProcStats as BASE
		join TargetProcStats as TRG on 
					( TRG.[database_id] = BASE.[database_id] )
			and ( TRG.[object_id] = BASE.[object_id] )		
		cross apply dbo.CalcRelativeWeight( BASE.[elapsed_time], BASE.[elapsed_time_ttl] ) as WBASE
		cross apply dbo.CalcRelativeWeight( TRG.[elapsed_time], TRG.[elapsed_time_ttl] ) as WTRG
		cross apply dbo.CalcProcStatsRatio ( 
			BASE.[avg_exec_count], BASE.[avg_elapsed_time], BASE.[avg_worker_time], WBASE.[RelativeWeight],
			TRG.[avg_exec_count], TRG.[avg_elapsed_time], TRG.[avg_worker_time], WTRG.[RelativeWeight] 
		) as R
)