--New and enhanced functions and expressions
--Using STRING_SPLIT
USE tempdb;

SELECT
	[Value]
FROM
	string_split(N'Rapid Wien, Benfica Lisboa, Seattle Seahawks', ',');

USE WideWorldImportersDW2016;

SELECT
	[Stock Item Key] AS StockItemID,
	[Stock Item] AS StockItem,
	Brand AS Tags  
FROM
	Dimension.[Stock Item]  
WHERE
	'"16GB"' IN (
		SELECT
			value
		FROM
			STRING_SPLIT(REPLACE(REPLACE(Brand,'[',''), ']',''), ',')
	);


USE WideWorldImporters2016;

DECLARE @orderIds AS VARCHAR(100) = '1,3,7,8,9,11'; 

SELECT
	so.OrderID,
	so.CustomerID,
	so.OrderDate
FROM
	Sales.Orders AS so
INNER JOIN
	STRING_SPLIT(@orderIds,',') AS x
	ON x.value= so.OrderID;


DECLARE @input AS NVARCHAR(20) = NULL; 

SELECT
	*
FROM
	STRING_SPLIT(@input,',');


USE WideWorldImporters2016;
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 120; 
GO 

SELECT value FROM STRING_SPLIT('1,2,3',','); 

/*Result: 
Msg 208, Level 16, State 1, Line 65 
Invalid object name 'STRING_SPLIT'. 
*/ 

--back to the original compatibility level 
ALTER DATABASE WideWorldImporters2016 SET COMPATIBILITY_LEVEL = 130;

-- Using STRING_ESCAPE
SELECT STRING_ESCAPE('a\bc/de"f', 'JSON') AS escaped_input; 

SELECT
	STRING_ESCAPE(CHAR(0), 'JSON') AS escaped_char0,
	STRING_ESCAPE(CHAR(4), 'JSON') AS escaped_char4,
	STRING_ESCAPE(CHAR(31), 'JSON') AS escaped_char31;

SELECT
	STRING_ESCAPE(CHAR(9), 'JSON') AS escaped_tab1,
	STRING_ESCAPE('    ', 'JSON') AS escaped_tab2;


DECLARE @input AS NVARCHAR(20) = NULL; 

SELECT STRING_ESCAPE(@input, 'JSON') AS escaped_input;

SELECT STRING_ESCAPE(N'key:1, i\d:4', 'JSON') AS escaped_input;

-- Using STRING_AGG
SELECT name FROM sys.databases;

SELECT
	STRING_AGG (name, ',') AS dbs_as_csv
FROM
	sys.databases;

SELECT
	STRING_AGG (database_id, ',') AS dbiss_as_csv
FROM
	sys.databases;

USE WideWorldImporters;
SELECT STRING_AGG(name, ',') AS cols FROM sys.syscolumns; 

USE WideWorldImporters;
SELECT STRING_AGG (CAST(name AS NVARCHAR(MAX)), ',') AS cols FROM sys.syscolumns;

-- Handling NULLs in the STRING_AGG function

SELECT STRING_AGG(c, ',') AS fav_city FROM (VALUES('Vienna'), ('Lisbon')) AS T(c)
UNION ALL
SELECT STRING_AGG(c, ',') AS fav_city FROM (VALUES('Vienna'), (NULL), ('Lisbon')) AS T(c);

SELECT STRING_AGG(c, ',') AS fav_city FROM (VALUES('Vienna'), ('Lisbon')) AS T(c)
UNION ALL
SELECT STRING_AGG(COALESCE(c, 'N/A'), ',') AS fav_city FROM (VALUES('Vienna'), (NULL), ('Lisbon')) AS T(c);

-- The WITHIN GROUP clause
DECLARE @vinput AS VARCHAR(20) = '1059,1060,1061';

SELECT
	o.CustomerID,
	STRING_AGG(o.OrderID, ',') AS OrderIDs
FROM
	Sales.Orders AS o
INNER JOIN 
	STRING_SPLIT(@vinput,',') AS x 
	ON x.value = o.CustomerID
GROUP BY
	o.CustomerID
ORDER BY
	o.CustomerID;

DECLARE @input02 VARCHAR(20) = '1059,1060,1061';

SELECT
	so.CustomerID,
	STRING_AGG(so.OrderID, ',') WITHIN GROUP (
		ORDER BY so.OrderID DESC
	) AS orderids
FROM
	Sales.Orders AS so
INNER JOIN
	STRING_SPLIT(@input02,',') x 
	ON x.value = so.CustomerID
GROUP BY
	so.CustomerID
ORDER BY
	so.CustomerID;

SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

DECLARE @input03 VARCHAR(20) = '1059,1060,1061';

