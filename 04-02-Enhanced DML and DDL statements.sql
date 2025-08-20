--Enhanced DML and DDL statements
--The conditional DROP statement (DROP IF EXISTS)
--The following objects are supported: AGGREGATE, ASSEMBLY, COLUMN, CONSTRAINT, DATABASE, DEFAULT, FUNCTION, INDEX, PROCEDURE, ROLE, RULE, SCHEMA, SECURITY POLICY, SEQUENCE, SYNONYM, TABLE, TRIGGER, TYPE, USER, and VIEW.

-- The object exists; user has permissions: When the object is removed, everything is fine.
-- The object does not exist; user has permissions: There are no error messages displayed.
-- The object exists; user does not have permissions: When the object is not removed, no error messages are displayed. The caller does not get the information that the object still exists; its DROP command has been executed successfully!
-- The object does not exist; user does not have permissions: There are no error messages displayed.

-- Before SQLServer 2016
IF OBJECT_ID('dbo.T1','U') IS NOT NULL 
  DROP TABLE dbo.T1;

--Now
DROP TABLE IF EXISTS dbo.T1;

DROP PROCEDURE IF EXISTS dbo.P1;


--Using CREATE OR ALTER
--Before SQL Server 2016 SP1
IF OBJECT_ID(N'dbo.uspMyStoredProc','P') IS NULL 
  EXEC('CREATE PROCEDURE dbo.uspMyStoredProc AS SELECT NULL'); 
GO
--ALTER PROCEDURE dbo.uspMyStoredProc 
--AS
--... 

--Now
CREATE OR ALTER FUNCTION dbo.GetWorldsBestCityToLiveIn() 
	RETURNS NVARCHAR(10) 
AS 
BEGIN 
    RETURN N'Vienna'; 
END 

--Resumable online index rebuild
--Example
USE WideWorldImporters;
CREATE INDEX IX1 ON Sales.OrderLines (OrderId, StockItemId, UnitPrice);
GO

--Connection 1
ALTER INDEX IX1 ON Sales.OrderLines
	REBUILD WITH (RESUMABLE = ON, ONLINE = ON)
GO

--Connection 2
USE WideWorldImporters;
ALTER INDEX IX1 ON Sales.OrderLines PAUSE;
GO

--sys.index_resumable_operations view:

SELECT
	name,
	sql_text,
	state_desc,
	percent_complete,
	start_time,
	last_pause_time
FROM
	sys.index_resumable_operations;

USE WideWorldImporters;
ALTER INDEX IX1 ON Sales.OrderLines RESUME;
GO

--Online ALTER COLUMN
-- Change the data type: This is usually when you come close to the maximum value supported by the actual data type (typically from smallint to int, or from int to bigint).
-- Change the size: This is a common case for poorly planned string columns; the current column size cannot accept all the required data.
-- Change the precision: This is when you need to store more precise data, usually due to changed requirements.
-- Change the collation: This is when you have to use a different (usually case- sensitive) collation for a column due to changed requirements.
-- Change the null-ability: This is when the requirements are changed.

USE WideWorldImporters; 

DROP TABLE IF EXISTS dbo.Orders; 
CREATE TABLE dbo.Orders( 
	id INT IDENTITY(1,1) NOT NULL, 
	custid INT NOT NULL, 
	orderdate DATETIME NOT NULL, 
	amount MONEY NOT NULL, 
	rest CHAR(100) NOT NULL DEFAULT 'test', 
	CONSTRAINT PK_Orders PRIMARY KEY CLUSTERED (id ASC) 
); 
GO 

CREATE OR ALTER FUNCTION dbo.GetNums(@low AS BIGINT, @high AS BIGINT) RETURNS TABLE 
AS 
RETURN 
  WITH 
    L0   AS (SELECT c FROM (SELECT 1 UNION ALL SELECT 1) AS D(c)), 
    L1   AS (SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B), 
    L2   AS (SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B), 
    L3   AS (SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B), 
    L4   AS (SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B), 
    L5   AS (SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B), 
    Nums AS
			(
				SELECT
					ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS rownum 
				FROM L5
			)
  SELECT
		TOP(@high - @low + 1) @low + rownum - 1 AS n 
  FROM
		Nums 
  ORDER BY
		rownum;


