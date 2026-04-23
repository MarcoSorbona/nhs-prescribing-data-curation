# Data Dictionary – English Prescribing Dataset (EPD) Curation

**Dataset:** Curated EPD with SNOMED (sample size varies by API limit)  
**Author:** Marco Sorbona  
**Date:** April 2026  
**Source:** NHSBSA Open Data Portal via CKAN API

---

## Variable Descriptions

| Variable | Type | Description | Example | Notes |
|----------|------|-------------|---------|-------|
| `year_month` | character | Year and month of prescription | `2025-12`, `202311` | ⚠️ Format varies by year |
| `date` | Date | Standardised date for time series | `2025-12-01` | Created from `year_month`; use for chronological plots |
| `year` | character | Year extracted from `year_month` | `2025` | |
| `month` | character | Month extracted from `year_month` | `12` | |
| `regional_office_name` | character | NHS England region | `NORTH WEST`, `MIDLANDS` | 8 regions including `UNIDENTIFIED` |
| `regional_office_code` | character | Region code | `Y62` | |
| `icb_name` | character | Integrated Care Board name | `NHS LANCASHIRE AND SOUTH CUMBRIA ICB` | |
| `icb_code` | character | ICB code | `QE1` | |
| `pco_name` | character | Primary Care Organisation name | `ABOUT HEALTH` | |
| `pco_code` | character | PCO code | `NPR00` | |
| `practice_code` | character | Unique GP practice identifier (ODS code) | `Y07032`, `A84006` | Used to join with practice lookup |
| `practice_name_raw` | character | GP practice name from API | `ABH MANCHESTER & TRAFFORD CDAT` | |
| `address_1` | character | Practice address line 1 | `ABOUT HEALTH` | |
| `address_2` | character | Practice address line 2 | `INNOVATION CENTRE` | |
| `address_3` | character | Practice address line 3 | `BLACKBURN` | |
| `address_4` | character | Practice address line 4 | `LANCASHIRE` | |
| `postcode` | character | Practice postcode | `BB1 2FD` | |
| `bnf_presentation_code` | character | 15-digit BNF drug code | `0103050L0AAAAAA` | Primary drug identifier |
| `bnf_presentation_name` | character | Drug name | `Lansoprazole 30mg capsules` | ⚠️ Missing for some years |
| `bnf_chemical_substance_code` | character | Active ingredient code | `0103050L0` | |
| `bnf_chemical_substance` | character | Active ingredient name | `Lansoprazole` | |
| `bnf_chapter_plus_code` | character | BNF chapter description | `01: Gastro-Intestinal System` | |
| `quantity` | numeric | Quantity prescribed | `14` | Can be negative (returns) |
| `items` | numeric | Number of prescription items | `1`, `2` | Primary volume measure |
| `total_quantity` | numeric | Total quantity (items × quantity per item) | `518` | |
| `adq_usage` | numeric | Average Daily Quantity usage | `777` | Clinical measure |
| `nic` | numeric | Net Ingredient Cost (£) | `18.87` | Cost before deductions |
| `actual_cost` | numeric | Actual cost to NHS (£) | `19.25` | Primary cost measure |
| `snomed_code` | character | SNOMED CT code | `42354611000001104` | Clinical terminology standard |
| `source_month` | character | Source month label | `December 2025` | Added during fetch |
| `has_known_corruption` | logical | Whether month has known issues | `FALSE` | Set based on source |
| `is_corruption_month` | logical | Flag for corrupted month | `FALSE` | Set based on source |
| `corruption_flag` | character | Specific corruption type | `MISSING_DRUG_NAME` | Flags rows with known issues |
| `BNF_PRESENTATION` | character | Drug name from BNF lookup | `Lansoprazole 30mg capsules` | Added via join |
| `BNF_CHAPTER` | character | BNF chapter name | `Gastro-Intestinal System` | Added via join |

---

## Key Quality Notes

### Known Data Issues

| Issue | Impact | Status |
|-------|--------|--------|
| **Missing drug names** | Costs un-attributable to specific drugs for affected months | Documented; flagged |
| **Inconsistent date formats** | 2023 uses `YYYYMM`, later years use `YYYY-MM` | Standardised via `date` column |
| **Negative quantities** | Returns to pharmacy | Retained; flag if needed |

### Join Success Rates (From Quality Report)

| Join | Typical Success Rate | Notes |
|------|---------------------|-------|
| Practice lookup | ~98% | Most practice codes match |
| BNF lookup | Varies | Lower for months with missing drug names |

---

## Usage Recommendations

### For Drug-Level Analysis
- **Use:** Months with complete drug names (check `corruption_flag`)
- **Avoid:** Months where `bnf_presentation_name` is missing

### For Regional Analysis
- All months are valid
- Note sample size per region (API limit applies)

### For Time Series
- Use `date` column (standardised)
- Be aware of sampling variation (10k rows/month via API)

### For Cost Analysis
- Use `actual_cost` (NHS reimbursement cost)
- Use `items` for volume

---

## Data Source Attribution

**Source:** NHS Business Services Authority. "English Prescribing Dataset (EPD) with SNOMED Code" NHS Business Services Authority Open Data. Accessed April 2026.

**Licence:** Open Government Licence v3.0

**Copyright:** NHSBSA Copyright 2025

---

## Contact

**Marco Sorbona, PhD**  
GitHub: [MarcoSorbona](https://github.com/MarcoSorbona)