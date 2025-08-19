IF OBJECT_ID(N'dbo.SimpleOrders', N'U') IS NOT NULL
BEGIN
	DROP TABLE dbo.SimpleOrders;
END;

CREATE TABLE dbo.SimpleOrders
(
	OrderId INT NOT NULL,
	OrderDate DATE NOT NULL,
	Customer NVARCHAR(5) NOT NULL,
	CONSTRAINT PK_Simple_Orders PRIMARY KEY (OrderId)
);


IF OBJECT_ID(N'dbo.SimpleOrderDetails', N'U') IS NOT NULL
BEGIN
	DROP TABLE dbo.SimpleOrderDetails;
END;

CREATE TABLE dbo.SimpleOrderDetails
(
	OrderId INT NOT NULL,
	ProductId INT NOT NULL,
	Quantity INT NOT NULL,
	CHECK(Quantity <> 0),
	CONSTRAINT PK_SimpleOrderDetails PRIMARY KEY (OrderId, ProductId)
);


ALTER TABLE dbo.SimpleOrderDetails
	ADD CONSTRAINT FK_SimpleOrderDetails_SimpleOrders FOREIGN KEY (OrderId) REFERENCES dbo.SimpleOrders(OrderId);


INSERT INTO dbo.SimpleOrders
     (OrderId, OrderDate, Customer)
VALUES
     (1, '20160701', N'CustA');


INSERT INTO dbo.SimpleOrderDetails
     (OrderId, ProductId, Quantity)
VALUES
     (1, 7, 100),
     (1, 3, 200);


SELECT
	o.OrderId,
	o.OrderDate,
	o.Customer,
	od.ProductId,
	od.Quantity
FROM
	dbo.SimpleOrderDetails AS od
INNER JOIN
	dbo.SimpleOrders AS o
    ON od.OrderId = o.OrderId
ORDER BY
	o.OrderId, od.ProductId;


UPDATE
	dbo.SimpleOrderDetails
SET
	Quantity = 150
WHERE
	OrderId = 1
	AND ProductId = 3;


INSERT INTO dbo.SimpleOrders
	(OrderId, OrderDate, Customer)
	OUTPUT inserted.*
VALUES
	(2, '20160701', N'CustB');

INSERT INTO
	dbo.SimpleOrderDetails
	(OrderId, ProductId, Quantity)
	OUTPUT inserted.*
VALUES
	(2, 4, 200);


INSERT INTO dbo.SimpleOrders
	(OrderId, OrderDate, Customer)
VALUES
	(3, '20100701', N'CustC');


SELECT
	o.OrderId,
	o.OrderDate,
	o.Customer
FROM
	dbo.SimpleOrders AS o
ORDER BY
	o.OrderId;


CREATE TRIGGER Trg_SimpleOrders_OrdereDate
	ON dbo.SimpleOrders AFTER INSERT, UPDATE
AS
	UPDATE
		dbo.SimpleOrders
	SET
		OrderDate = '20160101'
	WHERE
		OrderDate < '20160101';


INSERT INTO dbo.SimpleOrders
	(OrderId, OrderDate, Customer)
VALUES
	(4, '20100701', N'CustD');

UPDATE
	dbo.SimpleOrders
SET
	OrderDate = '20110101'
WHERE
	OrderId = 3;

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
ORDER BY
	o.OrderId, od.ProductId;


CREATE PROCEDURE dbo.InsertSimpleOrder 
(
	@OrderId AS INT,
	@OrderDate AS DATE,
	@Customer AS NVARCHAR(5)
) AS
INSERT INTO dbo.SimpleOrders
	(OrderId, OrderDate, Customer) 
VALUES
	(@OrderId, @OrderDate, @Customer);

CREATE PROCEDURE dbo.InsertSimpleOrderDetail 
(
	@OrderId AS INT,
	@ProductId AS INT,
	@Quantity AS INT
) AS 
	INSERT INTO dbo.SimpleOrderDetails
		(OrderId, ProductId, Quantity)
	VALUES 
		(@OrderId, @ProductId, @Quantity);


EXEC dbo.InsertSimpleOrder 
	@OrderId = 5, @OrderDate = '20160702', @Customer = N'CustA'; 

EXEC dbo.InsertSimpleOrderDetail 
	@OrderId = 5, @ProductId = 1, @Quantity = 50;


EXEC dbo.InsertSimpleOrderDetail
	@OrderId = 2, @ProductId = 5, @Quantity = 150;
EXEC dbo.InsertSimpleOrderDetail
	@OrderId = 2, @ProductId = 6, @Quantity = 250;
EXEC dbo.InsertSimpleOrderDetail
	@OrderId = 1, @ProductId = 5, @Quantity = 50;
EXEC dbo.InsertSimpleOrderDetail
	@OrderId = 1, @ProductId = 6, @Quantity = 200;


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
ORDER BY
	o.OrderId,
	od.ProductId;


CREATE VIEW dbo.OrdersWithoutDetails AS 
	SELECT
		o.OrderId,
		o.OrderDate,
		o.Customer 
	FROM
		dbo.SimpleOrderDetails AS od
	RIGHT OUTER JOIN
		dbo.SimpleOrders AS o
		ON od.OrderId = o.OrderId 
	WHERE
		od.OrderId IS NULL;


SELECT
	OrderId,
	OrderDate,
	Customer 
FROM
	dbo.OrdersWithoutDetails;


CREATE FUNCTION dbo.Top2OrderDetails 
(
	@OrderId AS INT
) 
RETURNS TABLE 
AS RETURN 
	SELECT
		TOP 2
		ProductId,
		Quantity 
	FROM
		dbo.SimpleOrderDetails
	WHERE
		OrderId = @OrderId
	ORDER BY
		Quantity DESC;


SELECT
	o.OrderId,
	o.OrderDate,
	o.Customer,
	t2.ProductId,
	t2.Quantity
FROM
	dbo.SimpleOrders AS o 
	OUTER APPLY
		dbo.Top2OrderDetails(o.OrderId) AS t2 
	ORDER BY
		o.OrderId,
		t2.Quantity
	DESC;
