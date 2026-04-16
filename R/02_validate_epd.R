# 02_validate_epd.R
# Post-curation quality validation

library(arrow)
library(dplyr)
library(ggplot2)

# Read curated data
curated <- read_parquet("data/clean/epd_curated.parquet")

# Validation checks
validation_report <- list()

# 1. No negative costs after aggregation
validation_report$negative_costs <- curated |> 
  filter(total_cost < 0) |> 
  nrow()

# 2. Date range continuity
validation_report$date_range <- curated |> 
  summarise(
    min_month = min(processing_month),
    max_month = max(processing_month),
    months_expected = as.numeric(difftime(
      as.Date(paste0(max_month, "01"), format = "%Y%m%d"),
      as.Date(paste0(min_month, "01"), format = "%Y%m%d"),
      units = "days"
    ) / 30)
  )

# 3. Join quality
validation_report$practice_match_rate <- mean(!is.na(curated$practice_name)) * 100
validation_report$bnf_match_rate <- mean(!is.na(curated$bnf_name)) * 100

# 4. Check for Dec 2023 corruption flags
if("corruption_flag" %in% names(curated)) {
  validation_report$dec2023_flags <- curated |> 
    filter(!is.na(corruption_flag)) |> 
    count(corruption_flag)
}

# 5. Unusual values
validation_report$zero_cost_times <- sum(curated$total_cost == 0, na.rm = TRUE)
validation_report$negative_quantity_flags <- sum(curated$negative_quantity_counts > 0)

# Print report
print(validation_report)

# Save
saveRDS(validation_report, "data/clean/validation_report.rds")