create view [dbo].[vRecentAgentJobFailures]
as
select
	ajfh.[ServerName],
	ajfh.[CaptureTime],
	ajfh.[JobName],
	ajfh.[StepID],
	ajfh.[StepName],
	ajfh.[RunDateTime],
	ajfh.[RunDurationSeconds],
	ajfh.[RunStatusDescription],
	ajfh.[Message]
from [dbo].[AgentJobFailureHistory] as ajfh
where ajfh.[RunDateTime] >= dateadd(day, -7, getdate())
go