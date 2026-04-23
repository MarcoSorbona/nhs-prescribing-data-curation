# NHS Prescribing Data Curation

English Prescribing Dataset (EPD) with SNOMED: data curation pipeline, quality assurance, and reproducible documentation for NHS primary care prescribing data.

[**View the Interactive Dashboard →**](https://marcosorbona.github.io/nhs-prescribing-data-curation/epd_dashboard.html) \| [**View the Curation Report →**](https://marcosorbona.github.io/nhs-prescribing-data-curation/docs/curation_report.html)

------------------------------------------------------------------------

## ⚠️ Important Note

This project is based on a sample (10,000 rows per month via API). Findings are generated dynamically from the data – **no hardcoded insights**. The primary purpose is to demonstrate data curation skills, not to draw national conclusions.

**The only generalisable finding:** The API endpoint returns zero drug names for certain years – a data quality issue affecting all users of this historical data.

------------------------------------------------------------------------

## 📊 Key Discovery: Data Quality Issue

During curation, the pipeline automatically detects data quality issues, including: - Missing drug names in certain years - Inconsistent date formats across API endpoints

**The dashboard's "Data Quality" chart shows which months are affected.**

------------------------------------------------------------------------

## 🎯 Project Overview

A reproducible pipeline to fetch, clean, and document the English Prescribing Dataset (EPD) via CKAN API.

**Skills demonstrated:** - API integration (CKAN) - Data harmonisation (mixed types across months) - Lookup table joins (practice + BNF) - Quality flagging (missing drug names) - Interactive dashboard (flexdashboard) - Parquet export for efficient storage

------------------------------------------------------------------------

## 📁 Project Structure

```         
nhs-prescribing-data-curation/
├── README.md                    # This file
├── epd_dashboard.Rmd            # Interactive dashboard source
├── epd_dashboard.html           # Rendered dashboard
├── data_dictionary.md           # Variable descriptions
├── R/
│   ├── 01_curate_epd_api.R      # Data curation pipeline
│   └── 02_validate_epd.R        # Quality validation
├── docs/
│   ├── curation_report.qmd      # Main curation documentation 
│   └── curation_report.html     # Rendered curation documentation
├── data/
│   ├── lookup/                  # Practice + BNF lookup tables
│   └── clean/                   # Curated output (gitignored)
├── outputs/
│   └── figures/                 # Quality visualisations
├── INFO_GOVERNANCE.md
├── DATA_QUALITY.md
└── EDI.md
```

------------------------------------------------------------------------

## 📦 Data Source

| Property      | Value                                              |
|---------------|----------------------------------------------------|
| **Dataset**   | English Prescribing Dataset (EPD) with SNOMED Code |
| **Provider**  | NHS Business Services Authority (NHSBSA)           |
| **Access**    | CKAN API (`https://opendata.nhsbsa.net/api/3/`)    |
| **Licence**   | Open Government Licence v3.0                       |
| **Copyright** | NHSBSA Copyright 2025                              |

**Months processed:** November 2023, December 2023, December 2025, January 2026 **Rows per month:** 10,000 (API limit for demonstration)

------------------------------------------------------------------------

## 🛠️ Technical Approach

| Challenge | Solution |
|--------------------------------------|----------------------------------|
| **Large file size** | CKAN API – fetch sample only |
| **Mixed data types across months** | Harmonise all columns to character before binding |
| **Missing practice/drug names** | LEFT JOIN with lookup tables |
| **Data quality issues** | Automatic flagging with `corruption_flag` |
| **Efficient storage** | Parquet format (compressed, fast to read) |

------------------------------------------------------------------------

## 🔁 Reproducibility

``` bash
# 1. Clone repo
# 2. Ensure lookup tables are in data/lookup/
# 3. Run pipeline
Rscript R/01_curate_epd_api.R
# 4. Validate data
Rscript R/02_validate_epd.R
# 5. Render dashboard
Rscript -e "rmarkdown::render('reports/epd_dashboard.Rmd')"
# 6. Render report
quarto render curation_report.qmd
```

------------------------------------------------------------------------

## 📄 Data Attribution & Licence

**Source:** NHS Business Services Authority. "English Prescribing Dataset (EPD) with SNOMED Code" NHS Business Services Authority Open Data. Accessed April 2026. URL: <https://opendata.nhsbsa.net/dataset/english-prescribing-dataset-epd-with-snomed-code>

**Licence:** Open Government Licence v3.0 – <https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/>

**Copyright Notice:** NHSBSA Copyright 2025

**Code Licence:** MIT © Marco Sorbona

------------------------------------------------------------------------

## 📚 Documentation

-   [Information Governance](INFO_GOVERNANCE.md)
-   [Data Quality Prevention](DATA_QUALITY.md)
-   [Equality, Diversity and Inclusion](EDI.md)

------------------------------------------------------------------------

## 📬 Contact

**Marco Sorbona, PhD**\
[GitHub](https://github.com/MarcoSorbona) \| [LinkedIn](https://linkedin.com/in/marco-sorbona-phd)
