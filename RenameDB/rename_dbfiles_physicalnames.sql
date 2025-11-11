:setvar DBName "LearnJoins"
:setvar DataFileName "LearnJoins"
:setvar DataFileNameNew "LearnJoins1"
:setvar DBLogFileName "LearnJoins_log"
:setvar DBLogFileNameNew "LearnJoins_log1"


/* Rename Logical Names of DB Files */
use [master]

alter database [$(DBName)]
set single_user with rollback immediate
go

alter database [$(DBName)]
modify file (name=[$(DataFileName)], newname=[$(DataFileNameNew)] )
go

alter database [$(DBName)]
modify file (name=[$(DBLogFileName)], newname=[$(DBLogFileNameNew)])


use [master]
go 

exec master.dbo.sp_detach_db @dbname = N'TestDB'
go

use [master]
go

sp_configure 'show advanced options', 1
reconfigure with override
go 
sp_configure 'xp_cmdshell', 1
reconfigure with override
go

use [master]
go

exec xp_cmdshell 'rename "N:\MSSQLDATA\DBA\TestDB\TestDB_Primary_1.mdf", "Primary.mdf"'
go
exec xp_cmdshell 'rename "N:\MSSQLDATA\DBA\TestDB\TestDB_Log.ldf", "Log.ldf"'
go
exec xp_cmdshell 'rename "N:\MSSQLDATA\DBA\TestDB\TestDB_Data.ndf", "Data.ndf"'
go
exec xp_cmdshell 'rename "N:\MSSQLDATA\DBA\TestDB\TestDB_Index.ndf", "Index.ndf"'
go

use [master]
go
sp_configure 'xp_cmdshell', 0
reconfigure with override
go

sp_configure 'show advanced options', 0
reconfigure with override
go


use [master]
go


create database [TestDB] on
(filename = N'N:\MSSQLDATA\DBA\TestDB\Primary.mdf'),
(filename = N'N:\MSSQLDATA\DBA\TestDB\Log.ldf'),
(filename = N'N:\MSSQLDATA\DBA\TestDB\Data.ndf'),
(filename = N'N:\MSSQLDATA\DBA\TestDB\Index.ndf')
for attach
go

