
-- ---------------------------------------------------------------------
-- etl/Stored Procedures/usp_Ensure_UnknownMembers.sql
-- ---------------------------------------------------------------------
 ---  Inserta los "miembros desconocidos" (clave -1) en cada dimensión.
-- Permite que el hecho nunca quede con claves NULL (p.ej. pedido sin fecha de envío).
CREATE PROCEDURE [etl].[usp_Ensure_UnknownMembers]
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM [dim].[DimDate] WHERE [DateKey] = -1)
        INSERT INTO [dim].[DimDate]
            ([DateKey],[FullDate],[Year],[Quarter],[QuarterName],[Month],[MonthName],[MonthShortName],
             [YearMonth],[YearMonthName],[Day],[DayOfWeek],[DayName],[WeekOfYear],[IsWeekend])
        VALUES (-1,'19000101',1900,0,N'N/D',0,N'Desconocido',N'N/D',-1,N'N/D',0,0,N'Desconocido',0,0);

    IF NOT EXISTS (SELECT 1 FROM [dim].[DimCustomer] WHERE [CustomerKey] = -1)
    BEGIN
        SET IDENTITY_INSERT [dim].[DimCustomer] ON;
        INSERT INTO [dim].[DimCustomer] ([CustomerKey],[CustomerID],[CompanyName],[City],[Region],[Country],[MarketRegion])
        VALUES (-1,N'N/D',N'Desconocido',N'N/D',N'N/D',N'N/D',N'N/D');
        SET IDENTITY_INSERT [dim].[DimCustomer] OFF;
    END;

    IF NOT EXISTS (SELECT 1 FROM [dim].[DimProduct] WHERE [ProductKey] = -1)
    BEGIN
        SET IDENTITY_INSERT [dim].[DimProduct] ON;
        INSERT INTO [dim].[DimProduct] ([ProductKey],[ProductID],[ProductName],[Discontinued],[ProductStatus],[CategoryName],[SupplierName])
        VALUES (-1,-1,N'Desconocido',0,N'N/D',N'N/D',N'N/D');
        SET IDENTITY_INSERT [dim].[DimProduct] OFF;
    END;

    IF NOT EXISTS (SELECT 1 FROM [dim].[DimEmployee] WHERE [EmployeeKey] = -1)
    BEGIN
        SET IDENTITY_INSERT [dim].[DimEmployee] ON;
        INSERT INTO [dim].[DimEmployee] ([EmployeeKey],[EmployeeID],[FullName],[SalesRegion])
        VALUES (-1,-1,N'Desconocido',N'N/D');
        SET IDENTITY_INSERT [dim].[DimEmployee] OFF;
    END;

    IF NOT EXISTS (SELECT 1 FROM [dim].[DimShipper] WHERE [ShipperKey] = -1)
    BEGIN
        SET IDENTITY_INSERT [dim].[DimShipper] ON;
        INSERT INTO [dim].[DimShipper] ([ShipperKey],[ShipperID],[CompanyName])
        VALUES (-1,-1,N'Desconocido');
        SET IDENTITY_INSERT [dim].[DimShipper] OFF;
    END;
END;
