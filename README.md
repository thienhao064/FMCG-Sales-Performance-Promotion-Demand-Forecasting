# FMCG Sales Performance, Promotion & Demand Forecasting

**Table of Contents**
1. Project Overview
2. Business Problem
3. Dataset
4. Data Quality Findings
5. Analysis
6. Key Insights
7. Dashboard
8. Recommendations
9. Limitations
10. Next Steps
11. Repository Structure

English Version (Vietnamese below)
--------------------------------------------------------
## **1. Project Overview**
- This project analyses 190,757 daily sales records of a Fast Moving Consumer Goods (FMCG) portfolio across 3 sales channels and 3 regions of Poland, covering from 2022-01-21 to 2024-12-31. The goal is to turn raw transactional data into decisions a commercial and demand-planning team can act on:
  + Sales performance >> How revenue and volume trend across time, product hierarchy, channel and region.
  + Promotion effectiveness >> Whether promotions actually lift volume, and by how much.
  + Demand forecasting >> A weekly forecast to support inventory and supply planning.
- Tools:
  + SQL (Data quality + Analysis query)
  + Python (Cleaning, EDA)
  + Power BI (Interactive Dashboard)
  + PowerPoint (Storytelling)
- Database: SQL Server

## **2. Business Problem**
A demand-planning and commercial analytics team at an FMCG company needs to answer:
- Performance: Which categories, brands, channels and regions drive sales, and how is the trend developing year over year?
- Promotion: Do promotions generate incremental volume, or do they mostly discount sales that would have happened anyway?
- Availability: Where are we losing sales to stock outs, and how does delivery lead time relate to this?
- Planning: Can we forecast weekly demand accurately enough to reduce both stock-outs and overstock?

## **3. Dataset**
- Source >> Kaggle — `https://www.kaggle.com/code/devsurakshitkapoor/fmcg-eda-business-insights`
- Grain >> Date × SKU × channel × region × pack_type
- Rows >> 190,757
- Columns >> 14
- Date range (YYYY-MM-DD) >> From 2022-01-21 to 2024-12-31
- Channels >> Retail, Discount, E-commerce
- Regions >> PL-Central, PL-North, PL-South (PL = Poland)
- Pack types >> Single, Multipack, Carton

## **4. Data Quality Findings**
Results at `sql/02_data_quality_checks.sql`

- Rows × Columns >> 190,757 × 14 >> OK
- Date range >> From 2022-01-21 to 2024-12-31 >> OK
- Missing values >> 0 >> OK
- Duplicate business keys >> 0 >> OK
- Product-hierarchy consistency >> 0 inconsistent SKUs >> OK
- Negative/invalid cells >> 9 cells / 3 rows >> ALERT
- Dimensions >> 30 SKUs - 14 brands - 5 categories - 3 channels - 3 regions - 3 pack types >> OK
- Stock out >> 3,862 rows (2.0%), all with stock = 0 >> OK

Three anomalies flagged `docs/data_quality_findings.md`:
- 3 rows with negative quantities (rows 70491 / 83503 / 123635), corrupt ~0.002% of data
- Varies `price_unit` looks synthetic, flat mean ~5.25 and identical 1.5–9.0 range every year, and the same SKU/day varies 1.55–8.58 across channels. Analysis is volume-first `units_sold`, revenue treated as a caveated proxy only
- No new SKUs in 2024 contradicts the dataset description and angle dropped from scope.

## **5. Analysis**
Full analysis in `sql/03_analysis_queries.sql`

- Trend >> Weekly & YoY volume >> `dashboard_screenshots/reports/figures/01_weekly_volume.png`
- Seasonality >> Month-of-year & day-of-week >> `dashboard_screenshots/reports/figures/02_seasonality.png`
- Product hierarchy >> Category share, top brands, SKU Pareto >> `dashboard_screenshots/reports/figures/03_hierarchy.png`
- Channel & region >> Volume mix >> `dashboard_screenshots/reports/figures/04_channel_region.png`
- Promotion >> Uplift on volume, by category >> `dashboard_screenshots/reports/figures/05_promo_uplift.png`
- Stock-out >> Rate by dimension & over time >> `dashboard_screenshots/reports/figures/06_stockout_trend.png`
- Forecasting >> TBU

