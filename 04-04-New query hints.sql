--New query hints
--Using NO_PERFORMANCE_SPOOL
--Use the query hint NO_SPOOL_OPERATOR when:
--You want to avoid the spool operator in the execution object
--You know that this is a good idea (performance issue is caused by the Spool operator)
--You cannot achieve this with reasonable effort otherwise

USE WideWorldImporters; 
GO 

CREATE OR ALTER FUNCTION dbo.ParseInt 
( 
   @List       VARCHAR(MAX), 
   @Delimiter  CHAR(1) 
) 
RETURNS @Items TABLE 
( 
   Item INT 
) 
AS 
BEGIN 
   DECLARE @Item VARCHAR(30), @Pos  INT; 

   WHILE LEN(@List)>0
   BEGIN 
       SET @Pos = CHARINDEX(@Delimiter, @List); 

       IF @Pos = 0
				SET @Pos = LEN(@List)+1; 
       
			 SET @Item = LEFT(@List, @Pos-1); 

       INSERT @Items SELECT CONVERT(INT, LTRIM(RTRIM(@Item)));

       SET @List = SUBSTRING(@List, @Pos + LEN(@Delimiter), LEN(@List));

       IF LEN(@List) = 0
				BREAK;
   END 
   RETURN; 
END 
GO 

DECLARE @SalesPersonList VARCHAR(MAX) = '3,6,8'; 
SELECT
	o.* 
FROM
	Sales.Orders o 
INNER JOIN
	dbo.ParseInt(@SalesPersonList,',') a 
	ON a.Item = o.SalespersonPersonID
ORDER BY
	o.OrderID;
	

USE WideWorldImporters;
DROP TABLE IF EXISTS dbo.T1 
CREATE TABLE dbo.T1(
	id INT NOT NULL, 
	c1 INT NOT NULL, 
); 
GO

INSERT INTO dbo.T1
	(id, c1)
VALUES
	(1, 5),
	(1, 10);


INSERT INTO dbo.T1
	(id, c1) 
	SELECT
		id,
		c1
	FROM
		dbo.T1 
	WHERE
		id < 10;

--Demostration
INSERT INTO dbo.T1(id, c1)
SELECT
	id,
	c1
FROM
	dbo.T1 
WHERE
	id < 10; 
 
INSERT INTO dbo.T1(id, c1) 
SELECT
	id,
	c1
FROM
	dbo.T1 
WHERE
	id < 10 
OPTION
	(NO_PERFORMANCE_SPOOL); 

--Using MAX_GRANT_PERCENT
--The query hint MAX_GRANT_PERCENT should be used when:
--You don't know how to trick the optimizer into coming up with the appropriate memory grant
--You want to fix the problem immediately and buy time to search for a final solution

USE WideWorldImporters;

DECLARE @now DATETIME = GETDATE();

SELECT * FROM dbo.Orders
WHERE orderdate >= @now
ORDER BY amount DESC; 

--Demostration
DECLARE @now DATETIME = GETDATE();
SELECT * FROM dbo.Orders
WHERE orderdate >= @now
ORDER BY amount DESC
OPTION (MAX_GRANT_PERCENT=0.001);

SELECT * FROM dbo.Orders
WHERE orderdate >=  GETDATE()
ORDER BY amount DESC;

--Using MIN_GRANT_PERCENT
