source("renv/activate.R")

# Check if renv is initialized, if not, do it!
if (!file.exists("renv.lock")) {
  renv::init()
}

# Automatically restore dependencies whenever the script runs
renv::restore(prompt = FALSE)
