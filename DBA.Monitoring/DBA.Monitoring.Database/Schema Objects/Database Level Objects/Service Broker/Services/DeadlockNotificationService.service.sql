create service [DeadlockNotificationService]
	on queue [dbo].[DeadlockNotificationQueue] (
		[http://schemas.microsoft.com/SQL/Notifications/PostEventNotification]
	)
go