set tran isolation level read uncommitted
SELECT 
	[name], 
	[create_date], 
	[modify_date] 
FROM sys.objects --where [name] = 'App.trg_SnGBeastPointsKOOL_ins'
--FROM sys.objects --where [name] = 'QueryNotificationErrorsQueue'
where [create_date] > '2017-06-28 00:00:00.000'
where [name] = 'App.trg_SnGBeastPointsKOOL_ins'
GO


declare @SQLEdition NVARCHAR(50)
set @SQLEdition = CONVERT(NVARCHAR(50),(select SERVERPROPERTY('Edition') AS Edition))

if (@SQLEdition like 'Ent%')
print 'OK'
else print 'NOT OK'
go
--select @SQLEdition

declare @SQLEdition NVARCHAR(50)
set @SQLEdition = CONVERT(NVARCHAR(50),(select SERVERPROPERTY('Edition') AS Edition))

if (@SQLEdition like 'Web%')
print 'OK'
else print 'NOT OK'
go
--select @SQLEdition


set tran isolation level read uncommitted
waitfor time '00:11:01'
go 

print getdate()