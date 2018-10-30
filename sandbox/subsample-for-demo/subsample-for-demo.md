---
title: "SubSample for Demonstrations"
date: "Date: 2018-10-29"
output: 
  html_document: 
    keep_md: yes
    toc: yes
    toc_float: yes
    output:
    highlight: tango
    theme: spacelab
---
This report narrates the creation of a subsample from data set provided during the IPDLN-2018 Hackathon. This subsample is meant FOR DEMONSTRATION PURPOSES ONLY and does not claim accuracy of patterns in the underlying phenomena. 
<!--  Set the working directory to the repository's base directory; this assumes the report is nested inside of two directories.-->


<!-- Set the report-wide options, and point to the external code file. -->


# load sources
<!-- Load the sources.  Suppress the output when loading sources. --> 

```r
# Call `base::source()` on any repo file that defines functions needed below.  
# Ideally, no real operations are performed.
base::source("./scripts/graphing/graph-logistic.R")
base::source("./scripts/graphing/graph-presets.R") # fonts, colors, themes 
```
# load packages
<!-- Load 'sourced' R files.  Suppress the output when loading packages. --> 

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

# declare globals
<!-- Load any global functions and variables declared in the R file.  Suppress the output. --> 

```r
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
```

<!-- Declare any global functions specific to a Rmd output.  Suppress the output. --> 

```r
# Put presentation-specific code in here.  It doesn't call a chunk in the codebehind file.
#   It should be rare (and used cautiously), but sometimes it makes sense to include code in Rmd 
#   that doesn't live in the codebehind R file.
```
# load data
<!-- Load the datasets.   -->

```r
ds0      <- readRDS(path_input_micro) #  product of `./manipulation/0-greeter.R`
ls_guide <- readRDS(path_input_meta) #  product of `./manipulation/0-metador.R`
```
# tweek data
<!-- Tweak the datasets.   -->

```r
ds0 %>% dplyr::glimpse()
```

```
Observations: 4,346,649
Variables: 34
$ ABDERR             <fct> Non-Aboriginal Identity, Non-Aboriginal Identity, Non-Aboriginal Ide...
$ ABIDENT            <fct> Non-Aboriginal identity population, Non-Aboriginal identity populati...
$ ADIFCLTY           <fct> No, No, No, No, No, No, No, No, No, No, No, No, No, No, No, No, No, ...
$ CITSM              <fct> Not a Canadian citizen by birth, Not a Canadian citizen by birth, Ca...
$ COWD               <fct> Paid Worker - Working for wages, salary, tips or commission, Paid Wo...
$ DISABFL            <fct> No, No, Yes, sometimes, No, No, No, No, No, Yes, sometimes, No, No, ...
$ DISABIL            <fct> No difficulty with daily activities and no reduced activities, No di...
$ DVISMIN            <fct> Not a visible minority, Not a visible minority, Not a visible minori...
$ FOL                <fct> English only, English only, French only, English only, English only,...
$ FPTIM              <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, ...
$ GENSTPOB           <fct> 1st generation - Respondent born outside Canada, 1st generation - Re...
$ HCDD               <fct> Bachelors degree, University certificate or diploma below bachelor l...
$ IMMDER             <fct> Immigrants, Immigrants, Non-immigrants, Non-immigrants, Non-immigran...
$ LOINCA             <fct> non-low income, non-low income, non-low income, non-low income, non-...
$ LOINCB             <fct> non-low income, non-low income, non-low income, low income, non-low ...
$ MARST              <fct> Legally married (and not separated), Legally married (and not separa...
$ NOCSBRD            <fct> D Health occupations, D Health occupations, Not Applicable, F Occupa...
$ OLN                <fct> Both English and French, English only, French only, Both English and...
$ POBDER             <fct>  Born outside Canada ,  Born outside Canada ,  Born in province of r...
$ SEX                <fct> Female, Female, Female, Female, Male, Male, Female, Male, Male, Fema...
$ TRMODE             <fct> Car, truck, van as driver, Car, truck, van as driver, Not applicable...
$ RPAIR              <fct> Yes, major repairs are needed , No, only regular maintenance, No, on...
$ PR                 <fct> Ontario, Manitoba, Quebec, British Columbia, Alberta, New Brunswick,...
$ RUINDFG            <fct> Rural, Rural, Urban, Urban, Urban, Rural, Rural, Urban, Urban, Rural...
$ d_licoratio_da_bef <fct> 5th  decile, 3rd  decile, 3rd  decile, 2nd  decile, 9th  decile, 7th...
$ S_DEAD             <fct> Not dead, Not dead, Dead, Not dead, Not dead, Not dead, Not dead, No...
$ EFCNT_PP_R         <fct> 4 family members, 5 family members, 2 family members, 4 family membe...
$ AGE_IMM_R_group    <fct> 35 to < 40, 25 to < 30, Non-immigrants and institutional residents, ...
$ COD1               <fct> Did not die, Did not die, Noncommunicable diseases, Did not die, Did...
$ COD2               <fct> Did not die, Did not die, Other causes of death or cause of death no...
$ DPOB11N            <fct> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, Aust...
$ KID_group          <fct> one or two children, three or more children, no children, one or two...
$ YRIM_group         <fct> 2002 or later, 2002 or later, Non-immigrants and institutional resid...
$ age_group          <fct> 40 to 44, 30 to 34, 65 to 69, 19 to 24, 55 to 59, 70 to 74, 30 to 34...
```

