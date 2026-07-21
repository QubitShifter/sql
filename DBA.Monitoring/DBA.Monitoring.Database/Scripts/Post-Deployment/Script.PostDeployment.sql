use [$(DatabaseName)];
go

/* Snapshot seed data */
:r .\Snapshots\CounterSnapshotTypes.sql
go

/* Deadlock event notification */
:r .\Deadlocks\DeadlockEventNotification.sql
go

use [msdb];
go

/* SQL Agent Jobs */
:r .\SQLAgentJobs.sql
go

use [master];
go

/* Server-level permissions */
:r .\Set_ViewPermissions.sql
go

/* Query Store enable */
:r .\Enable_QueryStore.sql
go

use [$(DatabaseName)];
go