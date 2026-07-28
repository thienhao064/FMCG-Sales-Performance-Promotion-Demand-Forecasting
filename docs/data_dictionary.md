**Data Dictionary**
- Grain: `date × sku × channel × region × pack_type`
- Rows: 190,757
- Columns: 14
- Timerange: From 2022-01-21 to 2024-12-31

| # | Column | Type | Description | Observed values / notes |
|---|--------|------|-------------|--------------------------|
| 1 | `date` | date (YYYY-MM-DD) | Transaction day | 2022-01-21 → 2024-12-31 |
| 2 | `sku` | string | Stock Keeping Unit | `MI-006`, `MI-026`, `SN-030`. Prefix = category code (`MI`=Milk, `SN`=SnackBar, …) |
| 3 | `brand` | string | Brand name | `MiBrand1`, `MiBrand4`, `SnBrand2`. `<CatCode>Brand<n>`. |
| 4 | `segment` | string | Sub-segment within a category | `Milk-Seg2`, `Milk-Seg3`, `SnackBar-Seg1`. |
| 5 | `category` | string | Top product category | `Milk`, `SnackBar` |
| 6 | `channel` | string | Sales channel | `Retail`, `Discount`, `E-commerce`. |
| 7 | `region` | string | Region (Poland) | `PL-Central`, `PL-North`, `PL-South`. |
| 8 | `pack_type` | string | Packaging format | `Single`, `Multipack`, `Carton`. |
| 9 | `price_unit` | float | Unit price | Observed 1.50–8.97 |
| 10 | `promotion_flag` | int | 1 = promotion active that day for that row | Binary |
| 11 | `delivery_days` | int | Delivery lead time | Observed 1–5. |
| 12 | `stock_available` | int | Units available in stock | ≥ 0 |
| 13 | `delivered_qty` | int | Units delivered/replenished | ≥ 0 |
| 14 | `units_sold` | int | Units sold | ≥ 0 |
