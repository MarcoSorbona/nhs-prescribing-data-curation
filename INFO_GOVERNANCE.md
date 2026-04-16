# Information Governance

## My Approach to Data Security

In my previous role, I worked with patient‑level data stored on secure level‑3 servers across Europe. My practice includes:

-   **Password protection** – All sensitive files are password‑protected
-   **Role‑based access** – Access restricted to authorised team members only
-   **Encrypted transfers** – Approved secure methods for data sharing
-   **Audit trails** – All access and actions logged
-   **Data sharing agreements** – Formal agreements with collaborators

## In This Project

All data used in this EPD curation project are public (NHS Business Services Authority Open Data Portal). However, I apply the same principles:

-   Data accessed via official NHSBSA Open Data Portal
-   Cached locally as Parquet files, not redistributed beyond analysis scope
-   Code is version‑controlled and reproducible
-   No patient‑identifiable information is used (EPD is aggregated at practice level)

## Live Environment Practice

In a live UKHSA, NHS, or HDR UK setting, I would also:

-   Follow organisational SOPs for data transfer and storage
-   Use approved secure environments (e.g., NHS Secure Data Environment, OpenSAFELY)
-   Complete annual information governance training
-   Adhere to Data Protection Act 2018 and UK GDPR requirements

## Data Source & Attribution

### English Prescribing Dataset (EPD) with SNOMED Code

-   **Provider:** NHS Business Services Authority (NHSBSA)
-   **Licence:** Open Government Licence v3.0
-   **Copyright:** NHSBSA Copyright 2025
-   **Citation:** NHS Business Services Authority. "English Prescribing Dataset (EPD) with SNOMED Code" NHS Business Services Authority Open Data. Accessed 16 April 2026. URL: <https://opendata.nhsbsa.net/dataset/english-prescribing-dataset-epd-with-snomed-code>

### Terms of Use

-   This project uses data under OGL v3.0 terms
-   No press or broadcast use is intended (as required by NHSBSA)
-   Attribution is provided as required
-   No patient-identifiable information is contained in this dataset
-   No ethical approval required for public open data

### Third Party Copyright

Any data elements not subject to NHSBSA copyright retain their original copyright. This project does not reproduce third-party data without permission.

## Additional Governance Considerations for EPD

| Consideration | How Addressed |
|----|----|
| BNF/SNOMED code changes over time | Version-aware joins; documented in curation report |
| SSP utilisation cannot be identified | Explicit limitation documented |
| Practice-level data (small numbers) | No suppression applied as data is public; would follow NHSBSA disclosure control if republishing |
| Monthly file updates | Pipeline designed for incremental updates |
