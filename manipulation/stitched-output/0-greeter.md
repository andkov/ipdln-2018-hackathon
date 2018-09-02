



This report was automatically generated with the R package **knitr**
(version 1.20).


```r
# this script imports the raw data described in this shared document 
# https://drive.google.com/file/d/10idMxy8eX8nTHr6wr2Q40x4XOP3Y5ck7/view
# and prepares a state of data used as a standard point of departure for any subsequent reproducible analytics

# Lines before the first chunk are invisible to Rmd/Rnw callers
# Run to stitch a tech report of this script (used only in RStudio)
# knitr::stitch_rmd(
#   script = "./manipulation/0-greeter.R",
#   output = "./manipulation/stitched-output/0-greeter.md"
# )
# this command is typically executed by the ./manipulation/governor.R

rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. 
# This is not called by knitr, because it's above the first chunk.
cat("\f") # clear console when working in RStudio
```



```r
library(magrittr) #Pipes
requireNamespace("dplyr", quietly=TRUE)
```


```r
# link to the source of the location mapping
path_input_micro <- "./data-unshared/raw/ipdln_synth_final.csv"
path_input_meta  <- "./data-unshared/derived/ls_guide.rds"

# test whether the file exists / the link is good
testit::assert("File does not exist", base::file.exists(path_input_micro))
testit::assert("File does not exist", base::file.exists(path_input_meta))

# declare where you will store the product of this script
path_save <- "./data-unshared/derived/0-greeted.rds"

# See definitions of commonly  used objects in:
source("./manipulation/object-glossary.R")   # object definitions
```

```r
# functions, the use of which is localized to this script
# for commonly used function see ./manipulation/function-support.R
```

```r
ds0      <- readr::read_csv(path_input_micro) %>% as.data.frame()
```

```
## Parsed with column specification:
## cols(
##   .default = col_integer()
## )
```

```
## See spec(...) for full column specifications.
```

```r
ls_guide <- readRDS(path_input_meta)
```

```r
# basic inspection
ds0 %>% dplyr::glimpse(50)
```

```
## Observations: 4,346,649
## Variables: 34
## $ ABDERR_synth             <int> 2, 2, 2, 2, ...
## $ ABIDENT_synth            <int> 6, 6, 6, 6, ...
## $ ADIFCLTY_synth           <int> 1, 1, 1, 1, ...
## $ CITSM_synth              <int> 2, 2, 1, 1, ...
## $ COWD_synth               <int> 4, 4, 7, 4, ...
## $ DISABFL_synth            <int> 1, 1, 4, 1, ...
## $ DISABIL_synth            <int> 9, 9, 14, 9,...
## $ DVISMIN_synth            <int> 14, 14, 14, ...
## $ FOL_synth                <int> 1, 1, 2, 1, ...
## $ FPTIM_synth              <int> 1, 1, 3, 2, ...
## $ GENSTPOB_synth           <int> 1, 1, 3, 3, ...
## $ HCDD_synth               <int> 9, 8, 1, 2, ...
## $ IMMDER_synth             <int> 1, 1, 3, 3, ...
## $ LOINCA_synth             <int> 1, 1, 1, 1, ...
## $ LOINCB_synth             <int> 1, 1, 1, 2, ...
## $ MARST_synth              <int> 2, 2, 2, 4, ...
## $ NOCSBRD_synth            <int> 4, 4, 11, 6,...
## $ OLN_synth                <int> 3, 1, 2, 3, ...
## $ POBDER_synth             <int> 3, 3, 1, 1, ...
## $ SEX_synth                <int> 1, 1, 1, 1, ...
## $ TRMODE_synth             <int> 2, 2, 9, 5, ...
## $ RPAIR_synth              <int> 3, 1, 1, 2, ...
## $ PR_synth                 <int> 35, 46, 24, ...
## $ RUINDFG_synth            <int> 1, 1, 2, 2, ...
## $ d_licoratio_da_bef_synth <int> 5, 3, 3, 2, ...
## $ S_DEAD_synth             <int> 2, 2, 1, 2, ...
## $ EFCNT_PP_R_synth         <int> 4, 5, 2, 4, ...
## $ AGE_IMM_R_group_synth    <int> 8, 6, 15, 15...
## $ COD1_synth               <int> 5, 5, 2, 5, ...
## $ COD2_synth               <int> 14, 14, 13, ...
## $ DPOB11N_synth            <int> 4, 2, 1, 1, ...
## $ KID_group_synth          <int> 2, 3, 1, 2, ...
## $ YRIM_group_synth         <int> 1, 1, 6, 6, ...
## $ age_group_synth          <int> 5, 3, 10, 1,...
```

