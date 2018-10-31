



This report was automatically generated with the R package **knitr**
(version 1.20).


```r
# Run next lint to stitch a tech report of this script (used only in RStudio)
# knitr::stitch_rmd( script = "./reports/technique-demonstration/technique-demonstration.R", output = "./reports/technique-demonstration/stitched_output/technique-demonstration.md" )

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
```

```r
# ds0      <- readRDS(path_input_micro) #  product of `./manipulation/0-greeter.R`
ds0      <- readRDS(path_input_micro) #  product of `./analysis/subsample-for-demo/`
ls_guide <- readRDS(path_input_meta) #  product of `./manipulation/0-metador.R`
```

```r
ds0 %>% dplyr::glimpse(50)
```

```
## Observations: 4,346,649
## Variables: 34
## $ ABDERR             <fct> Non-Aboriginal Ide...
## $ ABIDENT            <fct> Non-Aboriginal ide...
## $ ADIFCLTY           <fct> No, No, No, No, No...
## $ CITSM              <fct> Not a Canadian cit...
## $ COWD               <fct> Paid Worker - Work...
## $ DISABFL            <fct> No, No, Yes, somet...
## $ DISABIL            <fct> No difficulty with...
## $ DVISMIN            <fct> Not a visible mino...
## $ FOL                <fct> English only, Engl...
## $ FPTIM              <fct> NA, NA, NA, NA, NA...
## $ GENSTPOB           <fct> 1st generation - R...
## $ HCDD               <fct> Bachelors degree, ...
## $ IMMDER             <fct> Immigrants, Immigr...
## $ LOINCA             <fct> non-low income, no...
## $ LOINCB             <fct> non-low income, no...
## $ MARST              <fct> Legally married (a...
## $ NOCSBRD            <fct> D Health occupatio...
## $ OLN                <fct> Both English and F...
## $ POBDER             <fct>  Born outside Cana...
## $ SEX                <fct> Female, Female, Fe...
## $ TRMODE             <fct> Car, truck, van as...
## $ RPAIR              <fct> Yes, major repairs...
## $ PR                 <fct> Ontario, Manitoba,...
## $ RUINDFG            <fct> Rural, Rural, Urba...
## $ d_licoratio_da_bef <fct> 5th  decile, 3rd  ...
## $ S_DEAD             <fct> Not dead, Not dead...
## $ EFCNT_PP_R         <fct> 4 family members, ...
## $ AGE_IMM_R_group    <fct> 35 to < 40, 25 to ...
## $ COD1               <fct> Did not die, Did n...
## $ COD2               <fct> Did not die, Did n...
## $ DPOB11N            <fct> NA, NA, NA, NA, NA...
## $ KID_group          <fct> one or two childre...
## $ YRIM_group         <fct> 2002 or later, 200...
## $ age_group          <fct> 40 to 44, 30 to 34...
```

```r
# create an explicity person identifier
ds0 <-  ds0 %>% 
  tibble::rownames_to_column("person_id") %>% 
  dplyr::mutate( person_id = as.integer(person_id)) %>% 
  dplyr::select(person_id, dplyr::everything())
```

```r
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


where_to_store_graphs <- "./reports/technique-demonstration/prints/1/" # female marital educ3 poor_health
# where_to_store_graphs = "./reports/technique-demonstration/prints/2/" # educ3 poor_health first
# where_to_store_graphs = "./reports/technique-demonstration/prints/3/", # other collection of predictors

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
library(dplyr)
# because we need to examine observed values of each predictor
ds0 %>% group_by(PR)        %>% summarize(n = n())
```

```
## # A tibble: 13 x 2
##    PR                              n
##    <fct>                       <int>
##  1 Newfoundland and Labrador   74281
##  2 Prince Edward Island        18372
##  3 Nova Scotia                128755
##  4 New Brunswick              105097
##  5 Quebec                    1047824
##  6 Ontario                   1604077
##  7 Manitoba                   176994
##  8 Saskatchewan               150432
##  9 Alberta                    444249
## 10 British Columbia           557466
## 11 Yukon                        9239
## 12 Northwest Territories       15454
## 13 Nunavut                     14409
```