## **6. Key Insight**
- Volume is flat YoY once the ramp is excluded. Total = 3.80M units. After SKUs were onboarded through 2022, weekly volume peaked at ~39k (mid-2023) and settled into a 30–35k band in 2024, 2024 vs 2023 = −0.9% (essentially flat). (The +165% "2023 vs 2022" is an artifact of a partial/ramp-up 2022 and is not treated as growth.)
- Demand is strongly seasonal by month, not by weekday. Average units peak in June–July and trough in Nov–Dec (~40% peak-to-trough). Day of Week is flat (~20 units across all days) so no intraweek pattern.
- The portfolio is concentrated. Yogurt alone = 41.2% of volume; 23 of 30 SKUs drive 80% of volume, leaving a 7-SKU low-volume tail.
- Promotions roughly double volume. Overall uplift +95.3% on the 14.9% of rows that are promoted, consistent across all five categories (93–97%). (The uniformity indicates a synthetic promo rule; validate magnitude with real promo-cost/margin data before acting.)
- Availability is healthy and stable. Stock out rate is ~2.0% with no upward trend; nearly all zero-sales rows occur when `stock_available` = 0.
- Region and channel are evenly balanced (each region ~1.26M units; the three channels are similar), so geography/channel add little differentiation in this dataset. A dedicated region-comparison view is not warranted.

## **7. Dashboard**
A 3-page Power BI report built on a star schema (`fact_sales`, `dim_date`, `dim_product`, `dim_channel`, `dim_region`):
- Executive Overview >> KPI cards, weekly trend, monthly seasonality, region/channel balance.
- Product & Promotion >> Category/brand contribution, SKU league table, Pareto, promo uplift.
- Availability & Forecast >> Stock out rate & heat-matrix.

Screenshots: `dashboard_screenshots/pic/`

## **8. Recommendations**
- Plan supply to the summer peak. The ~40% Jun–Jul seasonal swing is the dominant planning signal; build inventory ahead of Q2-end. Day-of-week can be ignored in replenishment cadence.
- Concentrate S&OP on the core 23 SKUs (80% of volume), Yogurt first, and review the 7 tail SKUs for rationalisation or targeted support.
- Treat promotions as a volume lever, not a default. Since promos ~double units, guarantee stock cover on promo weeks — but validate ROI with margin/cost data before increasing the 14.9% promo frequency.
- Hold availability at ~2% and target the specific channel×region cells with the highest stock out rate rather than adding blanket safety stock.
- For forecasting, model weekly/ SKU or SKU/ region with annual seasonality + a promotion regressor, exclude day-of-week.

## **9. Limitations**
- Synthetic data. Several patterns look generator-driven: `price_unit` is random within 1.5–9.0, region/channel volumes are near-uniform, and promo uplift is uniform (~95%) across categories. Treat magnitudes as illustrative.
- In year 2022 is a partial and ramp-up year (data starts 2022-01-21 and SKUs phase in), so 2022 to 2023 growth is not comparable; growth claims use 2024 vs 2023 only.
- No cost/ margin data. `revenue_proxy` = `price_unit` × `units_sold` is unreliable and used only as a caveated secondary metric, profitability and promo ROI are out of scope.
- No holiday/calendar table, seasonality is inferred from the dates themselves.
- No new-product analysis, the dataset has no SKUs introduced in 2024 despite its description.

## **10. Next Steps**
- Add promotion cost/ margin data to turn the +95% volume uplift into a true ROI view.
- Introduce a holiday/calendar table to separate calendar effects from the summer seasonal peak.
- Extend the forecast horizon and add prediction intervals; automate a weekly dashboard refresh.
- Add a promotion-scenario toggle to the forecast.

