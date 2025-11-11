set tran isolation level read uncommitted
select
 [Table] = object_name(object_id),
 [Rows] = sum([row_count])
from sys.dm_db_partition_stats
--where object_id = object_id('MoneyTransaction')
group by object_name(object_id)
order by sum([row_count]) desc
