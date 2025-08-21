--Converting JSON data in a tabular format
--OPENJSON with the default schema
DECLARE @json NVARCHAR(MAX) = N'{
	"Album":"Wish You Were Here", 
	"Year":1975, 
	"IsVinyl":true, 
	"Songs":[
		{"Title":"Shine On You Crazy Diamond","Authors":"Gilmour, Waters, Wright"}, 
		{"Title":"Have a Cigar","Authors":"Waters"}, 
		{"Title":"Welcome to the Machine","Authors":"Waters"}, 
		{"Title":"Wish You Were Here","Authors":"Gilmour, Waters"}
	],
	"Members":{
		"Guitar":"David Gilmour",
		"Bass Guitar":"Roger Waters",
		"Keyboard":"Richard Wright",
		"Drums":"Nick Mason"
	}
}'; 

SELECT * FROM OPENJSON(@json); 

DECLARE @json NVARCHAR(MAX) = N'{
	"Album":"Wish You Were Here", 
	"Year":1975, 
	"IsVinyl":true, 
	"Songs":[
		{"Title":"Shine On You Crazy Diamond","Authors":"Gilmour, Waters, Wright"}, 
		{"Title":"Have a Cigar","Authors":"Waters"}, 
		{"Title":"Welcome to the Machine","Authors":"Waters"}, 
		{"Title":"Wish You Were Here","Authors":"Gilmour, Waters"}
	], 
	"Members":{
		"Guitar":"David Gilmour",
		"Bass Guitar":"Roger Waters",
		"Keyboard":"Richard Wright",
		"Drums":"Nick Mason"
	} 
}';

SELECT * FROM OPENJSON(@json,'$.Songs');

DECLARE @json NVARCHAR(MAX) = N'{
	"Album":"Wish You Were Here", 
	"Year":1975, 
	"IsVinyl":true, 
	"Songs":[
		{"Title":"Shine On You Crazy Diamond","Authors":"Gilmour, Waters, Wright"}, 
		{"Title":"Have a Cigar","Authors":"Waters"}, 
		{"Title":"Welcome to the Machine","Authors":"Waters"}, 
		{"Title":"Wish You Were Here","Authors":"Gilmour, Waters"}
	], 
	"Members":{
		"Guitar":"David Gilmour",
		"Bass Guitar":"Roger Waters",
		"Keyboard":"Richard Wright",
		"Drums":"Nick Mason"
	} 
}';

SELECT * FROM OPENJSON(@json,'$.Members');

--Processing data from a comma-separated list of values
USE WideWorldImporters2016; 

DECLARE @orderIds AS VARCHAR(100) = '1,3,7,8,9,11'; 

SELECT
	o.OrderID,
	o.CustomerID,
	o.OrderDate  
FROM
	Sales.Orders o 
INNER JOIN
	(
		SELECT
			value
		FROM
			OPENJSON('[' + @orderIds + ']' )
	) x
	ON x.value= o.OrderID;

--Returning the difference between two table rows
SELECT  
  mst.[key],  
  mst.[value] AS mst_val,  
  mdl.[value] AS mdl_val 
FROM
	OPENJSON (
		(
			SELECT
				* 
			FROM
				sys.databases
			WHERE
				database_id = 1
			FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
		)
	) mst 
INNER JOIN
	OPENJSON(
		(
			SELECT
				*
			FROM
				sys.databases
			WHERE
				database_id = 3
			FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
		)
	) mdl 
	ON mst.[key] = mdl.[key] 
	AND mst.[value] <> mdl.[value]

--OPENJSON with an explicit schema
DECLARE @json NVARCHAR(MAX) = N'{
	"Album":"Wish You Were Here", 
	"Year":1975, 
	"IsVinyl":true, 
	"Songs" :[
		{"Title":"Shine On You Crazy Diamond","Writers":"Gilmour, Waters, Wright"}, 
		{"Title":"Have a Cigar","Writers":"Waters"}, 
		{"Title":"Welcome to the Machine","Writers":"Waters"}, 
		{"Title":"Wish You Were Here","Writers":"Gilmour, Waters"}
	], 
	"Members":{
		"Guitar":"David Gilmour",
		"Bass Guitar":"Roger Waters",
		"Keyboard":"Richard Wright",
		"Drums":"Nick Mason"
	} 
}'; 
SELECT
	*
