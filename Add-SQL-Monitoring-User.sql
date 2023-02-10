-- Use this script to add a user to your database to monitor with LogicMonitor
-- Slightly more fleshed out version of https://www.logicmonitor.com/support/monitoring/applications-databases/microsoft-sql-server/

-- Enter username here
DECLARE @username VARCHAR(100)
select @username = 'FABRIKAM\monitoringuser'

-- Create user login from Windows
-- Make sure to put your complete username in the form of DOMAIN\USERNAME
-- If the user already exists for a database there will be errors displayed.  These can be ignored

DECLARE @usercreate VARCHAR(200)
SET @usercreate = N'CREATE LOGIN ['+@username+'] FROM WINDOWS;'
EXEC (@usercreate)


DECLARE @dbname VARCHAR(50)  
DECLARE @statement NVARCHAR(max)
Use master;
SELECT @statement = 'CREATE USER ['+@username+'] FOR LOGIN ['+@username+'];
GRANT VIEW ANY DEFINITION TO ['+@username+'];
GRANT VIEW SERVER STATE TO ['+ @username+'];
GRANT VIEW ANY DATABASE TO ['+ @username + '];
USE MSDB;
CREATE USER ['+ @username + '] FOR LOGIN ['+ @username + '];
GRANT SELECT ON SYSJOBS TO ['+ @username + '];
GRANT SELECT ON SYSJOBHISTORY TO ['+ @username + '];
GRANT SELECT ON SYSJOBACTIVITY TO ['+ @username + '];'
exec sp_executesql @statement
