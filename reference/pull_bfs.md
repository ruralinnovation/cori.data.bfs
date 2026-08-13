# Pull Business Formation Statistics across multiple years

Downloads the Census Bureau BFS county Excel file and returns business
application counts for all U.S. counties, states, and the nation.

## Usage

``` r
pull_bfs(years = 2005:as.integer(format(Sys.Date(), "%Y")))
```

## Arguments

- years:

  Integer vector. Years to return. Default: `2005` to current year.

## Details

Returns `business_applications` (BA series) for all U.S. counties,
states, and the nation. State and national totals are computed by
summing county values.
