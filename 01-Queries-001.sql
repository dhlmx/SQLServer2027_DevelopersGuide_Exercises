SELECT
	*
FROM
	Dimension.Customer;

--

SELECT
	[Customer Key],
	[WWI Customer ID],
	Customer,
	[Buying Group]
FROM
	Dimension.Customer;

--

SELECT
	[Customer Key] AS CustomerKey,
	[WWI Customer ID] AS CustomerId,
	Customer,
	[Buying Group] AS BuyingGroup
FROM
	Dimension.Customer;

--

SELECT
	[Customer Key] AS CustomerKey,
	[WWI Customer ID] AS CustomerId,
	Customer,
	[Buying Group] AS BuyingGroup
FROM
	Dimension.Customer
WHERE
	[Customer Key] <> 0;

--

SELECT
	c.[Customer Key] AS CustomerKey,
	c.[WWI Customer ID] AS CustomerId,
	c.Customer,
	c.[Buying Group] AS BuyingGroup,
	s.Quantity,
	s.[Total Excluding Tax] AS Amount,
	s.Profit
FROM
	Fact.Sale AS s
INNER JOIN
	Dimension.Customer AS c
ON
	s.[Customer Key] = c.[Customer Key];

--

SELECT
	c.[Customer Key] AS CustomerKey,
	c.[WWI Customer ID] AS CustomerId,
	c.Customer,
	c.[Buying Group] AS BuyingGroup,
	s.Quantity,
	s.[Total Excluding Tax] AS Amount,
	s.Profit
FROM
	Fact.Sale AS s
INNER JOIN
	Dimension.Customer AS c
ON
	s.[Customer Key] = c.[Customer Key]
WHERE
	c.[Customer Key] <> 0;

--

SELECT
	d.Date,
	s.[Total Excluding Tax],
	s.[Delivery Date Key]
FROM
	Fact.Sale AS s
INNER JOIN
	Dimension.Date AS d
ON
	s.[Delivery Date Key] = d.Date;


--

SELECT
	d.Date,
	s.[Total Excluding Tax],
	s.[Delivery Date Key],
	s.[Invoice Date Key]
FROM
	Fact.Sale AS s
LEFT OUTER JOIN
	Dimension.Date AS d
ON
	s.[Delivery Date Key] = d.Date
ORDER BY
	s.[Invoice Date Key] DESC;

--

SELECT
	cu.[Customer Key] AS CustomerKey,
	cu.Customer, 
	ci.[City Key] AS CityKey,
	ci.City,  
	ci.[State Province] AS StateProvince,
	ci.[Sales Territory] AS SalesTeritory, 
	d.Date,
	d.[Calendar Month Label] AS CalendarMonth,  
	d.[Calendar Year] AS CalendarYear, 
	s.[Stock Item Key] AS StockItemKey,
	s.[Stock Item] AS Product,
	s.Color, 
	e.[Employee Key] AS EmployeeKey,
	e.Employee, 
	f.Quantity,
	f.[Total Excluding Tax] AS TotalAmount,
	f.Profit 
FROM
(
	Fact.Sale AS f
	INNER JOIN
		Dimension.Customer AS cu 
	    ON f.[Customer Key] = cu.[Customer Key] 
	INNER JOIN
		Dimension.City AS ci 
		ON f.[City Key] = ci.[City Key] 
	INNER JOIN
		Dimension.[Stock Item] AS s 
		ON f.[Stock Item Key] = s.[Stock Item Key] 
	INNER JOIN
		Dimension.Employee AS e 
		ON f.[Salesperson Key] = e.[Employee Key]
)
LEFT OUTER JOIN
	Dimension.Date AS d 
	ON f.[Delivery Date Key] = d.Date;

--

SELECT COUNT(*) AS SalesCount FROM Fact.Sale;

--

SELECT
	c.Customer, 
	COUNT(*) AS Orders,
	SUM(f.Quantity) AS TotalQuantity, 
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
	c.Customer;

--

SELECT
	c.Customer,
	SUM(f.Quantity) AS TotalQuantity,
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
HAVING
	COUNT(*) > 400; 

--

SELECT
	c.Customer,
	SUM(f.Quantity) AS TotalQuantity, 
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
HAVING
	COUNT(*) > 400 
ORDER BY
	SalesCount DESC;
