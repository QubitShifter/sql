SELECT i.name AS IndexName 
       , ROUND(s.avg_fragmentation_in_percent,2) AS [Fragmentation %] 
FROM sys.dm_db_index_physical_stats(DB_ID('Poker'), 
OBJECT_ID('MoneyTransaction'), NULL, NULL, NULL) s 
INNER JOIN sys.indexes i ON s.[object_id] = i.[object_id] 
    AND s.index_id = i.index_id 