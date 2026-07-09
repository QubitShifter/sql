/*
Procedure for saving database files stats 
*/
CREATE PROCEDURE [dbo].[SaveFileStats]
AS
SET NOCOUNT ON; 

DECLARE  @counter_snapshot_id INT;

BEGIN TRY 

	BEGIN TRAN; 

	--Getting snapshot ID 
	EXEC dbo.RegisterCounterSnapshot 
										@counter_snapshot_type_id = 3 ,  -- "File Stats"
										@counter_snapshot_id = @counter_snapshot_id OUTPUT ; 

					
	INSERT INTO dbo.FileStats WITH(TABLOCKX)  
											  (
											   counter_snapshot_id, 
											   [database_id],
											   [file_id],
											   sample_ms,
											   num_of_reads,
											   num_of_bytes_read,
											   io_stall_read_ms,
											   num_of_writes,
											   num_of_bytes_written,
											   io_stall_write_ms,
											   io_stall,
											   size_on_disk_bytes
											 )			   


	
	SELECT 		 
	           @counter_snapshot_id, 				       
			   f.[database_id],
			   f.[file_id],
			   f.sample_ms,
			   f.num_of_reads,
			   f.num_of_bytes_read,
			   f.io_stall_read_ms,
			   f.num_of_writes,
			   f.num_of_bytes_written,
			   f.io_stall_write_ms,
			   f.io_stall,
			   f.size_on_disk_bytes
	        
	FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS f 
	WHERE f.[database_id] NOT IN (
	                               DB_ID(N'master'),
								   DB_ID(N'model'),
								   32767 -- RESOURCE db  
								  ); 

IF XACT_STATE() = 1 
	COMMIT TRAN;

END TRY 
BEGIN CATCH 

IF XACT_STATE() <> 0 
	ROLLBACK TRAN; 

EXEC dbo.RethrowError ; 

END CATCH; 