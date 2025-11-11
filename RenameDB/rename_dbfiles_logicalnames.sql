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