CREATE TABLE [dbo].[FileStats] (
	[counter_snapshot_id]   INT      NOT NULL,
	[database_id]						SMALLINT NOT NULL,
	[file_id]								SMALLINT NOT NULL,
	[sample_ms]             BIGINT NOT NULL,
	[num_of_reads]          BIGINT NOT NULL,
	[num_of_bytes_read]     BIGINT NOT NULL,
	[io_stall_read_ms]      BIGINT NOT NULL,
	[num_of_writes]         BIGINT NOT NULL,
	[num_of_bytes_written]  BIGINT NOT NULL,
	[io_stall_write_ms]     BIGINT NOT NULL,
	[io_stall]              BIGINT NOT NULL,
	[size_on_disk_bytes]		BIGINT NOT NULL,

	CONSTRAINT [PK_FileStats_counter_snapshot_id_database_id_file_id] PRIMARY KEY ( [counter_snapshot_id], [database_id], [file_id] ),
	CONSTRAINT [FK_FileStats_counter_snapshot_id]
		FOREIGN KEY ( [counter_snapshot_id] )
		REFERENCES CounterSnapshots ( [counter_snapshot_id] )	
);