INSERT INTO dbo.Orders
	(custid,orderdate,amount) 
	SELECT
	  1 + ABS(CHECKSUM(NEWID())) % 1000 AS custid,
	  DATEADD(minute, -ABS(CHECKSUM(NEWID())) % 5000000, '20160630') AS orderdate,
	  50 + ABS(CHECKSUM(NEWID())) % 1000 AS amount
	FROM
		dbo.GetNums(1,10000000);

--Connection 01
ALTER TABLE dbo.Orders
	ALTER COLUMN amount DECIMAL(10,2) NOT NULL; 

--Connection 02
USE WideWorldImporters; 
SELECT
	TOP (2)
	id,
	custid,
	orderdate,
	amount 
FROM
	dbo.Orders
ORDER BY
	id DESC; 


SELECT
	request_mode,
	request_type,
	request_status,
	request_owner_type 
FROM
	sys.dm_tran_locks
WHERE
	request_session_id = 66;

USE WideWorldImporters; 

ALTER TABLE dbo.Orders
ALTER COLUMN amount DECIMAL(10,2) NOT NULL WITH (ONLINE = ON); 

SELECT
	TOP (2)
	id,
	custid,
	orderdate,
	amount 
FROM
	dbo.Orders
ORDER BY
	id DESC; 


USE WideWorldImporters;

CREATE STATISTICS MyStat
	ON dbo.Orders(amount);

ALTER TABLE dbo.Orders
ALTER COLUMN amount DECIMAL(10,3) NOT NULL;

-- Msg 5074, Level 16, State 1, Line 76
-- The statistics 'MyStat' is dependent on column 'amount'.
-- Msg 4922, Level 16, State 9, Line 76
-- ALTER TABLE ALTER COLUMN amount failed because one or more objects access this column. 

ALTER TABLE dbo.Orders
ALTER COLUMN amount DECIMAL(10, 3) NOT NULL WITH (ONLINE = ON);

-- Using TRUNCATE TABLE
TRUNCATE TABLE dbo.T1 WITH (PARTITIONS (1, 2, 4));

TRUNCATE TABLE dbo.T2 WITH (PARTITIONS (3 TO 15000));

TRUNCATE TABLE dbo.T1 WITH (PARTITIONS (2, 4 TO 8));

-- Maximum key size for nonclustered indexes
-- For SQL Server 2014/2012/2008 instances
USE tempdb;

CREATE TABLE dbo.T1
(
	id INT NOT NULL PRIMARY KEY CLUSTERED,
	c1 NVARCHAR(500) NULL,
	c2 NVARCHAR(851) NULL
);

CREATE INDEX ix1 ON dbo.T1(c1); 
--Warning! The maximum key length is 900 bytes. The index 'ix1' has maximum length of 1000 bytes. For some combination of large values, the insert/update operation will fail

INSERT INTO dbo.T1(id,c1, c2) VALUES(1, N'Mila', N'Vasilije');
--ERROR
INSERT INTO dbo.T1(id,c1, c2) VALUES(2,REPLICATE('Mila',113), NULL);
-- Msg 1946, Level 16, State 3, Line 7
-- Operation failed. The index entry of length 904 bytes for the index 'ix1' exceeds the maximum length of 900 bytes.

--SQL Server 2016
DROP TABLE IF EXISTS dbo.T1;
CREATE TABLE dbo.T1(
	id INT NOT NULL PRIMARY KEY CLUSTERED,
	c1 NVARCHAR(500) NULL,
	c2 NVARCHAR(851) NULL); 
GO

CREATE INDEX ix1 ON dbo.T1(c1); 
--Warning! The maximum key length for a nonclustered index is 1700 bytes. The index 'ix2' has maximum length of 1702 bytes. For some combination of large values, the insert/update operation will fail.

