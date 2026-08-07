#' Write processed BFS data to S3 as a versioned vintage
#'
#' Downloads the Census BFS Excel file, processes it into the four-column tidy
#' format, and writes year-partitioned parquet files to S3. A `_LATEST` pointer
#' file is updated so [get_business_applications()] can find the current vintage.
#'
#' @param years Integer vector. Years to include. Default: `2005` to current year.
#' @param s3_bucket Character. S3 bucket name. Default: `"cori.data.bfs"`.
#' @param s3_path_prefix Character. Optional prefix for all S3 keys, e.g.
#'   `"test/"` during development. Default: `""`.
#' @param overwrite Logical. If `TRUE`, delete the existing S3 vintage prefix
#'   before uploading. Default: `FALSE`.
#' @param sync_to_s3 Logical. Upload to S3 after writing locally. Default: `TRUE`.
#'
#' @return Invisibly, a named list: `$vintage` and `$n_rows`.
#'
#' @keywords internal
write_bfs_processed_to_s3 <- function(
    years          = 2005:as.integer(format(Sys.Date(), "%Y")),
    s3_bucket      = "cori.data.bfs",
    s3_path_prefix = "",
    overwrite      = FALSE,
    sync_to_s3     = TRUE
) {

  message("Pulling BFS data...")
  processed <- pull_bfs(years)

  vintage     <- as.character(max(processed$year, na.rm = TRUE))
  vintage_tag <- sprintf("vintage_%s", vintage)

  message(sprintf("Vintage: %s | Rows: %s", vintage,
                  format(nrow(processed), big.mark = ",")))

  # Write parquet locally, partitioned by year
  out_dir <- file.path(tempdir(), "bfs_s3", vintage_tag)
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  con <- DBI::dbConnect(duckdb::duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

  DBI::dbWriteTable(con, "processed", processed, overwrite = TRUE)
  DBI::dbExecute(con, sprintf(
    "COPY processed TO '%s' (FORMAT 'parquet', PARTITION_BY (year), OVERWRITE_OR_IGNORE)",
    out_dir
  ))

  # Write _LATEST pointer
  latest_dir  <- file.path(tempdir(), "bfs_s3")
  latest_file <- file.path(latest_dir, "_LATEST")
  writeLines(vintage_tag, latest_file)

  message(sprintf("Parquet written to: %s", out_dir))

  if (sync_to_s3) {
    s3_vintage_prefix <- sprintf("%sdata_processed/%s/", s3_path_prefix, vintage_tag)

    if (overwrite) {
      if (!cori.data.s3::has_local_aws_credentials()) {
        stop("No local AWS credentials found. Deleting an S3 prefix requires ",
             "local AWS credentials. Run cori.data.s3::set_aws_credentials() or ",
             "configure the AWS CLI.", call. = FALSE)
      }
      s3_uri <- sprintf("s3://%s/%s", s3_bucket, s3_vintage_prefix)
      message(sprintf("Deleting existing S3 prefix: %s", s3_uri))
      system2("aws", args = c("s3", "rm", s3_uri, "--recursive"))
    }

    cori.data.s3::put_s3_objects_recursive(s3_bucket, s3_vintage_prefix, out_dir)

    # _LATEST is a pointer meant to be overwritten on every run, not
    # versioned data -- put_s3_object()'s overwrite-protection would block
    # every run after the first, so it's uploaded directly instead.
    .bfs_upload_to_s3(
      s3_bucket,
      sprintf("%sdata_processed/_LATEST", s3_path_prefix),
      latest_file
    )
    message(sprintf("_LATEST updated to: %s", vintage_tag))
  }

  invisible(list(vintage = vintage, n_rows = nrow(processed)))
}


# Internal: upload the _LATEST pointer file to S3 via AWS CLI, always
# overwriting (see comment at the call site for why this bypasses
# put_s3_object()).
.bfs_upload_to_s3 <- function(s3_bucket, s3_prefix, local_path) {
  s3_uri <- sprintf("s3://%s/%s", s3_bucket, s3_prefix)
  message(sprintf("Uploading to %s...", s3_uri))

  exit_code <- base::system2("aws", args = c("s3", "cp", local_path, s3_uri))

  if (exit_code != 0) stop(sprintf("AWS CLI upload failed: %s -> %s", local_path, s3_uri))
}
