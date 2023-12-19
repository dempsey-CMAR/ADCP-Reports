# June 1, 2023

# code to re-name Current Report files

library(dplyr)
library(googlesheets4)
library(lubridate)
library(stringr)
library(tidyr)

path <- file.path(
  "Y:/coastal_monitoring_program/program_documents/website_documents/current_reports/final/uploaded"
)

# read in ADCP TRACKING sheet
link <- "https://docs.google.com/spreadsheets/d/1DVfJbraoWL-BW8-Aiypz8GZh1sDS6-HtYCSrnOSW07U/edit#gid=0"
tracking <- googlesheets4::read_sheet(link, sheet = "Tracking") %>%
  filter(county != "#N/A") %>%
  select(-`nsdfa station name`)

# reports to be renamed
files <- list.files(path)
files_full <- list.files(path, full.names = TRUE)

i <- 1

for (i in seq_along(files)) {

  file_i <- files[i]

  depl_i <- file_i %>%
    data.frame() %>%
    separate(".", into = c("depl_date", "station", NA), sep = "_") %>%
    mutate(depl_date = as_datetime(depl_date))

  tracking_i <- tracking %>%
    filter(station == depl_i$station & depl_date == depl_i$depl_date)

  if(nrow(tracking_i) > 1) break

  depl_i <- depl_i %>%
    mutate(
      dep_id = tracking_i$depl_id,
      station = str_replace_all(station, " ", "_")
    )

  new_name <- paste(
    depl_i$dep_id,
    depl_i$station,
    depl_i$depl_date,
    "Current_Report.pdf",
    sep = "_"
  )

  file.rename(files_full[i], paste(path, new_name, sep = "/"))

}
