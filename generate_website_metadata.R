# January 5, 2022

# this script exports a csv file with information needed to upload the Current reports
# to the cmar website map


library(dplyr)
library(readr)
library(tidyr)

# import the file exported from open_data_metadata.R --------------------

open_data_metadata <- list.files(
  "Y:/coastal_monitoring_program/data_branches/current/open_data/submitted_data/",
  pattern = "current_data_deployment_info",
  full.names = TRUE
)

if (length(open_data_metadata) == 0) {

  stop("No file with the name << current_data_deployment_info >> found in << submitted_data >> folder")

} else if (length(open_data_metadata) == 1) {

  open_data_metadata <- read_csv(
    open_data_metadata,
    show_col_types = FALSE,
    col_select = c(deployment_id, deployment_date, county, station, latitude, longitude)
  ) %>%
    mutate(deployment_date = as.character(deployment_date))

} else {

  stop("Found more than one file with the name << current_data_deployment_info >> in << submitted_data >> folder")
}

#  reports  -----------------------------------------------------------------

path <- file.path("Y:/coastal_monitoring_program/program_documents/website_documents")

links <- read_csv(
  paste0(path, "/map_datasets/dataset_links/current_dataset_links.csv"),
  show_col_types = FALSE
)

reports <- list.files(
  paste0(path, "/current_reports/final"), pattern = "pdf"
) %>%
  data.frame() %>%
  rename(file_name = ".") %>%
  separate(
    "file_name",
    into = c("station", "deployment_date", "deployment_id", NA, NA),
    sep = "_", remove = FALSE
  )

# merge files -------------------------------------------------------------

dat <- open_data_metadata %>%
  left_join(links, by = "county") %>%
  # filter for the stations that have new reports to upload
  right_join(reports, by = c("station", "deployment_date", "deployment_id")) %>%
  mutate(`Program Branch` = "Current") %>%
  select(
    `Program Branch`,
    County = county,
    Deployment_ID = deployment_id,
    Station = station,
    Latitude = latitude,
    Longitude = longitude,
    `Open Data Portal Link`,
    File = file_name
  )

# Export ------------------------------------------------------------------

write_csv(
  dat,
  file = paste0(path, "/map_datasets/", Sys.Date(), "_current_map_dataset.csv")
)





