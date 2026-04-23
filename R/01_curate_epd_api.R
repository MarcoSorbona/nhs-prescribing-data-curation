#!/usr/bin/env Rscript
# ============================================================================
# English Prescribing Dataset (EPD) Curation Pipeline
# Using CKAN API for data access (returns pre-aggregated data)
#
# Author: Marco Sorbona
# Purpose: HDR UK Data Curator Portfolio
# Data Source: NHSBSA Open Data Portal (OGL v3.0)
# Copyright: NHSBSA Copyright 2025
# ============================================================================

# 1. Setup ------------------------------------------------------------------

# Load required packages
library(httr)      # For API calls
library(jsonlite)  # For parsing JSON
library(tidyverse) # For data manipulation
library(arrow)     # For Parquet export
library(fs)        # For file system operations
library(tictoc)    # For timing

# Configuration
DATA_LOOKUP_DIR <- "data/lookup"
DATA_CLEAN_DIR <- "data/clean"

# Create directories if they don't exist
dir_create(DATA_CLEAN_DIR)

# Start timer
tic("Total curation time")

# 2. Connect to API and Fetch Data -----------------------------------------

cat("\n📡 Fetching data from CKAN API...\n")

# Define the months you want to fetch (4 months)
months_to_fetch <- list(
  jan2026 = list(
    resource_id = "EPD_SNOMED_202601",
    name = "January 2026",
    has_corruption = FALSE,
    is_corruption_month = FALSE
  ),
  dec2025 = list(
    resource_id = "EPD_SNOMED_202512",
    name = "December 2025",
    has_corruption = FALSE,
    is_corruption_month = FALSE
  ),
  dec2023 = list(
    resource_id = "EPD_SNOMED_202312",
    name = "December 2023",
    has_corruption = TRUE,
    is_corruption_month = TRUE
  ),
  nov2023 = list(
    resource_id = "EPD_SNOMED_202311",
    name = "November 2023",
    has_corruption = FALSE,
    is_corruption_month = FALSE
  )
)

# Function to fetch data for one resource
fetch_epd_api <- function(resource_id, limit = 10000) {
  url <- "https://opendata.nhsbsa.net/api/3/action/datastore_search"
  
  response <- GET(url, query = list(
    resource_id = resource_id,
    limit = limit
  ))
  
  if(status_code(response) != 200) {
    stop("API error for ", resource_id, ": ", status_code(response))
  }
  
  data <- fromJSON(content(response, "text"))
  records <- data$result$records
  
  if(is.null(records) || length(records) == 0) {
    return(data.frame())
  }
  
  return(as.data.frame(records))
}

# Fetch data for all months
all_months_data <- list()

for(month_name in names(months_to_fetch)) {
  month <- months_to_fetch[[month_name]]
  cat("  Fetching ", month$name, "...\n", sep = "")
  
  month_data <- fetch_epd_api(month$resource_id, limit = 10000)
  
  if(nrow(month_data) > 0) {
    month_data$source_month <- month$name
    month_data$has_known_corruption <- month$has_corruption
    month_data$is_corruption_month <- month$is_corruption_month
    all_months_data[[month_name]] <- month_data
    cat("      ✅ Got ", nrow(month_data), " rows\n", sep = "")
  } else {
    cat("      ⚠️ No data returned for ", month$resource_id, "\n", sep = "")
  }
}

# 3. Combine Months with Type Harmonisation --------------------------------

cat("\n🔄 Combining months with type harmonisation...\n")

# Function to convert all columns to character for a single dataframe
harmonise_types <- function(df) {
  df <- as.data.frame(df)
  # Convert every column to character
  df[] <- lapply(df, as.character)
  return(df)
}

# Apply harmonisation to all months
all_months_data_harmonised <- lapply(all_months_data, harmonise_types)

# Now bind safely (all columns are character)
epd_raw <- bind_rows(all_months_data_harmonised)

cat("✅ Total rows fetched: ", nrow(epd_raw), "\n")
cat("   Columns: ", paste(names(epd_raw), collapse = ", "), "\n")

# Convert key columns back to appropriate types
epd_raw <- epd_raw |>
  mutate(
    # Numeric columns
    QUANTITY = as.numeric(QUANTITY),
    ITEMS = as.numeric(ITEMS),
    TOTAL_QUANTITY = as.numeric(TOTAL_QUANTITY),
    ADQ_USAGE = as.numeric(ADQ_USAGE),
    NIC = as.numeric(NIC),
    ACTUAL_COST = as.numeric(ACTUAL_COST),
    # Character columns
    YEAR_MONTH = as.character(YEAR_MONTH),
    PRACTICE_CODE = as.character(PRACTICE_CODE),
    BNF_PRESENTATION_CODE = as.character(BNF_PRESENTATION_CODE),
    POSTCODE = as.character(POSTCODE)
  )

cat("✅ Types harmonised and converted\n")


# 4. Clean and Standardise Column Names ------------------------------------

cat("\n🧹 Cleaning column names...\n")

