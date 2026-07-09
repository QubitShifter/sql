CREATE PROCEDURE [dbo].[SaveTempDBStats]
AS
SET NOCOUNT ON; 

DECLARE @counter_snapshot_id INT; 


BEGIN TRY 

	BEGIN TRAN;

	--Getting snapshot ID 
	EXEC dbo.RegisterCounterSnapshot 
			 @counter_snapshot_type_id = 5 ,  -- "TempDB Stats"
			 @counter_snapshot_id = @counter_snapshot_id OUTPUT ; 


	INSERT INTO dbo.TempDBStats 
								(
								  counter_snapshot_id,
								  [file_id], 
								  unallocated_extent_page_count,
								  version_store_reserved_page_count,
								  user_object_reserved_page_count,
								  internal_object_reserved_page_count,
								  mixed_extent_page_count
								)

	SELECT 
		   @counter_snapshot_id, 
		   u.[file_id], 	       
		   u.unallocated_extent_page_count,
		   u.version_store_reserved_page_count,
		   u.user_object_reserved_page_count,
		   u.internal_object_reserved_page_count,
		   u.mixed_extent_page_count

	FROM   sys.dm_db_file_space_usage AS u 
	OPTION (LOOP JOIN) -- this prevents from page locking table CounterSnapshot by FK

	IF XACT_STATE() = 1 
		COMMIT TRAN; 

END TRY 
BEGIN CATCH 

	IF XACT_STATE() <> 0 
		ROLLBACK TRAN; 
    
	EXEC dbo.RethrowError ;

END CATCH;  				
