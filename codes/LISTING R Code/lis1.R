#---------------------------------------------------------
# Program Name : lis1.R
# Study        : AIRIS PHARMA Private Limited.
# Purpose      : Listing: 16.2.1.1 Assignment to Analysis Populations
# Author       : Vijay Pratap
# Created Date : 08 May Fri, 2026
# Input        : adsl.RData
# Output       : lis1.rtf
#---------------------------------------------------------

install.packages("labelled")
install.packages("rstudioapi")

library(labelled)
library(dplyr)
library(gt)
library(rstudioapi)

adams_path <- path.expand("~/Desktop/listings/listing_project/ADAM_RData")
adsl <- get(load(paste0(adams_path, "/adsl.RData")))

head(adsl)

tbl <- adsl %>%
  select(
    USUBJID, SAFFL, DLTEVLFL, PKEVLFL, ENRLFL
  ) %>%
  set_variable_labels(
    USUBJID = "Subject\nNumber",
    SAFFL = "Safety\nPopulation", 
    DLTEVLFL = "Enrolled\nPopulation", 
    PKEVLFL = "DLT Evaluable\nPopulation", 
    ENRLFL = "PK Evaluable\nPopulation"
  )

current_time <- format(Sys.time(), "%H:%M  %A, %b %d, %Y")
output_folder <- path.expand("~/Desktop/listings/listing_project/LISTING OUTPUT")

my_table <- tbl %>% gt() %>%
  tab_header(
    title = html(
      paste0(
        "<table width='100%'>
          <tr align='right'>
              ", current_time, " 
          </tr>
          <tr>
            <td align='left'>
              AIRIS PHARMA Private Limited.<br>
              Protocol: 043-1810
            </td>
          </tr>
        </table>"
      )
    ),
    subtitle = "16.2.1.1 Assignment to Analysis Populations"
  ) %>% 
  cols_align(
    align = "left",
    columns = everything()
  ) %>%
  tab_style(
    style = cell_text(
      align = "center",
      weight = "normal"
    ),
    locations = cells_title(groups = "subtitle")
  ) %>%
  tab_options(
    table.font.names = "Courier, monospace", 
    table.font.size = px(12),
    column_labels.font.size = px(12),
    heading.title.font.size = px(12),
    heading.subtitle.font.size = px(12),
    source_notes.font.size = px(12),
    data_row.padding = px(2),
    heading.align = "right",
    column_labels.border.bottom.color = "black",
    column_labels.border.bottom.width = px(2),
    table_body.border.bottom.color = "black",
    table_body.border.bottom.width = px(2) 
  ) %>%
  tab_source_note(
  source_note = rstudioapi::getActiveDocumentContext()$path
)


file_path <- file.path(output_folder, "lis1.pdf")
my_table %>%
  gtsave(filename = file_path)
message("Table saved to: ", file_path)

# format_listing(tbl, "~/Desktop/listings/listing_project/LISTING OUTPUT", "abc")