```r
# create an explicity person identifier
ds0 <-  ds0 %>% 
  tibble::rownames_to_column("person_id") %>% 
  dplyr::mutate( person_id = as.integer(person_id)) %>% 
  dplyr::select(person_id, dplyr::everything())
```
# inspect data

```r
ds0 %>% dplyr::glimpse(50)
```

```
Observations: 4,346,649
Variables: 35
$ person_id          <int> 1, 2, 3, 4, 5, 6, ...
$ ABDERR             <fct> Non-Aboriginal Ide...
$ ABIDENT            <fct> Non-Aboriginal ide...
$ ADIFCLTY           <fct> No, No, No, No, No...
$ CITSM              <fct> Not a Canadian cit...
$ COWD               <fct> Paid Worker - Work...
$ DISABFL            <fct> No, No, Yes, somet...
$ DISABIL            <fct> No difficulty with...
$ DVISMIN            <fct> Not a visible mino...
$ FOL                <fct> English only, Engl...
$ FPTIM              <fct> NA, NA, NA, NA, NA...
$ GENSTPOB           <fct> 1st generation - R...
$ HCDD               <fct> Bachelors degree, ...
$ IMMDER             <fct> Immigrants, Immigr...
$ LOINCA             <fct> non-low income, no...
$ LOINCB             <fct> non-low income, no...
$ MARST              <fct> Legally married (a...
$ NOCSBRD            <fct> D Health occupatio...
$ OLN                <fct> Both English and F...
$ POBDER             <fct>  Born outside Cana...
$ SEX                <fct> Female, Female, Fe...
$ TRMODE             <fct> Car, truck, van as...
$ RPAIR              <fct> Yes, major repairs...
$ PR                 <fct> Ontario, Manitoba,...
$ RUINDFG            <fct> Rural, Rural, Urba...
$ d_licoratio_da_bef <fct> 5th  decile, 3rd  ...
$ S_DEAD             <fct> Not dead, Not dead...
$ EFCNT_PP_R         <fct> 4 family members, ...
$ AGE_IMM_R_group    <fct> 35 to < 40, 25 to ...
$ COD1               <fct> Did not die, Did n...
$ COD2               <fct> Did not die, Did n...
$ DPOB11N            <fct> NA, NA, NA, NA, NA...
$ KID_group          <fct> one or two childre...
$ YRIM_group         <fct> 2002 or later, 200...
$ age_group          <fct> 40 to 44, 30 to 34...
```
# custom functions

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
```
# create subsample

```r
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
```

```
$Alberta
 [1] "person_id"          "ABDERR"             "ABIDENT"            "ADIFCLTY"          
 [5] "CITSM"              "COWD"               "DISABFL"            "DISABIL"           
 [9] "DVISMIN"            "FOL"                "FPTIM"              "GENSTPOB"          
