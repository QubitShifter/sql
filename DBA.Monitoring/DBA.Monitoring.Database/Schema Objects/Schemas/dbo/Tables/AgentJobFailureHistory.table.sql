create table [dbo].[AgentJobFailureHistory] (
	[AgentJobFailureHistoryID]	bigint identity(1,1)	not null,
	[MonitoringRunID]			bigint					not null,
	[CaptureTime]				datetime2(0)			not null constraint [DF_AgentJobFailureHistory_CaptureTime] default (sysdatetime()),
	[ServerName]				sysname					not null constraint [DF_AgentJobFailureHistory_ServerName] default (@@servername),

	[SourceJobID]				uniqueidentifier		not null,
	[SourceInstanceID]			int						not null,

	[JobName]					sysname					not null,
	[StepID]					int						not null,
	[StepName]					sysname					null,
	[RunDateTime]				datetime				null,
	[RunDurationSeconds]		int						null,
	[RunStatus]					int						not null,
	[RunStatusDescription]		nvarchar(30)			not null,
	[Message]					nvarchar(4000)			null

constraint [PK_AgentJobFailureHistory_AgentJobFailureHistoryID] primary key clustered ( [AgentJobFailureHistoryID] ),
constraint [FK_AgentJobFailureHistory_MonitoringRun_MonitoringRunID] foreign key ( [MonitoringRunID] )
	references [dbo].[MonitoringRun] ( [MonitoringRunID] ),
constraint [UQ_AgentJobFailureHistory_SourceJobID_SourceInstanceID] unique ( [SourceJobID], [SourceInstanceID] )
);
go

create index [IX_AgentJobFailureHistory_CaptureTime_JobName]
	on [dbo].[AgentJobFailureHistory] ([CaptureTime], [JobName])
go