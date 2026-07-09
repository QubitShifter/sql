create table [dbo].[WaitStatsSnapshot] (
	[SPID] int not null,
	[Timestamp] datetime2(2) not null constraint [DF_WaitStatsSnapshot_Timestamp] default (sysdatetime()),
	[Context] varchar(64) not null,
	[WaitType] sysname not null,
	[WaitTime] bigint not null,
	[NbrWaits] bigint not null,

	constraint [PK_WaitStatsSnapshot_SPID_WaitType_Timestamp]
		primary key nonclustered (
			[SPID],
			[WaitType],
			[Timestamp]
		)
)
go

create clustered index [IX_WaitStatsSnapshot_Timestamp]
	on [dbo].[WaitStatsSnapshot] (
		[Timestamp]
	)
go