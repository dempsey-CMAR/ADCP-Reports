# This script generates ADCP reports for all stations and dates.

# SECTION 1: Specify stations and dates for which to generate report

# SECTION 2: Generate report(s)

library(dplyr)
library(here)
library(readxl)



# SECTION 1: Specify counties ---------------------------------------------

report <- here("ADCP_Report.Rmd")

tracker <- read_xlsx("Z:/Coastal Monitoring Program/ADCP/Side Lobe Trimmed/Reports/ADCP_Report_Tracker.xlsx")
tracker <- tracker %>% filter(is.na(`2022 Report (sidelobe trimmed)`))

station <- tracker$Open_Data_Station[c(2, 3, 4, 1)]
depl_date <- tracker$Depl_Date[c(2, 3, 4, 1)]
deployment <- data.frame(station, depl_date)

# SECTION 2: GENERATE REPORTS --------------------------------------------------------

sapply(1:4, function(x) {

  rmarkdown::render(
    input = report,
    output_file = paste0(deployment$depl_date[x], "_", deployment$station[x], "_ADCP Report.docx"),
    params = list(station = deployment$station[x],
                  depl_date = deployment$depl_date[x]))

})

