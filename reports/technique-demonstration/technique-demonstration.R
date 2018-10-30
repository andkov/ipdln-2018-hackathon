# Run next lint to stitch a tech report of this script (used only in RStudio)
# knitr::stitch_rmd( script = "./reports/technique-demonstration/technique-demonstration.R", output = "./reports/technique-demonstration/stitched_output/technique-demonstration.md" )

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
# path_input_micro <- "./data-unshared/derived/simulated_subsample.rds"
path_input_meta  <- "./data-unshared/derived/ls_guide.rds"

# test whether the file exists / the link is good
testit::assert("File does not exist", base::file.exists(path_input_micro))
testit::assert("File does not exist", base::file.exists(path_input_meta))

# declare where you will store the product of this script
# path_save <- "./data-unshared/derived/object.rds"

# See definitions of commonly  used objects in:
source("./manipulation/object-glossary.R")   # object definitions
# ---- load-data ---------------------------------------------------------------
# ds0      <- readRDS(path_input_micro) #  product of `./manipulation/0-greeter.R`
ds0      <- readRDS(path_input_micro) #  product of `./analysis/subsample-for-demo/`
ls_guide <- readRDS(path_input_meta) #  product of `./manipulation/0-metador.R`



# ---- inspect-data ----------------------------
ds0 %>% dplyr::glimpse(50)
ds0 %>% 
  dplyr::group_by(PR, IMMDER, GENSTPOB) %>% 
  dplyr::summarize(n = length(unique(person_id)))


# ---- tweak-data --------------------------------------------------------------
library(dplyr)
# because we need to examine observed values of each predictor
ds0 %>% group_by(PR)        %>% summarize(n = n())
ds0 %>% group_by(SEX)       %>% summarize(n = n())
ds0 %>% group_by(MARST)     %>% summarize(n = n())
ds0 %>% group_by(HCDD)      %>% summarize(n = n())
ds0 %>% group_by(ADIFCLTY)  %>% summarize(n = n())
ds0 %>% group_by(DISABFL)   %>% summarize(n = n())
ds0 %>% group_by(age_group) %>% summarize(n = n())
ds0 %>% group_by(FOL,PR) %>% summarize(n = n())
ds0 %>% group_by(OLN,PR) %>% summarize(n = n())


# as evident from above
# some variables are too granular for general analysis
# they need to be re-scaled in order to be more useful