# Rename to standard tidy names
epd_clean <- epd_raw |>
  rename(
    year_month = YEAR_MONTH,
    regional_office_name = REGIONAL_OFFICE_NAME,
    regional_office_code = REGIONAL_OFFICE_CODE,
    icb_name = ICB_NAME,
    icb_code = ICB_CODE,
    pco_name = PCO_NAME,
    pco_code = PCO_CODE,
    practice_name_raw = PRACTICE_NAME,
    practice_code = PRACTICE_CODE,
    address_1 = ADDRESS_1,
    address_2 = ADDRESS_2,
    address_3 = ADDRESS_3,
    address_4 = ADDRESS_4,
    postcode = POSTCODE,
    bnf_chemical_substance_code = BNF_CHEMICAL_SUBSTANCE_CODE,
    bnf_chemical_substance = BNF_CHEMICAL_SUBSTANCE,
    bnf_presentation_code = BNF_PRESENTATION_CODE,
    bnf_presentation_name = BNF_PRESENTATION_NAME,
    bnf_chapter_plus_code = BNF_CHAPTER_PLUS_CODE,
    quantity = QUANTITY,
    items = ITEMS,
    total_quantity = TOTAL_QUANTITY,
    adq_usage = ADQ_USAGE,
    nic = NIC,
    actual_cost = ACTUAL_COST,
    snomed_code = SNOMED_CODE
  ) |>
  # Convert numeric columns
  mutate(
    quantity = as.numeric(quantity),
    items = as.numeric(items),
    total_quantity = as.numeric(total_quantity),
    adq_usage = as.numeric(adq_usage),
    nic = as.numeric(nic),
    actual_cost = as.numeric(actual_cost),
    # Extract year and month from YEAR_MONTH (format: "2025-12")
    year = substr(year_month, 1, 4),
    month = substr(year_month, 6, 7),
    is_dec2023 = (grepl("2023", year_month) & grepl("12", year_month))
  )

cat("✅ Column names standardised\n")
cat("   Rows after cleaning: ", nrow(epd_clean), "\n")

# 5. Flag December 2023 Corruption -----------------------------------------

cat("\n⚠️ Flagging December 2023 corruption...\n")

epd_clean <- epd_clean |>
  mutate(
    corruption_flag = case_when(
      is_dec2023 & is.na(bnf_presentation_code) ~ "MISSING_BNF_CODE_DEC2023",
      is_dec2023 & nchar(bnf_presentation_code) < 9 ~ "MALFORMED_BNF_DEC2023",
      is_dec2023 ~ "DEC2023_MONTH",
      TRUE ~ NA_character_
    )
  )

# Count affected records
dec2023_issues <- epd_clean |>
  filter(!is.na(corruption_flag)) |>
  group_by(corruption_flag) |>
  summarise(
    n = n(),
    items_affected = sum(items, na.rm = TRUE),
    cost_affected = sum(actual_cost, na.rm = TRUE)
  )

if(nrow(dec2023_issues) > 0) {
  cat("⚠️ December 2023 corruption detected:\n")
  print(dec2023_issues)
} else {
  cat("✅ No December 2023 corruption flags triggered\n")
}

# 6. Load and Join Practice Lookup (Optional) -----------------------------

cat("\n🏥 Checking practice lookup...\n")

practice_lookup_path <- fs::dir_ls(DATA_LOOKUP_DIR, glob = "*practice*.csv")
if(length(practice_lookup_path) > 0) {
  practice_lookup <- read.csv(practice_lookup_path[1], stringsAsFactors = FALSE)
  cat("Loaded practice lookup with columns: ", paste(names(practice_lookup), collapse = ", "), "\n")
  cat("Practice lookup rows: ", nrow(practice_lookup), "\n")
  
  # Optional: Join if you need additional practice details
  # epd_clean <- epd_clean |>
  #   left_join(practice_lookup, by = c("practice_code" = "PRACTICE_CODE"))
} else {
  cat("No practice lookup found – using existing practice_name_raw column\n")
}

# 7. Load and Join BNF Lookup -----------------------------------

cat("\n💊 Loading BNF lookup...\n")

bnf_lookup_path <- fs::dir_ls(DATA_LOOKUP_DIR, glob = "*bnf*.csv")
if(length(bnf_lookup_path) > 0) {
  bnf_lookup <- read.csv(bnf_lookup_path[1], stringsAsFactors = FALSE)
  cat("Loaded BNF lookup with columns: ", paste(names(bnf_lookup), collapse = ", "), "\n")
  cat("BNF lookup rows: ", nrow(bnf_lookup), "\n")
  
  # Join to add more drug details
  epd_clean <- epd_clean |>
    left_join(bnf_lookup, by = c("bnf_presentation_code" = "BNF_PRESENTATION_CODE"))
  
  # Check join success
  bnf_join_stats <- epd_clean |>
    summarise(
      total = n(),
      matched = sum(!is.na(BNF_PRESENTATION)),
      match_pct = round(100 * matched / total, 2)
    )
  cat("BNF join success: ", bnf_join_stats$match_pct, "%\n")
} else {
  cat("No BNF lookup found – using existing bnf_presentation_name\n")
}

# 8. Final Quality Checks -------------------------------------------------