## **11. Repository Structure**
```
fmcg-sales-analytics/
├── README.md
├── data/
│   ├── raw.csv
│   └── processed.csv
├── sql/
│   ├── 01_data_quality_checks.sql
│   ├── 02_analysis_queries.sql
│   └── 03_star_schema.sql
├── notebooks/
│   ├── 01_data_profiling.ipynb
│   ├── 02_cleaning.ipynb
│   ├── 03_eda.ipynb
│   └── 04_forecasting.ipynb
├── powerbi/
├── dashboard_screenshots/
│   ├── pic/
│   ├── reports/
│   │   ├── figures/
├── presentation/
└── docs/
    ├── data_dictionary.md
    └── data_quality_findings.md
```

#-----#-----#------#------#-----#-----#-----#

Phiên bản Tiếng Việt
--------------------------------------------------------
## **1. Tổng Quan Dự Án**

- Dự án này phân tích 190.757 dòng bán hàng hằng ngày của một danh mục FMCG trên ba kênh bán hàng và ba khu vực tại Ba Lan, trong giai đoạn từ 21/01/2022 đến 31/12/2024. Mục tiêu là chuyển đổi dữ liệu giao dịch thô thành các thông tin hỗ trợ đội ngũ kinh doanh và lập kế hoạch nhu cầu đưa ra quyết định:
  + Hiệu quả bán hàng >> Doanh thu và sản lượng thay đổi như thế nào theo thời gian, phân cấp sản phẩm, kênh bán hàng và khu vực.
  + Hiệu quả khuyến mãi >> Các chương trình khuyến mãi có thực sự làm tăng sản lượng hay không, và mức tăng là bao nhiêu.
  + Dự báo nhu cầu >> Xây dựng dự báo theo tuần nhằm hỗ trợ lập kế hoạch tồn kho và cung ứng.

- Công cụ sử dụng:
  + SQL: Kiểm tra chất lượng dữ liệu và truy vấn để phân tích.
  + Python: Làm sạch dữ liệu, khám phá dữ liệu.
  + Power BI: Xây dựng dashboard tương tác.
  + PowerPoint: Trình bày kết quả phân tích.
- Database: SQL Server

## **2. Bài Toán Kinh Doanh**
Đội ngũ lập kế hoạch nhu cầu hoặc phân tích kinh doanh tại một công ty FMCG cần trả lời các câu hỏi sau:
- Hiệu quả kinh doanh: Những ngành hàng, thương hiệu, kênh bán hàng và khu vực nào đóng góp chính vào doanh số? Xu hướng tăng trưởng qua từng năm đang diễn biến như thế nào?
- Khuyến mãi: Các chương trình khuyến mãi có tạo ra sản lượng tăng thêm hay chủ yếu chỉ giảm giá cho những giao dịch vốn vẫn sẽ phát sinh?
- Khả năng cung ứng: Doanh nghiệp đang mất doanh số ở đâu do hết hàng, tức là có nhu cầu nhưng số lượng bán bằng 0? Thời gian giao hàng có liên quan như thế nào đến tình trạng này?
- Lập kế hoạch: Có thể dự báo nhu cầu theo tuần đủ chính xác để giảm cả tình trạng hết hàng và tồn kho dư thừa hay không?

## **3. Bộ Dữ Liệu**
- Nguồn dữ liệu >> Kaggle — `https://www.kaggle.com/code/devsurakshitkapoor/fmcg-eda-business-insights`
- Cấp độ chi tiết dữ liệu >> Một dòng tương ứng với ngày × SKU × kênh bán hàng × khu vực × loại bao bì
- Số dòng >> 190.757
- Số cột >> 14
- Khoảng thời gian (Định dạng YYYY-MM-DD) >> Từ 2022-01-21 đến 2024-12-31
- Kênh bán hàng >> Kênh bán lẻ, Kênh bán sỉ, Thương mại điện tử
- Khu vực >> PL-Central, PL-North, PL-South
- Loại bao bì >> Sản phẩm đơn, Lốc sản phẩm, Thùng

