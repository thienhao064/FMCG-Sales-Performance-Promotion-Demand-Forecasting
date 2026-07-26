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

English Version (Vietnameses below)
--------------------------------------------------------
**1. Project Overview**
- This project analyses 190,757 daily sales records of a Fast-Moving Consumer Goods (FMCG) portfolio across three sales channels and three regions of Poland, covering 2022-01-21 to 2024-12-31. The goal is to turn raw transactional data into decisions a commercial / demand-planning team can act on:
 + Sales performance >> How revenue and volume trend across time, product hierarchy, channel and region.
 + Promotion effectiveness >> Whether promotions actually lift volume, and by how much.
 + Demand forecasting >> A weekly forecast to support inventory and supply planning.

- Tools:
  + SQL (Data quality + Analysis query)
  + Python (Cleaning, EDA, forecasting)
  + Power BI (Interactive dashboard)
  + PowerPoint (Executive storytelling)

**2. Business Problem**
A demand-planning / commercial analytics team at an FMCG company needs to answer:
- Performance: Which categories, brands, channels and regions drive sales, and how is the trend developing year over year?
- Promotion: Do promotions generate incremental volume (uplift), or do they mostly discount sales that would have happened anyway?
- Availability: Where are we losing sales to stock-outs (demand present but zero units sold), and how does delivery lead time relate to this?
- Planning: Can we forecast weekly demand accurately enough to reduce both stock-outs and overstock?

**3. Dataset**
- Source >> Kaggle — `https://www.kaggle.com/code/devsurakshitkapoor/fmcg-eda-business-insights`
- Grain >> One row per date × SKU × channel × region × pack_type
- Rows >> 190,757
- Columns >> 14
- Date range (YYYY-MM-DD) >> From 2022-01-21 to 2024-12-31
- Channels >> Retail, Discount, E-commerce
- Regions >> PL-Central, PL-North, PL-South (PL = Poland)
- Pack types >> Single, Multipack, Carton

**4. Data Quality Findings**
Produced by `sql/02_data_quality_checks.sql`

- Rows × Columns >> 190,757 × 14 >> OK
- Date range >> From 2022-01-21 to 2024-12-31 >> OK
- Missing values >> 0 >> OK
- Duplicate business keys >> 0 >> OK
- Product-hierarchy consistency >> 0 inconsistent SKUs >> OK
- Negative/invalid cells >> 9 cells / 3 rows >> ALERT
- Dimensions >> 30 SKUs - 14 brands - 5 categories - 3 channels - 3 regions - 3 pack types >> OK
- Stock out >> 3,862 rows (2.0%), all with stock = 0 >> OK

Three anomalies flagged `docs/data_quality_findings.md`:
- 3 rows with negative quantities (rows 70491 / 83503 / 123635) — corrupt, ~0.002% of data
- (price_unit) looks synthetic — flat mean (~5.25) and identical 1.5–9.0 range every year, and the same SKU/day varies 1.55–8.58 across channels. Analysis is volume-first (units_sold); revenue treated as a caveated proxy only
- No new SKUs in 2024 contradicts the dataset description, cold-start angle dropped from scope.

**5. Analysis**
Full analysis in `sql/03_analysis_queries.sql`

Trend >> Weekly & YoY volume >> `reports/figures/01_weekly_volume.png`
Seasonality >> Month-of-year & day-of-week >> `reports/figures/02_seasonality.png`
Product hierarchy >> Category share, top brands, SKU Pareto >> `reports/figures/03_hierarchy.png`
Channel & region >> Volume mix >> `reports/figures/04_channel_region.png`
Promotion >> Uplift on volume, by category >> `reports/figures/05_promo_uplift.png`
Stock-out >> Rate by dimension & over time >> `reports/figures/06_stockout_trend.png`
Forecasting >> Weekly per-SKU, 12-week horizon >> `reports/figures/07_forecast_top_skus.png`

**Forecasting** "notebooks/04_forecasting.ipynb":
weekly `units_sold` per SKU (30 models), **seasonal-naive baseline vs Prophet** (yearly seasonality + promotion regressor), evaluated on a **12-week hold-out** (MAE + WAPE).

