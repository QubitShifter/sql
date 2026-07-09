CREATE PROCEDURE [dbo].[RegisterCounterSnapshot]
	@counter_snapshot_type_id TINYINT,  -- counter_snapshot_type 
	@counter_snapshot_id      INT = NULL  OUTPUT 
AS
SET NOCOUNT ON; 

INSERT INTO dbo.CounterSnapshots 
                                  (
								     datestamp,
									 counter_snapshot_type_id
								  )
VALUES 
       (
	     GETDATE(), 
		 @counter_snapshot_type_id
	   ); 

SET @counter_snapshot_id = SCOPE_IDENTITY(); 