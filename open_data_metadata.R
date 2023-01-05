# DATE: 
# NAME: 
# NOTES:

# Export additional files for Open Data Portal:
## The Deployment Information Dataset
## Number of rows expected for each county

library(adcp)
library(dplyr)
library(glue)
library(readr)

# file paths --------------------------------------------------------------

### update the file name
path_nsdfa <- file.path(
  "Y:/coastal_monitoring_program/tracking_sheets/2022-12-19 - NSDFA Tracking Sheet.xlsx"
)

path_export <- file.path(
  "Y:/coastal_monitoring_program/data_branches/current/open_data/submitted_data"
)

# Number of rows per county ---------------------

DATA <- adcp_import_data()

n_rows <- DATA %>%
  group_by(county) %>%
  summarize(n_row = n())

write_csv(n_rows, glue("{path_export}/{Sys.Date()}_county_n_rows.csv"))


# Deployment Information Dataset ------------------------------------------

depl_id <- distinct(DATA, deployment_id)

adcp_export_deployment_info(
  path_nsdfa = path_nsdfa,
  deployments = depl_id$deployment_id,
  path_export = path_export
)














