# knitr::stitch_rmd(script="./manipulation/0-ellis-map.R", output="./manipulation/stitched-output/0-ellis-map.md")
# This script reads two files: encounter counts with location mapping and encounter timelines for selected individuals
rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-sources ------------------------------------------------------------
#Load any source files that contain/define functions, but that don't load any other types of variables
#   into memory.  Avoid side effects and don't pollute the global environment.
source("./manipulation/function-support.R")  # assisting functions for data wrangling and testing
source("./manipulation/object-glossary.R")   # object definitions
source("./scripts/common-functions.R")       # reporting functions and quick views
source("./scripts/graphing/graph-presets.R") # font and color conventions
# ---- load-packages -----------------------------------------------------------
library(ggplot2) #For graphing
library(dplyr)
library(magrittr) #Pipes
requireNamespace("readxl")

requireNamespace("knitr", quietly=TRUE)
requireNamespace("scales", quietly=TRUE) #For formating values in graphs
requireNamespace("RColorBrewer", quietly=TRUE)
requireNamespace("dplyr", quietly=TRUE)
requireNamespace("DT", quietly=TRUE) # for dynamic tables
# requireNamespace("plyr", quietly=TRUE)
# requireNamespace("reshape2", quietly=TRUE) #For converting wide to long
# requireNamespace("mgcv, quietly=TRUE) #For the Generalized Additive Model that smooths the longitudinal graphs.

# ---- declare-globals ---------------------------------------------------------
# link to the source of the location mapping
# path_input <- "./data-unshared/raw/SearchVariables.csv"
path_input <- "./data-unshared/raw/coverage.csv"
# test whether the file exists / the link is good
testit::assert("File does not exist", base::file.exists(path_input))
# declare where you will store the product of this script
# path_save <- "./data-unshared/derived/memory"
path_save <- "./data-unshared/derived/dto-1"
# See definitions of commonly  used objects in:
source("./manipulation/object-glossary.R")   # object definitions
path_save_meta <- "./data-unshared/meta/coverage-live.csv"
path_input_meta <- "./data-public/meta/coverage-dead.csv"

# path_save_meta <- "./data-unshared/meta/memory-live.csv"
# path_input_meta <- "./data-public/meta/memory-dead.csv"

# ---- utility-functions ----------------------------------------------------- 
# functions, the use of which is localized to this script

# ---- load-data ---------------------------------------------------------------
ds <- readr::read_csv(path_input,skip = 2) %>% as.data.frame() 
ds <- ds %>% tibble::as_tibble()
# ds <- readr::read_csv(path_input) %>% as.data.frame() 

# ---- inspect-data -----------------------------------------------------------
ds %>% dplyr::glimpse()

# ---- tweak-data -------------------------------------------------------------
# identify the function of variables with respect to THIS wide-long tranformation
variables_static <- common_stem
variables_dynamic <- setdiff(colnames(ds), variables_static)
# tranform
ds_long <- ds %>% 
  tidyr::gather_("measure","value", variables_dynamic)

ds_long %>% head()
ds_long %>% glimpse()
# save unique measure names 
ds_long %>% 
  dplyr::distinct(measure) %>% 
  readr::write_csv(path_save_meta) 
# edit the meta data spreadsheed manually and save it in data-public/meta
ds_meta  <- readr::read_csv(path_input_meta)
# augemnt the long file with meta data
ds_long <- ds_long %>% 
  dplyr::left_join(ds_meta, by = "measure" ) %>% 
  tibble::as_tibble()

# ---- explore-data ------------------------------------------


# ---- save-to-disk ----------------
saveRDS(ds_long, paste0(path_save,".rds"))
readr::write_csv(ds_long, paste0(path_save,".csv"))