## **4. Kết Quả Kiểm Tra Chất Lượng Dữ Liệu**
Kết quả được tạo từ file `sql/02_data_quality_checks.sql`
- Số dòng × số cột >> 190.757 × 14 >> OK
- Khoảng thời gian >> Từ 2022-01-21 đến 2024-12-31 >> OK
- Giá trị thiếu >> Không có giá trị bị thiếu >> OK
- Key nghiệp vụ bị trùng dữ liệu >> Không trùng >> OK
- Tính nhất quán của phân cấp sản phẩm >> Không có SKU không nhất quán >> OK
- Dữ liệu âm hoặc null >> 9 ô thuộc 3 dòng >> Cảnh báo
- Dimensions >> 30 SKUs, 14 thương hiệu, 5 ngành hàng, 3 kênh bán hàng, 3 khu vực và 3 loại bao bì >> OK
- Hết hàng >> 3.862 dòng và tất cả đều có tồn kho bằng 0 >> OK

Ba bất thường được ghi nhận trong `docs/data_quality_findings.md`:
- Có 3 dòng chứa số lượng âm, tại các dòng 70491, 83503 và 123635. Đây là dữ liệu lỗi, chiếm khoảng 0,002% tổng dữ liệu.
- Biến `price_unit` có dấu hiệu là dữ liệu giả lập. Giá trị trung bình gần như không đổi, khoảng 5,25, và khoảng giá từ 1,5 đến 9,0 giống nhau trong từng năm. Cùng một SKU trong cùng một ngày có thể có mức giá từ 1,55 đến 8,58 giữa các kênh bán hàng. Vì vậy, phân tích tập trung chủ yếu vào sản lượng `units_sold`, doanh thu chỉ được sử dụng như một chỉ số đại diện và cần kèm theo lưu ý.
- Không có SKU mới trong năm 2024, ngược với phần mô tả của bộ dữ liệu trong source. Vì vậy, nội dung phân tích sản phẩm mới chưa có dữ liệu lịch sử và đã được loại khỏi phạm vi dự án.

## **5. Phân Tích**
Toàn bộ phân tích được thực hiện trong file `sql/03_analysis_queries.sql`.
- Xu hướng >> Sản lượng theo tuần và tăng trưởng cùng kỳ năm trước >> `dashboard_screenshots/reports/figures/01_weekly_volume.png`
- Tính mùa vụ >> Phân tích theo tháng trong năm và ngày trong tuần >> `dashboard_screenshots/reports/figures/02_seasonality.png`
- Phân cấp sản phẩm >> Tỷ trọng ngành hàng, thương hiệu hàng đầu và phân tích Pareto theo SKU >> `dashboard_screenshots/reports/figures/03_hierarchy.png`
- Kênh bán hàng và khu vực >> Cơ cấu sản lượng >> `dashboard_screenshots/reports/figures/04_channel_region.png`
- Khuyến mãi >> Mức tăng sản lượng do khuyến mãi theo từng ngành hàng >> `dashboard_screenshots/reports/figures/05_promo_uplift.png`
- Hết hàng >> Tỷ lệ hết hàng theo từng chiều dữ liệu và theo thời gian >> `dashboard_screenshots/reports/figures/06_stockout_trend.png`
- Dự báo >> Sẽ cập nhật sau

