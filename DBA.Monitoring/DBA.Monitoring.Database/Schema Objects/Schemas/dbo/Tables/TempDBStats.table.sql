CREATE TABLE [dbo].[TempDBStats] (
	[counter_snapshot_id]                 INT  NOT NULL, 
	[file_id]                             INT NOT NULL, 
	[unallocated_extent_page_count]       BIGINT NOT NULL,
	[version_store_reserved_page_count]   BIGINT  NULL,
  [user_object_reserved_page_count]     BIGINT  NULL,
	[internal_object_reserved_page_count] BIGINT  NULL,
  [mixed_extent_page_count]             BIGINT NOT NULL,

	CONSTRAINT [PK_TempDBStats_counter_snapshot_id_file_id] PRIMARY KEY ( [counter_snapshot_id], [file_id] ),
	CONSTRAINT [FK_TempDBStats_counter_snapshot_id] 
		FOREIGN KEY ( [counter_snapshot_id] )
		REFERENCES  [dbo].[CounterSnapshots] ( [counter_snapshot_id] )
)
