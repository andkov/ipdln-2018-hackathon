



This report was automatically generated with the R package **knitr**
(version 1.20).


```r
# Run next lint to stitch a tech report of this script (used only in RStudio)
# knitr::stitch_rmd( script = "./reports/graphing-phase-only/graphing-phase-only.R", output = "./reports/graphing-phase-only/stitched_output/graphing-phase-only.md" )

rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. 
# This is not called by knitr, because it's above the first chunk.
cat("\f") # clear console when working in RStudio
```



```r
# Call `base::source()` on any repo file that defines functions needed below.  
# Ideally, no real operations are performed.
base::source("./scripts/graphing/graph-logistic.R")
base::source("./scripts/graphing/graph-presets.R") # fonts, colors, themes 
```

```r
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(ggplot2) #For graphing
library(magrittr) # Pipes
library(dplyr)
requireNamespace("dplyr", quietly=TRUE)
requireNamespace("TabularManifest") # devtools::install_github("Melinae/TabularManifest")
requireNamespace("knitr")
requireNamespace("scales") #For formating values in graphs
requireNamespace("RColorBrewer")
```

```r
# link to the source of the location mapping

# This script works with model results data estimated during /technique-demonstration/
path_input_micro <- "./data-public/derived/technique-demonstration/ls_model.rds"
path_input_meta  <- "./data-unshared/derived/ls_guide.rds"

# test whether the file exists / the link is good
testit::assert("File does not exist", base::file.exists(path_input_micro))
testit::assert("File does not exist", base::file.exists(path_input_meta))

# declare where you will store the product of this script
# path_save <- "./data-unshared/derived/object.rds"

# See definitions of commonly  used objects in:
source("./manipulation/object-glossary.R")   # object definitions
```

```r
ls_model <- readRDS(path_input_micro) #  product of `./reports/technique-demonstration/technique-demonstration.R`
ls_guide <- readRDS(path_input_meta) #  product of `./manipulation/0-metador.R`
```

```r
ds_predicted <- ls_model$predicted_values 
```

```r
ls_model %>% lapply(names)
```

```
## $call
## NULL
## 
## $summary
##  [1] "call"           "terms"          "family"         "deviance"      
##  [5] "aic"            "contrasts"      "df.residual"    "null.deviance" 
##  [9] "df.null"        "iter"           "deviance.resid" "coefficients"  
## [13] "aliased"        "dispersion"     "df"             "cov.unscaled"  
## [17] "cov.scaled"    
## 
## $coefficients
##  [1] "PRQuebec"                   "PROntario"                 
##  [3] "PRAlberta"                  "PRBritish Columbia"        
##  [5] "age_group25"                "age_group30"               
##  [7] "age_group35"                "age_group40"               
##  [9] "age_group45"                "age_group50"               
## [11] "age_group55"                "age_group60"               
## [13] "age_group65"                "age_group70"               
## [15] "age_group75"                "age_group80"               
## [17] "age_group85"                "age_group90"               
## [19] "femaleTRUE"                 "maritalwidowed"            
## [21] "maritalsingle"              "maritalmar_cohab"          
## [23] "educ3high school"           "educ3more than high school"
## [25] "poor_healthFALSE"           "FOLFrench only"            
## [27] "FOLEnglish only"            "FOLBoth English and French"
## 
## $predicted_values
## [1] "PR"          "age_group"   "female"      "educ3"       "marital"    
## [6] "poor_health" "FOL"         "dv_hat"      "dv_hat_p"
```

```r
ls_model$call # model equation
```

```
## [1] "dv ~ -1 + PR + age_group + female + marital + educ3 + poor_health + FOL"
```

```r
ls_model$summary # model solution
```

