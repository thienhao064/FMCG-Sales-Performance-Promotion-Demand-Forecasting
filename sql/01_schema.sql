IF OBJECT_ID('dbo.fmcg_sales', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.fmcg_sales
    (
        date            DATE           NOT NULL,
        sku               NVARCHAR(50)    NOT NULL,
        brand             NVARCHAR(50)    NOT NULL,
        segment           NVARCHAR(50)    NOT NULL,
        category          NVARCHAR(50)    NOT NULL,
        channel           NVARCHAR(50)    NOT NULL,
        region            NVARCHAR(50)    NOT NULL,
        pack_type         NVARCHAR(50)    NOT NULL,
        price_unit        DECIMAL(10,2)  NOT NULL,
        promotion_flag    SMALLINT       NOT NULL,
        delivery_days     INT            NULL,
        stock_available   INT            NULL,
        delivered_qty     INT            NULL,
        units_sold        INT            NULL,

        CONSTRAINT PK_fmcg_sales PRIMARY KEY
        (
            date,
            sku,
            channel,
            region,
            pack_type
        )
    );
END;
GO