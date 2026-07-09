/*
Procedure for saving wiat stats 
*/
CREATE PROCEDURE [dbo].[SaveWaitStats]
AS
SET NOCOUNT ON; 

DECLARE @counter_snapshot_id INT;

BEGIN TRY 

	BEGIN TRAN;

	--Getting snapshot ID 
	EXEC dbo.RegisterCounterSnapshot 
										   @counter_snapshot_type_id = 1 ,  -- "Wait Stats"
										   @counter_snapshot_id = @counter_snapshot_id OUTPUT ; 


	INSERT INTO dbo.WaitStats WITH (TABLOCKX)
											  (
												counter_snapshot_id,
												wait_type,
												waiting_tasks_count,
												wait_time_ms, 
												max_wait_time_ms, 
												signal_wait_time_ms	
											 )

	SELECT 
		   @counter_snapshot_id, 
		   d.wait_type,
		   d.waiting_tasks_count,
		   d.wait_time_ms,
		   d.max_wait_time_ms,
		   d.signal_wait_time_ms
       
	FROM sys.dm_os_wait_stats AS d 
	WHERE d.waiting_tasks_count > 0
	  AND d.wait_type NOT IN 
							   (
                           			N'CLR_SEMAPHORE', N'LAZYWRITER_SLEEP', N'RESOURCE_QUEUE', N'SLEEP_TASK',
									N'SLEEP_SYSTEMTASK', N'SQLTRACE_BUFFER_FLUSH', N'WAITFOR', N'LOGMGR_QUEUE',
									N'CHECKPOINT_QUEUE', N'REQUEST_FOR_DEADLOCK_SEARCH', N'XE_TIMER_EVENT', N'BROKER_TO_FLUSH',
									N'BROKER_TASK_STOP', N'CLR_MANUAL_EVENT', N'CLR_AUTO_EVENT', N'DISPATCHER_QUEUE_SEMAPHORE',
									N'FT_IFTS_SCHEDULER_IDLE_WAIT', N'XE_DISPATCHER_WAIT', N'XE_DISPATCHER_JOIN', N'BROKER_EVENTHANDLER',
									N'TRACEWRITE', N'FT_IFTSHC_MUTEX', N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP',
									N'BROKER_RECEIVE_WAITFOR', N'ONDEMAND_TASK_QUEUE', N'DBMIRROR_EVENTS_QUEUE',
									N'DBMIRRORING_CMD', N'BROKER_TRANSMITTER', N'SQLTRACE_WAIT_ENTRIES',
									N'SLEEP_BPOOL_FLUSH', N'SQLTRACE_LOCK'                     
							   ); 	
						   

	IF XACT_STATE() = 1 
		COMMIT TRAN; 

END TRY 
BEGIN CATCH 

	IF XACT_STATE() <> 0 
		ROLLBACK TRAN; 
    
	EXEC dbo.RethrowError ;

END CATCH;  						    