```
## 
## Call:
## glm(formula = equation_formula, family = binomial(link = "logit"), 
##     data = ds_for_modeling)
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -3.6773   0.0872   0.1688   0.3635   1.8669  
## 
## Coefficients:
##                            Estimate Std. Error z value Pr(>|z|)    
## PRQuebec                    4.33434    0.46789   9.264  < 2e-16 ***
## PROntario                   4.55186    0.46640   9.760  < 2e-16 ***
## PRAlberta                   4.56119    0.46713   9.764  < 2e-16 ***
## PRBritish Columbia          4.51707    0.46663   9.680  < 2e-16 ***
## age_group25                -0.39125    0.58658  -0.667 0.504771    
## age_group30                -0.72434    0.54078  -1.339 0.180431    
## age_group35                -1.41586    0.48782  -2.902 0.003703 ** 
## age_group40                -1.68424    0.47577  -3.540 0.000400 ***
## age_group45                -2.53001    0.46166  -5.480 4.25e-08 ***
## age_group50                -2.46218    0.46289  -5.319 1.04e-07 ***
## age_group55                -3.43099    0.45591  -7.526 5.25e-14 ***
## age_group60                -3.94645    0.45496  -8.674  < 2e-16 ***
## age_group65                -4.02185    0.45571  -8.825  < 2e-16 ***
## age_group70                -4.17885    0.45581  -9.168  < 2e-16 ***
## age_group75                -4.42325    0.45615  -9.697  < 2e-16 ***
## age_group80                -4.85780    0.45685 -10.633  < 2e-16 ***
## age_group85                -5.25667    0.46192 -11.380  < 2e-16 ***
## age_group90                -5.41861    0.47663 -11.369  < 2e-16 ***
## femaleTRUE                  0.71318    0.04691  15.203  < 2e-16 ***
## maritalwidowed             -0.62827    0.08306  -7.564 3.90e-14 ***
## maritalsingle              -0.02683    0.10860  -0.247 0.804852    
## maritalmar_cohab            0.26822    0.07122   3.766 0.000166 ***
## educ3high school            0.13361    0.05605   2.384 0.017141 *  
## educ3more than high school  0.52122    0.05378   9.692  < 2e-16 ***
## poor_healthFALSE            1.09996    0.04500  24.441  < 2e-16 ***
## FOLFrench only              0.17020    0.10869   1.566 0.117358    
## FOLEnglish only            -0.06443    0.08020  -0.803 0.421786    
## FOLBoth English and French  0.09699    0.14881   0.652 0.514568    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 55452  on 40000  degrees of freedom
## Residual deviance: 15224  on 39972  degrees of freedom
## AIC: 15280
## 
## Number of Fisher Scoring iterations: 8
```

```r
ls_model$coefficients %>% round(2)# estimated coefficients
```

```
##                   PRQuebec                  PROntario 
##                       4.33                       4.55 
##                  PRAlberta         PRBritish Columbia 
##                       4.56                       4.52 
##                age_group25                age_group30 
##                      -0.39                      -0.72 
##                age_group35                age_group40 
##                      -1.42                      -1.68 
##                age_group45                age_group50 
##                      -2.53                      -2.46 
##                age_group55                age_group60 
##                      -3.43                      -3.95 
##                age_group65                age_group70 
##                      -4.02                      -4.18 
##                age_group75                age_group80 
##                      -4.42                      -4.86 
##                age_group85                age_group90 
##                      -5.26                      -5.42 
##                 femaleTRUE             maritalwidowed 
##                       0.71                      -0.63 
##              maritalsingle           maritalmar_cohab 
##                      -0.03                       0.27 
##           educ3high school educ3more than high school 
##                       0.13                       0.52 
##           poor_healthFALSE             FOLFrench only 
##                       1.10                       0.17 
##            FOLEnglish only FOLBoth English and French 
##                      -0.06                       0.10
```

```r
ls_model$predicted_values %>% glimpse(50) # predicted values
```

