#' Read processed BFS data from S3
#'
#' Queries CORI's processed Business Formation Statistics parquet files from S3
#' using DuckDB. Returns long-format data — one row per geoid/year/variable.
#'
#' @param vintage Character. Vintage to read, e.g. `"2024"`. Default: `"latest"`,
#'   which reads the `_LATEST` pointer written by [write_bfs_processed_to_s3()].
#' @param variables Character vector. Variables to return. Default: all.
#'   See [get_bfs_codebook()] for names.
#' @param years Integer vector. Years to return. Default: all.
#' @param geoids Character vector. FIPS codes to return (5-digit county, 2-digit
#'   state, or `"00"` for national). Default: all.
#' @param s3_bucket Character. S3 bucket name. Default: `"cori.data.bfs"`.
#' @param s3_path_prefix Character. Optional prefix matching the one used in
#'   [write_bfs_processed_to_s3()], e.g. `"test/"`. Default: `""`.
#'
#' @return A data frame with columns: `geoid`, `year`, `variable`, `value`,
#'   `agg_var`.
#'
#' @seealso [latest_bfs_vintage()], [get_bfs_codebook()]
#'
#' @examples
#' \dontrun{
#' # All data, latest vintage
#' df <- read_bfs_from_s3()
#'
#' # Business applications for specific counties
#' df <- read_bfs_from_s3(
#'   variables = "business_applications",
#'   geoids    = c("54011", "54025")
#' )
#' }
#'
#' @export
read_bfs_from_s3 <- function(
    vintage        = "latest",
    variables      = NULL,
    years          = NULL,
    geoids         = NULL,
    s3_bucket      = "cori.data.bfs",
    s3_path_prefix = ""
) {

  vintage_tag <- if (vintage == "latest") {
    latest_bfs_vintage(s3_bucket, s3_path_prefix)
  } else {
    if (!startsWith(vintage, "vintage_")) sprintf("vintage_%s", vintage) else vintage
  }

  con <- DBI::dbConnect(duckdb::duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

  DBI::dbExecute(con, "INSTALL httpfs; LOAD httpfs;")
  DBI::dbExecute(con, "INSTALL aws;   LOAD aws;")
  DBI::dbExecute(con, sprintf("SET temp_directory = '%s';", tempdir()))
  DBI::dbExecute(con, "CREATE OR REPLACE SECRET s3_secret (
    TYPE S3,
    PROVIDER CREDENTIAL_CHAIN,
    CHAIN 'env;config',
    REGION 'us-east-1',
    URL_STYLE 'path'
  );")

  glob  <- sprintf(
    "s3://%s/%sdata_processed/%s/**/*.parquet",
    s3_bucket, s3_path_prefix, vintage_tag
  )
  query <- sprintf(
    "SELECT geoid, year, variable, value, agg_var FROM read_parquet('%s', hive_partitioning = true)",
    glob
  )

  where <- character(0)
  if (!is.null(geoids)) {
    where <- c(where, sprintf("geoid IN (%s)", paste0("'", geoids, "'", collapse = ", ")))
  }
  if (!is.null(years)) {
    where <- c(where, sprintf("year IN (%s)", paste(years, collapse = ", ")))
  }
  if (!is.null(variables)) {
    where <- c(where, sprintf("variable IN (%s)", paste0("'", variables, "'", collapse = ", ")))
  }
  if (length(where) > 0) {
    query <- paste(query, "WHERE", paste(where, collapse = " AND "))
  }

  DBI::dbGetQuery(con, query) |>
    dplyr::mutate(
      geoid   = as.character(geoid),
      year    = as.integer(year),
      value   = as.numeric(value),
      agg_var = as.numeric(agg_var)
    )
}
