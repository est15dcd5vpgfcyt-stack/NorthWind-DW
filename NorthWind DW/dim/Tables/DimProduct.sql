CREATE TABLE [dim].[DimProduct] (
    [ProductKey]          INT            IDENTITY (1, 1) NOT NULL,
    [ProductID]           INT            NOT NULL,
    [ProductName]         NVARCHAR (40)  NOT NULL,
    [QuantityPerUnit]     NVARCHAR (20)  NULL,
    [ListUnitPrice]       MONEY          NULL,
    [Discontinued]        BIT            NOT NULL,
    [ProductStatus]       NVARCHAR (15)  NOT NULL,
    [CategoryID]          INT            NULL,
    [CategoryName]        NVARCHAR (15)  NULL,
    [CategoryDescription] NVARCHAR (MAX) NULL,
    [SupplierID]          INT            NULL,
    [SupplierName]        NVARCHAR (40)  NULL,
    [SupplierCity]        NVARCHAR (15)  NULL,
    [SupplierCountry]     NVARCHAR (15)  NULL,
    [LoadedAt]            DATETIME2 (0)  CONSTRAINT [DF_DimProduct_LoadedAt] DEFAULT (sysdatetime()) NOT NULL,
    [UpdatedAt]           DATETIME2 (0)  NULL,
    CONSTRAINT [PK_DimProduct] PRIMARY KEY CLUSTERED ([ProductKey] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimProduct_ProductID]
    ON [dim].[DimProduct]([ProductID] ASC);