```r
ds0 %>% group_by(SEX)       %>% summarize(n = n())
```

```
## # A tibble: 2 x 2
##   SEX          n
##   <fct>    <int>
## 1 Female 2242681
## 2 Male   2103968
```

```r
ds0 %>% group_by(MARST)     %>% summarize(n = n())
```

```
## # A tibble: 5 x 2
##   MARST                                      n
##   <fct>                                  <int>
## 1 Divorced                              376637
## 2 Legally married (and not separated)  2304941
## 3 Separated, but still legally married  140009
## 4 Never legally married (single)       1264326
## 5 Widowed                               260736
```

```r
ds0 %>% group_by(HCDD)      %>% summarize(n = n())
```

```
## # A tibble: 13 x 2
##    HCDD                                                                  n
##    <fct>                                                             <int>
##  1 None                                                             9.02e5
##  2 High school graduation certificate or equivalency certificate    1.07e6
##  3 Other trades certificate or diploma                              3.33e5
##  4 Registered apprenticeship certificate                            1.84e5
##  5 College, CEGEP or other non-university certificate or diploma f~ 1.10e5
##  6 College, CEGEP or other non-university certificate or diploma f~ 3.90e5
##  7 College, CEGEP or other non-university certificate or diploma f~ 3.16e5
##  8 University certificate or diploma below bachelor level           2.02e5
##  9 Bachelors degree                                                 5.37e5
## 10 University certificate or diploma above bachelor level           8.94e4
## 11 Degree in medicine, dentistry, veterinary medicine or optometry  2.39e4
## 12 Masters degree                                                   1.57e5
## 13 Earned doctorate degree                                          3.15e4
```

```r
ds0 %>% group_by(ADIFCLTY)  %>% summarize(n = n())
```

```
## # A tibble: 4 x 2
##   ADIFCLTY             n
##   <fct>            <int>
## 1 No             3610703
## 2 Not stated       54059
## 3 Yes, often      282002
## 4 Yes, sometimes  399885
```

```r
ds0 %>% group_by(DISABFL)   %>% summarize(n = n())
```

```
## # A tibble: 4 x 2
##   DISABFL              n
##   <fct>            <int>
## 1 No             3359763
## 2 Not stated       45969
## 3 Yes, often      423068
## 4 Yes, sometimes  517849
```

```r
ds0 %>% group_by(age_group) %>% summarize(n = n())
```

```
## # A tibble: 15 x 2
##    age_group         n
##    <fct>         <int>
##  1 19 to 24     370193
##  2 25 to 29     357121
##  3 30 to 34     370583
##  4 35 to 39     406491
##  5 40 to 44     479630
##  6 45 to 49     485782
##  7 50 to 54     437395
##  8 55 to 59     388211
##  9 60 to 64     295752
## 10 65 to 69     227771
## 11 70 to 74     192595
## 12 75 to 79     156532
## 13 80 to 84     106865
## 14 85 to 89      51146
## 15 90 and older  20582
```

```r
ds0 %>% group_by(FOL,PR)    %>% summarize(n = n())
```

```
## # A tibble: 52 x 3
## # Groups:   FOL [?]
##    FOL          PR                              n
##    <fct>        <fct>                       <int>
##  1 English only Newfoundland and Labrador   73794
##  2 English only Prince Edward Island        17539
##  3 English only Nova Scotia                123550
##  4 English only New Brunswick               69961
##  5 English only Quebec                     124818
##  6 English only Ontario                   1486333
##  7 English only Manitoba                   168102
##  8 English only Saskatchewan               147337
##  9 English only Alberta                    429295
## 10 English only British Columbia           531644
## # ... with 42 more rows
```

```r
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
```

