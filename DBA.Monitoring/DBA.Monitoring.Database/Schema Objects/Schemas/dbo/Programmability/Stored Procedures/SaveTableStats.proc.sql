/*
Procedure for saving table stats 
*/
CREATE PROCEDURE [dbo].[SaveTableStats]
AS
SET NOCOUNT ON; 


DECLARE @counter_snapshot_id INT ; 

--Getting snapshot ID 
EXEC dbo.RegisterCounterSnapshot 
										@counter_snapshot_type_id = 4 ,  -- "Table Stats"
										@counter_snapshot_id = @counter_snapshot_id OUTPUT ; 

DECLARE @database_id SMALLINT;

DECLARE @str NVARCHAR(MAX);
DECLARE @param_str NVARCHAR(1000); 

SET @param_str = N'@counter_snapshot_id INT'; 

DECLARE @cur CURSOR ;  -- loop throught databases 
SET @cur = CURSOR STATIC FOR 
SELECT 
       d.database_id      
FROM sys.databases AS d
WHERE
		  d.name NOT IN ('master', N'tempdb', N'model') -- excluding system databases
	  AND d.[state] = CAST(0 AS TINYINT) -- "online"
	  AND d.user_access = CAST(0 AS TINYINT) -- "multi_user"  ;

OPEN @cur ;
FETCH NEXT FROM @cur INTO @database_id; 
WHILE @@FETCH_STATUS = 0 BEGIN 
    
	SET @str = N'USE ' + QUOTENAME(DB_NAME(@database_id)) + N'; ' +
	N'	    
		INSERT INTO ' + QUOTENAME(DB_NAME(DB_ID())) + N'.dbo.TableStats WITH (TABLOCKX) 
																						   (
																							 counter_snapshot_id, 
																							 database_id, 
																							 [object_id],
																							 [index_id],
																							 [partition_number], 
																							 [rows], 
																							 [SizeMb]

																						   )

	    SELECT 
		       @counter_snapshot_id, 
		       DB_ID(), 
			   p.[object_id],
			   p.index_id,
			   p.partition_number,
			   p.[rows], 
			   CAST(q.total_pages * 8 / 1024.00 AS DECIMAL(19, 2))  
       
		FROM sys.partitions AS p 
		JOIN 
			 ( 
				SELECT
						au.container_id, 
					   SUM(au.total_pages) AS [total_pages]
				FROM sys.allocation_units au
				GROUP BY au.container_id 
			 ) AS q 
		   ON p.hobt_id = q.container_id   
 
		 JOIN sys.objects AS o 
		   ON o.[object_id] = p.[object_id] 
   
		WHERE o.[type] IN (N''U'', ''V'') 
		   AND 
			  p.[rows] > 0 ' ; 
      
	  EXEC sys.sp_executesql
	                              @stmt = @str, 
								  @params = @param_str, 
								  @counter_snapshot_id = @counter_snapshot_id ; 


	FETCH NEXT FROM @cur INTO @database_id; 
END; 

CLOSE @cur; 
DEALLOCATE @cur; 

