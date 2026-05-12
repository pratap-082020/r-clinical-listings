library(dplyr)
library(tidyr)
library(gt)

# Read ADSL
adams_path <- path.expand("~/Desktop/listings/listing_project/ADAM_RData")

adsl <- get(load(paste0(adams_path, "/adsl.RData"))) %>%
  filter(TRT01P != "")

# Create Overall Group
adsl_overall <- adsl %>%
  mutate(TRT01P  = "Overall", TRT01PN = 5)

adsl_final <- bind_rows(adsl, adsl_overall) %>%
  select(USUBJID, TRT01P, TRT01PN, SAFFL)

# Denominator
denom <- adsl_final %>%
  group_by(TRT01P, TRT01PN) %>%
  summarise(denom = n_distinct(USUBJID), .groups = "drop")

# Numerator
num <- adsl_final %>%
  group_by(TRT01P, TRT01PN) %>%
  summarise(num = sum(SAFFL == "Y"), .groups = "drop")

# Create n (%)
prep <- left_join(num, denom, by = c("TRT01P", "TRT01PN")) %>%
  mutate(
    pct = round(num / denom * 100, 2),
    calc = case_when(
      is.na(num) | num == 0 ~ "0",
      num == denom ~ paste0(num, " (100%)"),
      TRUE ~ paste0(num, " (", pct, "%)")
    ),
    col = paste0("t", TRT01PN)
  )

# Transpose
prep_t <- prep %>%
  select(col, calc) %>%
  pivot_wider(names_from = col, values_from = calc) %>%
  mutate(Population = "Safety Population", Statistic  = "n (%)") %>%
  relocate(Population, Statistic)

# Denominator Values
n1 <- denom %>% filter(TRT01PN == 1) %>% pull(denom)
n2 <- denom %>% filter(TRT01PN == 2) %>% pull(denom)
n3 <- denom %>% filter(TRT01PN == 3) %>% pull(denom)
n4 <- denom %>% filter(TRT01PN == 4) %>% pull(denom)
n5 <- denom %>% filter(TRT01PN == 5) %>% pull(denom)

# GT Table
tbl <- prep_t %>%
  gt() %>%
  tab_header(title = md("**Table 14.1.1 Subject Assignment to Analysis Populations**")) %>%
  cols_label(
    Population = "Population",
    Statistic  = "Statistic",
    t1 = html(paste0("DRUG A<br>(N = ", n1, ")")),
    t2 = html(paste0("DRUG B<br>(N = ", n2, ")")),
    t3 = html(paste0("DRUG C<br>(N = ", n3, ")")),
    t4 = html(paste0("DRUG D<br>(N = ", n4, ")")),
    t5 = html(paste0("ALL<br>(N = ", n5, ")"))
  ) %>%
  cols_align(align = "left", columns = everything())

tbl