:setvar DBName "LearnJoins3"
:setvar DBNewName "LearnJoins"

use [master]
go

alter database [$(DBName)]
set single_user with rollback immediate
go

exec master..sp_renamedb [$(DBName)], [$(DBNewName)]
go

alter database [$(DBNewName)]
set multi_user with rollback immediate
go