```
## Observations: 4,346,649
## Variables: 41
## $ person_id          <int> 1, 2, 3, 4, 5, 6, ...
## $ ABDERR             <fct> Non-Aboriginal Ide...
## $ ABIDENT            <fct> Non-Aboriginal ide...
## $ ADIFCLTY           <fct> No, No, No, No, No...
## $ CITSM              <fct> Not a Canadian cit...
## $ COWD               <fct> Paid Worker - Work...
## $ DISABFL            <fct> No, No, Yes, somet...
## $ DISABIL            <fct> No difficulty with...
## $ DVISMIN            <fct> Not a visible mino...
## $ FOL                <fct> English only, Engl...
## $ FPTIM              <fct> NA, NA, NA, NA, NA...
## $ GENSTPOB           <fct> 1st generation - R...
## $ HCDD               <fct> Bachelors degree, ...
## $ IMMDER             <fct> Immigrants, Immigr...
## $ LOINCA             <fct> non-low income, no...
## $ LOINCB             <fct> non-low income, no...
## $ MARST              <fct> Legally married (a...
## $ NOCSBRD            <fct> D Health occupatio...
## $ OLN                <fct> English only, Engl...
## $ POBDER             <fct>  Born outside Cana...
## $ SEX                <fct> Female, Female, Fe...
## $ TRMODE             <fct> Car, truck, van as...
## $ RPAIR              <fct> Yes, major repairs...
## $ PR                 <fct> Ontario, Manitoba,...
## $ RUINDFG            <fct> Rural, Rural, Urba...
## $ d_licoratio_da_bef <fct> 5th  decile, 3rd  ...
## $ S_DEAD             <fct> Not dead, Not dead...
## $ EFCNT_PP_R         <fct> 4 family members, ...
## $ AGE_IMM_R_group    <fct> 35 to < 40, 25 to ...
## $ COD1               <fct> Did not die, Did n...
## $ COD2               <fct> Did not die, Did n...
## $ DPOB11N            <fct> NA, NA, NA, NA, NA...
## $ KID_group          <fct> one or two childre...
## $ YRIM_group         <fct> 2002 or later, 200...
## $ age_group          <fct> 40, 30, 65, 19, 55...
## $ female             <fct> TRUE, TRUE, TRUE, ...
## $ marital            <fct> mar_cohab, mar_coh...
## $ educ5              <fct> college, college, ...
## $ educ3              <fct> more than high sch...
## $ poor_health        <fct> FALSE, FALSE, FALS...
## $ age_group_low      <fct> 40, 30, 65, 19, 55...
```

```r
# # because we want/need to inspect newly created variables
ds1 %>% group_by(educ3) %>% summarize(n = n())
```

```
## # A tibble: 3 x 2
##   educ3                       n
##   <fct>                   <int>
## 1 less than high school  902326
## 2 high school           1403807
## 3 more than high school 2040516
```

```r
ds1 %>% group_by(educ5) %>% summarize(n = n())
```

```
## # A tibble: 5 x 2
##   educ5                       n
##   <fct>                   <int>
## 1 less then high school  902326
## 2 high school           1587347
## 3 college               1555485
## 4 graduate               269945
## 5 Dr.                     31546
```

```r
ds1 %>% group_by(FOL)   %>% summarize(n = n())
```

```
## # A tibble: 4 x 2
##   FOL                              n
##   <fct>                        <int>
## 1 Neither English nor French   64633
## 2 French only                1032652
## 3 English only               3209323
## 4 Both English and French      40041
```

```r
# reminder: we use `ls_guide` to lookup data codebook
ls_guide$item$IMMDER
```

```
## $levels
##                         1                         2 
##              "Immigrants" "Non-permanent residents" 
##                         3 
##          "Non-immigrants" 
## 
## $label
## [1] "Immigration status"
## 
## $description
## [1] "Immigration status: Indicates whether the respondent is a non-immigrant, an immigrant or a non-permanent resident."
```

```r
ls_guide$item$GENSTPOB
```

```
## $levels
##                                                                                1 
##                                "1st generation - Respondent born outside Canada" 
##                                                                                2 
## "2nd generation - Respondent born in Canada of at least one foreign-born parent" 
##                                                                                3 
##     "3rd generation - Respondent born in Canada and both parents born in Canada" 
## 
## $label
## [1] "Generation in Canada"
## 
## $description
## [1] "Generation status: Refers to the generational status of the respondent, that is, 1st generation, 2nd generation or 3rd generation or more.Generation status is derived from place of birth of respondent, place of birth of father and place of birth of mother."
```

