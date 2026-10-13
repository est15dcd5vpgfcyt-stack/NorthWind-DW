CREATE TABLE [dim].[DimEmployee] (
    [EmployeeKey]     INT           IDENTITY (1, 1) NOT NULL,
    [EmployeeID]      INT           NOT NULL,
    [FullName]        NVARCHAR (31) NOT NULL,
    [FirstName]       NVARCHAR (10) NULL,
    [LastName]        NVARCHAR (20) NULL,
    [Title]           NVARCHAR (30) NULL,
    [TitleOfCourtesy] NVARCHAR (25) NULL,
    [BirthDate]       DATE          NULL,
    [HireDate]        DATE          NULL,
    [City]            NVARCHAR (15) NULL,
    [Country]         NVARCHAR (15) NULL,
    [ManagerID]       INT           NULL,
    [ManagerName]     NVARCHAR (31) NULL,
    [SalesRegion]     NVARCHAR (50) NULL,
    [TerritoryCount]  INT           NULL,
    [LoadedAt]        DATETIME2 (0) CONSTRAINT [DF_DimEmployee_LoadedAt] DEFAULT (sysdatetime()) NOT NULL,
    [UpdatedAt]       DATETIME2 (0) NULL,
    CONSTRAINT [PK_DimEmployee] PRIMARY KEY CLUSTERED ([EmployeeKey] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimEmployee_EmployeeID]
    ON [dim].[DimEmployee]([EmployeeID] ASC);

