# Write processed BFS data to S3 as a versioned vintage

Downloads the Census BFS Excel file, processes it into the four-column
tidy format, and writes year-partitioned parquet files to S3. A
`_LATEST` pointer file is updated so
[`get_business_applications()`](https://ruralinnovation.github.io/cori.data.bfs/reference/get_business_applications.md)
can find the current vintage.

## Usage

``` r
write_bfs_processed_to_s3(
  years = 2005:as.integer(format(Sys.Date(), "%Y")),
  s3_bucket = "cori.data.bfs",
  s3_path_prefix = "",
  overwrite = FALSE,
  sync_to_s3 = TRUE
)
```

## Arguments

- years:

  Integer vector. Years to include. Default: `2005` to current year.

- s3_bucket:

  Character. S3 bucket name. Default: `"cori.data.bfs"`.

- s3_path_prefix:

  Character. Optional prefix for all S3 keys, e.g. `"test/"` during
  development. Default: `""`.

- overwrite:

  Logical. If `TRUE`, delete the existing S3 vintage prefix before
  uploading. Default: `FALSE`.

- sync_to_s3:

  Logical. Upload to S3 after writing locally. Default: `TRUE`.

## Value

Invisibly, a named list: `$vintage` and `$n_rows`.
