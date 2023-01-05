# DATE:
# NAME: DD
# NOTES:

# This template reads in ADCP txt files and exports formatted csv file AND generates the
# report for each deployment

# The `ADCP Reports` repository downloaded
# Make sure deployments are included in the NSDFA tracking sheet, ADCP TRACKING
# sheet, and the current_report_tracker.xlsx


library(adcp)           # adcp datawrangling and visualization
library(data.table)     # fast data export
library(dplyr)          # data wrangling
library(ggplot2)        # export ggplots
library(googlesheets4)  # read in deployment IDs

# UPDATE FILE PATHS ------------------------------------------------------------

# path to raw data -- update this
path_import <- file.path("Y:/coastal_monitoring_program/data_branches/current/raw_data/2023-01-03_process")

# path to most recent NSDFA tracking sheet -- update this
path_nsdfa <- file.path("Y:/coastal_monitoring_program/tracking_sheets/2022-12-19 - NSDFA Tracking Sheet.xlsx")

# path to report rmd -- update this
path_rmd <- file.path("C:/Users/Danielle Dempsey/Desktop/RProjects/ADCP Reports/ADCP_Report.Rmd")


# leave these -------------------------------------------------------------

# path to data export
path_export <- file.path("Y:/coastal_monitoring_program/data_branches/current/processed_data/deployment_data")

# path to generated report
path_report <- file.path("Y:/coastal_monitoring_program/program_documents/website_documents/current_reports/drafts/")

# read in files --------------------------------------------------

# nsdfa tracking sheet
nsdfa <- adcp_read_nsdfa_metadata(path_nsdfa)

# raw data
files <- list.files(
  paste0(path_import, "/data_raw"), full.names = TRUE, pattern = ".txt"
)


# this section should change -- or be deleted -- with new tracking sheet ----------------------

# deployment ids -- won't need this is depl_id added to NSDFA tracking
link <- "https://docs.google.com/spreadsheets/d/1DVfJbraoWL-BW8-Aiypz8GZh1sDS6-HtYCSrnOSW07U/edit#gid=0"

depl_id <- googlesheets4::read_sheet(link, sheet = "Tracking") %>%
  select(
    Depl_ID = depl_id,
    County = county,
    Waterbody = waterbody,
    Station_Name = station,
    Depl_Date = depl_date
  )

tracking <- nsdfa %>%
  left_join(depl_id, by = c("County", "Waterbody", "Depl_Date", "Station_Name"))

# compile for Open Data Portal --------------------------------------------

for(j in seq_along(files)) {

  file.j <- files[j]

  # extract deployment info from the file name
  d.j <- adcp_extract_deployment_info(file.j)

  # extract metadata for deployment
  tracking.j <- tracking %>%
    filter(Station_Name == d.j$Station_Name & Depl_Date == d.j$Depl_Date)

  if(nrow(tracking.j) == 0) {
    message(paste(
      "Deployment <<", d.j$DEPLOYMENT, ">> not found in NSDFA Tracking sheet."
    ))

    break
  }

  # if custom flag values required, add here
  flag_val <- 1

# read in data & format for Open Data -------------------------------------

  # correct TIMESTAMP before removing NAs in case sensor was on before deployment
  depl.j <- file.j %>%
    adcp_read_txt() %>%
    adcp_assign_altitude(tracking.j) %>%
    adcp_correct_timestamp() %>%
    adcp_pivot_longer() %>%
    adcp_calculate_bin_depth(tracking.j) %>%
    adcp_add_opendata_cols(tracking.j) %>%
    adcp_flag_data(depth_flag = flag_val)

  # flag plots --------------------------------------------------------------

  # # add manual flags if required
  # if(d.j$DEPLOYMENT == "2011-10-12_Beaver Harbour"){
  #
  #   depl.j[which(depl.j$timestamp_utc == as_datetime("2011-10-12 18:15:00")), "depth_flag"] <- "manual flag"
  #
  # }

  # convert FLAG to ordered factor so figure legend will be consistent
  depl.j <- depl.j %>% adcp_convert_flag_to_ordered_factor()

  # output figure to verify flagged data
  p1 <- adcp_plot_depth_flags(depl.j, title = d.j$DEPLOYMENT)

  ggsave(
    filename = paste0(path_import, "/figures/flags/", d.j$DEPLOYMENT, ".png"),
    p1,
    device = "png",
    width = 30,
    height = 12,
    units = "cm",
    dpi = 600
  )

  # final depth plot
  depl.j <- depl.j %>%
    filter(depth_flag == "good") %>%
    select(-depth_diff, -depth_diff) %>%
    mutate(timestamp_utc = as.character(timestamp_utc))

  p2 <- adcp_plot_depth(depl.j, title = d.j$DEPLOYMENT)

  ggsave(
    filename = paste0(path_import, "/figures/", d.j$DEPLOYMENT, ".png"),
    p2,
    device = "png",
    width = 30,
    height = 12,
    units = "cm",
    dpi = 600
  )

# export formatted data to shared drive -----------------------------------

  depl.j <- select(depl.j, -depth_flag)

  fwrite(
    depl.j,
    file = paste0(
      path_export, "/",
      tracking.j$County, "/new/",
      d.j$DEPLOYMENT, "_",
      tracking.j$Depl_ID, ".csv"
    )
  )

  # generate report ---------------------------------------------------------

  # be careful with this because it **adds variables*** to the env
  # Document history is saved in Y:\coastal_monitoring_program\tracking_sheets
  rmarkdown::render(
    input = path_rmd,
    output_file = paste0(
      path_report, "/",
      d.j$Station_Name, "_",
      d.j$Depl_Date, "_",
      tracking.j$Depl_ID,
      "_Current_Report.docx"
    ),
    params = list(dat = depl.j, metadata = tracking.j)
  )

  print(paste0("Finished ", d.j$DEPLOYMENT))
}