```
## Observations: 3,873
## Variables: 9
## $ PR          <fct> Alberta, Alberta, Alberta...
## $ age_group   <fct> 35, 45, 75, 55, 55, 50, 7...
## $ female      <fct> TRUE, TRUE, TRUE, FALSE, ...
## $ educ3       <fct> more than high school, le...
## $ marital     <fct> single, sep_divorced, mar...
## $ poor_health <fct> FALSE, FALSE, FALSE, FALS...
## $ FOL         <fct> English only, English onl...
## $ dv_hat      <dbl> 5.388433, 3.779889, 2.389...
## $ dv_hat_p    <dbl> 0.9954517, 0.9776841, 0.9...
```

```r
where_to_store_graphs <- "./reports/graphing-phase-only/prints/1/" # female marital educ3 poor_health
# where_to_store_graphs = "./reports/graphing-phase-only/prints/2/" # educ3 poor_health first
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
```

```r
# declare the dependent variable and define descriptive labels
dv_name            <- "S_DEAD"
dv_label_prob      <- "Alive in X years"
dv_label_odds      <- "Odds(Dead)"

# select the predictors to evaluate graphically
# becasue we typically will have more predictors then we want to display
# these will define rows in the printed matrix of graphs
covar_order_values <- c("female","marital","educ3","poor_health") #for /prints/1/
# covar_order_values <- c("marital", "educ3","poor_health", "FOL") # for /prints/2/
```

```r
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
```

```
## [1] "./reports/graphing-phase-only/prints/1/g0.png"
## [2] "./reports/graphing-phase-only/prints/1/g1.png"
## [3] "./reports/graphing-phase-only/prints/1/g2.png"
## [4] "./reports/graphing-phase-only/prints/1/g3.png"
## [5] "./reports/graphing-phase-only/prints/1/g4.png"
## [6] "./reports/graphing-phase-only/prints/1/g5.png"
## [7] "./reports/graphing-phase-only/prints/1/g6.png"
```

```r
# temp hack: so that older code doesnot break: 
eq_global_string <- ls_model$call
# the function that supports older reports needs this
```

```r
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
```

<img src="figure/graphing-phase-only-Rmdprint-display-0-1.png" title="plot of chunk print-display-0" alt="plot of chunk print-display-0" style="display: block; margin: auto;" />

```r
g0 %>%  quick_save(name = "g0") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)
```

```
## [1] "./reports/graphing-phase-only/prints/1/g0.png"
## [2] "./reports/graphing-phase-only/prints/1/g1.png"
## [3] "./reports/graphing-phase-only/prints/1/g2.png"
## [4] "./reports/graphing-phase-only/prints/1/g3.png"
## [5] "./reports/graphing-phase-only/prints/1/g4.png"
## [6] "./reports/graphing-phase-only/prints/1/g5.png"
## [7] "./reports/graphing-phase-only/prints/1/g6.png"
```

```r
path_img <- paste0(where_to_store_graphs,"g0.png")
# cat('<img src="', path_img, '" alt="', basename(path_img),'">\n', sep="")
```

```r
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
```

<img src="figure/graphing-phase-only-Rmdprint-display-1-1.png" title="plot of chunk print-display-1" alt="plot of chunk print-display-1" style="display: block; margin: auto;" />

```r
g1 %>%  quick_save(name = "g1") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)
```

```
## [1] "./reports/graphing-phase-only/prints/1/g0.png"
## [2] "./reports/graphing-phase-only/prints/1/g1.png"
## [3] "./reports/graphing-phase-only/prints/1/g2.png"
## [4] "./reports/graphing-phase-only/prints/1/g3.png"
## [5] "./reports/graphing-phase-only/prints/1/g4.png"
## [6] "./reports/graphing-phase-only/prints/1/g5.png"
## [7] "./reports/graphing-phase-only/prints/1/g6.png"
```

```r
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
```

<img src="figure/graphing-phase-only-Rmdprint-display-2-1.png" title="plot of chunk print-display-2" alt="plot of chunk print-display-2" style="display: block; margin: auto;" />

