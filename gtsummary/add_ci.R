# add_ci() R में gtsummary पैकेज का फ़ंक्शन है जो आपकी summary table में Confidence Interval (CI) कॉलम जोड़ता है। इसका मतलब है कि यह किसी mean या proportion के साथ उसका भरोसेमंद अंतराल (जैसे 95% CI) दिखाता है, ताकि आप समझ सकें कि असली population value किस range में होने की संभावना है। 

install.packages("gtsummary")

library(gtsummary)
library(dplyr)

# Sample dataset
df <- tibble(
  trt = c("Drug A", "Drug B", "Drug A", "Drug B", "Drug A"),
  response = c("Yes", "No", "Yes", "Yes", "No"),
  age = c(45, 52, 37, 60, 41)
)


tbl_summary(
  data=df
) %>%
  add_ci()
