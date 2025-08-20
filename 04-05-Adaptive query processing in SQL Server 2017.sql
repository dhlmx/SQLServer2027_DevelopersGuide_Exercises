--Adaptive query processing in SQL Server 2017
--Interleaved execution

USE WideWorldImporters;
GO

CREATE OR ALTER FUNCTION dbo.SignificantOrders()
RETURNS @T TABLE
(
	ID INT NOT NULL
) AS
BEGIN
    INSERT INTO @T
    SELECT
			OrderId
		FROM
			Sales.Orders
    RETURN
END
GO

ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 130;
GO
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
	ol.OrderID,
	ol.UnitPrice,
	ol.StockItemID 
FROM
	Sales.Orderlines ol
INNER JOIN
	dbo.SignificantOrders() f1
	ON f1.Id = ol.OrderID
WHERE
	PackageTypeID = 7;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO


ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 140;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
	ol.OrderID,
	ol.UnitPrice,
	ol.StockItemID 
FROM
	Sales.Orderlines ol
INNER JOIN
	dbo.SignificantOrders() f1
	ON f1.Id = ol.OrderID
WHERE
	PackageTypeID = 7;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

--Batch mode adaptive memory grant feedback
--Batch mode adaptive memory grant feedback corrects the initial memory grant as follows:
--Overestimated memory grants: If the granted memory is more than two times the size of the actual used memory, memory grant feedback will recalculate the memory grant and update the cached plan.
--Underestimated memory grants: If the granted memory is too small and the operation is spilled to disk, memory grant feedback will calculate a new memory grant.

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 130;

CREATE OR ALTER PROCEDURE dbo.GetOrders
	@OrderDate DATETIME
AS
BEGIN
    DECLARE @now DATETIME = @OrderDate;

    SELECT
			*
		FROM
			dbo.Orders
    WHERE
			orderdate >= @now
    ORDER BY
			amount DESC;
END
GO

EXEC dbo.GetOrders '20180101';

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
ALTER DATABASE WideWorldImporters SET COMPATIBILITY_LEVEL = 140;

EXEC dbo.GetOrders '20180101';
GO 20

EXEC dbo.GetOrders '20180101';

CREATE NONCLUSTERED COLUMNSTORE INDEX ixc ON dbo.Orders(id, orderdate,custid, amount) WHERE id  = -4;

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
EXEC dbo.GetOrders '20180101';

EXEC dbo.GetOrders '20180101';
GO 20

EXEC dbo.GetOrders '20180101';

EXEC dbo.GetOrders '20000101';
GO 2

--Batch mode adaptive joins
--Logical joins are implemented through three physical join operators in SQL Server:
--Nested Loop, Hash Match, and Merge Join.

USE WideWorldImporters;
GO

CREATE OR ALTER PROCEDURE dbo.GetSomeOrderDeatils
	@UnitPrice DECIMAL(18,2)
AS
SELECT
	o.OrderID,
	o.OrderDate,
	ol.OrderLineID,
	ol.Quantity,
	ol.UnitPrice
FROM
	Sales.OrderLines ol
INNER JOIN
	Sales.Orders o 
	ON ol.OrderID = o.OrderID
WHERE
	ol.UnitPrice = @UnitPrice;
GO

EXEC dbo.GetSomeOrderDeatils 112;

EXEC dbo.GetSomeOrderDeatils 1;

--When Adaptive Join is used, you need to enable the trace flag 9415
DBCC TRACEON (9415);
EXEC dbo.GetSomeOrderDeatils 112;

--Disabling adaptive batch mode joins
ALTER DATABASE SCOPED CONFIGURATION
	SET DISABLE_BATCH_MODE_ADAPTIVE_JOINS = ON;

CREATE OR ALTER PROCEDURE dbo.GetSomeOrderDeatils
	@UnitPrice DECIMAL(18,2)
AS
SELECT
	o.OrderID,
	o.OrderDate,
	ol.OrderLineID,
	ol.Quantity,
	ol.UnitPrice
FROM
	Sales.OrderLines ol
INNER JOIN
	Sales.Orders o 
	ON ol.OrderID = o.OrderID
WHERE
	ol.UnitPrice = @UnitPrice 
OPTION (USE HINT ('DISABLE_BATCH_MODE_ADAPTIVE_JOINS'));

EXEC dbo.GetSomeOrderDeatils 112;

