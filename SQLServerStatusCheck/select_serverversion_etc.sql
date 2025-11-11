SELECT
  CASE 
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.0%' THEN 'SQL2008'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.5%' THEN 'SQL2008 R2'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '11%' THEN 'SQL2012'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '12%' THEN 'SQL2014'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '13%' THEN 'SQL2016'     
     ELSE 'SQL Version NOT Known'
  END AS MajorVersion,
  SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS Servername,
  --SERVERPROPERTY('ServerType') AS ServerType,
  SERVERPROPERTY('ProductLevel') AS ProductLevel,
  SERVERPROPERTY('InstanceName') AS InstanceName,
  SERVERPROPERTY('ServiceAccount') AS ServiceAccount,
  SERVERPROPERTY('BuildNumber') AS Build,
  SERVERPROPERTY('Edition') AS Edition,
  SERVERPROPERTY('ProductVersion') AS ProductVersion,
  SERVERPROPERTY('Collation') AS ServerCollation