```r
# define the scope of the exploration
selected_provinces <- c("Alberta","British Columbia", "Ontario", "Quebec")
sample_size = 10000

# because we want to focus on a meaningful sample: first-generation immigrants 
ds2 <- ds1 %>% 
  dplyr::filter(PR %in% selected_provinces) %>% 
  dplyr::filter(IMMDER   == "Immigrants") %>% 
  dplyr::filter(GENSTPOB == "1st generation - Respondent born outside Canada") #%>% 
# get_a_subsample(sample_size) # use when need get representative sample across provinces

#create samples of the same size from each  province
dmls <- list() # dummy list (dmls) to populate during the loop
for(province_i in selected_provinces){
  # province_i = "British Columbia" # for example
  dmls[[province_i]] <-  ds2 %>%
    dplyr::filter(PR == province_i) %>% 
    get_a_subsample(sample_size) # see `define-utility-functions` chunk
}
lapply(dmls, names) # view the contents of the list object
```

```
## $Alberta
##  [1] "person_id"          "ABDERR"             "ABIDENT"           
##  [4] "ADIFCLTY"           "CITSM"              "COWD"              
##  [7] "DISABFL"            "DISABIL"            "DVISMIN"           
## [10] "FOL"                "FPTIM"              "GENSTPOB"          
## [13] "HCDD"               "IMMDER"             "LOINCA"            
## [16] "LOINCB"             "MARST"              "NOCSBRD"           
## [19] "OLN"                "POBDER"             "SEX"               
## [22] "TRMODE"             "RPAIR"              "PR"                
## [25] "RUINDFG"            "d_licoratio_da_bef" "S_DEAD"            
## [28] "EFCNT_PP_R"         "AGE_IMM_R_group"    "COD1"              
## [31] "COD2"               "DPOB11N"            "KID_group"         
## [34] "YRIM_group"         "age_group"          "female"            
## [37] "marital"            "educ5"              "educ3"             
## [40] "poor_health"        "age_group_low"     
## 
## $`British Columbia`
##  [1] "person_id"          "ABDERR"             "ABIDENT"           
##  [4] "ADIFCLTY"           "CITSM"              "COWD"              
##  [7] "DISABFL"            "DISABIL"            "DVISMIN"           
## [10] "FOL"                "FPTIM"              "GENSTPOB"          
## [13] "HCDD"               "IMMDER"             "LOINCA"            
## [16] "LOINCB"             "MARST"              "NOCSBRD"           
## [19] "OLN"                "POBDER"             "SEX"               
## [22] "TRMODE"             "RPAIR"              "PR"                
## [25] "RUINDFG"            "d_licoratio_da_bef" "S_DEAD"            
## [28] "EFCNT_PP_R"         "AGE_IMM_R_group"    "COD1"              
## [31] "COD2"               "DPOB11N"            "KID_group"         
## [34] "YRIM_group"         "age_group"          "female"            
## [37] "marital"            "educ5"              "educ3"             
## [40] "poor_health"        "age_group_low"     
## 
## $Ontario
##  [1] "person_id"          "ABDERR"             "ABIDENT"           
##  [4] "ADIFCLTY"           "CITSM"              "COWD"              
##  [7] "DISABFL"            "DISABIL"            "DVISMIN"           
## [10] "FOL"                "FPTIM"              "GENSTPOB"          
## [13] "HCDD"               "IMMDER"             "LOINCA"            
## [16] "LOINCB"             "MARST"              "NOCSBRD"           
## [19] "OLN"                "POBDER"             "SEX"               
## [22] "TRMODE"             "RPAIR"              "PR"                
## [25] "RUINDFG"            "d_licoratio_da_bef" "S_DEAD"            
## [28] "EFCNT_PP_R"         "AGE_IMM_R_group"    "COD1"              
## [31] "COD2"               "DPOB11N"            "KID_group"         
## [34] "YRIM_group"         "age_group"          "female"            
## [37] "marital"            "educ5"              "educ3"             
## [40] "poor_health"        "age_group_low"     
## 
## $Quebec
##  [1] "person_id"          "ABDERR"             "ABIDENT"           
##  [4] "ADIFCLTY"           "CITSM"              "COWD"              
##  [7] "DISABFL"            "DISABIL"            "DVISMIN"           
## [10] "FOL"                "FPTIM"              "GENSTPOB"          
## [13] "HCDD"               "IMMDER"             "LOINCA"            
## [16] "LOINCB"             "MARST"              "NOCSBRD"           
## [19] "OLN"                "POBDER"             "SEX"               
## [22] "TRMODE"             "RPAIR"              "PR"                
## [25] "RUINDFG"            "d_licoratio_da_bef" "S_DEAD"            
## [28] "EFCNT_PP_R"         "AGE_IMM_R_group"    "COD1"              
## [31] "COD2"               "DPOB11N"            "KID_group"         
## [34] "YRIM_group"         "age_group"          "female"            
## [37] "marital"            "educ5"              "educ3"             
## [40] "poor_health"        "age_group_low"
```

