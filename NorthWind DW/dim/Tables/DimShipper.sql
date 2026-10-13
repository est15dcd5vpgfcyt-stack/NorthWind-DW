CREATE TABLE [dim].[DimShipper] (
    [ShipperKey]  INT           IDENTITY (1, 1) NOT NULL,
    [ShipperID]   INT           NOT NULL,
    [CompanyName] NVARCHAR (40) NOT NULL,
    [Phone]       NVARCHAR (24) NULL,
    [LoadedAt]    DATETIME2 (0) CONSTRAINT [DF_DimShipper_LoadedAt] DEFAULT (sysdatetime()) NOT NULL,
    [UpdatedAt]   DATETIME2 (0) NULL,
    CONSTRAINT [PK_DimShipper] PRIMARY KEY CLUSTERED ([ShipperKey] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimShipper_ShipperID]
    ON [dim].[DimShipper]([ShipperID] ASC);

