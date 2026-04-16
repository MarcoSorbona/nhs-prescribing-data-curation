# NHS Prescribing Data Curation

English Prescribing Dataset (EPD) with SNOMED: data curation pipeline, quality assurance, and reproducible documentation for NHS primary care prescribing data.

[**View the Curation Report →**](curation_report.html)

------------------------------------------------------------------------

## 📁 Project Structure

nhs-prescribing-data-curation/

├── curation_report.qmd \# Main curation documentation

├── data_dictionary.md \# Variable descriptions

├── README.md \# This file

├── R/

│ ├── 01_curate_epd.R \# Data curation pipeline

│ └── 02_validate_epd.R \# Quality checks

├── data/

│ ├── raw/ \# Monthly EPD CSV files

│ ├── lookup/ \# Practice + BNF lookup tables

│ └── clean/

│ └── epd_clean.parquet \# Curated dataset

└── outputs/

├── figures/

└── tables/

------------------------------------------------------------------------

## 🛠️ Skills Demonstrated

| Skill | Evidence |
|----|----|
| **Large-scale data curation** | 1M+ rows/month, processed with `vroom`/`arrow` |
| **Code versioning** | BNF/SNOMED changes across months |
| **Lookup table joins** | Practice codes, BNF hierarchy, SNOMED mapping |
| **Data quality documentation** | Missingness, known SSP limitation, join success rates |
| **Reproducible pipeline** | Quarto + Parquet + R scripts |

------------------------------------------------------------------------

## 📦 Data Source

| Property        | Value                                              |
|-----------------|----------------------------------------------------|
| **Dataset**     | English Prescribing Dataset (EPD) with SNOMED Code |
| **Provider**    | NHS Business Services Authority (NHSBSA)           |
| **Time period** | Monthly files (2024–2026)                          |
| **Access**      | Open Data Portal                                   |
| **Licence**     | Open Government Licence v3.0                       |

### Known Data Complexities Handled

| Challenge                         | Approach                                |
|-----------------------------------|-----------------------------------------|
| BNF/SNOMED codes change over time | Version-aware joins; documented         |
| SSP utilisation not identifiable  | Explicit limitation in curation report  |
| Negative quantities (returns)     | Flagged; exclusion rule documented      |
| Missing practice/BNF matches      | Join success rates calculated           |
| Large file size                   | `vroom` + Parquet for efficient storage |

------------------------------------------------------------------------

## 🔁 Reproducibility

1.  **Clone** this repository
2.  **Download** monthly EPD CSVs + lookup tables to `data/raw/` and `data/lookup/`
3.  **Run** `R/01_curate_epd.R`
4.  **Run** `R/02_validate_epd.R`
5.  **Render** `curation_report.qmd`

------------------------------------------------------------------------

## 📄 Data Attribution & Licence

**Source:** NHS Business Services Authority. "English Prescribing Dataset (EPD) with SNOMED Code" NHS Business Services Authority Open Data. Accessed 16 April 2026. URL: <https://opendata.nhsbsa.net/dataset/english-prescribing-dataset-epd-with-snomed-code>

**Licence:** Open Government Licence v3.0 – <https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/>

**Copyright Notice:** NHSBSA Copyright 2025

**Third Party Copyright:** Any data not subject to NHSBSA copyright retains original copyright; permission obtained before reproduction where required.

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
