#---------------------------------------------------------
# Program Name : lis6.R
# Study        : AIRIS PHARMA Private Limited.
# Purpose      : 16.2.1.6 Prior and Concomitant Medications
# Author       : Vijay Pratap
# Created Date : 09 May Fri, 2026
# Input        : adsl.RData
# Output       : lis6.pdf
#---------------------------------------------------------

install.packages("labelled")
install.packages("rstudioapi")

library(labelled)
library(dplyr)
library(gt)
library(rstudioapi)

adams_path <- path.expand("~/Desktop/listings/listing_project/ADAM_RData")
adsl <- get(load(paste0(adams_path, "/adsl.RData")))


tbl <- adsl %>%
  select(
    USUBJID, DCSREAS, TRTEDT, EOSSTT
  ) %>%
  set_variable_labels(
    USUBJID = "Subject Number",
    DCSREAS	= "Reason for Discontinuation from Study",
    TRTEDT	= "Date of Last Exposure to Treatment",
    EOSSTT	= "End of Study Status"
  )

format_listing(tbl, "~/Desktop/listings/listing_project/LISTING OUTPUT", "lis5", "16.2.1.5 Withdrawals from the Study")