```r
# OVERWRITE, making it a stratified sample across selected provinces (same size in each)
ds2 <- plyr::ldply(dmls,data.frame,.id = "PR")

# inspect the created data set 
ds2 %>% dplyr::glimpse(50)
```

```
## Observations: 40,000
## Variables: 41
## $ person_id          <int> 107, 1213, 1299, 1...
## $ ABDERR             <fct> Non-Aboriginal Ide...
## $ ABIDENT            <fct> Non-Aboriginal ide...
## $ ADIFCLTY           <fct> No, No, No, No, No...
## $ CITSM              <fct> Canadian citizen b...
## $ COWD               <fct> Paid Worker - Work...
## $ DISABFL            <fct> No, No, No, No, Ye...
## $ DISABIL            <fct> No difficulty with...
## $ DVISMIN            <fct> Not a visible mino...
## $ FOL                <fct> English only, Engl...
## $ FPTIM              <fct> NA, NA, NA, NA, NA...
## $ GENSTPOB           <fct> 1st generation - R...
## $ HCDD               <fct> College, CEGEP or ...
## $ IMMDER             <fct> Immigrants, Immigr...
## $ LOINCA             <fct> non-low income, no...
## $ LOINCB             <fct> non-low income, no...
## $ MARST              <fct> Never legally marr...
## $ NOCSBRD            <fct> G Sales and servic...
## $ OLN                <fct> English only, Engl...
## $ POBDER             <fct>  Born outside Cana...
## $ SEX                <fct> Female, Female, Fe...
## $ TRMODE             <fct> Car, truck, van as...
## $ RPAIR              <fct> No, only regular m...
## $ PR                 <fct> Alberta, Alberta, ...
## $ RUINDFG            <fct> Urban, Urban, Urba...
## $ d_licoratio_da_bef <fct> 8th  decile, 8th  ...
## $ S_DEAD             <fct> Not dead, Not dead...
## $ EFCNT_PP_R         <fct> 2 family members, ...
## $ AGE_IMM_R_group    <fct>  5 to < 10,  5 to ...
## $ COD1               <fct> Did not die, Did n...
## $ COD2               <fct> Did not die, Did n...
## $ DPOB11N            <fct> NA, NA, Australia,...
## $ KID_group          <fct> no children, one o...
## $ YRIM_group         <fct> 1986 or earlier, 1...
## $ age_group          <fct> 35, 45, 75, 55, 55...
## $ female             <fct> TRUE, TRUE, TRUE, ...
## $ marital            <fct> single, sep_divorc...
## $ educ5              <fct> college, less then...
## $ educ3              <fct> more than high sch...
## $ poor_health        <fct> FALSE, FALSE, FALS...
## $ age_group_low      <fct> 35, 45, 75, 55, 55...
```

```r
ds2 %>% dplyr::group_by(PR) %>% 
  dplyr::summarise(n_people = length(unique(person_id)))
```

```
## # A tibble: 4 x 2
##   PR               n_people
##   <fct>               <int>
## 1 Quebec              10000
## 2 Ontario             10000
## 3 Alberta             10000
## 4 British Columbia    10000
```

```r
# for the sake of modularization, create a data set that will passed to modeling
ds_for_modeling <- ds2 %>% 
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
```

```r
# define the model equation 
equation_string <- paste0(
  "dv ~ -1 + PR + age_group + female + marital + educ3 + poor_health + FOL"
  ) 
equation_formula <- as.formula(equation_string)
print(equation_formula, showEnv = FALSE)
```

