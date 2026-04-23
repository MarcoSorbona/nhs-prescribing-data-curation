#!/usr/bin/env Rscript
# ============================================================================
# Post-Curation Quality Validation
# English Prescribing Dataset (EPD) Curation
#
# Author: Marco Sorbona
# Purpose: Validate curated EPD data quality
# ============================================================================

# 1. Setup ------------------------------------------------------------------

library(arrow)
library(dplyr)
library(ggplot2)
library(tidyr)

# Configuration
DATA_CLEAN_DIR <- "data/clean"

# 2. Load Curated Data ------------------------------------------------------

cat("\n📂 Loading curated data...\n")

curated <- read_parquet(file.path(DATA_CLEAN_DIR, "epd_curated.parquet"))

cat("✅ Loaded", nrow(curated), "rows with", ncol(curated), "columns\n")

# 3. Validation Checks ------------------------------------------------------

validation_report <- list()

cat("\n", rep("=", 60), "\n", sep = "")
cat("POST-CURATION VALIDATION REPORT\n")
cat(rep("=", 60), "\n", sep = "")

# 3.1 Check for negative costs (should be none after aggregation)
validation_report$negative_costs <- curated |>
  filter(actual_cost < 0) |>
  nrow()

cat("\n1. Negative cost rows:", validation_report$negative_costs)
if(validation_report$negative_costs > 0) {
  cat(" ⚠️ WARNING")
} else {
  cat(" ✅ PASS")
}

# 3.2 Check for negative quantities (returns to pharmacy – expected)
validation_report$negative_quantities <- curated |>
  filter(quantity < 0) |>
  nrow()

cat("\n2. Negative quantity rows (returns):", validation_report$negative_quantities)
cat(" ℹ️  Expected (returns to pharmacy)")

# 3.3 Check for zero cost items
validation_report$zero_cost <- curated |>
  filter(actual_cost == 0) |>
  nrow()

cat("\n3. Zero cost rows:", validation_report$zero_cost)

# 3.4 Check for missing practice codes
validation_report$missing_practice <- curated |>
  filter(is.na(practice_code)) |>
  nrow()

cat("\n4. Missing practice codes:", validation_report$missing_practice)

# 3.5 Check for missing drug names (known issue for 2023 data)
validation_report$missing_drug_names <- curated |>
  filter(is.na(bnf_presentation_name)) |>
  summarise(
    rows = n(),
    cost = sum(actual_cost, na.rm = TRUE),
    items = sum(items, na.rm = TRUE)
  )

cat("\n5. Missing drug names:", validation_report$missing_drug_names$rows, "rows")
cat("   (£", format(round(validation_report$missing_drug_names$cost, 0), big.mark = ","), 
    ", ", format(validation_report$missing_drug_names$items, big.mark = ","), " items)", sep = "")

# 3.6 Check date range and continuity
date_range <- curated |>
  summarise(
    min_date = min(year_month, na.rm = TRUE),
    max_date = max(year_month, na.rm = TRUE),
    unique_months = n_distinct(year_month)
  )

validation_report$date_range <- list(
  min = date_range$min_date,
  max = date_range$max_date,
  unique_months = date_range$unique_months
)

cat("\n6. Date range:", date_range$min_date, "to", date_range$max_date)
cat("\n   Unique months:", date_range$unique_months)

# 3.7 Check for December 2023 corruption flags
validation_report$dec2023_flags <- curated |>
  filter(!is.na(corruption_flag)) |>
  group_by(corruption_flag) |>
  summarise(
    rows = n(),
    cost = sum(actual_cost, na.rm = TRUE),
    items = sum(items, na.rm = TRUE)
  )

if(nrow(validation_report$dec2023_flags) > 0) {
  cat("\n7. December 2023 corruption flags:\n")
  print(validation_report$dec2023_flags)
} else {
  cat("\n7. December 2023 corruption flags: None detected ✅\n")
}

# 3.8 Regional completeness
region_check <- curated |>
  group_by(regional_office_name) |>
  summarise(
    rows = n(),
    practices = n_distinct(practice_code),
    cost = sum(actual_cost, na.rm = TRUE)
  ) |>
  arrange(desc(cost))

validation_report$regions <- region_check

cat("\n8. Regional breakdown (by cost):\n")
print(region_check)

# 3.9 Check for duplicate rows
validation_report$duplicates <- curated |>
  group_by(practice_code, bnf_presentation_code, year_month) |>
  filter(n() > 1) |>
  nrow()

cat("\n9. Duplicate (practice, drug, month) rows:", validation_report$duplicates)
if(validation_report$duplicates == 0) {
  cat(" ✅ PASS")
}

# 3.10 Summary statistics
validation_report$summary_stats <- curated |>
  summarise(
    total_items = sum(items, na.rm = TRUE),
    total_cost = sum(actual_cost, na.rm = TRUE),
    avg_cost_per_item = total_cost / total_items,
    unique_practices = n_distinct(practice_code),
    unique_drugs = n_distinct(bnf_presentation_code)
  )

