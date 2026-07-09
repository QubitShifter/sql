create view [dbo].[vMonitorFileStatsDelta]
as
with [FileStatsWithPrevious] as (
	select
		cs.[counter_snapshot_id],
		cs.[datestamp],
		fs.[database_id],
		fs.[file_id],
		fs.[sample_ms],
		fs.[num_of_reads],
		fs.[num_of_bytes_read],
		fs.[io_stall_read_ms],
		fs.[num_of_writes],
		fs.[num_of_bytes_written],
		fs.[io_stall_write_ms],
		fs.[io_stall],
		fs.[size_on_disk_bytes],

		[previous_counter_snapshot_id] = lag(cs.[counter_snapshot_id]) over (
			partition by fs.[database_id], fs.[file_id]
			order by cs.[counter_snapshot_id]
		),

		[previous_datestamp] = lag(cs.[datestamp]) over (
			partition by fs.[database_id], fs.[file_id]
			order by cs.[counter_snapshot_id]
		),

		[previous_num_of_reads] = lag(fs.[num_of_reads]) over (
			partition by fs.[database_id], fs.[file_id]
			order by cs.[counter_snapshot_id]
		),

		[previous_num_of_bytes_read] = lag(fs.[num_of_bytes_read]) over (
			partition by fs.[database_id], fs.[file_id]
			order by cs.[counter_snapshot_id]
		),

		[previous_io_stall_read_ms] = lag(fs.[io_stall_read_ms]) over (
			partition by fs.[database_id], fs.[file_id]
			order by cs.[counter_snapshot_id]
		),

		[previous_num_of_writes] = lag(fs.[num_of_writes]) over (
			partition by fs.[database_id], fs.[file_id]
			order by cs.[counter_snapshot_id]
		),

		[previous_num_of_bytes_written] = lag(fs.[num_of_bytes_written]) over (
			partition by fs.[database_id], fs.[file_id]
			order by cs.[counter_snapshot_id]
		),

		[previous_io_stall_write_ms] = lag(fs.[io_stall_write_ms]) over (
			partition by fs.[database_id], fs.[file_id]
			order by cs.[counter_snapshot_id]
		),

		[previous_io_stall] = lag(fs.[io_stall]) over (
			partition by fs.[database_id], fs.[file_id]
			order by cs.[counter_snapshot_id]
		)
	from [dbo].[FileStats] as fs
	inner join [dbo].[CounterSnapshots] as cs
		on cs.[counter_snapshot_id] = fs.[counter_snapshot_id]
	where cs.[counter_snapshot_type_id] = 3
)
select
	fsp.[counter_snapshot_id],
	fsp.[datestamp],
	fsp.[previous_counter_snapshot_id],
	fsp.[previous_datestamp],
	fsp.[database_id],
	[database_name] = db_name(fsp.[database_id]),
	fsp.[file_id],
	[file_name] = mf.[name],
	[file_type_desc] = mf.[type_desc],
	[physical_name] = mf.[physical_name],

	[reads_delta] = fsp.[num_of_reads] - fsp.[previous_num_of_reads],
	[bytes_read_delta] = fsp.[num_of_bytes_read] - fsp.[previous_num_of_bytes_read],
	[read_mb_delta] = cast((fsp.[num_of_bytes_read] - fsp.[previous_num_of_bytes_read]) / 1048576.0 as decimal(19, 2)),
	[io_stall_read_ms_delta] = fsp.[io_stall_read_ms] - fsp.[previous_io_stall_read_ms],

	[writes_delta] = fsp.[num_of_writes] - fsp.[previous_num_of_writes],
	[bytes_written_delta] = fsp.[num_of_bytes_written] - fsp.[previous_num_of_bytes_written],
	[written_mb_delta] = cast((fsp.[num_of_bytes_written] - fsp.[previous_num_of_bytes_written]) / 1048576.0 as decimal(19, 2)),
	[io_stall_write_ms_delta] = fsp.[io_stall_write_ms] - fsp.[previous_io_stall_write_ms],

	[io_stall_ms_delta] = fsp.[io_stall] - fsp.[previous_io_stall],

	[avg_read_latency_ms] = case
		when fsp.[num_of_reads] - fsp.[previous_num_of_reads] > 0
			then cast(cast(fsp.[io_stall_read_ms] - fsp.[previous_io_stall_read_ms] as decimal(19, 2)) /
				(fsp.[num_of_reads] - fsp.[previous_num_of_reads]) as decimal(19, 2))
		else null
	end,

	[avg_write_latency_ms] = case
		when fsp.[num_of_writes] - fsp.[previous_num_of_writes] > 0
			then cast(cast(fsp.[io_stall_write_ms] - fsp.[previous_io_stall_write_ms] as decimal(19, 2)) /
				(fsp.[num_of_writes] - fsp.[previous_num_of_writes]) as decimal(19, 2))
		else null
	end,

	[size_on_disk_mb] = cast(fsp.[size_on_disk_bytes] / 1048576.0 as decimal(19, 2))
from [FileStatsWithPrevious] as fsp
left join [sys].[master_files] as mf
	on mf.[database_id] = fsp.[database_id]
	and mf.[file_id] = fsp.[file_id]
where fsp.[previous_counter_snapshot_id] is not null
  and fsp.[num_of_reads] >= fsp.[previous_num_of_reads]
  and fsp.[num_of_writes] >= fsp.[previous_num_of_writes]
go