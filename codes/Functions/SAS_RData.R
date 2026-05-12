#---------------------------------------------------------
# Program Name : SAS_RData.R
# Study        : 
# Purpose      : Convert sas7bdat dataset to R
# Author       : Vijay Pratap
# Created Date : Fri 8 May, 2026
# Input        : sas7bdat folder path
# Output       : RData folder path
#---------------------------------------------------------

# install package if not available
if(!require(stringr)){
  install.packages("stringr")
  library(stringr)
}

if(!require(haven)){
  install.packages("haven")
  library(haven)
}

message("Take input path from console")

# We use path.expand() to convert shortcut paths into full absolute paths that R 
# and terminal commands can understand reliably.

path_input <- readline("Enter sas7bdat path: ")
path_input <- path.expand(path_input)

path_output <- readline("Enter output path: ")
path_output <- path.expand(path_output)

# shQuote() adds quotes around a string so terminal/shell commands can safely read 
# paths or text containing spaces or special characters.

files <- system2(
  "ls",
  args = shQuote(path_input),
  stdout = TRUE
)

files <- files[str_detect(files, ".sas7bdat")]

for(i in files){
  ds_name <- strsplit(i, "\\.")[[1]][1]
  
  # assign() creates an object dynamically using a variable name stored in another variable.
  assign(
    ds_name,
    read_sas(paste0(path_input, "/", i))
  )
  save(
    list = ds_name,
    file = paste0(path_output, "/", ds_name, ".RData")
  )
}
