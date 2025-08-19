--Error Handling
EXEC dbo.InsertSimpleOrder
	@OrderId = 6, @OrderDate = '20160706', @Customer = N'CustE';
EXEC dbo.InsertSimpleOrderDetail
	@OrderId = 6, @ProductId = 2, @Quantity = 0;


EXEC dbo.InsertSimpleOrder
	@OrderId = 6, @OrderDate = '20160706', @Customer = N'CustE';


SELECT
	o.OrderId,
	o.OrderDate,
	o.Customer,
	od.ProductId,
	od.Quantity
FROM
	dbo.SimpleOrderDetails AS od
RIGHT OUTER JOIN
	dbo.SimpleOrders AS o
    ON od.OrderId = o.OrderId 
WHERE
	o.OrderId > 5
ORDER BY
	o.OrderId,
	od.ProductId;


BEGIN TRY
	EXEC dbo.InsertSimpleOrder
		@OrderId = 6, @OrderDate = '20160706', @Customer = N'CustF';

	EXEC dbo.InsertSimpleOrderDetail
		 @OrderId = 6, @ProductId = 2, @Quantity = 5;
END TRY

BEGIN CATCH
	SELECT
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_MESSAGE() AS ErrorMessage,
		ERROR_LINE() AS ErrorLine;
END CATCH


SELECT
	o.OrderId,
	o.OrderDate,
	o.Customer,
	od.ProductId,
	od.Quantity
FROM
	dbo.SimpleOrderDetails AS od
RIGHT OUTER JOIN
	dbo.SimpleOrders AS o 
    ON od.OrderId = o.OrderId 
WHERE
	o.OrderId > 5
ORDER BY
	o.OrderId, od.ProductId;


BEGIN TRY
	EXEC dbo.InsertSimpleOrder
		@OrderId = 7, @OrderDate = '20160706', @Customer = N'CustF';

	EXEC dbo.InsertSimpleOrderDetail
		@OrderId = 7, @ProductId = 2, @Quantity = 0;
END TRY 

BEGIN CATCH 
	SELECT
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_MESSAGE() AS ErrorMessage,
		ERROR_LINE() AS ErrorLine;
END CATCH 

--Using transactions

BEGIN TRY
	BEGIN TRANSACTION
		EXEC dbo.InsertSimpleOrder
			@OrderId = 8, @OrderDate = '20160706', @Customer = N'CustG';

		EXEC dbo.InsertSimpleOrderDetail
			@OrderId = 8, @ProductId = 2, @Quantity = 0;
	
	COMMIT TRANSACTION
END TRY

BEGIN CATCH 
	SELECT
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_MESSAGE() AS ErrorMessage,
		ERROR_LINE() AS ErrorLine;
	
	IF XACT_STATE() <> 0 
		ROLLBACK TRANSACTION;
END CATCH


SELECT
	o.OrderId,
	o.OrderDate,
	o.Customer,
	od.ProductId,
	od.Quantity
FROM
	dbo.SimpleOrderDetails AS od
RIGHT OUTER JOIN
	dbo.SimpleOrders AS o
    ON od.OrderId = o.OrderId
WHERE
	o.OrderId > 5
ORDER BY
	o.OrderId, od.ProductId;


DROP FUNCTION dbo.Top2OrderDetails; 
DROP VIEW dbo.OrdersWithoutDetails; 
DROP PROCEDURE dbo.InsertSimpleOrderDetail; 
DROP PROCEDURE dbo.InsertSimpleOrder; 
DROP TABLE dbo.SimpleOrderDetails; 
DROP TABLE dbo.SimpleOrders;


