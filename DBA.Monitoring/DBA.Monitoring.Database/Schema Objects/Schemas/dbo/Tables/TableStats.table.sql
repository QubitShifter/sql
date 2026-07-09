CREATE TABLE [dbo].[TableStats] (
	[counter_snapshot_id]  INT NOT NULL,
	[database_id]          INT NOT NULL, 
	[object_id]            INT NOT NULL,
	[index_id]             INT NOT NULL,
	[partition_number]     INT NOT NULL,
	[rows]                 BIGINT NOT NULL, 
	[SizeMb]               DECIMAL(19, 2) NOT NULL,

	CONSTRAINT [PK_TableStats] PRIMARY KEY ( [counter_snapshot_id], [database_id], [object_id], [index_id], [partition_number] ),
	CONSTRAINT [FK_TableStats_counter_snapshot_id] 
		FOREIGN KEY ( [counter_snapshot_id] )
		REFERENCES [dbo].[CounterSnapshots] ( [counter_snapshot_id] )	
)

