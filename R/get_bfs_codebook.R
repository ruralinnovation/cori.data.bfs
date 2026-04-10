#' Get the cori.data.bfs variable codebook
#'
#' Returns documentation for all variables produced by the CORI BFS processing
#' pipeline.
#'
#' @return A data frame with columns: `variable`, `label`, `unit`, `notes`.
#'
#' @seealso [read_bfs_from_s3()]
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
