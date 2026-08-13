# Introduction to cori.data.bfs

`cori.data.bfs` provides annual business application counts from the
U.S. Census Bureau’s Business Formation Statistics (BFS), processed and
stored in CORI’s S3 data lake. Data cover 2005–present and measure total
EIN applications filed with the IRS, excluding tax liens, estates,
trusts, agriculture (NAICS 11), and public administration (NAICS 92).

**Source:** U.S. Census Bureau, Business Formation Statistics
**Coverage:** 2005–present, updated annually **Geography:** County
(5-digit FIPS), state (2-digit FIPS), national (`"00"`)

## Variables

``` r

library(cori.data.bfs)

get_bfs_codebook() |>
  dplyr::select(variable, label, unit, notes) |>
  knitr::kable()
```

| variable | label | unit | notes |
|:---|:---|:---|:---|
| business_applications | Business applications | applications | Total business applications (BA series). Counts EIN applications filed with the IRS, excluding tax liens, estates, trusts, agriculture (NAICS 11), and public administration (NAICS 92). County, state, and national coverage. Coverage: 2005-present. |

## Reading data

All data are returned in long format: one row per
`geoid / year / variable`.

``` r

df <- get_business_applications(geography = "county")

dplyr::glimpse(df)
```

Filter to specific geographies, years, or variables:

``` r

# New Hampshire counties, 2010 onward
nh_bfs <- get_business_applications(
  geoids = grep("^33", unique(df$geoid), value = TRUE),
  years  = 2010:2024
)

dplyr::glimpse(nh_bfs)
```

## Rural vs. Nonrural

Business formation diverges between rural and nonrural counties. The
chart below shows total business applications by rural status using the
CBSA 2023 rural definition.

``` r

library(cori.charts)
library(ggplot2)
library(ruraldefinitions)
library(dplyr)

load_fonts()

rural_xwalk <- ruraldefinitions::cbsa_2023 |>
  select(geoid, is_rural)

rural_avg <- df |>
  left_join(rural_xwalk, by = "geoid") |>
  filter(!is.na(is_rural)) |>
  group_by(year, is_rural) |>
  summarise(value = sum(value, na.rm = TRUE), .groups = "drop")

ggplot(rural_avg, aes(x = year, y = value, color = is_rural)) +
  annotate("rect", xmin = 2007.9, xmax = 2009.5,
           ymin = -Inf, ymax = Inf, fill = "grey80", alpha = 0.4) +
  annotate("rect", xmin = 2020, xmax = 2020.5,
           ymin = -Inf, ymax = Inf, fill = "grey80", alpha = 0.4) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  scale_color_manual(
    values = c("Rural" = "#2F6E9B", "Nonrural" = "#7EBDC2"),
    labels = c("Rural" = "Rural counties", "Nonrural" = "Nonrural counties")
  ) +
  scale_x_continuous(
    breaks = seq(2005, 2024, by = 4),
    expand = expansion(mult = c(0, 0.2))
  ) +
  scale_y_continuous(labels = scales::label_number(scale = 1e-3, suffix = "K")) +
  theme_cori() +
  theme(legend.position = "bottom") +
  labs(
    title    = "Rural business formation surged during the pandemic and has held",
    subtitle = "Total business applications (BA series), 2005\u20132024",
    x        = NULL,
    y        = NULL,
    color    = NULL,
    caption  = paste0(
      "Source: CORI analysis of U.S. Census Bureau Business Formation Statistics.\n",
      "Shaded bands mark Great Recession (2008\u201309) and COVID-19 (2020). ",
      "Rural classification: CORI CBSA 2023 definition."
    )
  )
```

## County Spotlight: Grafton County, NH

``` r

library(cori.data.pep)

grafton_bfs <- get_business_applications(
  geoids = c("33009", "33", "00"),
  years  = 2005:2024
)

grafton_pop <- get_population(
  geoids    = c("33009", "33", "00"),
  variables = "population",
  years     = 2005:2024
) |>
  select(geoid, year, population = value)

grafton <- grafton_bfs |>
  left_join(grafton_pop, by = c("geoid", "year")) |>
  mutate(
    apps_per_1k = value / population * 1000,
    group = case_when(
      geoid == "33009" ~ "Grafton County, NH",
      geoid == "33"    ~ "New Hampshire",
      geoid == "00"    ~ "United States"
    ),
    group = factor(group, levels = c("Grafton County, NH", "New Hampshire", "United States"))
  )

ggplot(grafton, aes(x = year, y = apps_per_1k, color = group, linetype = group, linewidth = group)) +
  annotate("rect", xmin = 2007.9, xmax = 2009.5,
           ymin = -Inf, ymax = Inf, fill = "grey80", alpha = 0.4) +
  annotate("rect", xmin = 2020, xmax = 2020.5,
           ymin = -Inf, ymax = Inf, fill = "grey80", alpha = 0.4) +
  geom_line(na.rm = TRUE) +
  geom_point(size = 2.5, na.rm = TRUE) +
  scale_color_manual(values = c(
    "Grafton County, NH" = "#2F6E9B",
    "New Hampshire"      = "#7EBDC2",
    "United States"      = "#9DA7B0"
  )) +
  scale_linetype_manual(values = c(
    "Grafton County, NH" = "solid",
    "New Hampshire"      = "dashed",
    "United States"      = "dotted"
  )) +
  scale_linewidth_manual(values = c(
    "Grafton County, NH" = 1.2,
    "New Hampshire"      = 0.8,
    "United States"      = 0.8
  )) +
  scale_x_continuous(breaks = seq(2005, 2024, by = 4)) +
  scale_y_continuous(labels = scales::label_number(accuracy = 0.1)) +
  theme_cori() +
  theme(legend.position = "bottom") +
  labs(
    title    = "Business applications per 1,000 residents \u2014 Grafton County, NH",
    subtitle = "Compared to New Hampshire and the United States, 2005\u20132024",
    x        = NULL,
    y        = NULL,
    color    = NULL,
    linetype = NULL,
    linewidth = NULL,
    caption  = paste0(
      "Source: CORI analysis of U.S. Census Bureau Business Formation Statistics.\n",
      "Population denominator from Census Population Estimates Program via cori.data.pep.\n",
      "Shaded bands mark Great Recession (2008\u201309) and COVID-19 (2020)."
    )
  )
```