**Result — the simple baseline wins.** Average WAPE was **13.1% (baseline)** vs **16.2% (Prophet)**, and the baseline was more accurate on **18 of 30 SKUs**. With strong, stable yearly seasonality and little trend, "same week last year" is hard to beat; the added model complexity did not pay off. **The seasonal-naive baseline is therefore selected for the production forecast** — a reminder that model choice should be evidence-driven. The 12-week forward forecast per SKU is in `data/processed/weekly_forecast_next12w.csv`.

**6. Key Insight**
- Volume is flat year-on-year once the ramp is excluded. Total = 3.80M units. After SKUs were onboarded through 2022, weekly volume peaked at ~39k (mid-2023) and settled into a 30–35k band in 2024; 2024 vs 2023 = −0.9% (essentially flat). (The +165% "2023 vs 2022" is an artifact of a partial/ramp-up 2022 and is not treated as growth.)
- Demand is strongly seasonal by month, not by weekday. Average units peak in June–July and trough in Nov–Dec (~40% peak-to-trough). Day-of-week is flat (~20 units across all days) → no intra-week pattern.
- The portfolio is concentrated. Yogurt alone = 41.2% of volume; 23 of 30 SKUs drive 80% of volume, leaving a 7-SKU low-volume tail.
- Promotions roughly double volume. Overall uplift +95.3% on the 14.9% of rows that are promoted, consistent across all five categories (93–97%). (The uniformity indicates a synthetic promo rule; validate magnitude with real promo-cost/margin data before acting.)
- Availability is healthy and stable. Stock-out rate is ~2.0% with no upward trend; nearly all zero-sales rows occur when stock_available = 0.
- Region and channel are evenly balanced (each region ~1.26M units; the three channels are similar), so geography/channel add little differentiation in this dataset — a dedicated region-comparison view is not warranted.

**7. Dashboard**
A 3-page Power BI report built on a star schema (fact_sales + dim_date/product/channel/region + fact_forecast):
- Executive Overview — KPI cards, weekly trend, monthly seasonality, region/channel balance.
- Product & Promotion — category/brand contribution, SKU league table, Pareto, promo uplift.
- Availability & Forecast — stock-out rate & heat-matrix, 12-week per-SKU forecast.

Build specs: `powerbi/data_model.md`, `powerbi/power_query_steps.md`, `powerbi/measures.dax`, `powerbi/dashboard_layout.md` 
Screenshots: `dashboard_screenshots/`

**8. Recommendations**
- Plan supply to the summer peak. The ~40% Jun–Jul seasonal swing is the dominant planning signal; build inventory ahead of Q2-end. Day-of-week can be ignored in replenishment cadence.
- Concentrate S&OP on the core 23 SKUs (80% of volume), Yogurt first, and review the 7 tail SKUs for rationalisation or targeted support.
- Treat promotions as a volume lever, not a default. Since promos ~double units, guarantee stock cover on promo weeks — but validate ROI with margin/cost data before increasing the 14.9% promo frequency.
- Hold availability at ~2% and target the specific channel×region cells with the highest stock-out rate (query Q7) rather than adding blanket safety stock.
- For forecasting, model weekly per SKU (or SKU×region) with annual seasonality + a promotion regressor; exclude day-of-week.

**9. Limitations**
- Synthetic data. Several patterns look generator-driven: price_unit is random within 1.5–9.0, region/channel volumes are near-uniform, and promo uplift is uniform (~95%) across categories. Treat magnitudes as illustrative.
- 2022 is a partial / ramp-up year (data starts 2022-01-21 and SKUs phase in), so 2022→2023 growth is not comparable; growth claims use 2024 vs 2023 only.
- No cost / margin data → revenue_proxy (price_unit × units_sold) is unreliable and used only as a caveated secondary metric; profitability and promo ROI are out of scope.
- No holiday/calendar table; seasonality is inferred from the dates themselves.
- No new-product (cold-start) analysis — the dataset has no SKUs introduced in 2024 despite its description.

**10. Next Steps**
- Add promotion cost / margin data to turn the +95% volume uplift into a true ROI view.
- Introduce a holiday/calendar table to separate calendar effects from the summer seasonal peak.
- Extend the forecast horizon and add prediction intervals; automate a weekly dashboard refresh.
- Add a promotion-scenario toggle to the forecast (simulate planned promo weeks via the regressor).

