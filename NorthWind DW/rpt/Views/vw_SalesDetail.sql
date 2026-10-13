
-- ---------------------------------------------------------------------
-- rpt/Views/vw_SalesDetail.sql
-- ---------------------------------------------------------------------
-- Vista plana del modelo estrella, lista para Excel / Power BI / consultas ad hoc.
CREATE VIEW [rpt].[vw_SalesDetail]
AS
SELECT
    f.[OrderID],
    od.[FullDate]        AS [OrderDate],
    od.[Year]            AS [OrderYear],
    od.[QuarterName]     AS [OrderQuarter],
    od.[YearMonth]       AS [OrderYearMonth],
    od.[MonthName]       AS [OrderMonth],
    sd.[FullDate]        AS [ShippedDate],
    c.[CustomerID],
    c.[CompanyName]      AS [Customer],
    c.[City]             AS [CustomerCity],
    c.[Country]          AS [CustomerCountry],
    c.[MarketRegion],
    p.[ProductName]      AS [Product],
    p.[CategoryName]     AS [Category],
    p.[SupplierName]     AS [Supplier],
    p.[SupplierCountry],
    e.[FullName]         AS [Employee],
    e.[ManagerName],
    e.[SalesRegion],
    s.[CompanyName]      AS [Shipper],
    f.[Quantity],
    f.[UnitPrice],
    f.[Discount],
    f.[GrossAmount],
    f.[DiscountAmount],
    f.[NetAmount],
    f.[FreightAllocated],
    f.[DaysToShip],
    f.[IsShipped],
    f.[IsLate]
FROM [fact].[FactSales]  AS f
JOIN [dim].[DimDate]     AS od ON od.[DateKey]     = f.[OrderDateKey]
JOIN [dim].[DimDate]     AS sd ON sd.[DateKey]     = f.[ShippedDateKey]
JOIN [dim].[DimCustomer] AS c  ON c.[CustomerKey]  = f.[CustomerKey]
JOIN [dim].[DimProduct]  AS p  ON p.[ProductKey]   = f.[ProductKey]
JOIN [dim].[DimEmployee] AS e  ON e.[EmployeeKey]  = f.[EmployeeKey]
JOIN [dim].[DimShipper]  AS s  ON s.[ShipperKey]   = f.[ShipperKey];
