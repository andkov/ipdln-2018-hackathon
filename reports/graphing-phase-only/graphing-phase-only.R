# Run next lint to stitch a tech report of this script (used only in RStudio)
# knitr::stitch_rmd( script = "./reports/graphing-phase-only/graphing-phase-only.R", output = "./reports/graphing-phase-only/stitched_output/graphing-phase-only.md" )

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

# This script works with model results data estimated during /technique-demonstration/
path_input_micro <- "./data-public/derived/technique-demonstration/ls_model.rds"
path_input_meta  <- "./data-unshared/derived/0-ls_guide.rds"

# test whether the file exists / the link is good
testit::assert("File does not exist", base::file.exists(path_input_micro))
testit::assert("File does not exist", base::file.exists(path_input_meta))

# ---- load-data ---------------------------------------------------------------
ls_model <- readRDS(path_input_micro) #  product of `./reports/technique-demonstration/technique-demonstration.R`
ls_guide <- readRDS(path_input_meta) #  product of `./manipulation/0-metador.R`
 
# ---- tweak-data --------------------------------------------------------------
ds_predicted <- ls_model$predicted_values 

# ---- inspect-data ----------------------------
ls_model %>% lapply(names)
ls_model$call # model equation
ls_model$summary # model solution
ls_model$coefficients %>% round(2)# estimated coefficients
ls_model$predicted_values %>% glimpse(50) # predicted values

# ---- define-utility-functions ---------------
# where_to_store_graphs <- "./reports/graphing-phase-only/prints/1/" # female marital educ3 poor_health
where_to_store_graphs = "./reports/graphing-phase-only/prints/2/" # marital educ3 poor_health first
# where_to_store_graphs = "./reports/graphing-phase-only/prints/3/", # other collection of predictors

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
# covar_order_values <- c("female","marital","educ3","poor_health") #for /prints/1/
covar_order_values <- c("marital", "educ3","poor_health", "FOL") # for /prints/2/


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

# declare shared grahpical setting
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
eq_global_string <- ls_model$call
# the function that supports older reports needs this

# ---- graph-demo -----------------------------
# let us examine the ggplot2 logic of the graph
ds_predicted %>% glimpse()
g <-  ds_predicted %>% 
  # dplyr::filter(PR == "Alberta") %>% 
  ggplot2::ggplot(
    aes(x = age_group)
  ) +
  geom_jitter( 
    aes( y = dv_hat_p , fill = female)
    ,shape = 21
    ,alpha = .7
    ,size  = 5 
  ) +
  scale_fill_manual(values = c("TRUE" = "pink", 'FALSE' = "blue")) +
  facet_grid(. ~ PR) + 
  main_theme +
  labs(title = "Mortality across age groups")
g
# we have created two funtions that using this form
# graph_logistic_point_simple() - creates a generic graph 
# graph_logistic_point_complex_4() - stacks graphs for 4 predictors
# these functions are isolated in the script
base::source("./scripts/graphing/graph-logistic.R")

# ---- print-display-0 ----------------------
# 0 step : All colors are in
increased_risk_2  <- "#e41a1c"  # red     - further increased risk factor
increased_risk_1  <- "#ff7f00"  # organge - increased risk factor
reference_color   <- "#4daf4a"  # green   - REFERENCE  category
descreased_risk_1 <- "#377eb8"  # blue    - descreased risk factor
descreased_risk_2 <- "#984ea3"  # purple  - further descrease in risk factor
# color definitions are picked from  
# http://colorbrewer2.org/#type=qualitative&scheme=Set1&n=7


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
path_img <- paste0(where_to_store_graphs,"g0.png")
# cat('<img src="', path_img, '" alt="', basename(path_img),'">\n', sep="")


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
# this chunk will be disabled during production of stichted_output
path_report_1 <- "./reports/graphing-phase-only/graphing-phase-only.Rmd"
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
