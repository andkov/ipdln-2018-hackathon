# This script performs basic exploratory data analysis on raw data set

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

# ---- select-focus ------------------------
# this chunk is called by ./reports/eda-1/eda-1a-first-gen-immigrant.Rmd
ds <- ds %>% 
  # dplyr::filter(PR %in% selected_provinces) %>% 
  dplyr::filter(IMMDER   == "Immigrants") %>% 
  dplyr::filter(GENSTPOB == "1st generation - Respondent born outside Canada") 

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
    
    ls_guide$item[item_i] %>% print()
    cat("\n")
  }
}


# ---- save-to-disk ----------------------------

# ---- publish ---------------------------------------
# path_report_1 <- "./reports/eda-1/eda-1.Rmd"
path_report_1 <- "./reports/eda-1/eda-1a-first-gen-immigrant.Rmd"

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

















