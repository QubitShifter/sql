CREATE FUNCTION [dbo].[CalcProcStatsRatio] (
	@AvgNbrExecBase float,	
	@AvgElapsedTimeBase float,
	@AvgCPUTimeBase float,
	@WeightElapsedTimeBase float,
	@AvgNbrExecTrg float,	
	@AvgElapsedTimeTrg float,
	@AvgCPUTimeTrg float,
	@WeightElapsedTimeTrg float
)
RETURNS TABLE 
AS 
RETURN (
	select
		[RatioNbrExec]						= 100 * ( @AvgNbrExecTrg / @AvgNbrExecBase ),
		[RatioElapsedTime]				= 100 * ( @AvgElapsedTimeTrg / @AvgElapsedTimeBase ),
		[RatioCPUTime]						= 100 * ( @AvgCPUTimeTrg / @AvgCPUTimeBase ),
		[RatioWeightElapsedTime]	= 100 * ( @WeightElapsedTimeTrg / @WeightElapsedTimeBase  )
)
