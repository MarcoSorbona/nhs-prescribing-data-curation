# A&E Waiting Times Analysis

NHS A&E waiting times: data curation, time series analysis, regional variation, and operational analytics.

[**View the Live Analysis →**](ae_analysis.html)

---

## 📁 Project Structure
ae-waiting-times-analysis/
├── ae_analysis.qmd # Main analysis report
├── curation_report.qmd # Data curation documentation
├── data_dictionary.md # Variable descriptions
├── README.md # This file
├── R/
│ ├── 01_curate_ae_data.R # Data curation pipeline
│ └── 02_validate_ae_data.R # Quality checks
├── data/
│ ├── raw/
│ │ └── monthly_ae_*.csv # Messy source files
│ └── clean/
│ └── ae_clean.rds
└── outputs/
├── figures/
└── tables/


## 🛠️ Skills Demonstrated

| Skill | Evidence |
|-------|----------|
| **Data curation** | Handling messy CSV (header rows, footnotes, blank lines) |
| **Data validation** | Missing values, duplicates, range checks |
| **Time series analysis** | National trends, seasonal patterns |
| **Regional analysis** | ICB/regional variation |
| **Reproducible reporting** | Quarto, RDS caching |

## 📦 Data Source

| Property | Value |
|----------|-------|
| **Source** | NHS England (Monthly A&E Sitrep) |
| **Time period** | 2025-2026 |
| **Access** | CSV download |

## 🔁 Reproducibility

1. **Clone** this repository
2. **Download** raw CSV files to `data/raw/`
3. **Run** `R/01_curate_ae_data.R`
4. **Render** `ae_analysis.qmd`

## Documentation

- [Information Governance](INFO_GOVERNANCE.md)
- [Data Quality Prevention](DATA_QUALITY.md)
- [Equality, Diversity and Inclusion](EDI.md)

## 📬 Contact

**Marco Sorbona, PhD**  
[GitHub](https://github.com/MarcoSorbona) | [LinkedIn](https://linkedin.com/in/marco-sorbona-phd)

## 📄 License

**Code**: MIT © Marco Sorbona  
**Data**: Open Government Licence v3.0 (NHS Digital)