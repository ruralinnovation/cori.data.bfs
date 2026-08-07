## For CORI data engineers
# To refresh the S3 data after Census releases new estimates, 
# pass oldest and latest available years to write_bfs_processed_to_s3:
# ```r
# write_bfs_processed_to_s3(years = 2005:2025)
# ```
# Run devtools::load_all() before executing this script.
devtools::load_all()

latest_year = 2025

### check vintage
s3_vintageyr <- as.numeric(substr(latest_bfs_vintage(), 9, 12))
if(latest_year <= s3_vintageyr){
  message("Latest year does not reflect a new release of data")
} else{
  stopifnot(nrow(pull_bfs(latest_year))>0)
  ## write new vintage
  write_bfs_processed_to_s3(years=2000:latest_year)
}

