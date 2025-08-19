USE WideWorldImporters;

SELECT
	CityID,
	CityName,
	--[SalesTerritoryKey] AS SalesTerritory,
	Location AS LocationBinary,
	Location.ToString() AS LocationLongLat
FROM
	Application.Cities
WHERE
	CityID <> 0 
	AND CityName NOT IN (N'External', N'Far West');

SELECT
	C.CityID,
	C.CityName AS City,
	C.StateProvinceID AS [State],
	SP.StateProvinceName,
	C.LatestRecordedPopulation AS [Population],
	C.Location AS SpatialLocation,
	C.Location.ToString() AS LocationLongLat 
FROM
	Application.Cities AS C
INNER JOIN
	Application.StateProvinces AS SP
	ON C.StateProvinceID = SP.StateProvinceID
WHERE
	--C.CityID = 8913
	C.CityName = 'Seattle' -- 114129;
	AND C.ValidTo = '9999-12-31 23:59:59.9999999';

DECLARE @g AS GEOGRAPHY; 
DECLARE @h AS GEOGRAPHY; 
DECLARE @unit AS NVARCHAR(50); 

SET @g = (SELECT Location FROM Application.Cities WHERE CityID = 8913); 
SET @h = (SELECT Location FROM Application.Cities WHERE CityID = 30955); 

SET @unit = (
	SELECT
		unit_of_measure
	FROM
		sys.spatial_reference_systems
	WHERE
		spatial_reference_id = @g.STSrid
);

SELECT
	FORMAT(@g.STDistance(@h), 'N', 'en-us') AS Distance, 
	@unit AS Unit;


DECLARE @g AS GEOGRAPHY;

SET @g = (SELECT Location FROM Application.Cities WHERE CityID = 8913); 

SELECT
	DISTINCT
	C.CityName AS City, 
	SP.StateProvinceName AS [State], 
	FORMAT(C.LatestRecordedPopulation, '000,000') AS [Population],
	FORMAT(@g.STDistance(Location), '000,000.00') AS Distance 
FROM
	Application.Cities AS C
INNER JOIN
	Application.StateProvinces AS SP
	ON C.StateProvinceID = SP.StateProvinceID	
WHERE
	Location.STIntersects(@g.STBuffer(1000000)) = 1
	AND C.LatestRecordedPopulation > 200000
	AND CityID <> 8913
	AND C.ValidTo = '9999-12-31 23:59:59.9999999'
ORDER BY
	Distance; 


--CLR

EXEC sp_configure 'clr enabled', 1; 
RECONFIGURE WITH OVERRIDE; 
-- Check the CLR options
SELECT
    name, value, minimum, maximum, value_in_use
FROM
    sys.configurations
WHERE
    name LIKE N'clr %';


EXEC sys.sp_configure 'show advanced options', 1;
RECONFIGURE WITH OVERRIDE;
EXEC sys.sp_configure 'clr strict security', 1;
RECONFIGURE WITH OVERRIDE;

CREATE ASSEMBLY DescriptiveStatistics  
FROM 'C:\SQL2017DevGuide\DescriptiveStatistics.dll' 
WITH PERMISSION_SET = SAFE;

ALTER AUTHORIZATION ON database::WideWorldImportersDW TO sa;
ALTER DATABASE WideWorldImportersDW SET TRUSTWORTHY ON;

CREATE ASSEMBLY DescriptiveStatistics  
FROM 'C:\SQL2017DevGuide\DescriptiveStatistics.dll' 
WITH PERMISSION_SET = SAFE; 
 
CREATE AGGREGATE dbo.Skew(@s float) 
RETURNS float 
EXTERNAL NAME DescriptiveStatistics.Skew; 
 
CREATE AGGREGATE dbo.Kurt(@s float) 
RETURNS float 
EXTERNAL NAME DescriptiveStatistics.Kurt;


WITH CustomerSalesCTE AS 
( 
	SELECT
		c.Customer,  
		SUM(f.[Total Excluding Tax]) AS TotalAmount 
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
	ROUND(AVG(TotalAmount), 2) AS Average, 
	ROUND(STDEV(TotalAmount), 2) AS StandardDeviation,  
	ROUND(dbo.Skew(TotalAmount), 6) AS Skewness, 
	ROUND(dbo.Kurt(TotalAmount), 6) AS Kurtosis 
FROM
	CustomerSalesCTE;

DROP AGGREGATE dbo.Skew;
DROP AGGREGATE dbo.Kurt;
DROP ASSEMBLY DescriptiveStatistics;
ALTER DATABASE WideWorldImportersDW SET TRUSTWORTHY OFF;
GO
/*
EXEC sp_configure 'clr enabled', 0;
RECONFIGURE WITH OVERRIDE;
EXEC sys.sp_configure 'show advanced options', 0;
RECONFIGURE WITH OVERRIDE;
GO
*/

--XML support in SQL Server
SELECT
	c.CustomerKey,
	c.GeographyKey,
	c.CustomerAlternateKey,  
	--c.[Buying Group] AS BuyingGroup, 
	f.OrderQuantity, 
	f.TotalProductCost,
	f.TaxAmt 
FROM
	dbo.DimCustomer AS c 
INNER JOIN
	dbo.FactInternetSales AS f 
    ON c.CustomerKey = f.CustomerKey 
WHERE
	c.CustomerKey IN (127, 128) 
FOR XML AUTO, ELEMENTS,  
  ROOT('CustomersOrders'), 
  XMLSCHEMA('CustomersOrdersSchema'); 
GO

--XML to Tables

DECLARE @x AS XML;

SET @x = N' 
<CustomersOrders> 
  <Customer custid="1"> 
    <!-- Comment 111 --> 
    <companyname>CustA</companyname> 
    <Order orderid="1"> 
      <orderdate>2016-07-01T00:00:00</orderdate> 
    </Order> 
    <Order orderid="9"> 
      <orderdate>2016-07-03T00:00:00</orderdate> 
    </Order> 
    <Order orderid="12"> 
      <orderdate>2016-07-12T00:00:00</orderdate> 
    </Order> 
  </Customer> 
  <Customer custid="2"> 
    <!-- Comment 222 -->   
    <companyname>CustB</companyname> 
    <Order orderid="3"> 
      <orderdate>2016-07-01T00:00:00</orderdate> 
    </Order> 
    <Order orderid="10"> 
      <orderdate>2016-07-05T00:00:00</orderdate> 
    </Order> 
  </Customer> 
</CustomersOrders>';

SELECT
	@x.query(
		'for $i in CustomersOrders/Customer/Order 
			let $j := $i/orderdate 
            where $i/@orderid < 10900 
        order by ($j)[1] 
		return
	        <Order-orderid-element> 
				<orderid>{data($i/@orderid)}</orderid> 
					{$j} 
            </Order-orderid-element>'
	) 
    AS [Filtered, sorted and reformatted orders with let clause]; 