FROM
	OPENJSON(@json) 
WITH 
( 
 AlbumName NVARCHAR(50) '$.Album', 
  AlbumYear SMALLINT '$.Year', 
  IsVinyl BIT '$.IsVinyl',
	Members NVARCHAR(MAX) '$.Members' AS JSON
);

DECLARE @json NVARCHAR(MAX) = N'{ 
	"Album":"Wish You Were Here", 
	"Year":1975, 
	"IsVinyl":true, 
	"Songs" :[
		{"Title":"Shine On You Crazy Diamond","Writers":"Gilmour, Waters, Wright"}, 
		{"Title":"Have a Cigar","Writers":"Waters"}, 
		{"Title":"Welcome to the Machine","Writers":"Waters"}, 
		{"Title":"Wish You Were Here","Writers":"Gilmour, Waters"}
	], 
	"Members":{
		"Guitar":"David Gilmour",
		"Bass Guitar":"Roger Waters",
		"Keyboard":"Richard Wright",
		"Drums":"Nick Mason"
	} 
}'; 
SELECT
	s.SongTitle,
	s.SongAuthors,
	a.AlbumName
FROM
	OPENJSON(@json) 
	WITH 
	( 
		AlbumName NVARCHAR(50) '$.Album', 
		AlbumYear SMALLINT '$.Year', 
		IsVinyl BIT '$.IsVinyl', 
		Songs  NVARCHAR(MAX) '$.Songs' AS JSON, 
		Members NVARCHAR(MAX) '$.Members' AS JSON 
	) a 
CROSS APPLY
	OPENJSON(Songs) 
	WITH 
	( 
		SongTitle NVARCHAR(200) '$.Title', 
		SongAuthors NVARCHAR(200) '$.Writers' 
	)s;

--Import the JSON data from a file
USE WideWorldImporters;

SELECT
	PersonID,
	FullName,
	PhoneNumber,
	FaxNumber,
	EmailAddress,
	LogonName,
	IsEmployee,
	IsSalesperson
FROM
	Application.People
FOR JSON AUTO;

SELECT
	BulkColumn 
FROM
	OPENROWSET (BULK 'C:\dev\mssqlserver\SQLServer2027_DevelopersGuide_Exercises\app.people.json', SINGLE_CLOB) AS x;

SELECT
	[key],
	[value],
	[type]
FROM
	OPENROWSET (BULK 'C:\dev\mssqlserver\SQLServer2027_DevelopersGuide_Exercises\app.people.json', SINGLE_CLOB) AS x
CROSS APPLY OPENJSON(BulkColumn);


SELECT
	PersonID,
	FullName,
	PhoneNumber,
	FaxNumber,
	EmailAddress,
	LogonName,
	IsEmployee,
	IsSalesperson 
FROM
	OPENROWSET (BULK 'C:\dev\mssqlserver\SQLServer2027_DevelopersGuide_Exercises\app.people.json', SINGLE_CLOB) AS j
CROSS APPLY OPENJSON(BulkColumn) 
WITH 
( 
  PersonID INT '$.PersonID', 
  FullName NVARCHAR(50) '$.FullName', 
  PhoneNumber NVARCHAR(20) '$.PhoneNumber', 
  FaxNumber NVARCHAR(20) '$.FaxNumber', 
  EmailAddress NVARCHAR(256) '$.EmailAddress', 
  LogonName NVARCHAR(50) '$.LogonName', 
  IsEmployee  BIT '$.IsEmployee', 
  IsSalesperson BIT '$.IsSalesperson' 
); 
