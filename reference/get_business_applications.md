# Get Business Formation Statistics

Queries CORI's processed Business Formation Statistics (BFS) parquet
files from S3 using DuckDB. Returns long-format data: one row per
`geoid / year / variable`.

## Usage

``` r
get_business_applications(
  geography = c("all", "county", "state", "nation"),
  years = NULL,
  geoids = NULL,
  variables = NULL,
  vintage = "latest"
)
```

## Arguments

- geography:

  Character. One of `"all"`, `"county"`, `"state"`, or `"nation"`.
  Filters rows by geography level. Default: `"all"`.

- years:

  Integer vector. Years to return. Default: all available.

- geoids:

  Character vector. FIPS codes to return (5-digit county, 2-digit state,
  or `"00"` for national). When supplied, overrides `geography`.
  Default: all.

- variables:

  Character vector. Variables to return. Default: all. See
  [`get_bfs_codebook()`](https://ruralinnovation.github.io/cori.data.bfs/reference/get_bfs_codebook.md)
  for valid names.

- vintage:

  Character. Vintage to read, e.g. `"2024"`. Default: `"latest"`, which
  reads the `_LATEST` pointer written by
  [`write_bfs_processed_to_s3()`](https://ruralinnovation.github.io/cori.data.bfs/reference/write_bfs_processed_to_s3.md).

## Value

A data frame with columns: `geoid`, `year`, `variable`, `value`.

## See also

[`get_bfs_codebook()`](https://ruralinnovation.github.io/cori.data.bfs/reference/get_bfs_codebook.md)

## Examples

``` r
if (FALSE) { # \dontrun{
get_business_applications(geography = "county")
get_business_applications(geography = "county", years = 2015:2024)
get_business_applications(geoids = c("33009", "33"))
} # }
```
