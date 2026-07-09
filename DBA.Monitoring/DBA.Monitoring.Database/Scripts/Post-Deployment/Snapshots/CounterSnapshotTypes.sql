merge [dbo].[CounterSnapshotTypes] as TGT
using (
	select
		[counter_snapshot_type_id] = 1,
		[counter_snapshot_type_name] = N'Wait stats'

	union all

	select
		[counter_snapshot_type_id] = 2,
		[counter_snapshot_type_name] = N'Procedure stats'

	union all

	select
		[counter_snapshot_type_id] = 3,
		[counter_snapshot_type_name] = N'File stats'

	union all

	select
		[counter_snapshot_type_id] = 4,
		[counter_snapshot_type_name] = N'Table stats'

	union all

	select
		[counter_snapshot_type_id] = 5,
		[counter_snapshot_type_name] = N'TempDB stats'
) as SRC
	on SRC.[counter_snapshot_type_id] = TGT.[counter_snapshot_type_id]
when matched then
	update set
		TGT.[counter_snapshot_type_name] = SRC.[counter_snapshot_type_name]
when not matched by target then
	insert (
		[counter_snapshot_type_id],
		[counter_snapshot_type_name]
	)
	values (
		SRC.[counter_snapshot_type_id],
		SRC.[counter_snapshot_type_name]
	);
go