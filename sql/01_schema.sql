IF OBJECT_ID(N'fmcg_sales', N'U') IS NULL
BEGIN
    CREATE TABLE fmcg_sales
    (
        date DATE NOT NULL,
        sku NVARCHAR(50) NOT NULL,
        brand NVARCHAR(100) NOT NULL,
        segment NVARCHAR(50) NOT NULL,
        category NVARCHAR(50) NOT NULL,
        channel NVARCHAR(50) NOT NULL,
        region NVARCHAR(50) NOT NULL,
        pack_type NVARCHAR(50) NOT NULL,
        price_unit DECIMAL(18, 2) NOT NULL,
        promotion_flag INT NOT NULL,
        delivery_days INT NULL,
        stock_available INT NULL,
        delivered_qty INT NULL,
        units_sold INT NULL,

        CONSTRAINT PK_fmcg_sales
            PRIMARY KEY
            (date],
             sku,
             channel,
             region,
             pack_type
            )
    );
END;
GO
