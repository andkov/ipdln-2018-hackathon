# this script imports the raw data described in this shared document 
# https://drive.google.com/file/d/10idMxy8eX8nTHr6wr2Q40x4XOP3Y5ck7/view
# and prepares a state of data used as a standard point of departure for any subsequent reproducible analytics

# Lines before the first chunk are invisible to Rmd/Rnw callers
# Run to stitch a tech report of this script (used only in RStudio)
# knitr::stitch_rmd(
#   script = "./manipulation/0-greeter.R",
#   output = "./manipulation/stitched-output/0-greeter.md"
# )
# this command is typically executed by the ./manipulation/governor.R

rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. 
# This is not called by knitr, because it's above the first chunk.
cat("\f") # clear console when working in RStudio

# ---- load-packages -----------------------------------------------------------
library(magrittr) #Pipes
requireNamespace("dplyr", quietly=TRUE)

# ---- load-sources ------------------------------------------------------------


# ---- declare-globals ---------------------------------------------------------
# link to the source of the location mapping
path_input_micro <- "./data-unshared/raw/ipdln_synth_final.csv"
path_input_meta  <- "./data-unshared/derived/ls_guide.rds"

# test whether the file exists / the link is good
testit::assert("File does not exist", base::file.exists(path_input_micro))
testit::assert("File does not exist", base::file.exists(path_input_meta))

# declare where you will store the product of this script
path_save <- "./data-unshared/derived/0-greeted.rds"

# See definitions of commonly  used objects in:
base::source("./manipulation/object-glossary.R")   # object definitions

# ---- utility-functions ----------------------------------------------------- 
# functions, the use of which is localized to this script
# for commonly used function see ./manipulation/function-support.R

# ---- load-data ---------------------------------------------------------------
ds0      <- readr::read_csv(path_input_micro) %>% as.data.frame()
ls_guide <- readRDS(path_input_meta)

# ---- inspect-data -----------------------------------------------------------
# basic inspection
ds0 %>% dplyr::glimpse(50)

# ---- tweak-data -------------------------------------------------------------
# remove suffix in the name of variables
names(ds0) <- gsub("_synth$", "", names(ds0 )) # because it is redundant, all vars have it
names(ds0) # to verify
ds0 %>% dplyr::glimpse(50) # new look

# augment the micro data with meta data

# create a function to augment micro data with meta data
# because you will need to add selected metadata on the spot
augment_with_meta <- function(
  d,  # a dataframe with the original raw data, prepared by the ./manipulation/0-greeter.R
  l   # a list object with organized meta data, prepared by the ./manipulation/0-metador.R
){
  for(name_i in names(d)){
    # declare loop values for development
    # l      <- ls_guide
    # name_i <- "SEX"
    # d      <- ds0[1:1000,c("SEX","S_DEAD")]
    d <- d %>% 
      dplyr::rename_("target_variable" = name_i) %>% # to avoid NSE
      dplyr::mutate(
        target_variable = factor(
          target_variable, 
          levels = l$item[[name_i]]$levels %>% names(), 
          labels = l$item[[name_i]]$levels
        )
      ) 
    names(d) <- gsub("^target_variable$",name_i, names(d)) # back to NSE
    # d1 %>% dplyr::glimpse()
  }
  return(d)
}
# how to use
ds1 <- ds0 %>% augment_with_meta(ls_guide)
ds1 %>% dplyr::glimpse(50)

# ---- save-to-disk -------------
cat("Save results to ",path_save)
saveRDS(ds1, path_save)







