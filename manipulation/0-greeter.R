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
path_input <- "./data-unshared/raw/ipdln_synth_final/ipdln_synth_final.csv"
# path_input <- "./data-unshared/raw/ipdln_synth_final/ipdln_synth_final_compressed.sas7bdat"
# test whether the file exists / the link is good
testit::assert("File does not exist", base::file.exists(path_input))
# declare where you will store the product of this script
path_save <- "./data-unshared/derived/0-greeted.rds"
# See definitions of commonly  used objects in:
source("./manipulation/object-glossary.R")   # object definitions

# ---- utility-functions ----------------------------------------------------- 
# functions, the use of which is localized to this script
# Count frequencies of unique values in each column
col_freqs <- function(d, pandoc=F){
  for(i in names(d)){
    d %>% 
      group_by_(.dots = i) %>% 
      dplyr::summarize(n = n()) %>% 
      dplyr::arrange(desc(n)) 
    if(pandoc){
      d %>% knitr::kable(format = "pandoc") %>% print()
    }else{
      d %>% print()
    }
  }  
} 
# usage:
# ds_lookup %>% col_freqs()
# ---- load-data ---------------------------------------------------------------
ds0 <- readr::read_csv(path_input ) %>% tibble::as_tibble()
# ds0 <- haven::read_sas(path_input)


# ---- inspect-data -----------------------------------------------------------
ds0 %>% glimpse(50)
ds0 %>% str()
# ---- tweak-data -------------------------------------------------------------
# remove attributes of the imported object
attr(ds0, "row.names") <- NULL
attr(ds0, "spec") <- NULL

# remove the unnecessary suffix in the name of variables
names(ds0) <- gsub("_synth$", "", names(ds0 ))
names(ds0)


# ---- save-to-disk -------------
saveRDS(ds0, path_save)

ds0 <- readRDS(path_save)







