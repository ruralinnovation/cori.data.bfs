#' Read processed BFS data from S3
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' `read_bfs_from_s3()` is deprecated. Use [get_business_applications()] instead.
#'
#' @param vintage Passed to [get_business_applications()].
#' @param variables Passed to [get_business_applications()].
#' @param years Passed to [get_business_applications()].
#' @param geoids Passed to [get_business_applications()].
#' @param s3_bucket Ignored. No longer configurable in the public API.
#' @param s3_path_prefix Ignored. No longer configurable in the public API.
#'
#' @return A data frame. See [get_business_applications()] for details.
#'
#' @seealso [get_business_applications()]
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
  .Deprecated(
    new     = "get_business_applications",
    package = "cori.data.bfs",
    msg     = paste0(
      "`read_bfs_from_s3()` is deprecated. Use `get_business_applications()` instead.\n",
      "  Note: `s3_bucket` and `s3_path_prefix` are no longer configurable in the public API."
    )
  )
  get_business_applications(
    years     = years,
    geoids    = geoids,
    variables = variables,
    vintage   = vintage
  )
}


#' @keywords internal
latest_bfs_vintage <- function(s3_bucket = "cori.data.bfs", s3_path_prefix = "") {
  .latest_bfs_vintage(s3_bucket, s3_path_prefix)
}
