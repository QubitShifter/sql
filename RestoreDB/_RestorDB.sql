/*************************					DB RESTORE SCRIPT			******************************/


-----------------------------------------------------------------------------------------
-----		DECLARE TABLE TO INSERT INFO FROM BACKUP HEADER WITH RESTORE FILELISTONLY		-----

IF OBJECT_ID('#BackupToRestore') IS NOT NULL
DROP TABLE #BackupToRestore
GO

	DECLARE

					@DBName											SYSNAME								,
					@datafile1									NVARCHAR(100)					,
					@datafile2									NVARCHAR(100)					,
					@logfile										NVARCHAR(100)					,
					@bkpfile										NVARCHAR(100)					,
					@bkpfolder									NVARCHAR(25)					,
					@bkpfilename								NVARCHAR(100)					,
					@DBFolderName								NVARCHAR(25)					,
					@NetworkName								NVARCHAR(25)					,
					@DataFilePath								NVARCHAR(25)					,
					@LogFilePath								NVARCHAR(25)					,
					@datafile_path							NVARCHAR(250)					,
					@logfile_path								NVARCHAR(250)					,
					@sqlcmd_filesinfo 					NVARCHAR(1024)					,
					@sqlcmd_dbinfo 							NVARCHAR(1024)

	SET			@DataFilePath			=	'D:\MSSQLDATA\'
	SET			@LogFilePath			=	'D:\MSSQLDATA\'
	SET			@NetworkName			=	'POKER'
	SET			@bkpfolder				=	'D:\MSSQLBACKUPS\'
	SET			@bkpfile					=	'PKR-DB-02_Poker_FULL_20180603_080733.bak'
	SET			@bkpfilename			= 	@bkpfolder + @bkpfile		
	SET			@sqlcmd_filesinfo = 'RESTORE FILELISTONLY FROM DISK =	'+quotename (@bkpfilename,'''')
	SET			@sqlcmd_dbinfo		= 'RESTORE HEADERONLY  FROM DISK	=	'+quotename (@bkpfilename,'''')




-----------------------------------------------------------------------------------------
-----		DECLARE TABLE TO INSERT INFO FROM BACKUP HEADER WITH RESTORE FILELISTONLY		-----
	DECLARE
				@DBBackupFilesInfo	TABLE (
					[LogicalName]						NVARCHAR(128)						,
					[PhysicalName]					NVARCHAR(128)						,
					[Type]									CHAR(1)									,
					[FileGroup]							NVARCHAR(64)						,
					[Size]									NUMERIC(20,0)						,
					[MaxSize]								NUMERIC(20,0)						,
					[Field]									INT											,
					[CreateLSN]							NUMERIC(25,0)						,
					[DropLSN]								NUMERIC(25,0)						,
					[UniqueId]							UNIQUEIDENTIFIER				,
					[ReadOnlyLSN]						NUMERIC(25,0)						,
					[ReadWriteLSN]					NUMERIC(25,0)						,
					[BackupSizeInBytes]			BIGINT									,
					[SourceBlockSize]				INT											,
					[FileGroupId]						INT											,
					[LogGroupGUID]					UNIQUEIDENTIFIER				,
					[DifferentialBaseLSN]		NUMERIC(25,0)						,
					[DifferentialBaseGUID]	UNIQUEIDENTIFIER				,
					[IsreadOnly]						INT											,
					[IsPresent]							INT											,
					[TDThumbprint]					NVARCHAR(64)						,
					[SnapShotUrl]						NVARCHAR(64))		

-----------------------------------------------------------------------------------------
-----			DECLARE TABLE TO INSERT INFRO BACKUP HEADER WITH RESTORE HEADERONLY				-----
	DECLARE
				@DBBackupInfo	TABLE (
					[BackupName]									NVARCHAR(128)			,
					[BackupDescription]						NVARCHAR(128)			,
					[BackupType]									SMALLINT					,
					[ExpirationDate]							DATETIME					,
					[Compressed]									INT								,
					[Position]										SMALLINT					,
					[DeviceType]									TINYINT						,
					[UserName]										NVARCHAR(128)			,
					[ServerName]									NVARCHAR(128)			,
					[DataBaseName]								NVARCHAR(128)			,
					[DataBaseVersion]							INT								,
					[DataBaseCreationDate]				DATETIME					,
					[BackupSize]									NUMERIC(20,0)			,
					[FirstLSN]										NUMERIC(25,0)			,
					[LastLSN]											NUMERIC(25,0)			,
					[CheckPointLSN]								NUMERIC(25,0)			,
					[DataBaseBackupLSN]						NUMERIC(25,0)			,
					[BackupStartDate]							DATETIME					,
					[BackupFinishDate]						DATETIME					,
					[SortOrder]										SMALLINT					,
					[CodePage]										SMALLINT					,
					[UnicodeLocaleId]							INT								,
					[UnicodeComparisonStyle]			INT								,
					[CompatibilityLevel]					TINYINT						,
					[SoftwareVendorId]						INT								,
					[SoftwareVersionMajor]				INT								,
					[SoftwareVersionMinor]				INT								,
					[SoftwareVersionBuild]				INT								,
					[MachineName]									NVARCHAR(128)			,
					[Flags]												INT								,
					[BindingID]										UNIQUEIDENTIFIER	,
					[RecoveryForkID]							UNIQUEIDENTIFIER	,
					[Collation]										NVARCHAR(128)			,
					[FamilyGUID]									UNIQUEIDENTIFIER	,
					[HasBulkLoggedData]						BIT								,
					[IsSnapshot]									BIT								,
					[IsreadOnly]									BIT								,
					[IsSingleUser]								BIT								,
					[HasBackupChecksums]					BIT								,
					[IsDameged]										BIT								,
					[BeginsLogChain]							BIT								,
					[HasIncompleteMetaData]				BIT								,
					[IsForceOffline]							BIT								,
					[IsCopyOnly]									BIT								,
					[FirsRecoveryForkID]					UNIQUEIDENTIFIER	,
					[ForkPointLSN]								NUMERIC(25,0)			,
					[RecoveryModel]								NVARCHAR(60)			,
					[DifferentialBaseLSN]					NUMERIC(25,0)			,
					[DifferentialBaseGUID]				UNIQUEIDENTIFIER	,
					[BackupTypeDescription]				NVARCHAR(60)			,
					[BackupSetGUID]								UNIQUEIDENTIFIER	,
					[CompressedBackupSize]				BIGINT						,
					[Containment]									TINYINT						,
					[KeyAlgorithm]								NVARCHAR(32)			,
					[EncryptorThumbprint]					VARBINARY(20)			,
					[EncryptorType]								NVARCHAR(32)	)


	DECLARE 

					@DataBaseName					NVARCHAR(128)						,
					@LogicalName					NVARCHAR(128)						,
					@PhysicalName					NVARCHAR(128)						,
					@Type									CHAR(1)		


	DECLARE	
	@DBFolders				TABLE(subdirectory NVARCHAR(250), depth INT)

-------------------------------------------------------------------------------------------
--	INSERT INFO FROM BACKUP HEADER WITH 'RESTORE FILELISTONLY AND RESTORE HEADERONLY'		--
	INSERT @DBBackupFilesInfo
	EXEC	(@sqlcmd_filesinfo)
	SELECT 		
					[LogicalName],
					[Type],
					[PhysicalName]
	FROM @DBBackupFilesInfo

	INSERT @DBBackupInfo
	EXEC (@sqlcmd_dbinfo)
	SELECT [DataBaseName] 
	FROM @DBBackupInfo
----------------------------------------------------------------------------------------------
-- CREATE TABLE WITH IDENTITY COLUMN TO CATCH LOGICAL FILENAMES IN ORDER FOR ACTUAL RESTORE --
	CREATE TABLE #BackupToRestore (
					[ID]										INT IDENTITY(1,1)		,
					[DataBaseName]					NVARCHAR(128)				,
					[LogicalName]						NVARCHAR(128)				,
					[PhysicalName]					NVARCHAR(128)				,
					[Type]									CHAR(1)						)

	INSERT INTO #BackupToRestore 
	SELECT 		[DataBaseName] = (SELECT [DataBaseName] FROM @DBBackupInfo),	
					[LogicalName],
					[PhysicalName],
					[Type]  
	FROM @DBBackupFilesInfo	
	
	SELECT * FROM #BackupToRestore
	

