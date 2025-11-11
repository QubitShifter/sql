create procedure dbo.[sp_DropSnapShotsOlderThan.proc](
	@DBName		nvarchar(32),
	@DropPeriod	int
)

as  
set nocount on;  

declare @DropQuery nvarchar(max) = ''

select 
	@DropQuery = concat(@DropQuery, 'drop database ',quotename( S.[name] ),';' , char(13), char(10) )
from sys.databases as S -- snapshot DB
	join sys.databases as D on S.[source_database_id] = D.[database_id] 	
where S.[create_date] >= cast(dateadd(day,-@DropPeriod, getdate()) as date)
	and exists (
		select *  
		from sys.databases as SN
		where SN.[create_date] >= cast(getdate() as date)
			and D.[name] = @DBName
			and SN.[source_database_id] = D.[database_id] )

select (@DropQuery)
end