# Read processed BFS data from S3

**\[deprecated\]**

`read_bfs_from_s3()` is deprecated. Use
[`get_business_applications()`](https://ruralinnovation.github.io/cori.data.bfs/reference/get_business_applications.md)
instead.

## Usage

``` r
read_bfs_from_s3(
  vintage = "latest",
  variables = NULL,
  years = NULL,
  geoids = NULL,
  s3_bucket = "cori.data.bfs",
  s3_path_prefix = ""
)
```

## Arguments

- vintage:

  Passed to
  [`get_business_applications()`](https://ruralinnovation.github.io/cori.data.bfs/reference/get_business_applications.md).

- variables:

  Passed to
  [`get_business_applications()`](https://ruralinnovation.github.io/cori.data.bfs/reference/get_business_applications.md).

- years:

  Passed to
  [`get_business_applications()`](https://ruralinnovation.github.io/cori.data.bfs/reference/get_business_applications.md).

- geoids:

  Passed to
  [`get_business_applications()`](https://ruralinnovation.github.io/cori.data.bfs/reference/get_business_applications.md).

- s3_bucket:

  Ignored. No longer configurable in the public API.

- s3_path_prefix:

  Ignored. No longer configurable in the public API.

## Value

A data frame. See
[`get_business_applications()`](https://ruralinnovation.github.io/cori.data.bfs/reference/get_business_applications.md)
for details.

## See also

[`get_business_applications()`](https://ruralinnovation.github.io/cori.data.bfs/reference/get_business_applications.md)
