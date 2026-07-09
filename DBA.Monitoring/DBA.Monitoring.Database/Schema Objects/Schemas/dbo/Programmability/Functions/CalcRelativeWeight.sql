CREATE FUNCTION [dbo].[CalcRelativeWeight] (
	@Weight float,
	@WeightTtl float
)
RETURNS TABLE 
AS 
RETURN (
	SELECT [RelativeWeight] = 100 * ( @Weight / @WeightTtl )
)