```r
g2 %>%  quick_save(name = "g2") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)
```

```
## [1] "./reports/graphing-phase-only/prints/1/g0.png"
## [2] "./reports/graphing-phase-only/prints/1/g1.png"
## [3] "./reports/graphing-phase-only/prints/1/g2.png"
## [4] "./reports/graphing-phase-only/prints/1/g3.png"
## [5] "./reports/graphing-phase-only/prints/1/g4.png"
## [6] "./reports/graphing-phase-only/prints/1/g5.png"
## [7] "./reports/graphing-phase-only/prints/1/g6.png"
```

```r
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
```

<img src="figure/graphing-phase-only-Rmdprint-display-3-1.png" title="plot of chunk print-display-3" alt="plot of chunk print-display-3" style="display: block; margin: auto;" />

```r
g3 %>%  quick_save(name = "g3") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)
```

```
## [1] "./reports/graphing-phase-only/prints/1/g0.png"
## [2] "./reports/graphing-phase-only/prints/1/g1.png"
## [3] "./reports/graphing-phase-only/prints/1/g2.png"
## [4] "./reports/graphing-phase-only/prints/1/g3.png"
## [5] "./reports/graphing-phase-only/prints/1/g4.png"
## [6] "./reports/graphing-phase-only/prints/1/g5.png"
## [7] "./reports/graphing-phase-only/prints/1/g6.png"
```

```r
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
```

<img src="figure/graphing-phase-only-Rmdprint-display-4-1.png" title="plot of chunk print-display-4" alt="plot of chunk print-display-4" style="display: block; margin: auto;" />

```r
g4 %>%  quick_save(name = "g4") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)
```

```
## [1] "./reports/graphing-phase-only/prints/1/g0.png"
## [2] "./reports/graphing-phase-only/prints/1/g1.png"
## [3] "./reports/graphing-phase-only/prints/1/g2.png"
## [4] "./reports/graphing-phase-only/prints/1/g3.png"
## [5] "./reports/graphing-phase-only/prints/1/g4.png"
## [6] "./reports/graphing-phase-only/prints/1/g5.png"
## [7] "./reports/graphing-phase-only/prints/1/g6.png"
```

```r
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
```

<img src="figure/graphing-phase-only-Rmdprint-display-5-1.png" title="plot of chunk print-display-5" alt="plot of chunk print-display-5" style="display: block; margin: auto;" />

```r
g5 %>%  quick_save(name = "g5") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)
```

```
## [1] "./reports/graphing-phase-only/prints/1/g0.png"
## [2] "./reports/graphing-phase-only/prints/1/g1.png"
## [3] "./reports/graphing-phase-only/prints/1/g2.png"
## [4] "./reports/graphing-phase-only/prints/1/g3.png"
## [5] "./reports/graphing-phase-only/prints/1/g4.png"
## [6] "./reports/graphing-phase-only/prints/1/g5.png"
## [7] "./reports/graphing-phase-only/prints/1/g6.png"
```

```r
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
```

<img src="figure/graphing-phase-only-Rmdprint-display-6-1.png" title="plot of chunk print-display-6" alt="plot of chunk print-display-6" style="display: block; margin: auto;" />

```r
g6 %>%  quick_save(name = "g6") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)
```

```
## [1] "./reports/graphing-phase-only/prints/1/g0.png"
## [2] "./reports/graphing-phase-only/prints/1/g1.png"
## [3] "./reports/graphing-phase-only/prints/1/g2.png"
## [4] "./reports/graphing-phase-only/prints/1/g3.png"
## [5] "./reports/graphing-phase-only/prints/1/g4.png"
## [6] "./reports/graphing-phase-only/prints/1/g5.png"
## [7] "./reports/graphing-phase-only/prints/1/g6.png"
```