cat("\n\n", rep("=", 60), "\n", sep = "")
cat("SUMMARY STATISTICS\n")
cat(rep("=", 60), "\n", sep = "")
cat("   Total items:        ", format(validation_report$summary_stats$total_items, big.mark = ","), "\n")
cat("   Total cost:         £", format(round(validation_report$summary_stats$total_cost, 0), big.mark = ","), "\n")
cat("   Avg cost per item:  £", round(validation_report$summary_stats$avg_cost_per_item, 2), "\n")
cat("   Unique practices:   ", format(validation_report$summary_stats$unique_practices, big.mark = ","), "\n")
cat("   Unique drugs:       ", format(validation_report$summary_stats$unique_drugs, big.mark = ","), "\n")

# 4. Data Quality Visualisations --------------------------------------------

cat("\n", rep("=", 60), "\n", sep = "")
cat("GENERATING QUALITY PLOTS\n")
cat(rep("=", 60), "\n", sep = "")

# Create output directory for figures
dir.create("outputs/figures", showWarnings = FALSE, recursive = TRUE)

# Plot 1: Missing drug names by month (DYNAMIC)
missing_by_month <- curated |>
  group_by(year_month) |>
  summarise(
    missing_drug_names = sum(is.na(bnf_presentation_name)),
    total_rows = n(),
    pct_missing = 100 * missing_drug_names / total_rows
  )

# Generate dynamic subtitle
max_missing <- missing_by_month |> filter(pct_missing == max(pct_missing))
min_missing <- missing_by_month |> filter(pct_missing == min(pct_missing))

dynamic_subtitle <- paste0(
  round(max_missing$pct_missing, 0), "% missing in ", max_missing$year_month,
  " vs ", round(min_missing$pct_missing, 0), "% in ", min_missing$year_month
)

p1 <- ggplot(missing_by_month, aes(x = year_month, y = pct_missing, fill = year_month)) +
  geom_col() +
  geom_text(aes(label = paste0(round(pct_missing, 0), "%")), vjust = -0.5, size = 4) +
  labs(x = "Month", y = "Missing Drug Names (%)",
       title = "Data Quality: Missing Drug Names by Month",
       subtitle = dynamic_subtitle) +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("outputs/figures/missing_drug_names.png", p1, width = 8, height = 5)
cat("✅ Saved: outputs/figures/missing_drug_names.png\n")

# Plot 2: Monthly cost trend
monthly_cost <- curated |>
  group_by(year_month) |>
  summarise(total_cost = sum(actual_cost, na.rm = TRUE))

p2 <- ggplot(monthly_cost, aes(x = year_month, y = total_cost, group = 1)) +
  geom_line(linewidth = 1.2, color = "steelblue") +
  geom_point(size = 3, color = "darkblue") +
  labs(x = "Month", y = "Total Cost (£)",
       title = "Monthly Prescribing Cost Trend") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("outputs/figures/monthly_cost_trend.png", p2, width = 8, height = 5)
cat("✅ Saved: outputs/figures/monthly_cost_trend.png\n")

# Plot 3: Regional cost distribution
p3 <- ggplot(region_check, aes(x = reorder(regional_office_name, cost), y = cost, fill = regional_office_name)) +
  geom_col() +
  coord_flip() +
  labs(x = "", y = "Total Cost (£)",
       title = "Total Prescribing Cost by Region") +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("outputs/figures/regional_cost.png", p3, width = 8, height = 6)
cat("✅ Saved: outputs/figures/regional_cost.png\n")

# 5. Save Validation Report ------------------------------------------------

saveRDS(validation_report, file.path(DATA_CLEAN_DIR, "validation_report.rds"))
cat("\n✅ Validation report saved: data/clean/validation_report.rds\n")

# 6. Final Summary ---------------------------------------------------------

cat("\n", rep("=", 60), "\n", sep = "")
cat("VALIDATION COMPLETE\n")
cat(rep("=", 60), "\n", sep = "")

# Determine overall status
issues_found <- FALSE

if(validation_report$negative_costs > 0) {
  cat("⚠️  Issue: Negative costs detected\n")
  issues_found <- TRUE
}

if(validation_report$missing_practice > 0) {
  cat("⚠️  Issue: Missing practice codes detected\n")
  issues_found <- TRUE
}

if(validation_report$duplicates > 0) {
  cat("⚠️  Issue: Duplicate rows detected\n")
  issues_found <- TRUE
}

if(!issues_found) {
  cat("✅ All critical validation checks passed!\n")
  cat("   Known issue: Missing drug names in 2023 data (documented)\n")
}

cat("\n📁 Outputs:\n")
cat("   - data/clean/validation_report.rds\n")
cat("   - outputs/figures/missing_drug_names.png\n")
cat("   - outputs/figures/monthly_cost_trend.png\n")
cat("   - outputs/figures/regional_cost.png\n")