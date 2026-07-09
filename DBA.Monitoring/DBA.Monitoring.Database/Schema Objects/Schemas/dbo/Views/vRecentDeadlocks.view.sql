create view [dbo].[vRecentDeadlocks]
as
select
	dl.[DeadlockLogID],
	dl.[CaptureTime],

	[EventType] = dl.[DeadlockGraph].value(
		'(/*[local-name() = "EVENT_INSTANCE"]/*[local-name() = "EventType"]/text())[1]',
		'nvarchar(128)'
	),

	[PostTime] = dl.[DeadlockGraph].value(
		'(/*[local-name() = "EVENT_INSTANCE"]/*[local-name() = "PostTime"]/text())[1]',
		'datetime2(2)'
	),

	[SPID] = dl.[DeadlockGraph].value(
		'(/*[local-name() = "EVENT_INSTANCE"]/*[local-name() = "SPID"]/text())[1]',
		'int'
	),

	[LoginName] = dl.[DeadlockGraph].value(
		'(/*[local-name() = "EVENT_INSTANCE"]/*[local-name() = "LoginName"]/text())[1]',
		'nvarchar(256)'
	),

	[ServerName] = dl.[DeadlockGraph].value(
		'(/*[local-name() = "EVENT_INSTANCE"]/*[local-name() = "ServerName"]/text())[1]',
		'nvarchar(256)'
	),

	[VictimProcessID] = nullif(
		dl.[DeadlockGraph].value(
			'(//*[local-name() = "deadlock"]/@victim)[1]',
			'nvarchar(100)'
		),
		N''
	),

	[ProcessCount] = dl.[DeadlockGraph].value(
		'count(//*[local-name() = "process-list"]/*[local-name() = "process"])',
		'int'
	),

	[ResourceCount] = dl.[DeadlockGraph].value(
		'count(//*[local-name() = "resource-list"]/*)',
		'int'
	),

	dl.[DeadlockGraph]
from [dbo].[DeadlockLog] as dl
go