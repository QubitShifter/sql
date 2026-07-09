create queue [dbo].[DeadlockNotificationQueue]
with
	status = on,
	retention = off,
	activation (
		status = on,
		procedure_name = [dbo].[ProcessDeadlockMessages],
		max_queue_readers = 1,
		execute as self
	)
go