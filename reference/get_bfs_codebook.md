# Get the cori.data.bfs variable codebook

Returns documentation for all variables available from
[`get_business_applications()`](https://ruralinnovation.github.io/cori.data.bfs/reference/get_business_applications.md).

## Usage

``` r
get_bfs_codebook()
```

## Value

A data frame with columns: `variable`, `raw_variable`, `label`, `unit`,
`notes`. `raw_variable` is the original name stored in S3 parquet files.

## See also

[`get_business_applications()`](https://ruralinnovation.github.io/cori.data.bfs/reference/get_business_applications.md)

## Examples

``` r
get_bfs_codebook()
#>                variable          raw_variable                 label
#> 1 business_applications business_applications Business applications
#>           unit
#> 1 applications
#>                                                                                                                                                                                                                                                    notes
#> 1 Total business applications (BA series). Counts EIN applications filed with the IRS, excluding tax liens, estates, trusts, agriculture (NAICS 11), and public administration (NAICS 92). County, state, and national coverage. Coverage: 2005-present.
```
