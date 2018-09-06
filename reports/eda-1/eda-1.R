# This script ... (enter functional description)

# Lines before the first chunk are invisible to Rmd/Rnw callers
# Run to stitch a tech report of this script (used only in RStudio)
# knitr::stitch_rmd(
#   script = "./manipulation/0-greeter.R",
#   output = "./manipulation/stitched-output/0-greeter.md" # make sure the folder exists
# )

rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. 
# This is not called by knitr, because it's above the first chunk.
cat("\f") # clear console when working in RStudio

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  
# Ideally, no real operations are performed.

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(ggplot2) #For graphing
library(magrittr) # Pipes
requireNamespace("dplyr", quietly=TRUE)
requireNamespace("TabularManifest") # devtools::install_github("Melinae/TabularManifest")
requireNamespace("knitr")
requireNamespace("scales") #For formating values in graphs
requireNamespace("RColorBrewer")

# ---- declare-globals ---------------------------------------------------------
# link to the source of the location mapping
path_input_micro <- "./data-unshared/derived/0-greeted.rds"
path_input_meta  <- "./data-unshared/derived/ls_guide.rds"

# test whether the file exists / the link is good
testit::assert("File does not exist", base::file.exists(path_input_micro))
testit::assert("File does not exist", base::file.exists(path_input_meta))

# declare where you will store the product of this script
# path_save <- "./data-unshared/derived/0-greeted.rds"

# See definitions of commonly  used objects in:
source("./manipulation/object-glossary.R")   # object definitions
# ---- load-data ---------------------------------------------------------------
ds      <- readRDS(path_input_micro) # 'ds' stands for 'datasets'
ls_guide <- readRDS(path_input_meta)

# ---- tweak-data --------------------------------------------------------------
ds %>% dplyr::glimpse()


# ---- define-utility-functions ---------------

# ---- marginals ---------------------------------------------------------------
for(block_i in names(ls_guide$block) ){
# for(block_i in "demographic" ){
  # block_i <- "demographic"
  cat("\n#group(",block_i,")\n")
  for(item_i in ls_guide$block[[block_i]]){
  # item_i <- "SEX"
    cat("\n##",item_i,"\n")
    ds %>% TabularManifest::histogram_discrete(item_i) %>% print()
    cat("\n")
  }
}


# ---- save-to-disk ----------------------------

# ---- publish ---------------------------------------
path_report_1 <- "./reports/eda-1/eda-1.Rmd"
# path_report_2 <- "./reports/*/report_2.Rmd"
allReports <- c(path_report_1)

pathFilesToBuild <- c(allReports)
testit::assert("The knitr Rmd files should exist.", base::file.exists(pathFilesToBuild))
# Build the reports
for( pathFile in pathFilesToBuild ) {
  
  rmarkdown::render(input = pathFile,
                    output_format=c(
                      "html_document" # set print_format <- "html" in seed-study.R
                      # "pdf_document"
                      # ,"md_document"
                      # "word_document" # set print_format <- "pandoc" in seed-study.R
                    ),
                    clean=TRUE)
}

















