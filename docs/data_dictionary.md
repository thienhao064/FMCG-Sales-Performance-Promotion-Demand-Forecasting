Data Dictionary
- Grain: One row per `date × sku × channel × region × pack_type`
- Rows: 190,757
- Columns: 14
- Timerange: From 2022-01-21 to 2024-12-31

| # | Column | Type | Description | Observed values / notes |
|---|--------|------|-------------|--------------------------|
| 1 | `date` | date (YYYY-MM-DD) | Transaction/observation day | 2022-01-21 → 2024-12-31. File is grouped by SKU then date — **not** globally date-sorted. |
| 2 | `sku` | string | Stock Keeping Unit (product code) | e.g. `MI-006`, `MI-026`, `SN-030`. Prefix = category code (`MI`=Milk, `SN`=SnackBar, …). New SKUs appear in 2024. |
| 3 | `brand` | string | Brand name | e.g. `MiBrand1`, `MiBrand4`, `SnBrand2`. Pattern `<CatCode>Brand<n>`. |
| 4 | `segment` | string | Sub-segment within a category | e.g. `Milk-Seg2`, `Milk-Seg3`, `SnackBar-Seg1`. |
| 5 | `category` | string | Top product category | e.g. `Milk`, `SnackBar` (confirm full list via notebook). |
| 6 | `channel` | string | Sales channel | `Retail`, `Discount`, `E-commerce`. |
| 7 | `region` | string | Region (Poland) | `PL-Central`, `PL-North`, `PL-South`. |
| 8 | `pack_type` | string | Packaging format | `Single`, `Multipack`, `Carton`. |
| 9 | `price_unit` | float | Unit price (currency unspecified; treat as PLN) | Observed ~1.50–8.97; increases across years. |
| 10 | `promotion_flag` | int (0/1) | 1 = promotion active that day for that row | Binary. |
| 11 | `delivery_days` | int | Delivery lead time (days) | Observed 1–5. |
| 12 | `stock_available` | int | Units available in stock | ≥ 0; `0` occurs (stock-out signal). |
| 13 | `delivered_qty` | int | Units delivered/replenished | ≥ 0. |
| 14 | `units_sold` | int | Units sold (target/demand signal) | ≥ 0; `0` occurs even when `delivered_qty > 0`. |

## Derived fields to build (in cleaning step)
| Field | Formula | Purpose |
|---|---|---|
| `revenue` | `price_unit × units_sold` | Sales value proxy (no cost data). |
| `year`, `month`, `week`, `dow` | from `date` | Time-series grouping. |
| `is_stockout` | `1 if units_sold == 0 else 0` (optionally refined with `stock_available`) | Availability analysis. |
| `sell_through` | `units_sold / NULLIF(stock_available,0)` | Inventory efficiency. |

## Data quality flags to verify (see notebook 01)
- Missing values in any column.
- Duplicate `(date, sku, channel, region, pack_type)` keys.
- Negative or implausible `price_unit`, `units_sold`, `delivered_qty`, `stock_available`.
- Product-hierarchy consistency: each `sku` maps to exactly one `brand`, `segment`, `category`.
- `units_sold > stock_available` (selling more than available) — logical check.
- Date gaps per SKU (expected, given product introductions).