-----------------------------------------------------------------------------------------------
-----									CREATE NTFS FOLDERS FOR DATA FILES TO BE RESTORED										-----

	SET			@DBFolderName			=	 isnull((SELECT [DataBaseName] FROM @DBBackupInfo),'Folder Not Specified')
	SET			@datafile_path		=	'mkdir '+@DataFilePath + @NetworkName + '\' + @DBFolderName + '\'
	SET			@logfile_path			=	'mkdir '+@LogFilePath  + @NetworkName + '\'	+ @DBFolderName + '\'
	
	
	select	@datafile_path
	select	@logfile_path
	
	
	EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
	EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;
	EXEC master.dbo.xp_cmdshell @datafile_path
	EXEC master.dbo.xp_cmdshell @logfile_path	
	
	SET			@datafile_path		=	replace(@datafile_path,	'mkdir ', '' )
	SET			@logfile_path			=	replace(@logfile_path,	'mkdir ', '' )
	
	IF not exists (SELECT * FROM @DBFolders WHERE subdirectory in(@datafile_path,@logfile_path)) BEGIN
	
			EXEC master.dbo.xp_cmdshell @datafile_path
			EXEC master.dbo.xp_cmdshell @logfile_path
	
	END
	
	DELETE FROM @DBFolders


-------------------------------------------------------------------------------------------------------
-----				CREATE CURSOR FOR ITERATING THROUGH ALL BACKUPS FILES TAKEN FROM BACKUP HEADER				-----
	DECLARE RestoreDBCursor  CURSOR FOR
		SELECT 		
			[DataBaseName] = (SELECT [DataBaseName] FROM @DBBackupInfo),	
			[LogicalName],
			[PhysicalName],
			[Type]  
		FROM @DBBackupFilesInfo		
	
	OPEN RestoreDBCursor
	
	DECLARE	@CMD NVARCHAR(4000)	= ''			
	
	WHILE ( 1 = 1 ) BEGIN 
	
	-----------------------------------------------------------------------------------------
	-----						DECLARE TABLE TO INSERT INFO FROM BACKUP HEADER IN CURSOR						-----
	
		FETCH NEXT FROM RestoreDBCursor INTO @DataBaseName, @LogicalName, @PhysicalName, @Type	
			IF (@@fetch_status = 0)						 
			BEGIN 														 
					SET @CMD = @CMD + CASE @Type
								WHEN 'D' THEN	' MOVE N'''+@LogicalName+ ''' TO '''+@datafile_path+'' + ''+@LogicalName+'' + '.mdf''' + space(1) + ','
								WHEN 'L' THEN	' MOVE N'''+@LogicalName+ ''' TO '''+@logfile_path+''	+ ''+@LogicalName+'' + '.ldf''' + space(1) + ','
								ELSE  N'Type Unknown'
							END 		
			END
		ELSE BEGIN
		BREAK
		END
		END
	
		CLOSE				RestoreDBCursor
		DEALLOCATE	RestoreDBCursor
	
	
	SET @CMD = 'RESTORE DATABASE '+ '[' + @DatabaseName+ ']' +' FROM DISK = ' + quotename( @bkpfilename, '''' ) + space(2) + 'WITH  FILE = 1' + ',' 
		+ @CMD + ' NOUNLOAD, REPLACE, STATS = 5'			

	SELECT	@CMD
	EXEC(@cmd)


-- SAME IMPLEMENTATION WITHOUT USING CURSOR --
/**************************/
--set @CMD = 'restore database '+ @DatabaseName +' FROM DISK = ' + quotename( @bkpfilename, '''' )


--select	@CMD = @CMD + case 
	--											when [Type] = 'D' then	' MOVE N'''+[LogicalName]+ ''' TO '''+@datafile_path+'' + ''+[LogicalName]+'' + '.mdf'''
		--										when [Type] = 'L' then	' MOVE N'''+[LogicalName]+ ''' TO '''+@logfile_path+''	+ ''+[LogicalName]+'' + '.ldf'''
			--									else  N'Type Unknown'
				--							end 
--from #BackupToRestore

--select	@CMD = @CMD + ' NOUNLOAD, REPLACE, STATS = 5'

--SELECT	@CMD
--EXEC(@cmd)
------------------------------------------------------------------------------------------------------

	DROP TABLE #BackupToRestore

------------------------------------------------------------------------------------------------------
-- DISABLE XP_CMDSHELL --
EXEC sp_configure 'xp_cmdshell', 0; RECONFIGURE;
EXEC sp_configure 'show advanced options', 0; RECONFIGURE;








