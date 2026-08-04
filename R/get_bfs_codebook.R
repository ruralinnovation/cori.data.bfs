#' Get the cori.data.bfs variable codebook
#'
#' Returns documentation for all variables available from
#' [get_business_applications()].
#'
#' @return A data frame with columns: `variable`, `raw_variable`, `label`,
#'   `unit`, `notes`.
#'   `raw_variable` is the original name stored in S3 parquet files.
#'
#' @seealso [get_business_applications()]
#'
#' @examples
#' get_bfs_codebook()
#'
#' @export
get_bfs_codebook <- function() {
  data.frame(
    stringsAsFactors = FALSE,

    variable = c(
      "business_applications"
    ),

    raw_variable = c(
      "business_applications"
    ),

    label = c(
      "Business applications"
    ),

    unit = c(
      "applications"
    ),

    notes = c(
      paste0(
        "Total business applications (BA series). Counts EIN applications filed ",
        "with the IRS, excluding tax liens, estates, trusts, agriculture (NAICS 11), ",
        "and public administration (NAICS 92). County, state, and national coverage. ",
        "Coverage: 2005-present."
      )
    )
  )
}
