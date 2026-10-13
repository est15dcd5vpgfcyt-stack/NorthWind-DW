
-- ---------------------------------------------------------------------
-- etl/Stored Procedures/usp_Load_All.sql
-- ---------------------------------------------------------------------

-- Uso:  EXEC etl.usp_Load_All;
CREATE PROCEDURE [etl].[usp_Load_All]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        EXEC [etl].[usp_Ensure_UnknownMembers];
        EXEC [etl].[usp_Load_DimDate];
        EXEC [etl].[usp_Load_DimCustomer];
        EXEC [etl].[usp_Load_DimProduct];
        EXEC [etl].[usp_Load_DimEmployee];
        EXEC [etl].[usp_Load_DimShipper];
        EXEC [etl].[usp_Load_FactSales];

        COMMIT TRANSACTION;

        SELECT N'dim.DimDate'     AS [Tabla], COUNT(*) AS [Filas] FROM [dim].[DimDate]     UNION ALL
        SELECT N'dim.DimCustomer',            COUNT(*)            FROM [dim].[DimCustomer] UNION ALL
        SELECT N'dim.DimProduct',             COUNT(*)            FROM [dim].[DimProduct]  UNION ALL
        SELECT N'dim.DimEmployee',            COUNT(*)            FROM [dim].[DimEmployee] UNION ALL
        SELECT N'dim.DimShipper',             COUNT(*)            FROM [dim].[DimShipper]  UNION ALL
        SELECT N'fact.FactSales',             COUNT(*)            FROM [fact].[FactSales];
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