11. Repository Structure
fmcg-sales-analytics/
├── README.md
├── .gitignore
├── data/
│   ├── raw/
│   └── processed/
├── sql/
│   ├── 00_schema.sql
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
├── presentation/
└── docs/
    ├── data_dictionary.md
    └── data_quality_findings.md

#-----#-----#------#------#-----#-----#-----#

Phiên bản Tiếng Việt
--------------------------------------------------------
## **1. Tổng Quan Dự Án**

- Dự án này phân tích 190.757 dòng bán hàng hằng ngày của một danh mục FMCG trên ba kênh bán hàng và ba khu vực tại Ba Lan, trong giai đoạn từ 21/01/2022 đến 31/12/2024. Mục tiêu là chuyển đổi dữ liệu giao dịch thô thành các thông tin hỗ trợ đội ngũ kinh doanh và lập kế hoạch nhu cầu đưa ra quyết định:
  + Hiệu quả bán hàng >> Doanh thu và sản lượng thay đổi như thế nào theo thời gian, phân cấp sản phẩm, kênh bán hàng và khu vực.
  + Hiệu quả khuyến mãi >> Các chương trình khuyến mãi có thực sự làm tăng sản lượng hay không, và mức tăng là bao nhiêu.
  + Dự báo nhu cầu >> Xây dựng dự báo theo tuần nhằm hỗ trợ lập kế hoạch tồn kho và cung ứng.

- Công cụ sử dụng:
  + SQL: Kiểm tra chất lượng dữ liệu và truy vấn để phân tích
  + Python: Làm sạch dữ liệu, khám phá dữ liệu và dự báo
  + Power BI: Xây dựng dashboard tương tác
  + PowerPoint: Trình bày kết quả phân tích cho cấp quản lý

**2. Bài Toán Kinh Doanh**
Đội ngũ lập kế hoạch nhu cầu hoặc phân tích kinh doanh tại một công ty FMCG cần trả lời các câu hỏi sau:
- Hiệu quả kinh doanh: Những ngành hàng, thương hiệu, kênh bán hàng và khu vực nào đóng góp chính vào doanh số? Xu hướng tăng trưởng qua từng năm đang diễn biến như thế nào?
- Khuyến mãi: Các chương trình khuyến mãi có tạo ra sản lượng tăng thêm hay chủ yếu chỉ giảm giá cho những giao dịch vốn vẫn sẽ phát sinh?
- Khả năng cung ứng: Doanh nghiệp đang mất doanh số ở đâu do hết hàng, tức là có nhu cầu nhưng số lượng bán bằng 0? Thời gian giao hàng có liên quan như thế nào đến tình trạng này?
- Lập kế hoạch: Có thể dự báo nhu cầu theo tuần đủ chính xác để giảm cả tình trạng hết hàng và tồn kho dư thừa hay không?

**3. Bộ Dữ Liệu**
- Nguồn dữ liệu >> Kaggle — `https://www.kaggle.com/code/devsurakshitkapoor/fmcg-eda-business-insights`
- Cấp độ chi tiết dữ liệu >> Một dòng tương ứng với một tổ hợp ngày × SKU × kênh bán hàng × khu vực × loại bao bì
- Số dòng >> 190.757
- Số cột >> 14
- Khoảng thời gian, định dạng YYYY-MM-DD >> Từ 2022-01-21 đến 2024-12-31
- Kênh bán hàng >> Bán lẻ, Kênh chiết khấu, Thương mại điện tử
- Khu vực >> PL-Central, PL-North, PL-South, trong đó PL là Ba Lan
- Loại bao bì >> Sản phẩm đơn, Lốc nhiều sản phẩm, Thùng

**4. Kết Quả Kiểm Tra Chất Lượng Dữ Liệu**
Kết quả được tạo từ file `sql/02_data_quality_checks.sql`.
- Số dòng × số cột >> 190.757 × 14 >> OK
- Khoảng thời gian >> Từ 2022-01-21 đến 2024-12-31 >> OK
- Giá trị thiếu >> 0 >> OK
- Khóa nghiệp vụ bị trùng >> 0 >> OK
- Tính nhất quán của phân cấp sản phẩm >> 0 SKU không nhất quán >> OK
- Ô dữ liệu âm hoặc không hợp lệ >> 9 ô thuộc 3 dòng >> Cảnh báo
- Các chiều dữ liệu >> 30 SKU, 14 thương hiệu, 5 ngành hàng, 3 kênh bán hàng, 3 khu vực và 3 loại bao bì >> OK
- Hết hàng >> 3.862 dòng, tương đương 2,0%, tất cả đều có tồn kho bằng 0 >> OK

