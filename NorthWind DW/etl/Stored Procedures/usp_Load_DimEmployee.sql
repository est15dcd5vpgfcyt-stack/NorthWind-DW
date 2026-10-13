
-- ---------------------------------------------------------------------
-- etl/Stored Procedures/usp_Load_DimEmployee.sql
-- ---------------------------------------------------------------------
-- Carga de empleados: aplana la jerarquía (jefe directo) y la región de ventas
-- (EmployeeTerritories -> Territories -> Region). SCD Tipo 1.
CREATE PROCEDURE [etl].[usp_Load_DimEmployee]
AS
BEGIN
    SET NOCOUNT ON;

    MERGE [dim].[DimEmployee] AS t
    USING (
        SELECT
            e.[EmployeeID],
            CAST(CONCAT(e.[FirstName], N' ', e.[LastName]) AS NVARCHAR(31)) COLLATE DATABASE_DEFAULT AS [FullName],
            e.[FirstName]       COLLATE DATABASE_DEFAULT AS [FirstName],
            e.[LastName]        COLLATE DATABASE_DEFAULT AS [LastName],
            e.[Title]           COLLATE DATABASE_DEFAULT AS [Title],
            e.[TitleOfCourtesy] COLLATE DATABASE_DEFAULT AS [TitleOfCourtesy],
            CAST(e.[BirthDate] AS DATE) AS [BirthDate],
            CAST(e.[HireDate]  AS DATE) AS [HireDate],
            e.[City]            COLLATE DATABASE_DEFAULT AS [City],
            e.[Country]         COLLATE DATABASE_DEFAULT AS [Country],
            e.[ReportsTo]       AS [ManagerID],
            CAST(CASE WHEN m.[EmployeeID] IS NULL THEN N'(Sin jefe)'
                      ELSE CONCAT(m.[FirstName], N' ', m.[LastName]) END AS NVARCHAR(31))
                                COLLATE DATABASE_DEFAULT AS [ManagerName],
            CAST(ISNULL(x.[SalesRegion], N'N/D') AS NVARCHAR(50)) COLLATE DATABASE_DEFAULT AS [SalesRegion],
            x.[TerritoryCount]
        FROM [NorthWind].[dbo].[Employees] AS e
        LEFT JOIN [NorthWind].[dbo].[Employees] AS m ON m.[EmployeeID] = e.[ReportsTo]
        OUTER APPLY (
            SELECT MIN(RTRIM(r.[RegionDescription])) AS [SalesRegion],
                   COUNT(*)                          AS [TerritoryCount]
            FROM [NorthWind].[dbo].[EmployeeTerritories] AS et
            JOIN [NorthWind].[dbo].[Territories] AS tr ON tr.[TerritoryID] = et.[TerritoryID]
            JOIN [NorthWind].[dbo].[Region]      AS r  ON r.[RegionID]     = tr.[RegionID]
            WHERE et.[EmployeeID] = e.[EmployeeID]
        ) AS x
    ) AS s
    ON t.[EmployeeID] = s.[EmployeeID]
    WHEN MATCHED AND EXISTS (
        SELECT s.[FullName], s.[FirstName], s.[LastName], s.[Title], s.[TitleOfCourtesy], s.[BirthDate], s.[HireDate],
               s.[City], s.[Country], s.[ManagerID], s.[ManagerName], s.[SalesRegion], s.[TerritoryCount]
        EXCEPT
        SELECT t.[FullName], t.[FirstName], t.[LastName], t.[Title], t.[TitleOfCourtesy], t.[BirthDate], t.[HireDate],
               t.[City], t.[Country], t.[ManagerID], t.[ManagerName], t.[SalesRegion], t.[TerritoryCount]
    ) THEN UPDATE SET
        t.[FullName]        = s.[FullName],
        t.[FirstName]       = s.[FirstName],
        t.[LastName]        = s.[LastName],
        t.[Title]           = s.[Title],
        t.[TitleOfCourtesy] = s.[TitleOfCourtesy],
        t.[BirthDate]       = s.[BirthDate],
        t.[HireDate]        = s.[HireDate],
        t.[City]            = s.[City],
        t.[Country]         = s.[Country],
        t.[ManagerID]       = s.[ManagerID],
        t.[ManagerName]     = s.[ManagerName],
        t.[SalesRegion]     = s.[SalesRegion],
        t.[TerritoryCount]  = s.[TerritoryCount],
        t.[UpdatedAt]       = SYSDATETIME()
    WHEN NOT MATCHED BY TARGET THEN
        INSERT ([EmployeeID],[FullName],[FirstName],[LastName],[Title],[TitleOfCourtesy],[BirthDate],[HireDate],
                [City],[Country],[ManagerID],[ManagerName],[SalesRegion],[TerritoryCount])
        VALUES (s.[EmployeeID],s.[FullName],s.[FirstName],s.[LastName],s.[Title],s.[TitleOfCourtesy],s.[BirthDate],s.[HireDate],
                s.[City],s.[Country],s.[ManagerID],s.[ManagerName],s.[SalesRegion],s.[TerritoryCount]);
END;
