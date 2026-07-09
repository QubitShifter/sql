/*
Procedure to save basic stats : 
1) wait stats 
2) procedures stats 
3) file stats 
4) table stats  

*/
CREATE PROCEDURE [dbo].[CollectBasicStats]
AS
SET NOCOUNT ON; 

BEGIN TRY 

	EXEC dbo.SaveWaitStats; 

	EXEC dbo.SaveProcStats; 

	EXEC dbo.SaveFileStats ;

	EXEC dbo.SaveTableStats; 
	

END TRY 
BEGIN CATCH 

	EXEC dbo.RethrowError ; 

END CATCH 