Ba bất thường được ghi nhận trong `docs/data_quality_findings.md`:
- Có 3 dòng chứa số lượng âm, tại các dòng 70491, 83503 và 123635. Đây là dữ liệu lỗi, chiếm khoảng 0,002% tổng dữ liệu.
- Biến `price_unit` có dấu hiệu là dữ liệu giả lập. Giá trị trung bình gần như không đổi, khoảng 5,25, và khoảng giá từ 1,5 đến 9,0 giống nhau trong từng năm. Cùng một SKU trong cùng một ngày có thể có mức giá từ 1,55 đến 8,58 giữa các kênh bán hàng. Vì vậy, phân tích tập trung chủ yếu vào sản lượng `units_sold`; doanh thu chỉ được sử dụng như một chỉ số đại diện và cần kèm theo lưu ý.
- Không có SKU mới trong năm 2024, trái với phần mô tả của bộ dữ liệu. Vì vậy, nội dung phân tích sản phẩm mới chưa có dữ liệu lịch sử, hay cold-start, đã được loại khỏi phạm vi dự án.

**5. Phân Tích**
Toàn bộ phân tích được thực hiện trong file `sql/03_analysis_queries.sql`.
- Xu hướng >> Sản lượng theo tuần và tăng trưởng cùng kỳ năm trước >> `reports/figures/01_weekly_volume.png`
- Tính mùa vụ >> Phân tích theo tháng trong năm và ngày trong tuần >> `reports/figures/02_seasonality.png`
- Phân cấp sản phẩm >> Tỷ trọng ngành hàng, thương hiệu hàng đầu và phân tích Pareto theo SKU >> `reports/figures/03_hierarchy.png`
- Kênh bán hàng và khu vực >> Cơ cấu sản lượng >> `reports/figures/04_channel_region.png`
- Khuyến mãi >> Mức tăng sản lượng do khuyến mãi theo từng ngành hàng >> `reports/figures/05_promo_uplift.png`
- Hết hàng >> Tỷ lệ hết hàng theo từng chiều dữ liệu và theo thời gian >> `reports/figures/06_stockout_trend.png`
- Dự báo >> Dự báo theo tuần cho từng SKU với thời hạn 12 tuần >> `reports/figures/07_forecast_top_skus.png`

**Dự báo**
Phân tích dự báo được thực hiện trong file `notebooks/04_forecasting.ipynb`.

Dữ liệu được tổng hợp theo tuần dựa trên chỉ tiêu `units_sold` cho từng SKU, tương ứng với 30 mô hình. Hai phương pháp được so sánh:
- Mô hình cơ sở mùa vụ đơn giản, seasonal-naive
- Prophet với tính mùa vụ theo năm và biến giải thích khuyến mãi

Các mô hình được đánh giá trên tập kiểm tra giữ lại trong **12 tuần**, sử dụng hai chỉ số (MAE + WAPE)

**Kết quả**
WAPE trung bình đạt 13,1% đối với mô hình cơ sở và đạt 16,2% đối với Prophet. Mô hình cơ sở có độ chính xác cao hơn trên 18 trong tổng số 30 SKU. Do dữ liệu có tính mùa vụ theo năm mạnh, ổn định và gần như không có xu hướng tăng hoặc giảm dài hạn, phương pháp “sử dụng cùng tuần của năm trước” rất khó bị vượt qua. Việc bổ sung độ phức tạp của mô hình Prophet không mang lại hiệu quả tương xứng. Vì vậy, **mô hình seasonal-naive được lựa chọn làm mô hình dự báo chính thức**, cho thấy việc lựa chọn mô hình cần dựa trên kết quả kiểm định thực tế thay vì chỉ ưu tiên mô hình phức tạp hơn. Dự báo 12 tuần tiếp theo cho từng SKU được lưu tại `data/processed/weekly_forecast_next12w.csv`

