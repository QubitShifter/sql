CREATE TABLE [dbo].[CounterSnapshots] (
	[counter_snapshot_id]      INT      NOT NULL IDENTITY(1, 1),  
	[datestamp]                DATETIME NOT NULL, 
	[counter_snapshot_type_id] TINYINT  NOT NULL,

	CONSTRAINT [PK_CounterSnapshot_counter_snapshot_id] PRIMARY KEY ( [counter_snapshot_id] ),
	
	CONSTRAINT [FK_CounterSnapshots_counter_snapshot_type_id] 
		FOREIGN KEY ( [counter_snapshot_type_id] )
		REFERENCES dbo.CounterSnapshotTypes ( [counter_snapshot_type_id] )
)
