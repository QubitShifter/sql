create view [dbo].[vRecentOlaErrors]
as
select
	oclh.[ServerName],
	oclh.[CaptureTime],
	oclh.[SourceCommandLogID],
	oclh.[DatabaseName],
	oclh.[ObjectName],
	oclh.[CommandType],
	oclh.[StartTime],
	oclh.[EndTime],
	oclh.[ErrorNumber],
	oclh.[ErrorMessage],
	oclh.[Command]
from [dbo].[OlaCommandLogHistory] as oclh
where isnull(oclh.[ErrorNumber], 0) <> 0
   or oclh.[ErrorMessage] is not null
go