create table [dbo].[MonitoringRun] (
	[MonitoringRunID]	bigint identity(1,1)	not null,
	[RunType]			nvarchar(100)			not null,
	[ServerName]		sysname					not null constraint [DF_MonitoringRun_ServerName] default (@@servername),
	[StartTime]			datetime2(0)			not null constraint [DF_MonitoringRun_StartTime] default (sysdatetime()),
	[EndTime]			datetime2(0)			null,
	[Status]			nvarchar(30)			not null constraint [DF_MonitoringRun_Status] default (N'Running'),
	[ErrorMessage]		nvarchar(max)			null,

constraint [PK_MonitoringRun_MonitoringRunID] primary key clustered ( [MonitoringRunID] )
)
go