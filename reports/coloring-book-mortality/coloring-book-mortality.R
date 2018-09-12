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

# create an explicity person identifier
ds <-  ds %>% 
  tibble::rownames_to_column("person_id") %>% 
  dplyr::select(person_id, dplyr::everything())


# ---- inspect-data ----------------------------
ds %>% dplyr::glimpse(50)

# ---- define-utility-functions ---------------
# create a function to subset a dataset in this context
get_a_subsample <- function(d, sample_size, seed = 42){
  # sample_size <- 20000
  v_sample_ids <- sample(unique(d$person_id), sample_size)
  d1 <- d %>% 
    dplyr::filter(person_id %in% v_sample_ids)
  return(d1)
}
# how to use 
# ds1 <- ds %>% get_a_subsample(10000)  


# ---- transform-into-new-variables --------------------------------------

# new variables are 

# female
# marital 
#  - mar_cohab
#  - sep_divorced
#  - single
#  - widows
# educ3
# -less then highschool
# - highschool
# - more than highschool
# 
# poor_health
# - yes
# - no




# ---- a-1 ---------------------------------------------------------------
selected_provinces <- c("Alberta","British Columbia", "Ontario", "Quebec")

# middle aged immigrants in british columbia
ds1 <- ds %>% 
  # dplyr::filter(age_group == "40 to 44") %>% 
  dplyr::filter(PR %in% selected_provinces) %>% 
  dplyr::filter(IMMDER == "Immigrants") %>% 
  dplyr::filter(GENSTPOB == "1st generation - Respondent born outside Canada") %>% 
  get_a_subsample(10000)
ds <- ds1
# ---- assemble ------------------------
dv_name <- "S_DEAD"
dv_label_prob <- "Dead in X years"
dv_label_odds <- "Odds(Dead)"
# covar_order_values <- c("female","marital_f","educ3_f","poor_health")


# basic counts
table(ds$PR, ds$S_DEAD, useNA = "ifany")
table(ds$PR, ds$FOL) %>% knitr::kable()
table(ds$study_name, ds$female, useNA = "always")
table(ds$study_name, ds$marital, useNA = "always")
table(ds$study_name, ds$educ3, useNA = "always")

# ---- fit-model ----------------------------------------
ds2 <- ds %>% 
  dplyr::select_("person_id", "PR", "S_DEAD", 
                 "age_group", "SEX", "MARST", "FOL","OLN") %>% 
  na.omit() %>% 
  # dplyr::mutate(
  #   marital_f         = as.factor(marital),
  #   educ3_f           = as.factor(educ3)
  # ) %>% 
  dplyr::rename_(
    "dv" = dv_name
  ) 
#eq <- as.formula(paste0("smoke_now ~ -1 + study_name + age_in_years + female + marital_f + educ3_f + poor_health"))
# eq <- as.formula(paste0("smoke_now ~ -1 + age_in_years + female + educ3_f + poor_health"))
eq_global_string <- paste0(
  # "smoke_now ~ -1 + study_name + age_in_years + female + marital_f + educ3_f + poor_health + female:marital_f + female:educ3_f + female:poor_health + marital_f:educ3_f + marital_f:poor_health"
  "dv ~ -1 + PR + age_group + SEX + MARST + FOL + OLN"
)
eq_global <- as.formula(eq_global_string)

eq_local_string <- paste0(
  # "smoke_now ~ -1 + age_in_years + female + marital_f + educ3_f + poor_health + female:marital_f + female:educ3_f + female:poor_health + marital_f:educ3_f + marital_f:poor_health"
  "dv ~ -1 + age_group + SEX + MARST + FOL + OLN"
)

eq_local <- as.formula(eq_local_string)
# eq <- as.formula(paste0("smoke_now ~ -1 + age_in_years"))
model_global <- glm(
  eq_global,
  data = ds2, 
  family = binomial(link="logit")
) 
summary(model_global)
coefficients(model_global)
ds2$dv_p <- predict(model_global)

# ds_predicted_global <- expand.grid(
#   study_name      = sort(unique(ds2$study_name)), #For the sake of repeating the same global line in all studies/panels in the facetted graphs
#   age_in_years    = seq.int(40, 100, 10),
#   female        = sort(unique(ds2$female)),
#   educ3_f       = sort(unique(ds2$educ3_f)),
#   # marital_f     = sort(unique(d$marital_f)),
#   poor_health   = sort(unique(ds2$poor_health)),
#   stringsAsFactors = FALSE
# ) 

ds_predicted_global <- ds2 %>% 
  dplyr::select_(
    "study_name",
    "age_in_years", 
    "female",        
    "educ3_f",       
    "marital_f" ,
    "poor_health"  
  ) 

ds_predicted_global$dv_hat    <- as.numeric(predict(model_global, newdata=ds_predicted_global)) #logged-odds of probability (ie, linear)
ds_predicted_global$dv_hat_p  <- plogis(ds_predicted_global$dv_hat) 
