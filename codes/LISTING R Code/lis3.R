#---------------------------------------------------------
# Program Name : lis3.R
# Study        : AIRIS PHARMA Private Limited.
# Purpose      : 16.2.1.3 Study Visits
# Author       : Vijay Pratap
# Created Date : 08 May Fri, 2026
# Input        : adsl.RData
# Output       : lis3.pdf
#---------------------------------------------------------

install.packages("labelled")
install.packages("rstudioapi")

library(labelled)
library(dplyr)
library(gt)
library(rstudioapi)

adams_path <- path.expand("~/Desktop/listings/listing_project/SDTM_RData")
sv <- get(load(paste0(adams_path, "/sv.RData")))


tbl <- sv %>%
  select(
    USUBJID, VISITNUM, SVSTDTC, SVENDTC
  ) %>%
  set_variable_labels(
    USUBJID = "Subject Number",
    VISITNUM = "Visit",
    SVSTDTC = "Start date of Visit",
    SVENDTC = "End date of Visit"
  )

format_listing(tbl, "~/Desktop/listings/listing_project/LISTING OUTPUT", "lis3", "16.2.1.3 Study Visits")