## **6. Các Phát Hiện Cốt Lõi**
- Sản lượng gần như đi ngang so với cùng kỳ năm trước sau khi loại trừ giai đoạn tăng trưởng ban đầu. Tổng sản lượng đạt **3,8 triệu units**. Sau khi các SKU lần lượt được đưa vào danh mục trong năm 2022, sản lượng theo tuần đạt đỉnh khoảng **39 nghìn units vào giữa năm 2023**, sau đó ổn định trong khoảng **30 nghìn – 35 nghìn đơn vị trong năm 2024**. Năm 2024 so với năm 2023 giảm **0,9%**, về cơ bản là đi ngang. Mức tăng **165% của năm 2023 so với năm 2022** chủ yếu là kết quả của việc năm 2022 chỉ có dữ liệu một phần và đang trong giai đoạn mở rộng danh mục, do đó không được xem là tăng trưởng thực tế.
- Nhu cầu có tính mùa vụ rõ rệt theo tháng nhưng không rõ rệt theo ngày trong tuần. Số lượng bán trung bình đạt đỉnh vào tháng 6 và tháng 7, thấp nhất vào tháng 11 và tháng 12. Chênh lệch từ mức đỉnh đến mức thấp nhất khoảng **40%**. Sản lượng trung bình theo ngày trong tuần gần như không thay đổi, khoảng 20 đơn vị ở tất cả các ngày. Điều này cho thấy không có mô hình nhu cầu đáng kể trong phạm vi một tuần.
- Danh mục sản phẩm có mức độ tập trung cao. Riêng ngành hàng Yogurt chiếm **41,2% tổng sản lượng**. Có **23 trong tổng số 30 SKUs** đóng góp 80% tổng sản lượng, trong khi 7 SKUs còn lại thuộc nhóm sản lượng thấp.
- Khuyến mãi gần như làm sản lượng tăng gấp đôi. Mức tăng sản lượng tổng thể đạt **95,3%** trên 14,9% số dòng có áp dụng khuyến mãi. Kết quả tương đối đồng đều trên tất cả ngành hàng, trong khoảng từ 93% đến 97%. Tuy nhiên, mức độ đồng nhất này cho thấy khả năng dữ liệu khuyến mãi được tạo theo quy tắc giả lập. Doanh nghiệp cần kiểm chứng mức tăng này bằng dữ liệu thực tế về chi phí khuyến mãi và biên lợi nhuận trước khi đưa ra quyết định.
- Khả năng cung ứng đang ở mức tốt và ổn định. Tỷ lệ hết hàng khoảng **2,0%** và không có xu hướng tăng. Gần như tất cả các dòng có số lượng bán bằng 0 đều xuất hiện khi `stock_available = 0`.
- Sản lượng giữa các khu vực và kênh bán hàng được phân bổ tương đối đồng đều. Mỗi khu vực đóng góp khoảng **1,26 triệu units** và 3 kênh bán hàng có quy mô tương đương nhau. Vì vậy, khu vực địa lý và kênh bán hàng không tạo ra nhiều khác biệt trong bộ dữ liệu này. Không cần xây dựng riêng một trang phân tích so sánh khu vực.

## **7. Dashboard**

Báo cáo Power BI gồm ba trang, được xây dựng dựa trên star schema (`fact_sales`, `dim_date`, `dim_product`, `dim_channel`, `dim_region`):
- Trang tổng quan >> Thẻ KPI, xu hướng sản lượng theo tuần, tính mùa vụ theo tháng, cơ cấu sản lượng theo khu vực và kênh bán hàng.
- Trang sản phẩm và khuyến mãi >> Mức đóng góp theo ngành hàng và thương hiệu, bảng xếp hạng SKU, phân tích Pareto, mức tăng sản lượng do khuyến mãi.
- Trang khả năng cung ứng >> Tỷ lệ hết hàng, ma trận nhiệt phân tích hết hàng.

Ảnh chụp dashboard được lưu tại: `dashboard_screenshots/pic/`

