#---------------------------------------------------------
# Program Name : lis4.R
# Study        : AIRIS PHARMA Private Limited.
# Purpose      : 16.2.1.4 Subject Demographics
# Author       : Vijay Pratap
# Created Date : 08 May Fri, 2026
# Input        : adsl.RData
# Output       : lis4.pdf
#---------------------------------------------------------

install.packages("labelled")
install.packages("rstudioapi")

library(labelled)
library(dplyr)
library(gt)
library(rstudioapi)

adams_path <- path.expand("~/Desktop/listings/listing_project/ADAM_RData")
adsl <- get(load(paste0(adams_path, "/adsl.RData")))

empty_vars <- c(
  "HEIGHT",
  "WEIGHT",
  "BMI"
)

adsl[empty_vars] <- NA

tbl <- adsl %>%
  mutate(
    BMI = WEIGHT / (HEIGHT * HEIGHT)
  ) %>%
  select(
    USUBJID, AGE, SEX, RACE, HEIGHT, WEIGHT, BMI
  ) %>%
  set_variable_labels(
    USUBJID = "Subject Number",
    AGE = "Age* (years)",
    SEX = "Sex",
    RACE = "Race",
    HEIGHT = "Height (cm)", 
    WEIGHT = "Weight (kg)", 
    BMI = "BMI (kg/m2)"
  )

format_listing(tbl, "~/Desktop/listings/listing_project/LISTING OUTPUT", "lis4", "16.2.1.4 Subject Demographics")