```
## dv ~ -1 + PR + age_group + female + marital + educ3 + poor_health + 
##     FOL
```

```r
# pass model specification to the estimation routine
model_solution <- glm(
  equation_formula,
  data   = ds_for_modeling, 
  family = binomial(link="logit")
) 
# inspect model results
equation_formula # because we must see equation!
```

```
## dv ~ -1 + PR + age_group + female + marital + educ3 + poor_health + 
##     FOL
```

```r
model_solution %>% summary()
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
model_solution %>% coefficients() %>% round(2)
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
# ds_for_modeling$dv_p <- predict(model_solution) # fast check
```

```r
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
  "call"              = equation_string
  ,"summary"          = model_solution %>% summary()
  ,"coefficients"     = model_solution %>% stats::coefficients()
  ,"predicted_values" = ds_predicted
)
saveRDS(ls_model, "./data-public/derived/technique-demonstration/ls_model.rds")
# the script can be continutued in
# `./reports/technique-demonstrations/graphing-phase-demo.R`
# without relying on the raw data
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
## [1] "./reports/technique-demonstration/prints/1/g0.png"
## [2] "./reports/technique-demonstration/prints/1/g1.png"
## [3] "./reports/technique-demonstration/prints/1/g2.png"
## [4] "./reports/technique-demonstration/prints/1/g3.png"
## [5] "./reports/technique-demonstration/prints/1/g4.png"
## [6] "./reports/technique-demonstration/prints/1/g5.png"
## [7] "./reports/technique-demonstration/prints/1/g6.png"
```

```r
# temp hack: so that older code doesnot break:
eq_global_string <- equation_string
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

<img src="figure/technique-demonstration-Rmdprint-display-0-1.png" title="plot of chunk print-display-0" alt="plot of chunk print-display-0" style="display: block; margin: auto;" />

```r
g0 %>%  quick_save(name = "g0") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)
```

```
## [1] "./reports/technique-demonstration/prints/1/g0.png"
## [2] "./reports/technique-demonstration/prints/1/g1.png"
## [3] "./reports/technique-demonstration/prints/1/g2.png"
## [4] "./reports/technique-demonstration/prints/1/g3.png"
## [5] "./reports/technique-demonstration/prints/1/g4.png"
## [6] "./reports/technique-demonstration/prints/1/g5.png"
## [7] "./reports/technique-demonstration/prints/1/g6.png"
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

<img src="figure/technique-demonstration-Rmdprint-display-1-1.png" title="plot of chunk print-display-1" alt="plot of chunk print-display-1" style="display: block; margin: auto;" />

```r
g1 %>%  quick_save(name = "g1") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)
```

```
## [1] "./reports/technique-demonstration/prints/1/g0.png"
## [2] "./reports/technique-demonstration/prints/1/g1.png"
## [3] "./reports/technique-demonstration/prints/1/g2.png"
## [4] "./reports/technique-demonstration/prints/1/g3.png"
## [5] "./reports/technique-demonstration/prints/1/g4.png"
## [6] "./reports/technique-demonstration/prints/1/g5.png"
## [7] "./reports/technique-demonstration/prints/1/g6.png"
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

<img src="figure/technique-demonstration-Rmdprint-display-2-1.png" title="plot of chunk print-display-2" alt="plot of chunk print-display-2" style="display: block; margin: auto;" />

```r
g2 %>%  quick_save(name = "g2") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)
```

```
## [1] "./reports/technique-demonstration/prints/1/g0.png"
## [2] "./reports/technique-demonstration/prints/1/g1.png"
## [3] "./reports/technique-demonstration/prints/1/g2.png"
## [4] "./reports/technique-demonstration/prints/1/g3.png"
## [5] "./reports/technique-demonstration/prints/1/g4.png"
## [6] "./reports/technique-demonstration/prints/1/g5.png"
## [7] "./reports/technique-demonstration/prints/1/g6.png"
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

<img src="figure/technique-demonstration-Rmdprint-display-3-1.png" title="plot of chunk print-display-3" alt="plot of chunk print-display-3" style="display: block; margin: auto;" />

```r
g3 %>%  quick_save(name = "g3") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)
```

