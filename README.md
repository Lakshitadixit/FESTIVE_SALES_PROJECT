# Festive Sales Analysis (India – 2024)

An end-to-end data analytics project that analyzes sales performance during major Indian festivals (Holi, Eid, and Diwali) using Python, PostgreSQL, and Power BI.


## Project Objective

The goal of this project is to analyze how major Indian festivals impact sales performance by comparing festive and non-festive periods across key business metrics such as:

- Revenue
- Order volume
- Average Order Value (AOV)
- Discounts
- Category and regional performance

The analysis helps identify whether festivals truly drive higher-value sales or primarily increase order volume through discounts.


## 📊 Dataset Overview

- **Source**: Synthetic dataset generated for analysis
- **Time Period**: Year 2024
- **Granularity**: Order-level data
- **Total Records**: ~23,500 orders

The dataset represents e-commerce transactions across multiple Indian states and product
categories, including pricing, quantity, discounts, and order dates.


## Project Structure

FESTIVE_SALES_PROJECT/
│
├── PYTHON/
│   ├── 01_data_generation.ipynb
│   ├── 02_data_profiling.ipynb
│   ├── 03_data_cleaning.ipynb
│   ├── 04_load_to_postgres.ipynb
│   ├── sales_raw.csv
│   └── sales_clean.csv
│
├── SQL/
│   ├── 01_schema.sql
│   ├── 02_validation.sql
│   ├── 03_festival_calendar.sql
│   ├── 04_festival_window.sql
│   └── 05_analysis.sql
│
├── POWER BI/
│   └── Festive_Sales_Analysis.pbix
│
└── README.md


## Data Pipeline Overview

1. **Data Generation (Python)**
   - Synthetic sales data generated to mimic real-world e-commerce behavior.

2. **Data Profiling (Python)**
   - Structure, missing values, data types, and inconsistencies identified.

3. **Data Cleaning (Python)**
   - Standardized categories and states
   - Handled missing values
   - Fixed data types
   - Validated business logic (final amount calculation)

4. **Data Loading (PostgreSQL)**
   - Cleaned data loaded into PostgreSQL using SQLAlchemy.

5. **Analysis (SQL)**
   - Festival vs non-festival comparison
   - Category, region, and time-based analysis
   - Daily-level metrics to avoid period bias

6. **Power BI Integration**
   - Due to local PostgreSQL connection issues, the final SQL query outputs were **exported as CSV files** and imported into Power BI.

7. **Visualization (Power BI)**
   - Interactive dashboard summarizing key insights.



## Key Analysis Performed

- Festive vs non-festive revenue comparison
- Daily Average Order Value (AOV) analysis
- Category-wise festive uplift
- Discount vs AOV relationship
- State-wise festival performance
- Identification of categories negatively impacted during festivals



## Tools & Technologies

- **Python**: pandas, numpy, SQLAlchemy
- **PostgreSQL**: data storage and SQL analysis
- **Power BI**: dashboarding and visualization
- **Jupyter Notebook**: data exploration and cleaning
- **Git/GitHub**: version control



## Key Insights

- Festivals increased **order volume** but did not always improve **AOV**
- Fashion and Beauty categories showed **negative AOV uplift** during festivals
- Discounts were higher during festive periods but did not proportionally increase revenue
- Regional performance varied significantly across festivals



## Conclusion

This project demonstrates a complete analytics workflow — from raw data generation to business-ready insights — highlighting the importance of daily-level analysis when comparing uneven time periods such as festivals and non-festive windows.


