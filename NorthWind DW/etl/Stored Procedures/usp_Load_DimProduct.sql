
-- ---------------------------------------------------------------------
-- etl/Stored Procedures/usp_Load_DimProduct.sql
-- ---------------------------------------------------------------------

CREATE PROCEDURE [etl].[usp_Load_DimProduct]
AS
BEGIN
    SET NOCOUNT ON;

    MERGE [dim].[DimProduct] AS t
    USING (
        SELECT
            p.[ProductID],
            p.[ProductName]     COLLATE DATABASE_DEFAULT AS [ProductName],
            p.[QuantityPerUnit] COLLATE DATABASE_DEFAULT AS [QuantityPerUnit],
            p.[UnitPrice]                                AS [ListUnitPrice],
            p.[Discontinued],
            CAST(CASE WHEN p.[Discontinued] = 1 THEN N'Descontinuado' ELSE N'Activo' END AS NVARCHAR(15))
                                COLLATE DATABASE_DEFAULT AS [ProductStatus],
            p.[CategoryID],
            ISNULL(c.[CategoryName], N'N/D')             COLLATE DATABASE_DEFAULT AS [CategoryName],
            CAST(c.[Description] AS NVARCHAR(MAX))       COLLATE DATABASE_DEFAULT AS [CategoryDescription],
            p.[SupplierID],
            ISNULL(sp.[CompanyName], N'N/D')              COLLATE DATABASE_DEFAULT AS [SupplierName],
            sp.[City]                                    COLLATE DATABASE_DEFAULT AS [SupplierCity],
            sp.[Country]                                 COLLATE DATABASE_DEFAULT AS [SupplierCountry]
        FROM [NorthWind].[dbo].[Products] AS p
        LEFT JOIN [NorthWind].[dbo].[Categories] AS c ON c.[CategoryID] = p.[CategoryID]
        LEFT JOIN [NorthWind].[dbo].[Suppliers]  AS sp ON sp.[SupplierID] = p.[SupplierID]
    ) AS s
    ON t.[ProductID] = s.[ProductID]
    WHEN MATCHED AND EXISTS (
        SELECT s.[ProductName], s.[QuantityPerUnit], s.[ListUnitPrice], s.[Discontinued], s.[ProductStatus],
               s.[CategoryID], s.[CategoryName], s.[CategoryDescription],
               s.[SupplierID], s.[SupplierName], s.[SupplierCity], s.[SupplierCountry]
        EXCEPT
        SELECT t.[ProductName], t.[QuantityPerUnit], t.[ListUnitPrice], t.[Discontinued], t.[ProductStatus],
               t.[CategoryID], t.[CategoryName], t.[CategoryDescription],
               t.[SupplierID], t.[SupplierName], t.[SupplierCity], t.[SupplierCountry]
    ) THEN UPDATE SET
        t.[ProductName]         = s.[ProductName],
        t.[QuantityPerUnit]     = s.[QuantityPerUnit],
        t.[ListUnitPrice]       = s.[ListUnitPrice],
        t.[Discontinued]        = s.[Discontinued],
        t.[ProductStatus]       = s.[ProductStatus],
        t.[CategoryID]          = s.[CategoryID],
        t.[CategoryName]        = s.[CategoryName],
        t.[CategoryDescription] = s.[CategoryDescription],
        t.[SupplierID]          = s.[SupplierID],
        t.[SupplierName]        = s.[SupplierName],
        t.[SupplierCity]        = s.[SupplierCity],
        t.[SupplierCountry]     = s.[SupplierCountry],
        t.[UpdatedAt]           = SYSDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([ProductID],[ProductName],[QuantityPerUnit],[ListUnitPrice],[Discontinued],[ProductStatus],
                [CategoryID],[CategoryName],[CategoryDescription],[SupplierID],[SupplierName],[SupplierCity],[SupplierCountry])
        VALUES (s.[ProductID],s.[ProductName],s.[QuantityPerUnit],s.[ListUnitPrice],s.[Discontinued],s.[ProductStatus],
                s.[CategoryID],s.[CategoryName],s.[CategoryDescription],s.[SupplierID],s.[SupplierName],s.[SupplierCity],s.[SupplierCountry]);
END;