```r
# remove the unnecessary suffix in the name of variables
names(ds0) <- gsub("_synth$", "", names(ds0 ))
names(ds0)
```

```
##  [1] "ABDERR"             "ABIDENT"            "ADIFCLTY"          
##  [4] "CITSM"              "COWD"               "DISABFL"           
##  [7] "DISABIL"            "DVISMIN"            "FOL"               
## [10] "FPTIM"              "GENSTPOB"           "HCDD"              
## [13] "IMMDER"             "LOINCA"             "LOINCB"            
## [16] "MARST"              "NOCSBRD"            "OLN"               
## [19] "POBDER"             "SEX"                "TRMODE"            
## [22] "RPAIR"              "PR"                 "RUINDFG"           
## [25] "d_licoratio_da_bef" "S_DEAD"             "EFCNT_PP_R"        
## [28] "AGE_IMM_R_group"    "COD1"               "COD2"              
## [31] "DPOB11N"            "KID_group"          "YRIM_group"        
## [34] "age_group"
```

```r
# augment the micro data with meta data

# function to augment micro data with meta data
augment_with_meta <- function(
  d,  # a dataframe with the original raw data, prepared by the ./manipulation/0-greeter.R
  l   # a list object with organized meta data, prepared by the ./manipulation/0-metador.R
){
  for(name_i in names(d)){
    # name_i <- "SEX"
    # d_ <- ds0[1:1000,c("SEX","S_DEAD")]
    # l_ <- ls_guide
    d <- d %>% 
      dplyr::rename_("target_variable" = name_i) %>% 
      dplyr::mutate(
        target_variable = factor(
          target_variable, 
          levels = l$item[[name_i]]$levels %>% names(), 
          labels = l$item[[name_i]]$levels
        )
      ) 
    names(d) <- gsub("^target_variable$",name_i, names(d))
    # d1 %>% dplyr::glimpse()
  }
  return(d)
}
# how to use
ds1 <- ds0 %>% augment_with_meta(ls_guide)
ds1 %>% dplyr::glimpse(50)
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
## $ FOL                <fct> English , English ...
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
## $ EFCNT_PP_R         <fct> NA, NA, NA, NA, NA...
## $ AGE_IMM_R_group    <fct> NA, NA, NA, NA, NA...
## $ COD1               <fct> Did not die, Did n...
## $ COD2               <fct> Did not die, Did n...
## $ DPOB11N            <fct> NA, NA, NA, NA, NA...
## $ KID_group          <fct> one or two childre...
## $ YRIM_group         <fct> 2002 or later, 200...
## $ age_group          <fct> 40 to 44, 30 to 34...
```

```r
cat("Save results to ",path_save)
```

```
## Save results to  ./data-unshared/derived/0-greeted.rds
```

```r
saveRDS(ds1, path_save)
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
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] bindrcpp_0.2.2 ggplot2_3.0.0  magrittr_1.5  
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.18       rstudioapi_0.7     knitr_1.20        
##  [4] bindr_0.1.1        hms_0.4.1          tidyselect_0.2.3  
##  [7] munsell_0.5.0      testit_0.7         colorspace_1.3-2  
## [10] R6_2.2.2           rlang_0.2.0        stringr_1.3.1     
## [13] plyr_1.8.4         dplyr_0.7.6        tools_3.4.4       
## [16] grid_3.4.4         gtable_0.2.0       utf8_1.1.3        
## [19] cli_1.0.0          withr_2.1.1        lazyeval_0.2.1    
## [22] yaml_2.1.19        assertthat_0.2.0   tibble_1.4.2      
## [25] crayon_1.3.4       RColorBrewer_1.1-2 purrr_0.2.4       
## [28] readr_1.1.1        evaluate_0.10.1    glue_1.2.0        
## [31] stringi_1.1.7      compiler_3.4.4     pillar_1.2.1      
## [34] scales_1.0.0       pkgconfig_2.0.1
```

```r
Sys.time()
```

```
## [1] "2018-09-01 17:21:47 PDT"
```