ds1 <- ds0 %>% 
  dplyr::mutate(
    # because `female` is less ambiguous then `sex`
    female = car::recode(
      SEX, "
      'Female' = 'TRUE'
      ;'Male'  = 'FALSE'
      ")
    ,female = factor(female, levels = c("FALSE","TRUE"))
    # because `still legaly married` is more legal than human
    ,marital = car::recode(
      MARST, "
      'Divorced'                              = 'sep_divorced' 
      ;'Legally married (and not separated)'   = 'mar_cohab' 
      ;'Separated, but still legally married'  = 'sep_divorced' 
      ;'Never legally married (single)'        = 'single' 
      ;'Widowed'                               = 'widowed'
      ")
    ,marital = factor(marital, levels = c(
      "sep_divorced","widowed","single","mar_cohab"))
    # because more than 5 categories is too fragmented
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
    # because even only 5 may be too granular for our purposes
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
    # ADIFCLTY               "Problems with ADL" (physical & cognitive)
    # DISABFL                "Problems with ADL" (physical & social)
    # because this is what counts practically
    ,poor_health = ifelse(ADIFCLTY %in% c("Yes, often","Yes, sometimes")
                          &
                            DISABFL %in% c("Yes, often","Yes, sometimes"),
                          TRUE, FALSE
    )
    ,poor_health = factor(poor_health, levels = c("TRUE","FALSE"))
    # because interval floor is easer to display on the graph then `19 to 24`
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
  # because easier to reference, expressed as interval's floor
  dplyr::mutate(
    age_group = age_group_low
  ) %>% 
  # because it needs to be sorted from lowest to highest ability 
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

ds1 %>% glimpse(50)

# # because we want/need to inspect newly created variables
ds1 %>% group_by(educ3) %>% summarize(n = n())
ds1 %>% group_by(educ5) %>% summarize(n = n())
ds1 %>% group_by(FOL)   %>% summarize(n = n())

# reminder: we use `ls_guide` to lookup data codebook
ls_guide$item$IMMDER
ls_guide$item$GENSTPOB


# ---- define-utility-functions ---------------
where_to_store_graphs <- "./reports/technique-demonstration/prints/1/"
# where_to_store_graphs = "./reports/coloring-book-mortality/prints/2/", # educ3 poor_health first conversational
# where_to_store_graphs = "./reports/coloring-book-mortality/prints/3/", # other collection of predictors

# define a function to print a graph onto disk as an image
# because some aspects of appearances are easier to control during printing, not graphing
quick_save <- function(g,name){
  ggplot2::ggsave(
    filename = paste0(name,".png"), 
    plot   = g,
    device = png,
    path   = where_to_store_graphs, # female marital educ poor_healt
    width  = 1600,
    height = 1200,
    # units = "cm",
    dpi    = 200,
    limitsize = FALSE
  )
}

# ---- define-graph-controls --------------------------------------------
# declare the dependent variable and define descriptive labels
dv_name            <- "S_DEAD"
dv_label_prob      <- "Alive in X years"
dv_label_odds      <- "Odds(Dead)"

# select the predictors to evaluate graphically
# becasue we typically will have more predictors then we want to display
# these will define rows in the printed matrix of graphs
covar_order_values <- c("female","marital","educ3","poor_health") 
# covar_order_values <- c("educ3","poor_health", "FOL","OLN") 
# covar_order_values <- c("educ5","poor_health", "FOL","OLN") 

# ---- isloate-for-modeling --------------------------------------------
# for the sake of modularization, create a data set that will passed to modeling
ds_for_modeling <- ds1 %>% 
  # reorganize the order of variables to match your modeling preference
  dplyr::select_(
    "person_id", "PR", "S_DEAD"
    ,"age_group"
    ,"female", "marital", "educ3","poor_health", "FOL","OLN"
  ) %>%
  # add transformation as needed
  # na.omit() %>% 
  dplyr::rename_(
    "dv" = dv_name # to ease serialization and string handling
  ) 

# ---- model-specification ----------------------------------------
# define the model equation 
equation_string <- paste0(
  # "dv ~ -1 + PR + age_group + female + marital + educ3 + poor_health + FOL + OLN"
  "dv ~ -1 + PR + age_group + female + marital + educ3 + poor_health + FOL"
  ) 
equation_formula <- as.formula(equation_string)
print(equation_formula, showEnv = FALSE)

# ---- model-estimation ---------------------------------
# pass model specification to the estimation routine
model_solution <- glm(
  equation_formula,
  data   = ds_for_modeling, 
  family = binomial(link="logit")
) 
# inspect model results
equation_formula # because we must see equation!
model_solution %>% summary()
model_solution %>% coefficients() %>% round(2)
# ds_for_modeling$dv_p <- predict(model_solution) # fast check

# ---- model-prediction ----------------------------------
# distill all possible combinations of predictors
# because we will create predictions for them
# using the coefficients from the model solution
ds_predicted <- ds_for_modeling %>% 
  dplyr::select_(
    "PR"
    ,"age_group" 
    ,"female"        
    ,"educ3"
    # ,"educ5"       
    ,"marital" 
    ,"poor_health" 
    ,"FOL"
    # ,"ONL"
  ) %>% 
  dplyr::distinct()

# compute predicted values of the criterion 
# by applying model solution to all possible levels of predictors
#logged-odds of probability (ie, linear)
ds_predicted$dv_hat    <- as.numeric(predict(model_solution, newdata=ds_predicted)) 
#probability (ie, s-curve), because we want to visualize probability
ds_predicted$dv_hat_p  <- plogis(ds_predicted$dv_hat) 

# save a modeling object to plat later
ls_model <- list(
  "call"          = equation_string
  ,"summary"      = model_solution %>% summary()
  ,"coefficients" = model_solution %>% stats::coefficients()
  ,"predicted_values" = ds_predicted
)
writeRDS(ls_model, "./reports/")
# the script can be continutued in
# `./reports/technique-demonstrations/`


# ---- define-coloring-book-settings ---------------------------
# create a function that would assign color
# to the values of predictors based on informed expectation
assign_color <- function(color_group){
  
  if( color_group == "female") {
    palette_color <- c(
      "TRUE"   = reference_color
      ,"FALSE" = increased_risk_1
    ) 
  } else if( color_group %in% c("educ5") ) { 
    palette_color <- c(
      "less than high school" = increased_risk_2
      ,"high school"           = increased_risk_1
      , "college"              = reference_color
      , "graduate"             = descreased_risk_1
      , "Dr."                  = descreased_risk_2
    ) 
  } else if( color_group %in% c("educ3") ) { 
    palette_color <- c(
      "less than high school"  = increased_risk_1
      ,"high school"           = reference_color
      ,"more than high school" = descreased_risk_1
    ) 
  } else if( color_group %in% c("marital") ) {
    palette_color <- c(
      "mar_cohab"     = descreased_risk_1
      ,"sep_divorced" = increased_risk_2
      ,"single"       = reference_color
      ,"widowed"      = increased_risk_1
    )
  } else if( color_group %in% c("poor_health") ) {
    palette_color <- c(
      "FALSE" = reference_color
      ,"TRUE" = increased_risk_2
    )
  } else if( color_group %in% c("FOL") ) {
    palette_color <- c(
      "Both English and French"      = descreased_risk_1
      ,"English only"                = reference_color 
      ,"French only"                 = increased_risk_1
      ,"Neither English nor French"  = increased_risk_2
    )                       
  } else if( color_group %in% c("OLN") ) {
    palette_color <- c(
      "Both English and French"      = descreased_risk_2
      ,"English only"                = reference_color 
      ,"French only"                 = increased_risk_1
      ,"Neither English nor French"  = increased_risk_2
    )
  } else {
    stop("The palette for this variable is not defined.")
  }
  
}

# shared grahpical setting
common_alpha <- .7          # shared transparency
common_natural <- "grey90"  # the "no-color" color
y_low = .2 # to remove white space
y_high = 1 # to remove white space

# load the custom graphing function, isolated in this script
base::source("./scripts/graphing/graph-logistic.R")
# color definitions are picked from  
# http://colorbrewer2.org/#type=qualitative&scheme=Set1&n=7
list.files(where_to_store_graphs, full.names = TRUE)

# temp hack: so that older code doesnot break:
eq_global_string <- equation_string


# ---- print-display-0 ----------------------
# 0 step : All colors are in
increased_risk_2  <- "#e41a1c"  # red      - further increased risk factor
increased_risk_1  <- "#ff7f00"  # organge  - increased risk factor
reference_color   <- "#4daf4a"  # green    - REFERENCE  category
descreased_risk_1 <-"#377eb8"   # blue     - descreased risk factor
descreased_risk_2 <- "#984ea3"  # purple   - further descrease in risk factor

g0 <- ds_predicted %>% 
  graph_logistic_point_complex_4(
    x_name       = "age_group"
    ,y_name      = "dv_hat_p"
    ,covar_order = covar_order_values
    ,alpha_level = common_alpha
    ,y_title     = dv_label_prob
    ,y_range     = c(y_low, y_high)
  ) 
g0 %>% print() # inspect
g0 %>%  quick_save(name = "g0") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)

# ---- print-display-1 ----------------------
# 1 step of color logic: no color is added
increased_risk_2 <- common_natural  # red     - further increased risk factor
increased_risk_1 <- common_natural  # organge - increased risk factor
reference_color <- common_natural   # green   - REFERENCE  category
descreased_risk_1 <-common_natural  # blue    - descreased risk factor
descreased_risk_2 <- common_natural # purple  - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red     - further increased risk factor
# increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
# reference_color <- "#4daf4a"   # green   - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue    - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple  - further descrease in risk factor

g1 <- ds_predicted %>% 
  graph_logistic_point_complex_4(
    x_name       = "age_group"
    ,y_name      = "dv_hat_p"
    ,covar_order = covar_order_values
    ,alpha_level = common_alpha
    ,y_title     = dv_label_prob
    ,y_range     = c(y_low, y_high)
) 
g1 %>% print() # inspect
g1 %>%  quick_save(name = "g1") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)

# ---- print-display-2 ----------------------
# 2 step of color logic: add only the reference group
increased_risk_2 <- common_natural  # red     - further increased risk factor
increased_risk_1 <- common_natural  # organge - increased risk factor
reference_color <- common_natural   # green   - REFERENCE  category
descreased_risk_1 <-common_natural  # blue    - descreased risk factor
descreased_risk_2 <- common_natural # purple  - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red     - further increased risk factor
# increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
reference_color <- "#4daf4a"  # green   - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue    - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple  - further descrease in risk factor


g2 <- ds_predicted %>% 
  graph_logistic_point_complex_4(
    x_name       = "age_group"
    ,y_name      = "dv_hat_p"
    ,covar_order = covar_order_values
    ,alpha_level = common_alpha
    ,y_title     = dv_label_prob
    ,y_range     = c(y_low, y_high)
  ) 
g2 %>% print() # inspect
g2 %>%  quick_save(name = "g2") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)

