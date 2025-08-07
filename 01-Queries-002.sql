-- Advanced SELECT techniques

SELECT
	c.Customer,
	f.Quantity,
	(
		SELECT
			SUM(f1.Quantity)
		FROM
			Fact.Sale AS f1
		WHERE
			f1.[Customer Key] = c.[Customer Key]
	) AS TotalCustomerQuantity,
	f2.TotalQuantity
FROM
	(
		Fact.Sale AS f
	INNER JOIN
		Dimension.Customer AS c
		ON f.[Customer Key] = c.[Customer Key]
	)
	CROSS JOIN
	(
		SELECT
			SUM(f2.Quantity)
		FROM
			Fact.Sale AS f2
		WHERE
			f2.[Customer Key] <> 0
	) AS f2 (TotalQuantity)
WHERE
	c.[Customer Key] <> 0
ORDER BY
	c.Customer, f.Quantity DESC;

-- Window Functions

SELECT
	c.Customer,
	f.Quantity,
	SUM(f.Quantity)
		OVER(PARTITION BY c.Customer) AS TotalCustomerQuantity,
	SUM(f.Quantity)
		OVER() AS TotalQuantity
FROM
	Fact.Sale AS f
INNER JOIN
	Dimension.Customer AS c
    ON f.[Customer Key] = c.[Customer Key]
WHERE
	c.[Customer Key] <> 0
ORDER BY
	c.Customer, f.Quantity DESC;

-- Ranking Functions

SELECT
	c.Customer,
	f.Quantity,
	ROW_NUMBER()
		OVER(PARTITION BY c.Customer ORDER BY f.Quantity DESC) AS CustomerOrderPosition,
	ROW_NUMBER()
		OVER(ORDER BY f.Quantity DESC) AS TotalOrderPosition 
FROM
	Fact.Sale AS f
INNER JOIN
	Dimension.Customer AS c
    ON f.[Customer Key] = c.[Customer Key]
WHERE
	c.[Customer Key] <> 0
ORDER BY
	c.Customer, f.Quantity DESC;

--

SELECT
	c.Customer,
	f.[Sale Key] AS SaleKey,
	f.Quantity,
	SUM(f.Quantity)
		OVER(PARTITION BY c.Customer ORDER BY [Sale Key] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Q_RT,
	AVG(f.Quantity)
		OVER(PARTITION BY c.Customer ORDER BY [Sale Key] ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Q_MA
FROM
	Fact.Sale AS f
INNER JOIN
	Dimension.Customer AS c
    ON f.[Customer Key] = c.[Customer Key]
WHERE
	c.[Customer Key] <> 0
ORDER BY
	c.Customer, f.[Sale Key];

-- OFFSET, FETCH

SELECT
	c.Customer,
	f.[Sale Key] AS SaleKey,
	f.Quantity
FROM
	Fact.Sale AS f
INNER JOIN
	Dimension.Customer AS c
    ON f.[Customer Key] = c.[Customer Key]
WHERE
	c.Customer = N'Tailspin Toys (Aceitunas, PR)'
ORDER BY
	f.Quantity DESC
OFFSET 0 ROWS
FETCH NEXT 3 ROWS ONLY;

-- TOP WITH TIES

SELECT
	TOP 3 WITH TIES
	c.Customer,
	f.[Sale Key] AS SaleKey,
	f.Quantity
FROM
	Fact.Sale AS f
INNER JOIN
	Dimension.Customer AS c
    ON f.[Customer Key] = c.[Customer Key]
WHERE
	c.Customer = N'Tailspin Toys (Aceitunas, PR)'
ORDER BY
	f.Quantity DESC;

-- APPLY

SELECT
	c.Customer,
	t3.SaleKey,
	t3.Quantity
FROM
	Dimension.Customer AS c
CROSS APPLY
	(
		SELECT
			TOP(3)
			f.[Sale Key] AS SaleKey,
			f.Quantity
		FROM
			Fact.Sale AS f
		WHERE
			f.[Customer Key] = c.[Customer Key]
		ORDER BY
			f.Quantity DESC
	) AS t3
WHERE
	c.[Customer Key] <> 0
ORDER BY
	c.Customer, t3.Quantity DESC;

-- WITH (CTE)

WITH CustomerSalesCTE AS
( 
	SELECT
		c.Customer,
		SUM(f.[Total Excluding Tax]) AS TotalAmount,
		COUNT(*) AS SalesCount
	FROM
		Fact.Sale AS f
	INNER JOIN
		Dimension.Customer AS c
		ON f.[Customer Key] = c.[Customer Key]
	WHERE
		c.[Customer Key] <> 0
	GROUP BY
		c.Customer
) 
SELECT
	ROUND(AVG(TotalAmount), 6) AS AvgAmountPerCustomer,
	ROUND(STDEV(TotalAmount), 6) AS StDevAmountPerCustomer,
	AVG(SalesCount) AS AvgCountPerCustomer
FROM
	CustomerSalesCTE;
