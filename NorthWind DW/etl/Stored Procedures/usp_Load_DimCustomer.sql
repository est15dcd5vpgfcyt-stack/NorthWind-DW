
-- ---------------------------------------------------------------------
-- etl/Stored Procedures/usp_Load_DimCustomer.sql
-- ---------------------------------------------------------------------
--- Carga incremental de clientes (SCD Tipo 1: se sobrescriben los cambios).
-- COLLATE DATABASE_DEFAULT evita conflictos si NorthWind y NorthWindDW tienen distinta intercalación.
CREATE PROCEDURE [etl].[usp_Load_DimCustomer]
AS
BEGIN
    SET NOCOUNT ON;

    MERGE [dim].[DimCustomer] AS t
    USING (
        SELECT
            c.[CustomerID]   COLLATE DATABASE_DEFAULT AS [CustomerID],
            c.[CompanyName]  COLLATE DATABASE_DEFAULT AS [CompanyName],
            c.[ContactName]  COLLATE DATABASE_DEFAULT AS [ContactName],
            c.[ContactTitle] COLLATE DATABASE_DEFAULT AS [ContactTitle],
            c.[Address]      COLLATE DATABASE_DEFAULT AS [Address],
            c.[City]         COLLATE DATABASE_DEFAULT AS [City],
            ISNULL(c.[Region], N'N/D')     COLLATE DATABASE_DEFAULT AS [Region],
            ISNULL(c.[PostalCode], N'N/D') COLLATE DATABASE_DEFAULT AS [PostalCode],
            c.[Country]      COLLATE DATABASE_DEFAULT AS [Country],
            CAST(CASE
                    WHEN c.[Country] IN (N'USA', N'Canada', N'Mexico')            THEN N'Norteamérica'
                    WHEN c.[Country] IN (N'Argentina', N'Brazil', N'Venezuela')  THEN N'Sudamérica'
                    ELSE N'Europa'
                 END AS NVARCHAR(20)) COLLATE DATABASE_DEFAULT AS [MarketRegion],
            c.[Phone]        COLLATE DATABASE_DEFAULT AS [Phone]
        FROM [NorthWind].[dbo].[Customers] AS c
    ) AS s
    ON t.[CustomerID] = s.[CustomerID]
    WHEN MATCHED AND EXISTS (
        SELECT s.[CompanyName], s.[ContactName], s.[ContactTitle], s.[Address], s.[City],
               s.[Region], s.[PostalCode], s.[Country], s.[MarketRegion], s.[Phone]
        EXCEPT
        SELECT t.[CompanyName], t.[ContactName], t.[ContactTitle], t.[Address], t.[City],
               t.[Region], t.[PostalCode], t.[Country], t.[MarketRegion], t.[Phone]
    ) THEN UPDATE SET
        t.[CompanyName]  = s.[CompanyName],
        t.[ContactName]  = s.[ContactName],
        t.[ContactTitle] = s.[ContactTitle],
        t.[Address]      = s.[Address],
        t.[City]         = s.[City],
        t.[Region]       = s.[Region],
        t.[PostalCode]   = s.[PostalCode],
        t.[Country]      = s.[Country],
        t.[MarketRegion] = s.[MarketRegion],
        t.[Phone]        = s.[Phone],
        t.[UpdatedAt]    = SYSDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([CustomerID],[CompanyName],[ContactName],[ContactTitle],[Address],[City],
                [Region],[PostalCode],[Country],[MarketRegion],[Phone])
        VALUES (s.[CustomerID],s.[CompanyName],s.[ContactName],s.[ContactTitle],s.[Address],s.[City],
                s.[Region],s.[PostalCode],s.[Country],s.[MarketRegion],s.[Phone]);
END;
