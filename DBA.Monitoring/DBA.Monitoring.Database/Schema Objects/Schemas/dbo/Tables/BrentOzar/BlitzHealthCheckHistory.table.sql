create table [dbo].[BlitzHealthCheckHistory]
(
    [ID] int identity(1,1) not null,

    [ServerName] nvarchar(128) null,
    [CheckDate] datetimeoffset null,

    [Priority] tinyint null,
    [FindingsGroup] varchar(50) null,
    [Finding] varchar(200) null,
    [DatabaseName] nvarchar(128) null,

    [URL] varchar(200) null,
    [Details] nvarchar(4000) null,

    [QueryPlan] nvarchar(max) null,
    [QueryPlanFiltered] nvarchar(max) null,

    [CheckID] int null,

    constraint [PK_BlitzHealthCheckHistory]
        primary key clustered ([ID] asc)
);
go

create index [IX_BlitzHealthCheckHistory_CheckDate]
on [dbo].[BlitzHealthCheckHistory] ([CheckDate] desc);
go

create index [IX_BlitzHealthCheckHistory_Priority_CheckDate]
on [dbo].[BlitzHealthCheckHistory] ([Priority], [CheckDate] desc)
include
(
    [FindingsGroup],
    [Finding],
    [DatabaseName],
    [Details],
    [CheckID]
);
go

create index [IX_BlitzHealthCheckHistory_CheckID_CheckDate]
on [dbo].[BlitzHealthCheckHistory] ([CheckID], [CheckDate] desc);
go