
set transaction isolation level read uncommitted;

select
	[TABLE_CATALOG],
	[TABLE_SCHEMA],
	[TABLE_NAME]
into
	[#TableDetails]
from INFORMATION_SCHEMA.tables
where [TABLE_TYPE] = 'BASE TABLE';

declare
	@DynamicSQL  nvarchar(max);

set @DynamicSQL = '';

select
	@DynamicSQL = @DynamicSQL+char(10)+' select count_big(*)  as [TableName: '+[TABLE_CATALOG]+'.'+[TABLE_SCHEMA]+'. '+[TABLE_NAME]++'] from '+quotename([TABLE_CATALOG])+'.'+quotename([TABLE_SCHEMA])+'. '+quotename([TABLE_NAME])
from #TableDetails;
--EXECUTE sp_executesql @DynamicSQL                        

declare
	@StartOffset  int;

declare
	@Length  int;

set @StartOffset = 0;

set @Length = 4000;

while(@StartOffset < len(@DynamicSQL))
	begin
		print substring(@DynamicSQL, @StartOffset, @Length);
		set @StartOffset = @StartOffset + @Length;
	end;

print substring(@DynamicSQL, @StartOffset, @Length);

drop table #TableDetails;