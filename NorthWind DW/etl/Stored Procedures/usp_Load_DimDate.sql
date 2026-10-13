
-- ---------------------------------------------------------------------
-- etl/Stored Procedures/usp_Load_DimDate.sql
-- ---------------------------------------------------------------------
---- Genera el calendario. Si no se pasan fechas, cubre desde el 1-ene del primer año
-- hasta el 31-dic del último año presente en Orders (OrderDate, RequiredDate, ShippedDate).
-- Los nombres se generan en español sin depender de SET LANGUAGE ni de DATEFIRST.
CREATE PROCEDURE [etl].[usp_Load_DimDate]
    @StartDate DATE = NULL,
    @EndDate   DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @StartDate IS NULL OR @EndDate IS NULL
    BEGIN
        DECLARE @MinDate DATE, @MaxDate DATE;

        SELECT @MinDate = MIN(s.[d]), @MaxDate = MAX(s.[d])
        FROM (
            SELECT CAST([OrderDate]    AS DATE) FROM [NorthWind].[dbo].[Orders] UNION ALL
            SELECT CAST([RequiredDate] AS DATE) FROM [NorthWind].[dbo].[Orders] UNION ALL
            SELECT CAST([ShippedDate]  AS DATE) FROM [NorthWind].[dbo].[Orders]
        ) AS s([d]);

        SET @StartDate = ISNULL(@StartDate, DATEFROMPARTS(YEAR(@MinDate), 1, 1));
        SET @EndDate   = ISNULL(@EndDate,   DATEFROMPARTS(YEAR(@MaxDate), 12, 31));
    END;

    WITH [n] AS (
        SELECT TOP (DATEDIFF(DAY, @StartDate, @EndDate) + 1)
               ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS [i]
        FROM sys.all_objects AS a CROSS JOIN sys.all_objects AS b
    ),
    [d] AS (
        SELECT DATEADD(DAY, [i], @StartDate) AS [dt] FROM [n]
    ),
    [c] AS (
        SELECT [dt],
               (DATEDIFF(DAY, '19000101', [dt]) % 7) + 1 AS [dow],   -- 1900-01-01 fue lunes
               CHOOSE(MONTH([dt]), N'Enero',N'Febrero',N'Marzo',N'Abril',N'Mayo',N'Junio',
                                   N'Julio',N'Agosto',N'Septiembre',N'Octubre',N'Noviembre',N'Diciembre') AS [mname]
        FROM [d]
    )
    INSERT INTO [dim].[DimDate]
        ([DateKey],[FullDate],[Year],[Quarter],[QuarterName],[Month],[MonthName],[MonthShortName],
         [YearMonth],[YearMonthName],[Day],[DayOfWeek],[DayName],[WeekOfYear],[IsWeekend])
    SELECT
        CONVERT(INT, CONVERT(CHAR(8), [dt], 112)),
        [dt],
        YEAR([dt]),
        DATEPART(QUARTER, [dt]),
        CONCAT(N'T', DATEPART(QUARTER, [dt]), N' ', YEAR([dt])),
        MONTH([dt]),
        [mname],
        LEFT([mname], 3),
        YEAR([dt]) * 100 + MONTH([dt]),
        CONCAT(LEFT([mname], 3), N' ', YEAR([dt])),
        DAY([dt]),
        [dow],
        CHOOSE([dow], N'Lunes',N'Martes',N'Miércoles',N'Jueves',N'Viernes',N'Sábado',N'Domingo'),
        DATEPART(ISO_WEEK, [dt]),
        CASE WHEN [dow] IN (6, 7) THEN 1 ELSE 0 END
    FROM [c]
    WHERE NOT EXISTS (SELECT 1 FROM [dim].[DimDate] AS x WHERE x.[FullDate] = [c].[dt]);

    RETURN @@ROWCOUNT;
END;
