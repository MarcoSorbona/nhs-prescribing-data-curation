# Data Quality Prevention

## My Approach

Rather than fixing issues after they occur, I focus on preventing them:

### 1. Standardised Collection Tools
- Validation rules at data entry (range checks, required fields)
- Consistent date formats and coding systems
- Dropdown menus for categorical variables

### 2. Training
- Regular training for data collectors on definitions and protocols
- Clear documentation of data dictionaries
- Feedback loops to data providers

### 3. Standard Operating Procedures (SOPs)
- Documented procedures for data entry, validation, and correction
- Version control for SOPs
- Regular review and updates

### 4. Automated Validation
- Scripts to flag missing values, outliers, and duplicates
- Range checks for numeric variables
- Consistency checks across linked datasets

### 5. Audit and Feedback
- Regular data quality reports to providers
- Tracking of common errors
- Continuous improvement cycles

## Demonstrated in This Portfolio

- **OpenPrescribing curation** – Validation checks for duplicates, negatives, date ranges (`R/01_curate_ae_data.R`)
- **Quality report** – Generated automatically during curation
- **Data dictionary** – Complete variable documentation