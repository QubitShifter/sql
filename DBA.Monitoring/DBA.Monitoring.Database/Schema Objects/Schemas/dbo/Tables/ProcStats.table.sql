CREATE TABLE [dbo].[ProcStats] (
	[counter_snapshot_id]		INT NOT NULL, 
	[database_id]						INT NOT NULL,
	[plan_handle]						VARBINARY(64) NOT NULL, 
	[object_id]							INT NOT NULL ,
	[last_execution_time]		DATETIME NOT NULL,
	[execution_count]				BIGINT NOT NULL ,
	[total_worker_time]			BIGINT NOT NULL,
	[last_worker_time]			BIGINT NOT NULL ,
	[min_worker_time]				BIGINT NOT NULL,
	[max_worker_time]				BIGINT NOT NULL,
	[total_physical_reads]	BIGINT NOT NULL,
	[last_physical_reads]		BIGINT NOT NULL,
	[min_physical_reads]		BIGINT NOT NULL,
	[max_physical_reads]		BIGINT NOT NULL,
	[total_logical_writes]	BIGINT NOT NULL,
	[last_logical_writes]		BIGINT NOT NULL,
	[min_logical_writes]		BIGINT NOT NULL,
	[max_logical_writes]		BIGINT NOT NULL,
	[total_logical_reads]		BIGINT NOT NULL,
	[last_logical_reads]		BIGINT NOT NULL,
	[min_logical_reads]			BIGINT NOT NULL,
	[max_logical_reads]			BIGINT NOT NULL,
	[total_elapsed_time]		BIGINT NOT NULL,
	[last_elapsed_time]			BIGINT NOT NULL,
	[min_elapsed_time]			BIGINT NOT NULL,
	[max_elapsed_time]			BIGINT NOT NULL,

	CONSTRAINT [PK_ProcStats_counter_snapshot_id_database_id_plan_handle] PRIMARY KEY ( [counter_snapshot_id], [database_id], [plan_handle] ),
	CONSTRAINT [FK_ProcStats_counter_snapshot_id] 
		FOREIGN KEY ( [counter_snapshot_id] )
		REFERENCES dbo.CounterSnapshots( [counter_snapshot_id] )	
);
