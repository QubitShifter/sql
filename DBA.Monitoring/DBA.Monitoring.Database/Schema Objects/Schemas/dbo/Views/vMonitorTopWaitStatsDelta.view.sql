create view [dbo].[vMonitorTopWaitStatsDelta]
as
select
	[counter_snapshot_id],
	[datestamp],
	[previous_counter_snapshot_id],
	[previous_datestamp],
	[wait_type],
	[waiting_tasks_delta],
	[wait_time_ms_delta],
	[signal_wait_time_ms_delta],
	[resource_wait_time_ms_delta],
	[avg_wait_time_ms_delta],
	[wait_time_pct],
	[max_wait_time_ms]
from [dbo].[vMonitorWaitStatsDelta]
where [wait_time_ms_delta] > 0
  and [wait_type] not in (
		N'SOS_WORK_DISPATCHER',
		N'LOGMGR_QUEUE',
		N'BROKER_EVENTHANDLER',
		N'BROKER_RECEIVE_WAITFOR',
		N'BROKER_TASK_STOP',
		N'BROKER_TO_FLUSH',
		N'BROKER_TRANSMITTER',
		N'CHECKPOINT_QUEUE',
		N'CHKPT',
		N'CLR_AUTO_EVENT',
		N'CLR_MANUAL_EVENT',
		N'DIRTY_PAGE_POLL',
		N'DISPATCHER_QUEUE_SEMAPHORE',
		N'FT_IFTS_SCHEDULER_IDLE_WAIT',
		N'HADR_FILESTREAM_IOMGR_IOCOMPLETION',
		N'LAZYWRITER_SLEEP',
		N'ONDEMAND_TASK_QUEUE',
		N'QDS_ASYNC_QUEUE',
		N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP',
		N'REQUEST_FOR_DEADLOCK_SEARCH',
		N'RESOURCE_QUEUE',
		N'SLEEP_TASK',
		N'SLEEP_SYSTEMTASK',
		N'SP_SERVER_DIAGNOSTICS_SLEEP',
		N'SQLTRACE_BUFFER_FLUSH',
		N'WAITFOR',
		N'XE_DISPATCHER_WAIT',
		N'XE_TIMER_EVENT'
	)
go