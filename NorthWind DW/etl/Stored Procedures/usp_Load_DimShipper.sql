
-- ---------------------------------------------------------------------
-- etl/Stored Procedures/usp_Load_DimShipper.sql
-- ---------------------------------------------------------------------
-- Carga de Transportitas (SCD Tipo 1)
CREATE PROCEDURE [etl].[usp_Load_DimShipper]
AS
BEGIN
    SET NOCOUNT ON;

    MERGE [dim].[DimShipper] AS t
    USING (
        SELECT sh.[ShipperID],
               sh.[CompanyName] COLLATE DATABASE_DEFAULT AS [CompanyName],
               sh.[Phone]       COLLATE DATABASE_DEFAULT AS [Phone]
        FROM [NorthWind].[dbo].[Shippers] AS sh
    ) AS s
    ON t.[ShipperID] = s.[ShipperID]
    WHEN MATCHED AND EXISTS (
        SELECT s.[CompanyName], s.[Phone]
        EXCEPT
        SELECT t.[CompanyName], t.[Phone]
    ) THEN UPDATE SET
        t.[CompanyName] = s.[CompanyName],
        t.[Phone]       = s.[Phone],
        t.[UpdatedAt]   = SYSDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([ShipperID],[CompanyName],[Phone])
        VALUES (s.[ShipperID],s.[CompanyName],s.[Phone]);
END;
