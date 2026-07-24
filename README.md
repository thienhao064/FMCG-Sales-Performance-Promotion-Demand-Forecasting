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
- Source >> Kaggle — https://www.kaggle.com/code/devsurakshitkapoor/fmcg-eda-business-insights
- Grain >> One row per date × SKU × channel × region × pack_type
- Rows >> 190,757
- Columns >> 14
- Date range (YYYY-MM-DD) >> From 2022-01-21 to 2024-12-31
- Channels >> Retail, Discount, E-commerce
- Regions >> PL-Central, PL-North, PL-South (PL = Poland)
- Pack types >> Single, Multipack, Carton

**4. Data Quality Findings**




























