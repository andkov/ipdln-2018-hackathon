



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
path_input <- "./data-unshared/raw/ipdln_synth_final.csv"

# test whether the file exists / the link is good
testit::assert("File does not exist", base::file.exists(path_input))

# declare where you will store the product of this script
path_save <- "./data-unshared/derived/0-greeted.rds"

# See definitions of commonly  used objects in:
source("./manipulation/object-glossary.R")   # object definitions
```

```r
# functions, the use of which is localized to this script

# Count frequencies of unique values in each column (helpful to see scale)
col_freqs <- function(d, pandoc=F){
  for(i in names(d)){
    d %>% 
      group_by_(.dots = i) %>% 
      dplyr::summarize(n = n()) %>% 
      dplyr::arrange(desc(n)) 
    if(pandoc){
      d %>% knitr::kable(format = "pandoc") %>% print()
    }else{
      d %>% print()
    }
  }  
} 
# how to use:
# ds %>% col_freqs()
```

```r
ds0 <- readr::read_csv(path_input ) %>% tibble::as_tibble()
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
# ds0 %>% str() # reveals that columsn has attributes, hidden to avoid clutter
```

```r
# remove attributes of the imported object
attr(ds0, "row.names") <- NULL
attr(ds0, "spec") <- NULL

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
cat("Save results to ",path_save)
```

```
## Save results to  ./data-unshared/derived/0-greeted.rds
```

```r
saveRDS(ds0, path_save)
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
## [1] RColorBrewer_1.1-2 dichromat_2.0-0    ggplot2_2.2.1     
## [4] extrafont_0.17     magrittr_1.5      
## 
## loaded via a namespace (and not attached):
##  [1] Rcpp_0.12.15     Rttf2pt1_1.3.6   knitr_1.20       bindr_0.1       
##  [5] hms_0.4.1        munsell_0.4.3    testit_0.7       colorspace_1.3-2
##  [9] R6_2.2.2         rlang_0.2.0      highr_0.6        plyr_1.8.4      
## [13] stringr_1.3.1    dplyr_0.7.4      tools_3.4.4      gtable_0.2.0    
## [17] extrafontdb_1.0  lazyeval_0.2.1   yaml_2.1.19      assertthat_0.2.0
## [21] tibble_1.4.2     bindrcpp_0.2     readr_1.1.1      glue_1.2.0      
## [25] evaluate_0.10.1  stringi_1.1.7    compiler_3.4.4   pillar_1.2.1    
## [29] scales_0.5.0     markdown_0.8     pkgconfig_2.0.1
```

```r
Sys.time()
```

```
## [1] "2018-09-01 10:13:04 PDT"
```