SELECT
	C.CustomerID,
	STUFF(
		(
			SELECT 
				',' + CAST(OrderId AS VARCHAR(10)) AS [text()]
			FROM
				Sales.Orders AS O
			WHERE
				O.CustomerID = C.CustomerID
			ORDER BY
				OrderID ASC
			FOR XML PATH('')
		),
		1,
		1,
		NULL
	) AS OrderIDs
FROM
	Sales.Customers AS C
INNER JOIN
	dbo.SplitStrings(@input03,',') AS F
	ON F.item = C.CustomerID
ORDER BY
	CustomerID;

SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

DECLARE @input04 VARCHAR(20) = '1059,1060,1061';

SELECT
	CustomerID,
	STRING_AGG(OrderID, ',') WITHIN GROUP(ORDER BY OrderID ASC) AS OrderIDs
FROM
	Sales.Orders o
INNER JOIN
	STRING_SPLIT(@input04,',') x 
	ON x.value = o.CustomerID
GROUP BY
	CustomerID
ORDER BY
	CustomerID;


-- Using CONCAT_WS

SELECT
	CONCAT(name, ' / ', compatibility_level, ' / ', collation_name) AS db 
FROM
	sys.databases
WHERE
	database_id < 5;


SELECT
	CONCAT_WS(' / ', name, compatibility_level, collation_name)
FROM
	sys.databases
WHERE
	database_id < 5;

-- Using TRIM
SELECT TRIM('    Nothing special    ') AS NothingRare;
	
-- Using TRANSLATE
SELECT
	REPLACE(REPLACE('[Sales].[SalesOrderHeader]', '[', '('), ']', ')');

SELECT
	TRANSLATE('[Sales].[SalesOrderHeader]', '[]a', '()x');

-- ERROR
SELECT
	TRANSLATE('[Sales].[SalesOrderHeader]','[]','');


-- Using COMPRESS
SELECT
	target_name, 
	DATALENGTH(xet.target_data) AS original_size, 
	DATALENGTH(COMPRESS(xet.target_data)) AS compressed_size, 
	CAST((DATALENGTH(xet.target_data) - DATALENGTH(COMPRESS(xet.target_data)))*100.0/DATALENGTH(xet.target_data) AS DECIMAL(5,2)) AS compression_rate_in_percent
FROM
	sys.dm_xe_session_targets xet   
INNER JOIN
	sys.dm_xe_sessions xe 
	ON xe.address = xet.event_session_address
WHERE
	xe.name = 'system_health'; 

SELECT
	target_name, 
	--DATALENGTH(xet.target_data) AS original_size, 
	COMPRESS(xet.target_data) AS targetCompressed
	--CAST((DATALENGTH(xet.target_data) - DATALENGTH(COMPRESS(xet.target_data)))*100.0/DATALENGTH(xet.target_data) AS DECIMAL(5,2)) AS compression_rate_in_percent
FROM
	sys.dm_xe_session_targets xet   
INNER JOIN
	sys.dm_xe_sessions xe 
	ON xe.address = xet.event_session_address
WHERE
	xe.name = 'system_health';


DECLARE @input05 AS NVARCHAR(15) = N'SQL Server 2017'; 

SELECT
	@input05 AS input,
	DATALENGTH(@input05) AS input_size,
	COMPRESS(@input05) AS compressed,
	DATALENGTH(COMPRESS(@input05)) AS comp_size;

-- Using DECOMPRESS
DECLARE @input06 AS NVARCHAR(100) = N'SQL Server 2017 Developer''s Guide'; 
SELECT
	DECOMPRESS(COMPRESS(@input06)) AS Decompressed;

DECLARE @input07 AS NVARCHAR(100) = N'SQL Server 2017 Developer''s Guide';
SELECT
	CAST(DECOMPRESS(COMPRESS(@input07)) AS NVARCHAR(100)) AS input; 

DECLARE @input08 AS NVARCHAR(100) = N'SQL Server 2017 Developer''s Guide';
SELECT
	CAST(DECOMPRESS(COMPRESS(@input08)) AS VARCHAR(100)) AS input;

DECLARE @input09 AS VARCHAR(100) = 'SQL Server 2017 Developer''s Guide'; 
SELECT
	CAST(DECOMPRESS(COMPRESS(@input09)) AS NVARCHAR(100)) AS input;

-- Using CURRENT_TRANSACTION_ID
SELECT CURRENT_TRANSACTION_ID(); 
SELECT CURRENT_TRANSACTION_ID(); 

BEGIN TRAN 
	SELECT CURRENT_TRANSACTION_ID(); 
	SELECT CURRENT_TRANSACTION_ID(); 
COMMIT 

--ERROR (Azure, valid)
SELECT
	SESSION_ID();

SELECT
	*
FROM
	sys.dm_tran_active_transactions