**6. Các Phát Hiện Cốt Lõi**
- Sản lượng gần như đi ngang so với cùng kỳ năm trước sau khi loại trừ giai đoạn tăng trưởng ban đầu. Tổng sản lượng đạt **3,80 triệu đơn vị**. Sau khi các SKU lần lượt được đưa vào danh mục trong năm 2022, sản lượng theo tuần đạt đỉnh khoảng **39.000 đơn vị vào giữa năm 2023**, sau đó ổn định trong khoảng **30.000–35.000 đơn vị trong năm 2024**. Năm 2024 so với năm 2023 giảm **0,9%**, về cơ bản là đi ngang. Mức tăng **165% của năm 2023 so với năm 2022** chủ yếu là kết quả của việc năm 2022 chỉ có dữ liệu một phần và đang trong giai đoạn mở rộng danh mục, do đó không được xem là tăng trưởng thực tế.
- Nhu cầu có tính mùa vụ rõ rệt theo tháng nhưng không rõ rệt theo ngày trong tuần. Số lượng bán trung bình đạt đỉnh vào tháng 6 và tháng 7, thấp nhất vào tháng 11 và tháng 12. Chênh lệch từ mức đỉnh đến mức thấp nhất khoảng **40%**. Sản lượng trung bình theo ngày trong tuần gần như không thay đổi, khoảng 20 đơn vị ở tất cả các ngày. Điều này cho thấy không có mô hình nhu cầu đáng kể trong phạm vi một tuần.
- Danh mục sản phẩm có mức độ tập trung cao. Riêng ngành hàng sữa chua chiếm **41,2% tổng sản lượng**. Có **23 trong tổng số 30 SKU** đóng góp 80% tổng sản lượng, trong khi 7 SKU còn lại thuộc nhóm sản lượng thấp.
- Khuyến mãi gần như làm sản lượng tăng gấp đôi. Mức tăng sản lượng tổng thể đạt **95,3%** trên 14,9% số dòng có áp dụng khuyến mãi. Kết quả tương đối đồng đều trên cả năm ngành hàng, trong khoảng từ 93% đến 97%. Tuy nhiên, mức độ đồng nhất này cho thấy khả năng dữ liệu khuyến mãi được tạo theo quy tắc giả lập. Doanh nghiệp cần kiểm chứng mức tăng này bằng dữ liệu thực tế về chi phí khuyến mãi và biên lợi nhuận trước khi đưa ra quyết định.
- Khả năng cung ứng đang ở mức tốt và ổn định. Tỷ lệ hết hàng khoảng **2,0%** và không có xu hướng tăng. Gần như tất cả các dòng có số lượng bán bằng 0 đều xuất hiện khi `stock_available = 0`.
- Sản lượng giữa các khu vực và kênh bán hàng được phân bổ tương đối đồng đều. Mỗi khu vực đóng góp khoảng **1,26 triệu đơn vị** và ba kênh bán hàng có quy mô tương đương nhau. Vì vậy, khu vực địa lý và kênh bán hàng không tạo ra nhiều khác biệt trong bộ dữ liệu này. Không cần xây dựng riêng một trang phân tích so sánh khu vực.

**7. Dashboard**

Báo cáo Power BI gồm ba trang, được xây dựng dựa trên star schema (`fact_sales`, `dim_date`, `dim_product`, `dim_channel`, `dim_region`, `fact_forecast`):
- Trang Tổng quan điều hành >> Thẻ KPI, xu hướng sản lượng theo tuần, tính mùa vụ theo tháng, cơ cấu sản lượng theo khu vực và kênh bán hàng
- Trang Sản phẩm và khuyến mãi >> Mức đóng góp theo ngành hàng và thương hiệu, bảng xếp hạng SKU, phân tích Pareto, mức tăng sản lượng do khuyến mãi
- Trang Khả năng cung ứng và dự báo >> Tỷ lệ hết hàng, ma trận nhiệt phân tích hết hàng, dự báo 12 tuần cho từng SKU

Tài liệu hướng dẫn xây dựng: `powerbi/data_model.md`, `powerbi/power_query_steps.md`, `powerbi/measures.dax`, `powerbi/dashboard_layout.md`
Ảnh chụp dashboard được lưu tại: `dashboard_screenshots/`

