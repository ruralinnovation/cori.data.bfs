# Suppress R CMD check NOTEs for column names used in dplyr NSE pipelines.

utils::globalVariables(c(
  # Identifiers
  "geoid", "year",

  # Raw Excel column names
  "County Code",

  # Pivot / reshape intermediates
  "raw_var",

  # Processed output columns
  "variable", "value", "agg_var"
))