WHERE
	transaction_id = CURRENT_TRANSACTION_ID(); 

-- Using SESSION_CONTEXT
-- The size of the key cannot exceed 256 bytes and the limit for the total size of keys and values in the session context is 256 KB.
DECLARE @key AS NVARCHAR(40);

EXEC sys.sp_set_session_context @key = N'language', @value = N'German'; 
SELECT
	SESSION_CONTEXT(N'language') AS [Language];

--ERROR
SELECT SESSION_CONTEXT('language'); 

DECLARE @lng AS NVARCHAR(50) = N'language'; 
SELECT SESSION_CONTEXT(@lng);


-- Using DATEDIFF_BIG
-- datepart: This is the time unit (year, quarter, month, second, millisecond, microsecond, and nanosecond)
-- startdate: This is an expression of any date data type (date, time, smalldatetime, datetime, datetime2, and datetimeoffset)
-- enddate: This is also an expression of any date data type (date, time, smalldatetime, datetime, datetime2, and datetimeoffset)

--	Date part		Maximal supported date difference
--	Hour			250,000 years
--	Minute			4,086 years
--	Second			68 years
--	Millisecond		25 days
--	Microsecond		36 minutes
--	Nanosecond		2.15 seconds

SELECT
	DATEDIFF(SECOND,'19480101', '20160101') AS diff;

SELECT
	DATEDIFF(SECOND,'19470101', '20160101') AS diff;


SELECT
	DATEDIFF_BIG(MICROSECOND,'010101','99991231 23:59:59.999999999') AS diff;

--ERROR
SELECT
	DATEDIFF_BIG(NANOSECOND,'010101','99991231 23:59:59.999999999') AS diff;


-- Using AT TIME ZONE
-- sys.time_zone_info.
-- This is exactly the same list as in the registry KEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones.
SELECT  
  CONVERT(DATETIME, SYSDATETIMEOFFSET()) AS UTCTime, 
  CONVERT(DATETIME, SYSDATETIMEOFFSET() AT TIME ZONE 'Eastern Standard Time') AS NewYork_Local, 
  CONVERT(DATETIME, SYSDATETIMEOFFSET() AT TIME ZONE 'Central European Standard Time') AS Vienna_Local;

SELECT
	*
FROM
	sys.time_zone_info;


SELECT
	name,
	CONVERT(DATETIME, SYSDATETIMEOFFSET() AT TIME ZONE name) AS local_time  
FROM
	sys.time_zone_info 
WHERE
	name IN (
		SELECT
			value
		FROM 
			STRING_SPLIT('UTC,Eastern Standard Time,Central European Standard Time,Russian Standard Time',',')
	);

SELECT
	CAST('20250820 12:46' AS DATETIME)  
	AT TIME ZONE 'Central European Standard Time'  
	AT TIME ZONE 'Pacific Standard Time' AS Seattle_Time;

-- Using HASHBYTES
-- algorithm: This is a hashing algorithm for hashing the input. The possible values are MD2, MD4, MD5, SHA, SHA1, SHA2_256, and SHA2_512, but only the last two are recommended in SQL Server 2017.
-- input: This is an input variable, column, or expression that needs to be hashed. The data types that are allowed are varchar, nvarchar, and varbinary.

USE AdventureWorksDW2016; 
SELECT
	HASHBYTES('SHA2_256',(
		SELECT
			TOP (6)
			* 
		FROM
			dbo.DimReseller 
		FOR XML AUTO
	)) AS hashed_value;

USE AdventureWorksDW2016; 
SELECT
	HASHBYTES('SHA2_256',(
		SELECT
			TOP (7)
			* 
		FROM
			dbo.FactInternetSales 
		FOR XML AUTO
	)) AS hashed_value;

SELECT
	DATALENGTH(CAST(
		(
			SELECT
				TOP (700)
				*
			FROM
				dbo.FactInternetSales 
			FOR XML AUTO
		) AS NVARCHAR(MAX))
	) AS input_length; 


USE AdventureWorks2017; 
SELECT HASHBYTES('SHA2_256',(SELECT * FROM Sales.SalesOrderHeader FOR XML AUTO)) AS hashed_value;

USE AdventureWorks2017; 
SELECT
	HASHBYTES('SHA2_256',
		(
			SELECT
				*
			FROM
				Production.Product p 
			INNER JOIN
				Production.ProductSubcategory sc
				ON p.ProductSubcategoryID = sc.ProductSubcategoryID 
			INNER JOIN
				Production.ProductCategory c
				ON sc.ProductCategoryID = c.ProductCategoryID 
			INNER JOIN
				Production.ProductListPriceHistory ph
				ON ph.ProductID = p.ProductID
			FOR XML AUTO
		)
	) AS hashed_value;

-- Using JSON functions
