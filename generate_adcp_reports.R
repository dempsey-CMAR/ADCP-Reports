# This script generates ADCP reports for all stations and dates.

# SECTION 1: Specify stations and dates for which to generate report

# SECTION 2: Generate report(s)

library(dplyr)
library(here)
library(readxl)


# SECTION 1: Specify deployments ---------------------------------------------

report <- here("ADCP_Report.Rmd")

tracker <- read_xlsx("Y:/Coastal Monitoring Program/ADCP/Side Lobe Trimmed/Reports/ADCP_Report_Tracker.xlsx")
tracker <- tracker %>%
  filter(is.na(`2022 Report (sidelobe trimmed)`))

depl_date <- tracker$Depl_Date[1:2]
station <- tracker$Open_Data_Station[1:2]


# SECTION 2: GENERATE REPORTS --------------------------------------------------------

mapply(function(x, y) {

  rmarkdown::render(
    input = report,
    output_file = paste0(
      x, "_", y, "_ADCP Report.docx"
    ),
    params = list(depl_date = x, station = y),
  )

}, depl_date, station)


