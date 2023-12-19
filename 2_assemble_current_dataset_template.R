# DATE:
# NAME:
# NOTES:

# Returns assembled data as a csv file in /open_data
# and as an rds file in /assembled

# SECTION 1: Define county
# Modify county variable to include the county for which to assemble data

# SECTION 2: Check csv file and rds file are identical

# SECTION 3: Check for duplicate TIMESTAMP

library(data.table)
library(dplyr)
library(lubridate)
library(purrr)

# SECTION 1: Define counties and submission date --------------------------

county <- "victoria"
file_date <- as.character(Sys.Date())

path <- file.path("Y:/coastal_monitoring_program/data_branches/current")

# print Warning if there are files in the /new folder
dat_new <- list.files(
  paste0(path, "/processed_data/deployment_data/", county, "/new"), pattern = "csv") %>%
  unlist()

if(length(dat_new) > 0) {
  warning(paste0("There are ", length(dat_new), " files in the /new folder.
               \nMove these to the county folder to assemble"))
}

# Assemble county dataset ------------------------------------------------

# Import data
dat_raw <- list.files(
  paste0(path, "/processed_data/deployment_data/", county), pattern = "csv", full.names = TRUE
) %>%
  unlist() %>%
  map_dfr(fread) %>%
  select(-depth_flag)

# Make csv and rds files
file_name <- paste(county, file_date, sep = "_")

dat_raw %>%
  mutate(timestamp_utc = as.character(timestamp_utc)) %>%
  fwrite(file = paste0(path, "/open_data/submitted_data/", file_name, ".csv"))

saveRDS(dat_raw, file = paste0(path, "/processed_data/assembled_data/", file_name, ".rds"))

# SECTION 2: Check csv file and rds file are identical --------------------

dat_csv <- fread(paste0(path, "/open_data/submitted_data/", file_name, ".csv"))

dat_rds <- readRDS(paste0(path, "/processed_data/assembled_data/", file_name, ".rds"))

tz(dat_csv$timestamp_utc)
tz(dat_rds$timestamp_utc)

all.equal(dat_csv, dat_rds)

# SECTION 3: Check for duplicate TIMESTAMP --------------------

dat_rds %>%
  select(-sea_water_speed_m_s, -sea_water_to_direction_degree) %>%
  group_by(
    waterbody, station, deployment_id, timestamp_utc, sensor_depth_below_surface_m,
    bin_height_above_sea_floor_m) %>%
  filter(n() > 1) %>%
  ungroup() %>%
  summarize(n_dups = n())