# ---- print-display-3 ----------------------
# 3 step of color logic: add moderately increased risk
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

g3 <- ds_predicted %>% 
  graph_logistic_point_complex_4(
    x_name       = "age_group"
    ,y_name      = "dv_hat_p"
    ,covar_order = covar_order_values
    ,alpha_level = common_alpha
    ,y_title     = dv_label_prob
    ,y_range     = c(y_low, y_high)
  ) 
g3 %>% print() # inspect
g3 %>%  quick_save(name = "g3") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)

# ---- print-display-4 ----------------------

# 4 step of color logic: add moderately decreased risk
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


g4 <- ds_predicted %>% 
  graph_logistic_point_complex_4(
    x_name       = "age_group"
    ,y_name      = "dv_hat_p"
    ,covar_order = covar_order_values
    ,alpha_level = common_alpha
    ,y_title     = dv_label_prob
    ,y_range     = c(y_low, y_high)
  ) 
g4 %>% print() # inspect
g4 %>%  quick_save(name = "g4") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)

# ---- print-display-5 ----------------------
# 5 step of color logic: add substantially increased risk
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

g5 <- ds_predicted %>% 
  graph_logistic_point_complex_4(
    x_name       = "age_group"
    ,y_name      = "dv_hat_p"
    ,covar_order = covar_order_values
    ,alpha_level = common_alpha
    ,y_title     = dv_label_prob
    ,y_range     = c(y_low, y_high)
  ) 
g5 %>% print() # inspect
g5 %>%  quick_save(name = "g5") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)

# ---- print-display-6 ----------------------
# 6 step of color logic: add substantially decreased risk
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

g6 <- ds_predicted %>% 
  graph_logistic_point_complex_4(
    x_name       = "age_group"
    ,y_name      = "dv_hat_p"
    ,covar_order = covar_order_values
    ,alpha_level = common_alpha
    ,y_title     = dv_label_prob
    ,y_range     = c(y_low, y_high)
  ) 
g6 %>% print() # inspect
g6 %>%  quick_save(name = "g6") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)
# cat('<img src="', path, '" alt="', basename(path),'">\n', sep="")

# ---- save-to-disk ----------------------------
# writing to disk was localized during printing

# ---- publish ---------------------------------------
path_report_1 <- "./reports/technique-demonstration/technique-demonstration.Rmd"
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
