CREATE TABLE [fact].[FactSales] (
    [SalesKey]         BIGINT          IDENTITY (1, 1) NOT NULL,
    [OrderID]          INT             NOT NULL,
    [OrderDateKey]     INT             NOT NULL,
    [RequiredDateKey]  INT             NOT NULL,
    [ShippedDateKey]   INT             NOT NULL,
    [CustomerKey]      INT             NOT NULL,
    [EmployeeKey]      INT             NOT NULL,
    [ProductKey]       INT             NOT NULL,
    [ShipperKey]       INT             NOT NULL,
    [Quantity]         SMALLINT        NOT NULL,
    [UnitPrice]        MONEY           NOT NULL,
    [Discount]         DECIMAL (5, 4)  NOT NULL,
    [GrossAmount]      DECIMAL (19, 4) NOT NULL,
    [DiscountAmount]   DECIMAL (19, 4) NOT NULL,
    [NetAmount]        DECIMAL (19, 4) NOT NULL,
    [FreightAllocated] DECIMAL (19, 4) NULL,
    [DaysToShip]       INT             NULL,
    [IsShipped]        BIT             NOT NULL,
    [IsLate]           BIT             NULL,
    [LoadedAt]         DATETIME2 (0)   CONSTRAINT [DF_FactSales_LoadedAt] DEFAULT (sysdatetime()) NOT NULL,
    CONSTRAINT [PK_FactSales] PRIMARY KEY CLUSTERED ([SalesKey] ASC),
    CONSTRAINT [FK_FactSales_Customer] FOREIGN KEY ([CustomerKey]) REFERENCES [dim].[DimCustomer] ([CustomerKey]),
    CONSTRAINT [FK_FactSales_Employee] FOREIGN KEY ([EmployeeKey]) REFERENCES [dim].[DimEmployee] ([EmployeeKey]),
    CONSTRAINT [FK_FactSales_OrderDate] FOREIGN KEY ([OrderDateKey]) REFERENCES [dim].[DimDate] ([DateKey]),
    CONSTRAINT [FK_FactSales_Product] FOREIGN KEY ([ProductKey]) REFERENCES [dim].[DimProduct] ([ProductKey]),
    CONSTRAINT [FK_FactSales_RequiredDate] FOREIGN KEY ([RequiredDateKey]) REFERENCES [dim].[DimDate] ([DateKey]),
    CONSTRAINT [FK_FactSales_ShippedDate] FOREIGN KEY ([ShippedDateKey]) REFERENCES [dim].[DimDate] ([DateKey]),
    CONSTRAINT [FK_FactSales_Shipper] FOREIGN KEY ([ShipperKey]) REFERENCES [dim].[DimShipper] ([ShipperKey])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_FactSales_Order_Product]
    ON [fact].[FactSales]([OrderID] ASC, [ProductKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_OrderDateKey]
    ON [fact].[FactSales]([OrderDateKey] ASC)
    INCLUDE([NetAmount], [Quantity]);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_CustomerKey]
    ON [fact].[FactSales]([CustomerKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_ProductKey]
    ON [fact].[FactSales]([ProductKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_EmployeeKey]
    ON [fact].[FactSales]([EmployeeKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSales_ShipperKey]
    ON [fact].[FactSales]([ShipperKey] ASC);

