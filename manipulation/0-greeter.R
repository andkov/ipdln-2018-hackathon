# this script imports the raw data described in this shared document 
# https://drive.google.com/file/d/10idMxy8eX8nTHr6wr2Q40x4XOP3Y5ck7/view
# and prepares a state of data used as a standard point of departure for any subsequent reproducible analytics

# Lines before the first chunk are invisible to Rmd/Rnw callers
# Run to stitch a tech report of this script (used only in RStudio)
# knitr::stitch_rmd(
#   script = "./manipulation/0-greeter.R",
#   output = "./manipulation/stitched-output/0-greeter.md"
# )

rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. 
# This is not called by knitr, because it's above the first chunk.
cat("\f") # clear console when working in RStudio

# ---- load-sources ------------------------------------------------------------

# ---- load-packages -----------------------------------------------------------
library(magrittr) #Pipes
requireNamespace("dplyr", quietly=TRUE)

# ---- declare-globals ---------------------------------------------------------
# link to the source of the location mapping
path_input <- "./data-unshared/raw/ipdln_synth_final.csv"

# test whether the file exists / the link is good
testit::assert("File does not exist", base::file.exists(path_input))

# declare where you will store the product of this script
path_save <- "./data-unshared/derived/0-greeted.rds"

# See definitions of commonly  used objects in:
source("./manipulation/object-glossary.R")   # object definitions

# ---- utility-functions ----------------------------------------------------- 
# functions, the use of which is localized to this script

# Count frequencies of unique values in each column (helpful to see scale)
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
# how to use:
# ds %>% col_freqs()
# ---- load-data ---------------------------------------------------------------
ds0 <- readr::read_csv(path_input ) %>% tibble::as_tibble()

# ---- inspect-data -----------------------------------------------------------
# basic inspection
ds0 %>% dplyr::glimpse(50)
# ds0 %>% str() # reveals that columsn has attributes, hidden to avoid clutter

# ---- tweak-data -------------------------------------------------------------
# remove attributes of the imported object
attr(ds0, "row.names") <- NULL
attr(ds0, "spec") <- NULL

# remove the unnecessary suffix in the name of variables
names(ds0) <- gsub("_synth$", "", names(ds0 ))
names(ds0)

# ---- save-to-disk -------------
cat("Save results to ",path_save)
saveRDS(ds0, path_save)







