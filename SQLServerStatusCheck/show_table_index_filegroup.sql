select
 object_schema_name([t].object_id) as schema_name,
 [t].[name] as [table_name],
 [i].[index_id],
 [i].[name] as [index_name],
 [p].[partition_number],
 [fg].[name] as filegroup_name,
 FORMAT([p].[rows], '#,###') as [rows]
from sys.tables as t
 join sys.indexes as i on t.object_id = i.object_id
 join sys.partitions as p on i.object_id = p.object_id and i.index_id = p.index_id
 left outer join sys.partition_schemes as ps on i.data_space_id = ps.data_space_id
 left outer join sys.destination_data_spaces as dds on ps.data_space_id = dds.partition_scheme_id and p.partition_number = dds.destination_id
 join sys.filegroups as fg on coalesce(dds.data_space_id, i.data_space_id) = fg.data_space_id
 order by fg.name;