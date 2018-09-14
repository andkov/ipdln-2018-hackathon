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
  dplyr::select(person_id, dplyr::everything())


# ---- inspect-data ----------------------------
ds0 %>% dplyr::glimpse(50)

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
# ds1 <- ds0 %>% get_a_subsample(10000)  

quick_save <- function(g,name){
  ggplot2::ggsave(
    filename= paste0(name,".png"), 
    plot=g,
    device = png,
    # path = "./reports/coloring-book-mortality/prints/1/", # female marital educ poor_healt
    path = "./reports/coloring-book-mortality/prints/2/", # educ3 poor_health first conversational
    # path = "./reports/coloring-book-mortality/prints/3/",
    width = 1600,
    height = 1200,
    # units = "cm",
    dpi = 200,
    limitsize = FALSE
  )
}

# ---- define-graph-controls --------------------------------------------
dv_name            <- "S_DEAD"
dv_label_prob      <- "Alive in X years"
dv_label_odds      <- "Odds(Dead)"
# covar_order_values <- c("female","marital","educ3","poor_health") # rows in display matrix
covar_order_values <- c("educ3","poor_health", "FOL","OLN") # rows in display matrix
# covar_order_values <- c("educ5","poor_health", "FOL","OLN") # rows in display matrix


# ---- transform-into-new-variables --------------------------------------
# new variables are 
ds0 %>% group_by(PR)        %>% summarize(n = n())
ds0 %>% group_by(SEX)       %>% summarize(n = n())
ds0 %>% group_by(MARST)     %>% summarize(n = n())
ds0 %>% group_by(HCDD)      %>% summarize(n = n())
ds0 %>% group_by(ADIFCLTY)  %>% summarize(n = n())
ds0 %>% group_by(DISABFL)   %>% summarize(n = n())
ds0 %>% group_by(age_group) %>% summarize(n = n())

