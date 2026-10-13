CREATE TABLE [dim].[DimDate] (
    [DateKey]        INT           NOT NULL,
    [FullDate]       DATE          NOT NULL,
    [Year]           SMALLINT      NOT NULL,
    [Quarter]        TINYINT       NOT NULL,
    [QuarterName]    NVARCHAR (10) NOT NULL,
    [Month]          TINYINT       NOT NULL,
    [MonthName]      NVARCHAR (15) NOT NULL,
    [MonthShortName] NVARCHAR (3)  NOT NULL,
    [YearMonth]      INT           NOT NULL,
    [YearMonthName]  NVARCHAR (10) NOT NULL,
    [Day]            TINYINT       NOT NULL,
    [DayOfWeek]      TINYINT       NOT NULL,
    [DayName]        NVARCHAR (15) NOT NULL,
    [WeekOfYear]     TINYINT       NOT NULL,
    [IsWeekend]      BIT           NOT NULL,
    CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED ([DateKey] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_DimDate_FullDate]
    ON [dim].[DimDate]([FullDate] ASC);