[13] "HCDD"               "IMMDER"             "LOINCA"             "LOINCB"            
[17] "MARST"              "NOCSBRD"            "OLN"                "POBDER"            
[21] "SEX"                "TRMODE"             "RPAIR"              "PR"                
[25] "RUINDFG"            "d_licoratio_da_bef" "S_DEAD"             "EFCNT_PP_R"        
[29] "AGE_IMM_R_group"    "COD1"               "COD2"               "DPOB11N"           
[33] "KID_group"          "YRIM_group"         "age_group"         

$`British Columbia`
 [1] "person_id"          "ABDERR"             "ABIDENT"            "ADIFCLTY"          
 [5] "CITSM"              "COWD"               "DISABFL"            "DISABIL"           
 [9] "DVISMIN"            "FOL"                "FPTIM"              "GENSTPOB"          
[13] "HCDD"               "IMMDER"             "LOINCA"             "LOINCB"            
[17] "MARST"              "NOCSBRD"            "OLN"                "POBDER"            
[21] "SEX"                "TRMODE"             "RPAIR"              "PR"                
[25] "RUINDFG"            "d_licoratio_da_bef" "S_DEAD"             "EFCNT_PP_R"        
[29] "AGE_IMM_R_group"    "COD1"               "COD2"               "DPOB11N"           
[33] "KID_group"          "YRIM_group"         "age_group"         

$Ontario
 [1] "person_id"          "ABDERR"             "ABIDENT"            "ADIFCLTY"          
 [5] "CITSM"              "COWD"               "DISABFL"            "DISABIL"           
 [9] "DVISMIN"            "FOL"                "FPTIM"              "GENSTPOB"          
[13] "HCDD"               "IMMDER"             "LOINCA"             "LOINCB"            
[17] "MARST"              "NOCSBRD"            "OLN"                "POBDER"            
[21] "SEX"                "TRMODE"             "RPAIR"              "PR"                
[25] "RUINDFG"            "d_licoratio_da_bef" "S_DEAD"             "EFCNT_PP_R"        
[29] "AGE_IMM_R_group"    "COD1"               "COD2"               "DPOB11N"           
[33] "KID_group"          "YRIM_group"         "age_group"         

$Quebec
 [1] "person_id"          "ABDERR"             "ABIDENT"            "ADIFCLTY"          
 [5] "CITSM"              "COWD"               "DISABFL"            "DISABIL"           
 [9] "DVISMIN"            "FOL"                "FPTIM"              "GENSTPOB"          
[13] "HCDD"               "IMMDER"             "LOINCA"             "LOINCB"            
[17] "MARST"              "NOCSBRD"            "OLN"                "POBDER"            
[21] "SEX"                "TRMODE"             "RPAIR"              "PR"                
[25] "RUINDFG"            "d_licoratio_da_bef" "S_DEAD"             "EFCNT_PP_R"        
[29] "AGE_IMM_R_group"    "COD1"               "COD2"               "DPOB11N"           
[33] "KID_group"          "YRIM_group"         "age_group"         
```

```r
# overwrite, making it a stratified sample across selected provinces (same size in each)
ds1 <- plyr::ldply(dmls,data.frame,.id = "PR")
ds1 %>% dplyr::glimpse(50)
```

```
Observations: 40,000
Variables: 35
$ person_id          <int> 273, 331, 377, 564...
$ ABDERR             <fct> Non-Aboriginal Ide...
$ ABIDENT            <fct> Non-Aboriginal ide...
$ ADIFCLTY           <fct> Yes, often, No, No...
$ CITSM              <fct> Canadian citizen b...
$ COWD               <fct> Not applicable, Pa...
$ DISABFL            <fct> Yes, often, No, No...
$ DISABIL            <fct> Difficulty with da...
$ DVISMIN            <fct> Not a visible mino...
$ FOL                <fct> English only, Engl...
$ FPTIM              <fct> NA, NA, NA, NA, NA...
$ GENSTPOB           <fct> 1st generation - R...
$ HCDD               <fct> None, High school ...
$ IMMDER             <fct> Immigrants, Immigr...
$ LOINCA             <fct> non-low income, no...
$ LOINCB             <fct> non-low income, no...
$ MARST              <fct> Widowed, Never leg...
$ NOCSBRD            <fct> Not Applicable, G ...
$ OLN                <fct> English only, Engl...
$ POBDER             <fct>  Born outside Cana...
$ SEX                <fct> Female, Female, Fe...
$ TRMODE             <fct> Not applicable, Pu...
$ RPAIR              <fct> Yes, minor repairs...
$ PR                 <fct> Alberta, Alberta, ...
$ RUINDFG            <fct> Urban, Urban, Urba...
$ d_licoratio_da_bef <fct> 3rd  decile, 6th  ...
$ S_DEAD             <fct> Dead, Not dead, No...
$ EFCNT_PP_R         <fct> 2 family members, ...
$ AGE_IMM_R_group    <fct>  5 to < 10, 15 to ...
$ COD1               <fct> Noncommunicable di...
$ COD2               <fct> Other causes of de...
$ DPOB11N            <fct> NA, Australia, New...
$ KID_group          <fct> no children, one o...
$ YRIM_group         <fct> 1986 or earlier, 1...
$ age_group          <fct> 90 and older, 40 t...
```

```r
ds1 %>% dplyr::group_by(PR) %>% 
  dplyr::summarise(n_people = length(unique(person_id)))
