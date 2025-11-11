declare
 @DBInfo table (
 [ServerName]        varchar(100),
 [DatabaseName]       varchar(100),
 [FileSizeMB]                  int,
 [LogicalFileName]         sysname,
 [PhysicalFileName]  nvarchar(520),
 [Status]                  sysname,
 [Updateability]           sysname,
 [RecoveryMode]            sysname,
 [FreeSpaceMB]                 int,
 [FreeSpacePct]         varchar(7),
 [FreeSpacePages]              int,
 [PollDate]               datetime );
declare
 @command  varchar(5000);
select
 @command = 'Use ['+'?'+'] SELECT  
@@servername as ServerName,  
'+''''+'?'+''''+' AS DatabaseName,  
CAST(sysfiles.size/128.0 AS int) AS FileSize,  
sysfiles.name AS LogicalFileName, sysfiles.filename AS PhysicalFileName,  
CONVERT(sysname,DatabasePropertyEx(''?'',''Status'')) AS Status,  
CONVERT(sysname,DatabasePropertyEx(''?'',''Updateability'')) AS Updateability,  
CONVERT(sysname,DatabasePropertyEx(''?'',''Recovery'')) AS RecoveryMode,  
CAST(sysfiles.size/128.0 - CAST(FILEPROPERTY(sysfiles.name, '+''''+'SpaceUsed'+''''+' ) AS int)/128.0 AS int) AS FreeSpaceMB,  
CAST(100 * (CAST (((sysfiles.size/128.0 -CAST(FILEPROPERTY(sysfiles.name,  
'+''''+'SpaceUsed'+''''+' ) AS int)/128.0)/(sysfiles.size/128.0))  
AS decimal(4,2))) AS varchar(8)) + '+''''+'%'+''''+' AS FreeSpacePct,  
GETDATE() as PollDate FROM dbo.sysfiles';
insert into @DBInfo ( ServerName, DatabaseName, FileSizeMB, LogicalFileName, PhysicalFileName, Status, Updateability, RecoveryMode, FreeSpaceMB, FreeSpacePct, PollDate)
exec sys.sp_MSforeachdb @command;
select
 [ServerName],
 [DatabaseName],
 [LogicalFileName],
 [PhysicalFileName],
 [Status],
 [Updateability],
 [RecoveryMode],
 [FileSizeMB],
 [FreeSpaceMB],
 [FreeSpacePct],
 [PollDate]
from @DBInfo
where [DatabaseName] = 'ChatHistory'
order by
 [ServerName],
 [DatabaseName];