# transform the scale of some variable (to be used in the model)
ds0 <- ds0 %>% 
  dplyr::mutate(
    female = car::recode(
      SEX, "
      'Female' = 'TRUE'
      ;'Male'  = 'FALSE'
      ")
    ,female = factor(female, levels = c("FALSE","TRUE"))
    ,marital = car::recode(
      MARST, "
      'Divorced'                              = 'sep_divorced'
     ;'Legally married (and not separated)'   = 'mar_cohab' 
     ;'Separated, but still legally married'  = 'sep_divorced' 
     ;'Never legally married (single)'        = 'single' 
     ;'Widowed'                               = 'widowed'
    "),
    marital = factor(marital, levels = c(
      "sep_divorced","widowed","single","mar_cohab"))
    ,educ5 = car::recode(
     HCDD, "
     'None'                                                                                                          = 'less then high school'
    ;'High school graduation certificate or equivalency certificate'                                                 = 'high school'
    ;'Other trades certificate or diploma'                                                                           = 'high school'
    ;'Registered apprenticeship certificate'                                                                         = 'high school'
    ;'College, CEGEP or other non-university certificate or diploma from a program of 3 months to less than 1 year'  = 'college'
    ;'College, CEGEP or other non-university certificate or diploma from a program of 1 year to 2 years'             = 'college'
    ;'College, CEGEP or other non-university certificate or diploma from a program of more than 2 years'             = 'college'
    ;'University certificate or diploma below bachelor level'                                                        = 'college'
    ;'Bachelors degree'                                                                                              = 'college'
    ;'University certificate or diploma above bachelor level'                                                        = 'graduate'
    ;'Degree in medicine, dentistry, veterinary medicine or optometry'                                               = 'graduate'
    ;'Masters degree'                                                                                                = 'graduate'
    ;'Earned doctorate degree'                                                                                       = 'Dr.'
    ")
    ,educ5 = factor(educ5, levels = c( 
      "less then high school"
      ,"high school"          
      ,"college"             
      ,"graduate"            
      ,"Dr."  
      ) 
    ) 
    ,educ3 = car::recode(
      HCDD, "
     'None'                                                                                                          = 'less than high school'
    ;'High school graduation certificate or equivalency certificate'                                                 = 'high school'  
    ;'Other trades certificate or diploma'                                                                           = 'high school'  
    ;'Registered apprenticeship certificate'                                                                         = 'more than high school' 
    ;'College, CEGEP or other non-university certificate or diploma from a program of 3 months to less than 1 year'  = 'more than high school' 
    ;'College, CEGEP or other non-university certificate or diploma from a program of 1 year to 2 years'             = 'more than high school' 
    ;'College, CEGEP or other non-university certificate or diploma from a program of more than 2 years'             = 'more than high school' 
    ;'University certificate or diploma below bachelor level'                                                        = 'more than high school' 
    ;'Bachelors degree'                                                                                              = 'more than high school' 
    ;'University certificate or diploma above bachelor level'                                                        = 'more than high school'
    ;'Degree in medicine, dentistry, veterinary medicine or optometry'                                               = 'more than high school'
    ;'Masters degree'                                                                                                = 'more than high school'
    ;'Earned doctorate degree'                                                                                       = 'more than high school'
    ")
    ,educ3 = factor(educ3, levels = c(
       "less than high school"
      , "high school"
      , "more than high school"
      )
    )
    ,poor_health = ifelse(ADIFCLTY %in% c("Yes, often","Yes, sometimes")
                          &
                          DISABFL %in% c("Yes, often","Yes, sometimes"),
                          TRUE, FALSE
                          )
    ,poor_health = factor(poor_health, levels = c("TRUE","FALSE"))
    ,age_group_low = car::recode(
      age_group, 
      "
      '19 to 24'      = '19'
      ;'25 to 29'     = '25'
      ;'30 to 34'     = '30'
      ;'35 to 39'     = '35'
      ;'40 to 44'     = '40'
      ;'45 to 49'     = '45'
      ;'50 to 54'     = '50'
      ;'55 to 59'     = '55'
      ;'60 to 64'     = '60'
      ;'65 to 69'     = '65'
      ;'70 to 74'     = '70'
      ;'75 to 79'     = '75'
      ;'80 to 84'     = '80'
      ;'85 to 89'     = '85'
      ;'90 and older' = '90'  
      "
    )
  ) %>%  
  # replace for convenience
  dplyr::mutate(
    age_group = age_group_low
  ) %>% 
  dplyr::mutate(
    FOL = factor(FOL,levels = c(
       "Neither English nor French"
      ,"French only"
      ,"English only"
      ,"Both English and French"
      )
    )
    ,OLN = factor(FOL,levels = c(
       "Neither English nor French"
      ,"French only"
      ,"English only"
      ,"Both English and French"
      )
    )
  )

ds0 %>% glimpse(50)
ds0 %>% group_by(educ3) %>% summarize(n = n())
ds0 %>% group_by(educ5) %>% summarize(n = n())
ds0 %>% group_by(FOL) %>% summarize( n = n())
# ---- a-1 ---------------------------------------------------------------
selected_provinces <- c("Alberta","British Columbia", "Ontario", "Quebec")
sample_size = 10000

# middle aged immigrants in british columbia
ds1 <- ds0 %>% 
  dplyr::filter(PR %in% selected_provinces) %>% 
  dplyr::filter(IMMDER == "Immigrants") %>% 
  dplyr::filter(GENSTPOB == "1st generation - Respondent born outside Canada") #%>% 
  # get_a_subsample(sample_size) # representative sample across provinces


dmls <- list() # dummy list
for(province_i in selected_provinces){
  # province_i = "British Columbia"
  dmls[[province_i]] <-  ds1 %>%
  dplyr::filter(PR == province_i) %>% 
    get_a_subsample(sample_size)
}
lapply(dmls, names) # view the contents of the list object
# overwrite, making it a stratified sample across selected provinces (same size)
ds1 <- plyr::ldply(dmls,data.frame,.id = "PR")

ds1 %>% group_by(educ3) %>% summarize(n = n())
ds1 %>% group_by(educ5) %>% summarize(n = n())

# ---- assemble ------------------------


# basic counts
table(ds1$PR, ds1$S_DEAD,  useNA = "ifany" )
table(ds1$PR, ds1$FOL                      ) 
table(ds1$PR, ds1$female,  useNA = "always")
table(ds1$PR, ds1$marital, useNA = "always")
table(ds1$PR, ds1$educ3,   useNA = "always")
table(ds1$PR, ds1$educ5,   useNA = "always")
table(ds1$PR, ds1$FOL,   useNA = "always")
table(ds1$PR, ds1$OLN,   useNA = "always")

# ---- model-specification ----------------------------------------

ds2 <- ds1 %>% 
  dplyr::select_("person_id", "PR", "S_DEAD"
                 ,"age_group"
                 , "female", "marital", "educ3","poor_health", "FOL","OLN") %>%
                 # , "female", "marital", "educ5","poor_health", "FOL","OLN") %>%
  dplyr::mutate(
    poor_health = factor(poor_health)
  ) %>% 
  na.omit() %>% 
  dplyr::rename_(
    "dv" = dv_name # to ease serialization and string handling
  ) 

ds2 %>% group_by(educ5) %>% summarize(n = n())

# define the model equation 
eq_global_string <- paste0(
  "dv ~ -1 + PR + age_group + female + marital + educ3 + poor_health + FOL + OLN"
  # "dv ~ -1 + PR + age_group + female + marital + educ5 + poor_health + FOL + OLN"
)
eq_global <- as.formula(eq_global_string)

# model specification for using PROVINCE as a stratum, not a predictor in the model
eq_local_string <- paste0(
  #        + PR  (notice the absence of this term!) 
  "dv ~ -1      + age_group + female + marital + educ3 + poor_health + FOL + OLN"
  # "dv ~ -1      + age_group + female + marital + educ5 + poor_health + FOL + OLN"
)
eq_local <- as.formula(eq_local_string)

# ---- estimate-global-solutions ---------------------------------
# this solution enters PR as one of the predictors


model_global <- glm(
  eq_global,
  data   = ds2, 
  family = binomial(link="logit")
) 
summary(model_global)
coefficients(model_global)
# ds2$dv_p <- predict(model_global) # fast check

# create levels of the predictors for which we will generate predictions using model solution
ds_predicted_global <- ds2 %>% 
  dplyr::select_(
    "PR",
    "age_group", 
    "female",        
    "educ3",
    # "educ5",       
    "marital" ,
    "poor_health", 
    "FOL",
    "OLN"
  ) %>% 
  dplyr::distinct()

# compute predicted values of the criterion based on model solution and levels of predictors
#logged-odds of probability (ie, linear)
ds_predicted_global$dv_hat    <- as.numeric(predict(model_global, newdata=ds_predicted_global)) 
#probability (ie, s-curve)
ds_predicted_global$dv_hat_p  <- plogis(ds_predicted_global$dv_hat) 


# ----- estimate-local-solutions ------------------------
# these models are estimated without PR in their predictors
# instead, they use PR to subset data which is then fed to the estimation routine

ds_predicted_province_list <- list()
model_province_list <- list()
for( province_i in selected_provinces) {
  d_province <- ds2 %>% dplyr::filter(PR == province_i)
  model_province <- glm(eq_local, data=d_province,  family=binomial(link="logit")) 
  model_province_list[[province_i]] <- model_province
  
  d_predicted <- ds2 %>% 
    dplyr::select_(
      # "PR", (notice the absence of this term!)
      "age_group", 
      "female",        
      "educ3",
      # "educ5",       
      "marital" ,
      "poor_health", 
      "FOL",
      "OLN"
    ) %>% 
    dplyr::distinct()
  # compute predicted values of the criterion based on model solution and levels of predictors
  #logged-odds of probability (ie, linear)
  d_predicted$dv_hat      <- as.numeric(predict(model_province, newdata=d_predicted)) 
  #probability (ie, s-curve)
  d_predicted$dv_hat_p    <- plogis(d_predicted$dv_hat)
  # store
  ds_predicted_province_list[[province_i]] <- d_predicted
}
# collapse into a single data set
ds_predicted_province <- ds_predicted_province_list %>% 
  dplyr::bind_rows(.id="PR")

lapply(model_province_list, summary)
sapply(model_province_list, coefficients)



assign_color <- function(color_group){
  if( color_group == "female") {
    # http://colrd.com/image-dna/25114/
    palette_color <- c("TRUE"=reference_color, "FALSE"=increased_risk_1) # 98aab9
  } else if( color_group %in% c("educ5") ) { 
    # http://colrd.com/image-dna/24382/
    palette_color <- c(
       "less than high school" = increased_risk_2
      ,"high school"           = increased_risk_1
      , "college"              = reference_color
      , "graduate"             = descreased_risk_1
      , "Dr."                  = descreased_risk_2
      ) # 54a992, e8c571
  } else if( color_group %in% c("educ3") ) { 
    # http://colrd.com/image-dna/24382/
    palette_color <- c(
      "less than high school" = increased_risk_1
      ,"high school"           = reference_color
      , "more than high school"=descreased_risk_1
     ) # 54a992, e8c571
  } else if( color_group %in% c("marital") ) {
    # http://colrd.com/image-dna/23318/
    palette_color <- c("mar_cohab"=descreased_risk_1, "sep_divorced"= increased_risk_2, "single"=reference_color, "widowed"=increased_risk_1)
  } else if( color_group %in% c("poor_health") ) {
    # http://colrd.com/palette/18841/
    palette_color <- c("FALSE"=reference_color, "TRUE"=increased_risk_2)
  } else if( color_group %in% c("FOL") ) {
    # http://colrd.com/image-dna/23318/
    palette_color <- c("Both English and French"     = descreased_risk_1,
                       "English only"                = reference_color, 
                       "French only"                 = increased_risk_1,
                       "Neither English nor French"  = increased_risk_2
                       )
  } else if( color_group %in% c("OLN") ) {
    # http://colrd.com/image-dna/23318/
    palette_color <- c("Both English and French"     = descreased_risk_2,
                       "English only"                = reference_color, 
                       "French only"                 = increased_risk_1,
                       "Neither English nor French"  = increased_risk_2
    )
  } else {
    stop("The palette for this variable is not defined.")
  }
  
}

# ---- palette-color-1 ---------------------------

# ---- 1-global-probability ----------------------

common_alpha <- .7
common_natural <- "grey90"
y_low = .2
y_high = 1

source("./scripts/graphing/graph-logistic.R")
# 0 step : All colors are in
increased_risk_2  <- "#e41a1c"  # red      - further increased risk factor
increased_risk_1  <- "#ff7f00"  # organge  - increased risk factor
reference_color   <- "#4daf4a"  # green    - REFERENCE  category
descreased_risk_1 <-"#377eb8"   # blue     -  descreased risk factor
descreased_risk_2 <- "#984ea3"  # purple   - further descrease in risk factor

graph_logistic_point_complex_4(
  ds = ds_predicted_global,
  x_name = "age_group",
  y_name = "dv_hat_p",
  covar_order = covar_order_values,
  alpha_level = common_alpha,
  y_title = dv_label_prob,
  y_range = c(y_low, y_high)) %>% 
  quick_save("a0")

# 1 step of color logic:
increased_risk_2 <- common_natural  # red - further increased risk factor
increased_risk_1 <- common_natural  # organge - increased risk factor
reference_color <- common_natural   # green  - REFERENCE  category
descreased_risk_1 <-common_natural  # blue - descreased risk factor
descreased_risk_2 <- common_natural # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
# increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
# reference_color <- "#4daf4a"   # green  - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor

graph_logistic_point_complex_4(
  ds = ds_predicted_global,
  x_name = "age_group",
  y_name = "dv_hat_p",
  covar_order = covar_order_values,
  alpha_level = common_alpha,
  y_title = dv_label_prob,
  y_range = c(y_low, y_high)
) %>% 
  quick_save(name = "a1")
summary(ds_predicted_province_list)

# 2 step of color logic:
increased_risk_2 <- common_natural  # red - further increased risk factor
increased_risk_1 <- common_natural  # organge - increased risk factor
reference_color <- common_natural   # green  - REFERENCE  category
descreased_risk_1 <-common_natural  # blue - descreased risk factor
descreased_risk_2 <- common_natural # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
# increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
reference_color <- "#4daf4a"   # green  - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor


graph_logistic_point_complex_4(
  ds = ds_predicted_global,
  x_name = "age_group",
  # x_name = "age_in_years",
  y_name = "dv_hat_p",
  covar_order = covar_order_values,
  alpha_level = common_alpha,
  y_title = dv_label_prob,
  y_range = c(y_low, y_high)) %>%  
  quick_save(name = "a2")


# summary(ds_predicted_province)

# 3 step of color logic:
increased_risk_2 <- common_natural  # red - further increased risk factor
increased_risk_1 <- common_natural  # organge - increased risk factor
reference_color <- common_natural   # green  - REFERENCE  category
descreased_risk_1 <-common_natural  # blue - descreased risk factor
descreased_risk_2 <- common_natural # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
# reference_color <- "#4daf4a"   # green  - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor



graph_logistic_point_complex_4(
  ds = ds_predicted_global,
  x_name = "age_group",
  y_name = "dv_hat_p",
  covar_order = covar_order_values,
  alpha_level = common_alpha,
  y_title = dv_label_prob,
  y_range = c(y_low, y_high)) %>% 
  quick_save("a3")




# 4 step of color logic:
increased_risk_2 <- common_natural  # red - further increased risk factor
increased_risk_1 <- common_natural  # organge - increased risk factor
reference_color <- common_natural   # green  - REFERENCE  category
descreased_risk_1 <-common_natural  # blue - descreased risk factor
descreased_risk_2 <- common_natural # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
# increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
# reference_color <- "#4daf4a"   # green  - REFERENCE  category
descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor


graph_logistic_point_complex_4(
  ds = ds_predicted_global,
  x_name = "age_group",
  y_name = "dv_hat_p",
  covar_order = covar_order_values,
  alpha_level = common_alpha,
  y_title = dv_label_prob,
  y_range = c(y_low, y_high)) %>% 
  quick_save("a4")




# 5 step of color logic:
increased_risk_2 <- common_natural  # red - further increased risk factor
increased_risk_1 <- common_natural  # organge - increased risk factor
reference_color <- common_natural   # green  - REFERENCE  category
descreased_risk_1 <-common_natural  # blue - descreased risk factor
descreased_risk_2 <- common_natural # purple - further descrease in risk factor

increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
# increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
# reference_color <- "#4daf4a"   # green  - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor

graph_logistic_point_complex_4(
  ds = ds_predicted_global,
  x_name = "age_group",
  y_name = "dv_hat_p",
  covar_order = covar_order_values,
  alpha_level = common_alpha,
  y_title = dv_label_prob,
  y_range = c(y_low, y_high)) %>% 
  quick_save("a5")

# 6 step of color logic:
increased_risk_2 <- common_natural  # red - further increased risk factor
increased_risk_1 <- common_natural  # organge - increased risk factor
reference_color <- common_natural   # green  - REFERENCE  category
descreased_risk_1 <-common_natural  # blue - descreased risk factor
descreased_risk_2 <- common_natural # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
# increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
# reference_color <- "#4daf4a"   # green  - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor

graph_logistic_point_complex_4(
  ds = ds_predicted_global,
  x_name = "age_group",
  y_name = "dv_hat_p",
  covar_order = covar_order_values,
  alpha_level = common_alpha,
  y_title = dv_label_prob,
  y_range = c(y_low, y_high)) %>% 
  quick_save("a6")



