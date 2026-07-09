CREATE TABLE [dbo].[WaitStats] (
	[counter_snapshot_id]    INT           NOT NULL, 
	[wait_type]              NVARCHAR(200) NOT NULL,
	[waiting_tasks_count]    BIGINT        NOT NULL, 
	[wait_time_ms]           BIGINT        NOT NULL,
	[max_wait_time_ms]       BIGINT        NOT NULL, 
	[signal_wait_time_ms]    BIGINT        NOT NULL,

	CONSTRAINT [PK_WaitStats_counter_snapshot_id_wait_type] PRIMARY KEY ( [counter_snapshot_id], [wait_type] ),
	CONSTRAINT [FK_WaitStats_counter_snapshot_id] 
		FOREIGN KEY ([counter_snapshot_id])
		REFERENCES [dbo].[CounterSnapshots] ( [counter_snapshot_id] )	
);