**8. Khuyến Nghị**
- Lập kế hoạch nguồn cung cho giai đoạn cao điểm mùa hè. Biến động mùa vụ khoảng 40% trong tháng 6 và tháng 7 là tín hiệu quan trọng nhất cho công tác lập kế hoạch. Doanh nghiệp nên tăng tồn kho trước thời điểm kết thúc quý II. Yếu tố ngày trong tuần có thể được bỏ qua khi xây dựng chu kỳ bổ sung hàng.
- Tập trung quy trình S&OP vào 23 SKU chủ lực. Nhóm này đóng góp 80% tổng sản lượng, trong đó nên ưu tiên ngành hàng sữa chua. Bảy SKU có sản lượng thấp cần được rà soát để tinh gọn danh mục hoặc có chính sách hỗ trợ bán hàng phù hợp.
- Xem khuyến mãi là công cụ thúc đẩy sản lượng, không nên áp dụng mặc định. Vì khuyến mãi làm sản lượng gần như tăng gấp đôi, doanh nghiệp cần bảo đảm đủ tồn kho trong các tuần triển khai khuyến mãi. Tuy nhiên, cần đánh giá hiệu quả đầu tư dựa trên dữ liệu chi phí và biên lợi nhuận trước khi tăng tỷ lệ khuyến mãi hiện tại là 14,9%.
- Duy trì tỷ lệ hết hàng ở mức khoảng 2%. Nên tập trung xử lý các tổ hợp kênh bán hàng × khu vực có tỷ lệ hết hàng cao nhất theo truy vấn Q7, thay vì tăng tồn kho an toàn trên toàn bộ hệ thống.
- Đối với dự báo, nên xây dựng mô hình theo tuần cho từng SKU hoặc SKU × khu vực. Mô hình nên bao gồm tính mùa vụ theo năm và biến giải thích khuyến mãi. Không cần sử dụng yếu tố ngày trong tuần.

**9. Hạn Chế**
- Dữ liệu giả lập. Một số đặc điểm cho thấy dữ liệu được tạo tự động: `price_unit` được phân bổ ngẫu nhiên trong khoảng 1.5–9.0, sản lượng giữa các khu vực và kênh bán hàng gần như đồng đều, mức tăng sản lượng do khuyến mãi gần như giống nhau, khoảng 95%, trên các ngành hàng. Vì vậy, các giá trị tuyệt đối chỉ nên được xem là minh họa.
- Năm 2022 là năm có dữ liệu không đầy đủ và đang trong giai đoạn mở rộng danh mục. Dữ liệu bắt đầu từ ngày 21/01/2022 và các SKU được bổ sung dần. Do đó, mức tăng trưởng từ năm 2022 sang năm 2023 không có tính so sánh. Các đánh giá tăng trưởng chỉ sử dụng năm 2024 so với năm 2023.
- Không có dữ liệu chi phí hoặc biên lợi nhuận. Chỉ số `revenue_proxy`, được tính bằng `price_unit × units_sold`, không đủ độ tin cậy và chỉ được sử dụng như một chỉ số phụ kèm theo lưu ý. Phân tích lợi nhuận và hiệu quả đầu tư của chương trình khuyến mãi nằm ngoài phạm vi dự án.
- Không có bảng ngày lễ hoặc lịch sự kiện. Tính mùa vụ chỉ được suy luận trực tiếp từ dữ liệu ngày tháng.
- Không thực hiện phân tích sản phẩm mới hoặc cold-start. Mặc dù phần mô tả bộ dữ liệu có đề cập đến sản phẩm mới, thực tế không có SKU nào được giới thiệu trong năm 2024.

**10. Các Bước Tiếp Theo**
- Bổ sung dữ liệu chi phí khuyến mãi và biên lợi nhuận để chuyển mức tăng sản lượng 95% thành một chỉ số ROI thực tế.
- Bổ sung bảng ngày lễ và lịch sự kiện để tách biệt ảnh hưởng của lịch với mức tăng nhu cầu trong mùa hè.
- Mở rộng thời hạn dự báo và bổ sung khoảng dự báo; đồng thời tự động hóa việc làm mới dashboard theo tuần.
- Bổ sung chức năng mô phỏng kịch bản khuyến mãi trong mô hình dự báo, cho phép người dùng lựa chọn các tuần dự kiến triển khai khuyến mãi thông qua biến giải thích.

**11. Cấu trúc Repository**
fmcg-sales-analytics/
├── README.md
├── .gitignore
├── data/
│   ├── raw/
│   └── processed/
├── sql/
│   ├── 00_schema.sql
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
├── presentation/
└── docs/
    ├── data_dictionary.md
    └── data_quality_findings.md
