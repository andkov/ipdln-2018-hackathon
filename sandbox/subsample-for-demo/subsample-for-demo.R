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
base::source("./scripts/graphing/graph-logistic.R")
base::source("./scripts/graphing/graph-presets.R") # fonts, colors, themes 
# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(ggplot2) #For graphing
library(magrittr) # Pipes
library(dplyr)
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
# path_save <- "./data-unshared/derived/object.rds"

# See definitions of commonly  used objects in:
source("./manipulation/object-glossary.R")   # object definitions
# ---- load-data ---------------------------------------------------------------
ds0      <- readRDS(path_input_micro) #  product of `./manipulation/0-greeter.R`
ls_guide <- readRDS(path_input_meta) #  product of `./manipulation/0-metador.R`

# ---- tweak-data --------------------------------------------------------------
ds0 %>% dplyr::glimpse()

# create an explicity person identifier
ds0 <-  ds0 %>% 
  tibble::rownames_to_column("person_id") %>% 
  dplyr::mutate( person_id = as.integer(person_id)) %>% 
  dplyr::select(person_id, dplyr::everything())


# ---- inspect-data ----------------------------
ds0 %>% dplyr::glimpse(50)

# ---- define-utility-functions ---------------
# create a function to subset a dataset in this context
# because data is heavy and makes development cumbersome
get_a_subsample <- function(d, sample_size, seed = 42){
  # sample_size <- 20000
  v_sample_ids <- sample(unique(d$person_id), sample_size)
  d1 <- d %>% 
    dplyr::filter(person_id %in% v_sample_ids)
  return(d1)
}
# how to use 
# ds1 <- ds0 %>% get_a_subsample(10000)  

# ---- create-subsample ----------------------

# let ds0 be the raw data provided for the IPDLN-2018-hackathon
selected_provinces <- c("Alberta","British Columbia", "Ontario", "Quebec")
sample_size        <- 10000
# select  a meaningful sample: middle-aged first-generation immigrants from four provinces
ds1 <- ds0 %>% 
  dplyr::filter(PR %in% selected_provinces) %>% 
  dplyr::filter(IMMDER   == "Immigrants") %>% 
  dplyr::filter(GENSTPOB == "1st generation - Respondent born outside Canada") #%>% 
  # get_a_subsample(sample_size) # unstratified sampling across provinces, representative size

#create samples of the same size from each  province
dmls <- list() # dummy list (dmls) to populate during the loop
for(province_i in selected_provinces){
  # province_i = "British Columbia" # for example
  dmls[[province_i]] <-  ds1 %>%
  dplyr::filter(PR == province_i) %>% 
    get_a_subsample(sample_size) # see `define-utility-functions` chunk
}
lapply(dmls, names) # view the contents of the list object
# overwrite, making it a stratified sample across selected provinces (same size in each)
ds1 <- plyr::ldply(dmls,data.frame,.id = "PR")
ds1 %>% dplyr::glimpse(50)
ds1 %>% dplyr::group_by(PR) %>% 
  dplyr::summarise(n_people = length(unique(person_id)))

# limit to focal variables
variables_to_keep <- c(
  "IMMDER"    # Immigration status = "Immigrants"
  ,"GENSTPOB"  # Generation in Canada = "1st generation"
  ,"person_id"  
  ,"PR"        # Province of residence
  ,"S_DEAD"    # Mortality indicator, dead in X years
  ,"age_group" # 5-year age group 
  ,"SEX"       # 1-female, 2 
  ,"MARST"     # Marital status
  ,"HCDD"      # Highest Degree
  ,"ADIFCLTY"  # Difficulty with Activities of Daily Living
  ,"DISABFL"   # Difficulty with Activities of Daily Living
  ,"FOL"       # First Language
  ,"OLN"       # Conversational Language
)

ds2 <- ds1 %>% 
  dplyr::select_(.dots = variables_to_keep)

# ---- save-to-disk --------------
saveRDS(ds2, "./data-unshared/derived/simulated_subsample.rds")

# ---- publish ---------------------------------------
path_report_1 <- "./reports/subsample-for-demo/subsample-for-demo.Rmd"
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