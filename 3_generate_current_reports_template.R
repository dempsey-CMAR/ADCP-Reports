# DATE:
# NAME: DD
# NOTES:

# Use this to generate reports for deployments that have already been processed

# Make sure deployments are included in the NSDFA tracking sheet, ADCP TRACKING
# sheet, and the current_report_tracker.xlsx


library(adcp)           # adcp data wrangling and visualization
library(data.table)     # fast data export
library(dplyr)          # data wrangling

# UPDATE FILE PATHS ------------------------------------------------------------

# path to the common folder with data to be processed
path_import <- file.path(
  "R:/data_branches/current/processed_data/deployment_data"
)

# path to most recent NSDFA tracking sheet -- update this
path_nsdfa <- file.path(
  "R:/tracking_sheets/2023-11-27 - NSDFA Tracking Sheet.xlsx"
)

# path to report rmd -- update this
path_rmd <- file.path("C:/Users/Danielle Dempsey/Desktop/RProjects/ADCP Reports/ADCP_Report.Rmd")

# leave these -------------------------------------------------------------

# path to generated report
path_report <- file.path("R:/program_documents/website_documents/current_reports/drafts/")

# read in files --------------------------------------------------

# nsdfa tracking sheet
tracking <- adcp_read_nsdfa_metadata(path_nsdfa)

# raw data
# files <- c(
#   file.path(paste0(path_import, "/digby/new/2022-09-13_Long Beach_DG013.csv")),
#   file.path(paste0(path_import, "/yarmouth/new/2022-09-29_Angus Shoal_YR008.csv")),
#   file.path(paste0(path_import, "/yarmouth/new/2022-09-29_Western Shoal_YR009.csv"))
# )


# generate reports ---------------------------------------------------------

for (j in 1:length(files)) {

  depl.j <- fread(files[j])

  # will give a warning because the Depl_ID is included in the file name
  d.j <- adcp_extract_deployment_info(files[j])

  # extract metadata for deployment
  tracking.j <- tracking %>%
    filter(Station_Name == d.j$Station_Name & Depl_Date == d.j$Depl_Date)

  # Document history is saved in Y:\coastal_monitoring_program\tracking_sheets
  rmarkdown::render(
    input = path_rmd,
    output_file = paste0(
      path_report, "/",
      tracking.j$Depl_ID,
      d.j$Station_Name, "_",
      d.j$Depl_Date, "_",
      "_Current_Report.docx"
    ),
    params = list(dat = depl.j, metadata = tracking.j)
  )

}

