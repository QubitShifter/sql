if object_id('#PhysicalDiskSpace') is not null
drop table #PhysicalDiskSpace

declare
	@get_free_space_on_hdd				nvarchar(max),
	@xml								nvarchar(max),
	@body								nvarchar(max),
	@Query								nvarchar(max),
	@HTMLbody							nvarchar(max)

create table #PhysicalDiskSpace (
			[Disk Drive]				nvarchar(4),
			[FS Type]					nvarchar(4),
			[Total Size in GB]			decimal(5,2),
			[Available Size in GB]		decimal(5,2),
			[Free Space in %]			decimal(5,2)
	)

insert into #PhysicalDiskSpace
select distinct
	volume_mount_point [Disk Drive],
	file_system_type [FS Type],
	convert(decimal(18,2),total_bytes/1073741824.0) as [Total Size in GB],	
	convert(decimal(18,2),available_bytes/1073741824.0) as [Available Size in GB],
	cast(cast(available_bytes as float)/ cast(total_bytes as float) as decimal(18,2)) * 100 as [Free Space in %]
from sys.master_files
cross apply sys.dm_os_volume_stats(database_id, file_id)

set @xml = cast(
				(select [Disk Drive] as 'td', '', [FS Type] as 'td', '', [Total Size in GB] as 'td', '', [Available Size in GB] as 'td', '', [Free Space in %] as 'td'
					from #PhysicalDiskSpace as d
					order by d.[Disk Drive]
					for XML path ('tr'), elements) as nvarchar(max)
)

select * from #PhysicalDiskSpace

set nocount on
declare GetPhysicalFreeSpaceAsPercent cursor for
	select d.[Disk Drive], d.[Free Space in %] 
	from #PhysicalDiskSpace as d

open GetPhysicalFreeSpaceAsPercent
declare
	@treshold_warning		decimal(5,2),
	@treshold_critical		decimal(5,2),
	@percent_value			decimal(5,2),
	@MailSubject			nvarchar(256),
	@disk_drive				nvarchar(4)

set	@treshold_warning	= 30.00
set	@treshold_critical	= 20.00

while ( 1 = 1 ) begin
	fetch next from GetPhysicalFreeSpaceAsPercent into @disk_drive, @percent_value
		if (@@fetch_status = 0) begin
			if @percent_value  < @treshold_warning and  @percent_value  > @treshold_critical begin
					print N'Current disk usage for drive ' +@disk_drive+ ' has reached warning treshold'
							set @MailSubject	= N'Disk Space Usage - WARNING LEVEL'
							set @body ='<html><body><H4>Server: ' +@@servername+ ', Disk Space Usage for drive ' +@disk_drive+ ' reached WARNING LEVEL treshold</H4>
													<table border = 1> 
													<tr>
													<th> Disk Drive </th> <th> FS Type </th> <th> Total Size in GB </th> <th> Available Size in GB </th> <th>Free Space in % </th></tr>'
							set @body = @body + @xml +'</table></body></html>'

		end
	else
		if @percent_value  <= @treshold_critical begin
				print N'Current disk usage for drive ' +@disk_drive+ ' has reached critical treshold'
					set @MailSubject	= N'Disk Space Usage - CRITICAL LEVEL'
					set @body ='<html><body><H4>Server: ' +@@servername+ ', Disk Space Usage for drive ' +@disk_drive+ ' reached CRITICAL LEVEL treshold</H4>
						<table border = 1> 
						<tr>
						<th> Disk Drive </th> <th> FS Type </th> <th> Total Size in GB </th> <th> Available Size in GB </th> <th>Free Space in % </th></tr>'
					set @body = @body + @xml +'</table></body></html>'

break
		end
	end
end
close		GetPhysicalFreeSpaceAsPercent 
deallocate	GetPhysicalFreeSpaceAsPercent

declare 
	@ProfileName		nvarchar(64)		= 'DBMailProfile',
	@Recipients			nvarchar(1024)		= 'georgi.petrov@igsoft.com;joro.petroff@gmail.com',
	@Subject			varchar(256)		= @MailSubject,
	@Filename			nvarchar(32)		= N'Disk Usage'

exec msdb.dbo.sp_send_dbmail	
	@profile_name							= @ProfileName,
	@recipients								= @Recipients,
	@subject								= @subject,
	@body									= @body,
	@body_format							='HTML'



