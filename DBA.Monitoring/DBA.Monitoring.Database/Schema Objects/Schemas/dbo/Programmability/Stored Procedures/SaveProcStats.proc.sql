/*
Procedure for saving stored procedures stats 
*/
CREATE PROCEDURE [dbo].[SaveProcStats]
	
AS
SET NOCOUNT ON; 

DECLARE  @counter_snapshot_id INT;

BEGIN TRY 

	BEGIN TRAN; 

	--Getting snapshot ID 
	 EXEC dbo.RegisterCounterSnapshot 
										@counter_snapshot_type_id = 2 ,  -- "Proc Stats"
										@counter_snapshot_id = @counter_snapshot_id OUTPUT ; 
					
	INSERT INTO dbo.ProcStats WITH (TABLOCKX)
											   ( 
												   counter_snapshot_id,
												   database_id,
												   [plan_handle],
												   [object_id],
												   last_execution_time,
												   execution_count,
												   total_worker_time,
												   last_worker_time,
												   min_worker_time,
												   max_worker_time,
												   total_physical_reads,
												   last_physical_reads,
												   min_physical_reads,
												   max_physical_reads,
												   total_logical_writes,
												   last_logical_writes,
												   min_logical_writes,
												   max_logical_writes,
												   total_logical_reads,
												   last_logical_reads,
												   min_logical_reads,
												   max_logical_reads,
												   total_elapsed_time,
												   last_elapsed_time,
												   min_elapsed_time,
												   max_elapsed_time   
												 )
							       
	SELECT 
	       @counter_snapshot_id,
		   s.database_id,
		   s.[plan_handle],
		   s.[object_id],
		   s.last_execution_time,
		   s.execution_count,
		   s.total_worker_time,
		   s.last_worker_time,
		   s.min_worker_time,
		   s.max_worker_time,
		   s.total_physical_reads,
		   s.last_physical_reads,
		   s.min_physical_reads,
		   s.max_physical_reads,
		   s.total_logical_writes,
		   s.last_logical_writes,
		   s.min_logical_writes,
		   s.max_logical_writes,
		   s.total_logical_reads,
		   s.last_logical_reads,
		   s.min_logical_reads,
		   s.max_logical_reads,
		   s.total_elapsed_time,
		   s.last_elapsed_time,
		   s.min_elapsed_time,
		   s.max_elapsed_time  
	        
	FROM sys.dm_exec_procedure_stats AS s 
	WHERE s.database_id NOT IN
	                           (
	                             DB_ID('master'),
								 DB_ID(N'tempdb'),
								 DB_ID(N'model'), 
								 32767 -- RESOURCE db
								 
							 ) ;
   ;

IF XACT_STATE() = 1 
	COMMIT TRAN;

END TRY 
BEGIN CATCH 

IF XACT_STATE() <> 0 
	ROLLBACK TRAN; 

EXEC dbo.RethrowError ; 

END CATCH; 