```r
# cat('<img src="', path, '" alt="', basename(path),'">\n', sep="")
```

```r
# writing to disk was localized during printing
```

```r
# this chunk will be disabled during production of stichted_output
# path_report_1 <- "./reports/graphing-phase-only/graphing-phase-only.Rmd"
# # path_report_2 <- "./reports/*/report_2.Rmd"
# allReports <- c(path_report_1)
# 
# pathFilesToBuild <- c(allReports)
# testit::assert("The knitr Rmd files should exist.", base::file.exists(pathFilesToBuild))
# # Build the reports
# for( pathFile in pathFilesToBuild ) {
#   
#   rmarkdown::render(input = pathFile,
#                     output_format=c(
#                       "html_document" # set print_format <- "html" in seed-study.R
#                       # "pdf_document"
#                       # ,"md_document"
#                       # "word_document" # set print_format <- "pandoc" in seed-study.R
#                     ),
#                     clean=TRUE)
# }
```

The R session information (including the OS info, R version and all
packages used):


```r
sessionInfo()
```

```
## R version 3.4.4 (2018-03-15)
## Platform: x86_64-w64-mingw32/x64 (64-bit)
## Running under: Windows >= 8 x64 (build 9200)
## 
## Matrix products: default
## 
## locale:
## [1] LC_COLLATE=English_United States.1252 
## [2] LC_CTYPE=English_United States.1252   
## [3] LC_MONETARY=English_United States.1252
## [4] LC_NUMERIC=C                          
## [5] LC_TIME=English_United States.1252    
## 
## attached base packages:
## [1] grid      stats     graphics  grDevices utils     datasets  methods  
## [8] base     
## 
## other attached packages:
## [1] knitr_1.20         bindrcpp_0.2.2     dplyr_0.7.6       
## [4] magrittr_1.5       RColorBrewer_1.1-2 dichromat_2.0-0   
## [7] ggplot2_3.0.0      extrafont_0.17    
## 
## loaded via a namespace (and not attached):
##  [1] tidyselect_0.2.3            purrr_0.2.5                
##  [3] reshape2_1.4.3              haven_1.1.1                
##  [5] carData_3.0-1               colorspace_1.3-2           
##  [7] htmltools_0.3.6             yaml_2.1.19                
##  [9] utf8_1.1.3                  rlang_0.2.2                
## [11] pillar_1.2.1                foreign_0.8-69             
## [13] glue_1.3.0                  withr_2.1.1                
## [15] readxl_1.0.0                bindr_0.1.1                
## [17] plyr_1.8.4                  stringr_1.3.1              
## [19] munsell_0.5.0               gtable_0.2.0               
## [21] cellranger_1.1.0            zip_1.0.0                  
## [23] evaluate_0.10.1             labeling_0.3               
## [25] rio_0.5.10                  forcats_0.3.0              
## [27] curl_3.1                    markdown_0.8               
## [29] highr_0.6                   Rttf2pt1_1.3.6             
## [31] Rcpp_0.12.18                backports_1.1.2            
## [33] scales_1.0.0                TabularManifest_0.1-16.9003
## [35] abind_1.4-5                 testit_0.8                 
## [37] digest_0.6.18               stringi_1.1.7              
## [39] openxlsx_4.1.0              rprojroot_1.3-2            
## [41] cowplot_0.9.3               cli_1.0.0                  
## [43] tools_3.4.4                 lazyeval_0.2.1             
## [45] tibble_1.4.2                crayon_1.3.4               
## [47] car_3.0-0                   extrafontdb_1.0            
## [49] pkgconfig_2.0.1             data.table_1.10.4-3        
## [51] assertthat_0.2.0            rmarkdown_1.8              
## [53] rstudioapi_0.7              R6_2.2.2                   
## [55] compiler_3.4.4
```

```r
Sys.time()
```

```
## [1] "2018-10-30 13:48:51 PDT"
```

