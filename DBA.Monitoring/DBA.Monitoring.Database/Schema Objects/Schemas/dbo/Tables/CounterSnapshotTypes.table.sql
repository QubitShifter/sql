CREATE TABLE [dbo].[CounterSnapshotTypes] (
	[counter_snapshot_type_id]   TINYINT       NOT NULL, 
	[counter_snapshot_type_name] NVARCHAR(200) NOT NULL,

	CONSTRAINT [PK_CounterSnapshotTypes] PRIMARY KEY ( [counter_snapshot_type_id] )
);
