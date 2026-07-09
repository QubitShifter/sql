create table [dbo].[DeadlockLog] (
	[DeadlockLogID] bigint identity(1,1) not null,
	[CaptureTime] datetime2(2) not null constraint [DF_DeadlockLog_CaptureTime] default (sysdatetime()),
	[DeadlockGraph] xml not null,

	constraint [PK_DeadlockLog]
		primary key nonclustered (
			[DeadlockLogID]
		)
)
go

create clustered index [IX_DeadlockLog_CaptureTime_DeadlockLogID]
	on [dbo].[DeadlockLog] (
		[CaptureTime],
		[DeadlockLogID]
	)
go