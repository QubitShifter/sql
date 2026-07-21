create table [dbo].[DeadlockLog]
(
    [DeadlockLogID] bigint identity(1,1) not null,
    [CaptureTime] datetime2(3) not null
        constraint [DF_DeadlockLog_CaptureTime]
        default (sysdatetime()),

    [DeadlockGraph] xml not null,

    constraint [PK_DeadlockLog]
        primary key clustered ([DeadlockLogID] asc)
);
go

create index [IX_DeadlockLog_CaptureTime]
on [dbo].[DeadlockLog] ([CaptureTime] desc);
go