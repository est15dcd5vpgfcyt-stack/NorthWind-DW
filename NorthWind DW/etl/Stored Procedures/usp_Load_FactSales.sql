
-- ---------------------------------------------------------------------
-- etl/Stored Procedures/usp_Load_FactSales.sql
-- ---------------------------------------------------------------------
-- Carga completa (truncate + insert) de la tabla de hechos.
-- Busca las claves sustitutas en cada dimensión; si no encuentra, asigna -1 (desconocido).
CREATE PROCEDURE [etl].[usp_Load_FactSales]
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE [fact].[FactSales];

    WITH [src] AS (
        SELECT
            o.[OrderID],
            o.[CustomerID] COLLATE DATABASE_DEFAULT AS [CustomerID],
            o.[EmployeeID],
            o.[ShipVia],
            CAST(o.[OrderDate]    AS DATE) AS [OrderDate],
            CAST(o.[RequiredDate] AS DATE) AS [RequiredDate],
            CAST(o.[ShippedDate]  AS DATE) AS [ShippedDate],
            o.[Freight],
            od.[ProductID],
            od.[Quantity],
            od.[UnitPrice],
            CAST(od.[Discount] AS DECIMAL(5,4))               AS [Discount],
            CAST(od.[UnitPrice] * od.[Quantity] AS DECIMAL(19,4)) AS [GrossAmount]
        FROM [NorthWind].[dbo].[Orders] AS o
        JOIN [NorthWind].[dbo].[OrderDetails] AS od ON od.[OrderID] = o.[OrderID]
    )
    INSERT INTO [fact].[FactSales]
        ([OrderID],[OrderDateKey],[RequiredDateKey],[ShippedDateKey],
         [CustomerKey],[EmployeeKey],[ProductKey],[ShipperKey],
         [Quantity],[UnitPrice],[Discount],[GrossAmount],[DiscountAmount],[NetAmount],
         [FreightAllocated],[DaysToShip],[IsShipped],[IsLate])
    SELECT
        s.[OrderID],
        ISNULL(CONVERT(INT, CONVERT(CHAR(8), s.[OrderDate],    112)), -1),
        ISNULL(CONVERT(INT, CONVERT(CHAR(8), s.[RequiredDate], 112)), -1),
        ISNULL(CONVERT(INT, CONVERT(CHAR(8), s.[ShippedDate],  112)), -1),
        ISNULL(dc.[CustomerKey], -1),
        ISNULL(de.[EmployeeKey], -1),
        ISNULL(dp.[ProductKey],  -1),
        ISNULL(ds.[ShipperKey],  -1),
        s.[Quantity],
        s.[UnitPrice],
        s.[Discount],
        s.[GrossAmount],
        CAST(s.[GrossAmount] * s.[Discount]       AS DECIMAL(19,4)),
        CAST(s.[GrossAmount] * (1 - s.[Discount]) AS DECIMAL(19,4)),
        CAST(s.[Freight] * s.[GrossAmount]
             / NULLIF(SUM(s.[GrossAmount]) OVER (PARTITION BY s.[OrderID]), 0) AS DECIMAL(19,4)),
        DATEDIFF(DAY, s.[OrderDate], s.[ShippedDate]),
        CASE WHEN s.[ShippedDate] IS NULL THEN 0 ELSE 1 END,
        CASE WHEN s.[ShippedDate] IS NULL THEN NULL
             WHEN s.[ShippedDate] > s.[RequiredDate] THEN 1 ELSE 0 END
    FROM [src] AS s
    LEFT JOIN [dim].[DimCustomer] AS dc ON dc.[CustomerID] = s.[CustomerID]
    LEFT JOIN [dim].[DimEmployee] AS de ON de.[EmployeeID] = s.[EmployeeID]
    LEFT JOIN [dim].[DimProduct]  AS dp ON dp.[ProductID]  = s.[ProductID]
    LEFT JOIN [dim].[DimShipper]  AS ds ON ds.[ShipperID]  = s.[ShipVia];

    RETURN @@ROWCOUNT;
END;
