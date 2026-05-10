#---------------------------------------------------------
# Program Name : tab1_1.R
# Study        : TINKER BELLS 009/01
# Purpose      : Table 14.1.3 Subject Assignment to Analysis Populations
# Author       : Vijay Pratap
# Created Date : 09 May Fri, 2026
# Input        : adsl.RData
# Output       : tab1_1.pdf
#---------------------------------------------------------

install.packages("labelled")
install.packages("rstudioapi")
install.packages("tidyr")

library(labelled)
library(dplyr)
library(gt)
library(rstudioapi)
library(tidyr)


adams_path <- path.expand("~/Desktop/listings/listing_project/ADAM_RData")
adsl <- get(load(paste0(adams_path, "/adsl.RData")))

adsl_all <- adsl %>%
  mutate(TRT01P = if_else(!is.na(TRT01P) & TRT01P != "", "ALL", TRT01P))

adsl_final <- bind_rows(
  adsl,
  adsl_all
)

adsl_final %>%
  select(USUBJID, TRT01P, SAFFL, DLTEVLFL, PKEVLFL) %>%
  filter(!is.na(TRT01P), TRT01P != "") %>%
  group_by(TRT01P) %>%
  summarise(
    total_n = n()
  )


tbl <- adsl_final %>%
  select(USUBJID, TRT01P, SAFFL, DLTEVLFL, PKEVLFL) %>%
  filter(!is.na(TRT01P), TRT01P != "") %>%
  group_by(TRT01P) %>%
  summarise(
    total_n = n(),
    SAFFL_n = sum(SAFFL == "Y", na.rm = TRUE),
    DLTEVLFL_n = sum(DLTEVLFL == "Y", na.rm = TRUE),
    PKEVLFL_n = sum(PKEVLFL == "Y", na.rm = TRUE)
  ) %>%
  mutate(
    SAFFL = paste0(SAFFL_n, " (", round(100 * SAFFL_n / total_n, 2), "%)"),
    DLTEVLFL = paste0(DLTEVLFL_n, " (", round(100 * DLTEVLFL_n / total_n, 2), "%)"),
    PKEVLFL = paste0(PKEVLFL_n, " (", round(100 * PKEVLFL_n / total_n, 2), "%)")
  ) %>%
  select(TRT01P, SAFFL, DLTEVLFL, PKEVLFL) %>%
  set_variable_labels(
    TRT01P = "Treatment",
    SAFFL = "Safety Population",
    DLTEVLFL = "DLT Evaluable Population",
    PKEVLFL = "PK Evaluable Population"
  ) 


df_t <- tbl %>%
  pivot_longer(
    cols = c(SAFFL, DLTEVLFL, PKEVLFL),
    names_to = "PARAM",
    values_to = "VALUE"
  ) %>%
  pivot_wider(
    names_from = TRT01P,
    values_from = VALUE
  ) %>%
  mutate(
    Statistic = "n (%)",
    PARAM = if_else(PARAM == "SAFFL", "Safety Population", PARAM),
    PARAM = if_else(PARAM == "DLTEVLFL", "DLT Evaluable Population", PARAM),
    PARAM = if_else(PARAM == "PKEVLFL", "PK Evaluable Population", PARAM)
  ) %>% rename(
    Population = PARAM
  ) %>% 
  select(
    Population,
    Statistic,
    "AIRIS-101 80 mg QD Intermittent + nab-paclitaxel 75 mg/m^2",
    "AIRIS-101 160 mg QD Intermittent + nab-paclitaxel 75 mg/m^2",
    "AIRIS-101 240 mg QD Intermittent + nab-paclitaxel 75 mg/m^2",
    "AIRIS-101 240 mg QD Intermittent + nab-paclitaxel 100 mg/m^2",
    ALL
  )

df_t

View(df_t)

  
format_listing(df_t, "~/Desktop/listings/listing_project/LISTING OUTPUT", "tbl1", "Table 14.1.1 Subject Assignment to Analysis Populations")
