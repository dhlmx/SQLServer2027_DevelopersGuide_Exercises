--JSON Support in SQL Server.sql
--Why JSON?
--What is JSON?
--JSON object
{ 
	"Name":"Mila Radivojevic",  
	"Age":12,  
	"Instrument": "Flute" 
}
{}
{ 
	"Song":"Echoes",  
	"Group":"Pink Floyd",  
	"Album":{ 
		"Name":"Meddle",  
		"Year":1971 
	} 
} 
{ 
	"Name":"Tom Waits", 
	"Name":"Leonard Cohen" 
} 

--JSON array
["Benfica","Juventus","Rapid Vienna","Seattle Seahawks"] 
["NTNK",3,"Käsekrainer","Sejo Kalac","political correctness",true,null] 

--Primitive JSON data types
--Numbers: This is a double-precision float
--String: Unicode text surrounded by double quotes
--True/false: Boolean values; they must be written in lowercase
--Null: This represents a null value

--JSON in SQL Server prior to SQL Server 2016
--JSON4SQL
--JSON.SQL
--Transact-SQL-based solution
--Consuming JSON Strings in SQL Server: You can find this article at https://www.simple-talk.com/sql/t-sql-programming/consuming-json-strings-in-sql-server/.
--Producing JSON Documents from SQL Server queries via TSQL: The article is available at https://www.simple-talk.com/sql/t-sql-programming/producing-json-documents-from-sql-server-queries-via-tsql/.

--Retrieving SQL Server data in JSON format
--FOR JSON AUTO
--Error
SELECT GETDATE() AS today FOR JSON AUTO;
--Msg 13600, Level 16, State 1, Line 13
--FOR JSON AUTO requires at least one table for generating JSON objects. Use FOR JSON PATH or add a FROM clause with a table name.

USE WideWorldImporters;

SELECT
	TOP (3)
	PersonID,
	FullName,
	EmailAddress,
	PhoneNumber 
FROM
	[Application].People
ORDER BY
	PersonID ASC;

SELECT
	TOP (3)
	PersonID,
	FullName,
	EmailAddress,
	PhoneNumber 
FROM
	[Application].People
ORDER BY
	PersonID ASC
FOR XML AUTO;

SELECT
	TOP (3)
	PersonID,
	FullName,
	EmailAddress,
	PhoneNumber 
FROM
	[Application].People
ORDER BY
	PersonID ASC
FOR JSON AUTO;

USE WideWorldImporters; 

SELECT  
  DATALENGTH(CAST(
		(
			SELECT
				*
			FROM
				Sales.Orders
			FOR XML AUTO
		) AS NVARCHAR(MAX))
	) AS xml_raw_size,
	DATALENGTH(CAST(
		(
			SELECT
				*
			FROM
				Sales.Orders
			FOR XML AUTO, ELEMENTS
			) AS NVARCHAR(MAX))
		) AS xml_elements_size,
		DATALENGTH(CAST(
			(
				SELECT
					*
				FROM
					Sales.Orders
				FOR JSON AUTO
			) AS NVARCHAR(MAX))
		) AS json_size;


--FOR JSON PATH
SELECT
	TOP (3)
	PersonID,
	FullName,  
	EmailAddress AS 'Contact.Email',
	PhoneNumber AS 'Contact.Phone'
FROM
	Application.People
ORDER BY
	PersonID ASC
FOR JSON PATH;

SELECT
	GETDATE() AS today
FOR JSON PATH;

--FOR JSON additional options
--Add a root node: This option allows you to add a top-level element to the JSON output.
--Include null values: This option allows you to include null values in the JSON output (by default they are not shown).
--Remove array wrapper: By using this option, you can format JSON output as a single object.

--Add a root node to JSON output
SELECT
	TOP (3)
	PersonID,
	FullName,
	EmailAddress,
	PhoneNumber 
FROM
	Application.People
ORDER BY
	PersonID ASC
FOR JSON AUTO, ROOT('Persons');

--Include NULL values in the JSON output
SELECT
	TOP (3)
	PersonID,
	FullName,
	EmailAddress,
	PhoneNumber  
FROM
	Application.People
ORDER BY
	PersonID ASC
FOR JSON AUTO, INCLUDE_NULL_VALUES; 

--Formatting a JSON output as a single object
SELECT
	PersonID,
	FullName,
	EmailAddress,
	PhoneNumber  
FROM
	Application.People
WHERE
	PersonID = 2
FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER;

--Converting data types
--ERROR
SELECT
	PersonID,
	FullName,
	EmailAddress,
	PhoneNumber  
FROM
	Application.People
WHERE
	PersonID IN (2, 3)
FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, ROOT('');

--ERROR
SELECT
	*
FROM
	Application.Cities
FOR JSON AUTO; 

SELECT
	*
FROM
	Application.Cities; 

--Escaping characters
