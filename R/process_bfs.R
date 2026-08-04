# Processing functions for Census Bureau Business Formation Statistics (BFS).
# All functions return a data frame with columns: geoid, year, variable, value, agg_var
#
# Coverage: 2005-present, county + state + national.
# Source: single Excel file updated annually by Census Bureau.
#
# Variables:
#   business_applications  — total business applications (BA series)

.BFS_URL <- "https://www.census.gov/econ/bfs/xlsx/bfs_county_apps_annual.xlsx"


#' Pull Business Formation Statistics across multiple years
#'
#' Downloads the Census Bureau BFS county Excel file and returns business
#' application counts for all U.S. counties, states, and the nation.
#'
#' Returns `business_applications` (BA series) for all U.S. counties, states,
#' and the nation. State and national totals are computed by summing county values.
#'
#' @param years Integer vector. Years to return. Default: `2005` to current year.
#'
#' @keywords internal
pull_bfs <- function(years = 2005:as.integer(format(Sys.Date(), "%Y"))) {

  fp <- file.path(tempdir(), "bfs_county_apps_annual.xlsx")
  message("Downloading BFS Excel file...")
  utils::download.file(.BFS_URL, fp, mode = "wb", quiet = TRUE)

  raw <- readxl::read_xlsx(fp, skip = 2)

  # -- County-level BA and HBA --------------------------------------------------
  county <- raw |>
    dplyr::select(
      geoid = `County Code`,
      dplyr::matches("^BA\\d{4}$")
    ) |>
    dplyr::filter(!is.na(geoid)) |>
    tidyr::pivot_longer(
      cols      = -geoid,
      names_to  = "raw_var",
      values_to = "value"
    ) |>
    dplyr::mutate(
      year     = as.integer(stringr::str_extract(raw_var, "\\d{4}$")),
      variable = "business_applications",
      value    = as.numeric(value),
      agg_var  = NA_real_
    ) |>
    dplyr::filter(year %in% years) |>
    dplyr::select(geoid, year, variable, value, agg_var)

  # -- State rollups (sum counties within each state) ---------------------------
  state <- county |>
    dplyr::mutate(geoid = stringr::str_sub(geoid, 1, 2)) |>
    dplyr::group_by(geoid, year, variable) |>
    dplyr::summarise(value = sum(value, na.rm = TRUE), .groups = "drop") |>
    dplyr::mutate(agg_var = NA_real_)

  # -- National rollup ----------------------------------------------------------
  national <- county |>
    dplyr::group_by(year, variable) |>
    dplyr::summarise(value = sum(value, na.rm = TRUE), .groups = "drop") |>
    dplyr::mutate(geoid = "00", agg_var = NA_real_) |>
    dplyr::select(geoid, year, variable, value, agg_var)

  dplyr::bind_rows(county, state, national)
}