cat("\n📋 Final quality report...\n")

final_quality <- epd_clean |>
  summarise(
    unique_practices = n_distinct(practice_code, na.rm = TRUE),
    unique_drugs = n_distinct(bnf_presentation_code, na.rm = TRUE),
    unique_months = n_distinct(year_month, na.rm = TRUE),
    earliest_month = min(year_month, na.rm = TRUE),
    latest_month = max(year_month, na.rm = TRUE),
    total_items = sum(items, na.rm = TRUE),
    total_cost = sum(actual_cost, na.rm = TRUE),
    items_with_corruption = sum(if_else(!is.na(corruption_flag), items, 0), na.rm = TRUE),
    cost_with_corruption = sum(if_else(!is.na(corruption_flag), actual_cost, 0), na.rm = TRUE)
  )

cat("\n📊 Final Dataset Summary:\n")
print(final_quality)

# 9. Export to Parquet ----------------------------------------------------

cat("\n💾 Exporting curated data to Parquet...\n")
tic("Parquet export")

# Save full dataset
write_parquet(epd_clean, "data/clean/epd_curated.parquet")

# Save sample (100k rows or less)
sample_size <- min(100000, nrow(epd_clean))
epd_clean |>
  slice_sample(n = sample_size) |>
  write_parquet("data/clean/epd_curated_sample.parquet")

toc()
cat("✅ Exported to:\n")
cat("   - data/clean/epd_curated.parquet (", nrow(epd_clean), " rows)\n")
cat("   - data/clean/epd_curated_sample.parquet (", sample_size, " rows)\n")

# 10. Save Quality Report -------------------------------------------------

quality_report <- list(
  curation_date = Sys.time(),
  source = "NHSBSA English Prescribing Dataset with SNOMED",
  license = "Open Government Licence v3.0",
  copyright = "NHSBSA Copyright 2025",
  months_processed = names(months_to_fetch),
  months_details = lapply(months_to_fetch, function(x) x$name),
  total_rows_fetched = nrow(epd_raw),
  total_rows_after_cleaning = nrow(epd_clean),
  date_range = list(
    earliest = min(epd_clean$year_month, na.rm = TRUE),
    latest = max(epd_clean$year_month, na.rm = TRUE)
  ),
  final_summary = as.list(final_quality),
  dec2023_corruption_flags = if(exists("dec2023_issues") && nrow(dec2023_issues) > 0) {
    as.list(dec2023_issues)
  } else {
    NULL
  },
  columns_created = names(epd_clean)
)

# Add data quality findings to quality report (DYNAMIC)
# Calculate missing drug names from the actual data
missing_2023_data <- epd_clean |>
  filter(year_month %in% c("202311", "202312")) |>
  summarise(
    affected_rows = n(),
    affected_items = sum(items, na.rm = TRUE),
    affected_cost = sum(actual_cost, na.rm = TRUE)
  )

# Identify which months have missing drug names
months_with_missing <- epd_clean |>
  filter(is.na(bnf_presentation_name)) |>
  distinct(year_month) |>
  pull(year_month)

quality_report$data_quality_issues <- list(
  missing_drug_names = list(
    affected_months = months_with_missing,
    affected_rows = missing_2023_data$affected_rows,
    affected_items = missing_2023_data$affected_items,
    affected_cost = missing_2023_data$affected_cost,
    note = "Records with missing drug names detected. Check year_month column for affected months."
  ),
  api_limitation = "API endpoint returns zero drug names for certain years/years_formats"
)

saveRDS(quality_report, "data/clean/quality_report.rds")
cat("✅ Quality report saved: data/clean/quality_report.rds\n")

# 11. Summary of Corruption Findings ---------------------------------------

if(nrow(dec2023_issues) > 0) {
  cat("\n" , rep("=", 50), "\n", sep = "")
  cat("🔍 CORRUPTION SUMMARY\n")
  cat(rep("=", 50), "\n", sep = "")
  cat("December 2023 data quality issues:\n")
  print(dec2023_issues)
  cat("\n💡 Recommendation: Exclude or flag these rows in any analysis\n")
}

# 12. Final Summary -------------------------------------------------------

cat("\n" , rep("=", 50), "\n", sep = "")
cat("✨ CURATION PIPELINE COMPLETE!\n")
cat(rep("=", 50), "\n", sep = "")
cat("   Months processed: ", paste(names(months_to_fetch), collapse = ", "), "\n")
cat("   Total rows: ", format(nrow(epd_clean), big.mark = ","), "\n")
cat("   Total items: ", format(final_quality$total_items, big.mark = ","), "\n")
cat("   Total cost: £", format(round(final_quality$total_cost, 0), big.mark = ","), "\n")
if(final_quality$items_with_corruption > 0) {
  cat("   ⚠️  Corrupted items flagged: ", format(final_quality$items_with_corruption, big.mark = ","), "\n")
}
cat("\n   Output saved to: data/clean/\n")
cat("   - epd_curated.parquet\n")
cat("   - epd_curated_sample.parquet\n")
cat("   - quality_report.rds\n")

# Stop timer
toc()