## **8. Khuyến Nghị**
- Lập kế hoạch nguồn cung cho giai đoạn cao điểm mùa hè. Biến động mùa vụ khoảng 40% trong tháng 6 và tháng 7 là tín hiệu quan trọng nhất cho công tác lập kế hoạch. Doanh nghiệp nên tăng tồn kho trước thời điểm kết thúc quý 2. Yếu tố ngày trong tuần có thể được bỏ qua khi xây dựng chu kỳ bổ sung hàng.
- Tập trung quy trình S&OP vào 23 SKUs chủ lực. Nhóm này đóng góp 80% tổng sản lượng, trong đó nên ưu tiên ngành hàng yogurt. Bảy SKUs có sản lượng thấp cần được rà soát để tinh gọn danh mục hoặc có chính sách hỗ trợ bán hàng phù hợp.
- Xem khuyến mãi là công cụ thúc đẩy sản lượng, không nên áp dụng mặc định. Vì khuyến mãi làm sản lượng gần như tăng gấp đôi, doanh nghiệp cần bảo đảm đủ tồn kho trong các tuần triển khai khuyến mãi. Tuy nhiên, cần đánh giá hiệu quả đầu tư dựa trên dữ liệu chi phí và biên lợi nhuận trước khi tăng tỷ lệ khuyến mãi hiện tại là 14,9%.
- Duy trì tỷ lệ hết hàng ở mức khoảng 2%. Nên tập trung xử lý các tổ hợp kênh bán hàng × khu vực có tỷ lệ hết hàng cao nhất, thay vì tăng tồn kho an toàn trên toàn bộ hệ thống.
- Đối với dự báo, nên xây dựng mô hình theo tuần cho từng SKU hoặc SKU × khu vực. Mô hình nên bao gồm tính mùa vụ theo năm và biến giải thích khuyến mãi. Không cần sử dụng yếu tố ngày trong tuần.

## **9. Hạn Chế**
- Một số đặc điểm cho thấy dữ liệu được tạo tự động: `price_unit` được phân bổ ngẫu nhiên trong khoảng 1.5–9.0, sản lượng giữa các khu vực và kênh bán hàng gần như đồng đều, mức tăng sản lượng do khuyến mãi gần như giống nhau, khoảng 95% trên các ngành hàng.
- Năm 2022 là năm có dữ liệu không đầy đủ và đang trong giai đoạn mở rộng danh mục. Dữ liệu bắt đầu từ ngày 21/01/2022 và các SKU được bổ sung dần. Do đó, mức tăng trưởng từ năm 2022 sang năm 2023 không có tính so sánh. Các đánh giá tăng trưởng chỉ sử dụng năm 2024 so với năm 2023.
- Không có dữ liệu chi phí hoặc biên lợi nhuận. Chỉ số `revenue` = `price_unit × units_sold`, chỉ số này không đủ độ đáng tin nên xem đây là chỉ số phụ. Phân tích lợi nhuận và hiệu quả đầu tư của chương trình khuyến mãi nằm ngoài phạm vi dự án.
- Không có bảng ngày lễ hoặc lịch sự kiện. Tính mùa vụ chỉ được suy luận trực tiếp từ dữ liệu ngày tháng.
- Không thực hiện phân tích sản phẩm mới. Mặc dù phần mô tả từ nguồn dữ liệu có đề cập đến sản phẩm mới, thực tế không có SKU nào được giới thiệu trong năm 2024.

## **10. Các Bước Tiếp Theo**
- Bổ sung dữ liệu chi phí khuyến mãi và biên lợi nhuận để chuyển mức tăng sản lượng 95% thành một chỉ số ROI thực tế.
- Bổ sung bảng ngày lễ và lịch sự kiện để tách biệt ảnh hưởng của lịch với mức tăng nhu cầu trong mùa hè.
- Mở rộng thời hạn dự báo và bổ sung khoảng dự báo, đồng thời tự động hóa việc làm mới dashboard theo tuần.
- Bổ sung chức năng mô phỏng kịch bản khuyến mãi trong mô hình dự báo.

## **11. Cấu trúc Repository**
```
fmcg-sales-analytics/
├── README.md
├── data/
│   ├── raw.csv
│   └── processed.csv
├── sql/
│   ├── 01_data_quality_checks.sql
│   ├── 02_analysis_queries.sql
│   └── 03_star_schema.sql
├── notebooks/
│   ├── 01_data_profiling.ipynb
│   ├── 02_cleaning.ipynb
│   ├── 03_eda.ipynb
│   └── 04_forecasting.ipynb
├── powerbi/
├── dashboard_screenshots/
│   ├── pic/
│   ├── reports/
│   │   ├── figures/
├── presentation/
└── docs/
    ├── data_dictionary.md
    └── data_quality_findings.md
```