```

```
# A tibble: 4 x 2
  PR               n_people
  <fct>               <int>
1 Quebec              10000
2 Ontario             10000
3 Alberta             10000
4 British Columbia    10000
```

```r
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
```
# save to disk

```r
saveRDS(ds2, "./data-unshared/derived/simulated_subsample.rds")
```



# Session Information
For the sake of documentation and reproducibility, the current report was rendered on a system using the following software.

```
Report rendered by koval at 2018-10-29, 15:36 -0700 in 8 seconds.
```

```
R version 3.4.4 (2018-03-15)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows >= 8 x64 (build 9200)

Matrix products: default

locale:
[1] LC_COLLATE=English_United States.1252  LC_CTYPE=English_United States.1252   
[3] LC_MONETARY=English_United States.1252 LC_NUMERIC=C                          
[5] LC_TIME=English_United States.1252    

attached base packages:
[1] grid      stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] knitr_1.20         bindrcpp_0.2.2     dplyr_0.7.6        magrittr_1.5       RColorBrewer_1.1-2
[6] dichromat_2.0-0    ggplot2_3.0.0      extrafont_0.17    

loaded via a namespace (and not attached):
 [1] tidyselect_0.2.3            purrr_0.2.5                 haven_1.1.1                
 [4] carData_3.0-1               colorspace_1.3-2            htmltools_0.3.6            
 [7] yaml_2.1.19                 utf8_1.1.3                  rlang_0.2.2                
[10] pillar_1.2.1                foreign_0.8-69              glue_1.3.0                 
[13] withr_2.1.1                 pryr_0.1.4                  readxl_1.0.0               
[16] bindr_0.1.1                 plyr_1.8.4                  stringr_1.3.1              
[19] munsell_0.5.0               gtable_0.2.0                cellranger_1.1.0           
[22] zip_1.0.0                   evaluate_0.10.1             codetools_0.2-15           
[25] rio_0.5.10                  forcats_0.3.0               curl_3.1                   
[28] Rttf2pt1_1.3.6              highr_0.6                   Rcpp_0.12.18               
[31] readr_1.1.1                 backports_1.1.2             scales_1.0.0               
[34] TabularManifest_0.1-16.9003 abind_1.4-5                 testit_0.8                 
[37] hms_0.4.1                   digest_0.6.18               stringi_1.1.7              
[40] openxlsx_4.1.0              rprojroot_1.3-2             cowplot_0.9.3              
[43] cli_1.0.0                   tools_3.4.4                 lazyeval_0.2.1             
[46] tibble_1.4.2                crayon_1.3.4                extrafontdb_1.0            
[49] car_3.0-0                   pkgconfig_2.0.1             data.table_1.10.4-3        
[52] assertthat_0.2.0            rmarkdown_1.8               rstudioapi_0.7             
[55] R6_2.2.2                    compiler_3.4.4             
```
