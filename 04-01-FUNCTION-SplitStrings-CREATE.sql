CREATE FUNCTION dbo.SplitStrings
(
    @input NVARCHAR(MAX),
	@delimiter CHAR(1)
)
RETURNS @output TABLE(item NVARCHAR(MAX)) 
BEGIN 
    DECLARE @start INT, @end INT;

    SELECT 
		@start = 1,
		@end = CHARINDEX(@delimiter, @input);

    WHILE @start < LEN(@input) + 1 
	BEGIN 
        IF @end = 0
            SET @end = LEN(@input) + 1;
       
        INSERT INTO @output
			(item)
	    VALUES
			(SUBSTRING(@input, @start, @end - @start));
			
        SET @start = @end + 1;
        SET @end = CHARINDEX(@delimiter, @input, @start);
    END 
    RETURN 
END
GO
