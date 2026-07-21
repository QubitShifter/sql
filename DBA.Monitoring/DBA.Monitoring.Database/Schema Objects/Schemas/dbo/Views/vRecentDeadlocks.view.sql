create view [dbo].[vRecentDeadlocks]
as
with DeadlockSource as
(
    select
        [DeadlockLogID],
        [CaptureTime],
        [DeadlockGraph]
    from [dbo].[DeadlockLog]
)
select
    [DeadlockLogID] =
        [DeadlockLogID],

    [CaptureTime] =
        [CaptureTime],

    [EventType] =
        [DeadlockGraph].value(
            '(/*[local-name() = "EVENT_INSTANCE"]/*[local-name() = "EventType"]/text())[1]',
            'nvarchar(128)'
        ),

    [PostTime] =
        try_convert
        (
            datetime2(3),
            [DeadlockGraph].value(
                '(/*[local-name() = "EVENT_INSTANCE"]/*[local-name() = "PostTime"]/text())[1]',
                'nvarchar(50)'
            )
        ),

    [VictimProcessID] =
        nullif
        (
            [DeadlockGraph].value(
                '(//*[local-name() = "deadlock"]/@victim)[1]',
                'nvarchar(100)'
            ),
            N''
        ),

    [ProcessCount] =
        [DeadlockGraph].value(
            'count(//*[local-name() = "process-list"]/*[local-name() = "process"])',
            'int'
        ),

    [ResourceCount] =
        [DeadlockGraph].value(
            'count(//*[local-name() = "resource-list"]/*)',
            'int'
        )
from DeadlockSource;
go