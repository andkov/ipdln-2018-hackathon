---
date: "Date: 2018-09-06"
output: 
  html_document: 
    keep_md: yes
    toc: yes
    toc_float: yes
    output:
    highlight: tango
    theme: spacelab
---
This report  conducts the initial exploration of the data set of the banff-2018-hackathon
<!--  Set the working directory to the repository's base directory; this assumes the report is nested inside of two directories.-->


<!-- Set the report-wide options, and point to the external code file. -->


<!-- Load the sources.  Suppress the output when loading sources. --> 


<!-- Load 'sourced' R files.  Suppress the output when loading packages. --> 


<!-- Load any global functions and variables declared in the R file.  Suppress the output. --> 


<!-- Declare any global functions specific to a Rmd output.  Suppress the output. --> 


<!-- Load the datasets.   -->


<!-- Tweak the datasets.   -->

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
$ FOL                <fct> English , English , French , English , English , French , English , ...
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




#group( demographic )

## SEX 
<img src="figure-png/marginals-1.png" width="900px" />

## age_group 
<img src="figure-png/marginals-2.png" width="900px" />

## MARST 
<img src="figure-png/marginals-3.png" width="900px" />

## EFCNT_PP_R 
<img src="figure-png/marginals-4.png" width="900px" />

## KID_group 
<img src="figure-png/marginals-5.png" width="900px" />

## PR 
<img src="figure-png/marginals-6.png" width="900px" />

#group( identity )

## FOL 
<img src="figure-png/marginals-7.png" width="900px" />

## OLN 
<img src="figure-png/marginals-8.png" width="900px" />

## DVISMIN 
<img src="figure-png/marginals-9.png" width="900px" />

## ABDERR 
<img src="figure-png/marginals-10.png" width="900px" />

## ABIDENT 
<img src="figure-png/marginals-11.png" width="900px" />

#group( economic )

## HCDD 
<img src="figure-png/marginals-12.png" width="900px" />

## COWD 
<img src="figure-png/marginals-13.png" width="900px" />

## NOCSBRD 
<img src="figure-png/marginals-14.png" width="900px" />

## TRMODE 
<img src="figure-png/marginals-15.png" width="900px" />

## LOINCA 
<img src="figure-png/marginals-16.png" width="900px" />

## LOINCB 
<img src="figure-png/marginals-17.png" width="900px" />

## d_licoratio_da_bef 
<img src="figure-png/marginals-18.png" width="900px" />

## RUINDFG 
<img src="figure-png/marginals-19.png" width="900px" />

## RPAIR 
<img src="figure-png/marginals-20.png" width="900px" />

#group( immigration )

## POBDER 
<img src="figure-png/marginals-21.png" width="900px" />

## DPOB11N 
<img src="figure-png/marginals-22.png" width="900px" />

## IMMDER 
<img src="figure-png/marginals-23.png" width="900px" />

## AGE_IMM_R_group 
<img src="figure-png/marginals-24.png" width="900px" />

## YRIM_group 
<img src="figure-png/marginals-25.png" width="900px" />

## CITSM 
<img src="figure-png/marginals-26.png" width="900px" />

## GENSTPOB 
<img src="figure-png/marginals-27.png" width="900px" />

#group( health )

## ADIFCLTY 
<img src="figure-png/marginals-28.png" width="900px" />

## DISABFL 
<img src="figure-png/marginals-29.png" width="900px" />

## DISABIL 
<img src="figure-png/marginals-30.png" width="900px" />

## S_DEAD 
<img src="figure-png/marginals-31.png" width="900px" />

## COD1 
<img src="figure-png/marginals-32.png" width="900px" />

## COD2 
<img src="figure-png/marginals-33.png" width="900px" />








# Session Information
For the sake of documentation and reproducibility, the current report was rendered on a system using the following software.

```
Report rendered by koval at 2018-09-06, 07:06 -0700 in 90 seconds.
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
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] bindrcpp_0.2.2 magrittr_1.5   ggplot2_3.0.0  knitr_1.20    

loaded via a namespace (and not attached):
 [1] Rcpp_0.12.18                bindr_0.1.1                 tidyselect_0.2.3           
 [4] munsell_0.5.0               testit_0.7                  viridisLite_0.3.0          
 [7] colorspace_1.3-2            R6_2.2.2                    rlang_0.2.0                
[10] stringr_1.3.1               plyr_1.8.4                  dplyr_0.7.6                
[13] tools_3.4.4                 grid_3.4.4                  gtable_0.2.0               
[16] withr_2.1.1                 htmltools_0.3.6             assertthat_0.2.0           
[19] yaml_2.1.19                 lazyeval_0.2.1              rprojroot_1.3-2            
[22] digest_0.6.15               tibble_1.4.2                RColorBrewer_1.1-2         
[25] purrr_0.2.4                 glue_1.2.0                  evaluate_0.10.1            
[28] rmarkdown_1.8               labeling_0.3                stringi_1.1.7              
[31] compiler_3.4.4              pillar_1.2.1                scales_1.0.0               
[34] backports_1.1.2             TabularManifest_0.1-16.9003 pkgconfig_2.0.1            
```
