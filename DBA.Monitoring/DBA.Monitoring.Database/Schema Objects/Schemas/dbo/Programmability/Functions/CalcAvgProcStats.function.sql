CREATE FUNCTION [dbo].[CalcAvgProcStats] (
	@NbrExec float,
	@CPUTime float,
	@ElapsedTime float,
	@NbrSnapshots int
)
RETURNS TABLE 
AS 
RETURN (
	SELECT
		[AvgNbrExec]			= @NbrExec / @NbrSnapshots,
		[AvgCPUTime]			= @CPUTime / @NbrExec,
		[AvgElapsedTime]	= @ElapsedTime / @NbrExec
)