```
## [1] "./reports/technique-demonstration/prints/1/g0.png"
## [2] "./reports/technique-demonstration/prints/1/g1.png"
## [3] "./reports/technique-demonstration/prints/1/g2.png"
## [4] "./reports/technique-demonstration/prints/1/g3.png"
## [5] "./reports/technique-demonstration/prints/1/g4.png"
## [6] "./reports/technique-demonstration/prints/1/g5.png"
## [7] "./reports/technique-demonstration/prints/1/g6.png"
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

<img src="figure/technique-demonstration-Rmdprint-display-4-1.png" title="plot of chunk print-display-4" alt="plot of chunk print-display-4" style="display: block; margin: auto;" />

```r
g4 %>%  quick_save(name = "g4") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)
```

```
## [1] "./reports/technique-demonstration/prints/1/g0.png"
## [2] "./reports/technique-demonstration/prints/1/g1.png"
## [3] "./reports/technique-demonstration/prints/1/g2.png"
## [4] "./reports/technique-demonstration/prints/1/g3.png"
## [5] "./reports/technique-demonstration/prints/1/g4.png"
## [6] "./reports/technique-demonstration/prints/1/g5.png"
## [7] "./reports/technique-demonstration/prints/1/g6.png"
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

<img src="figure/technique-demonstration-Rmdprint-display-5-1.png" title="plot of chunk print-display-5" alt="plot of chunk print-display-5" style="display: block; margin: auto;" />

```r
g5 %>%  quick_save(name = "g5") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)
```

```
## [1] "./reports/technique-demonstration/prints/1/g0.png"
## [2] "./reports/technique-demonstration/prints/1/g1.png"
## [3] "./reports/technique-demonstration/prints/1/g2.png"
## [4] "./reports/technique-demonstration/prints/1/g3.png"
## [5] "./reports/technique-demonstration/prints/1/g4.png"
## [6] "./reports/technique-demonstration/prints/1/g5.png"
## [7] "./reports/technique-demonstration/prints/1/g6.png"
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

<img src="figure/technique-demonstration-Rmdprint-display-6-1.png" title="plot of chunk print-display-6" alt="plot of chunk print-display-6" style="display: block; margin: auto;" />

```r
g6 %>%  quick_save(name = "g6") # save to disk
list.files(where_to_store_graphs, full.names = TRUE)
```

```
## [1] "./reports/technique-demonstration/prints/1/g0.png"
## [2] "./reports/technique-demonstration/prints/1/g1.png"
## [3] "./reports/technique-demonstration/prints/1/g2.png"
## [4] "./reports/technique-demonstration/prints/1/g3.png"
## [5] "./reports/technique-demonstration/prints/1/g4.png"
## [6] "./reports/technique-demonstration/prints/1/g5.png"
## [7] "./reports/technique-demonstration/prints/1/g6.png"
```

```r
# cat('<img src="', path, '" alt="', basename(path),'">\n', sep="")
```

```r
# writing to disk was localized during printing
```

```r
# this chunk will be disabled during production of stichted_output
# path_report_1 <- "./reports/technique-demonstration/technique-demonstration.Rmd"
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
## [27] curl_3.1                    highr_0.6                  
## [29] Rttf2pt1_1.3.6              Rcpp_0.12.18               
## [31] backports_1.1.2             scales_1.0.0               
## [33] TabularManifest_0.1-16.9003 abind_1.4-5                
## [35] testit_0.8                  digest_0.6.18              
## [37] stringi_1.1.7               openxlsx_4.1.0             
## [39] rprojroot_1.3-2             cowplot_0.9.3              
## [41] cli_1.0.0                   tools_3.4.4                
## [43] lazyeval_0.2.1              tibble_1.4.2               
## [45] crayon_1.3.4                car_3.0-0                  
## [47] extrafontdb_1.0             pkgconfig_2.0.1            
## [49] data.table_1.10.4-3         assertthat_0.2.0           
## [51] rmarkdown_1.8               rstudioapi_0.7             
## [53] R6_2.2.2                    compiler_3.4.4
```

```r
Sys.time()
```

```
## [1] "2018-10-30 13:43:58 PDT"
```

