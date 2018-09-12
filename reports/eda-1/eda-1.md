---
date: "Date: 2018-09-11"
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
$SEX
$SEX$levels
       1        2 
"Female"   "Male" 

$SEX$label
[1] "Sex"

$SEX$description
[1] "Sex"




## age_group 
<img src="figure-png/marginals-2.png" width="900px" />
$age_group
$age_group$levels
             1              2              3              4              5              6 
    "19 to 24"     "25 to 29"     "30 to 34"     "35 to 39"     "40 to 44"     "45 to 49" 
             7              8              9             10             11             12 
    "50 to 54"     "55 to 59"     "60 to 64"     "65 to 69"     "70 to 74"     "75 to 79" 
            13             14             15 
    "80 to 84"     "85 to 89" "90 and older" 

$age_group$label
[1] "Age"

$age_group$description
[1] "Age: grouped"




## MARST 
<img src="figure-png/marginals-3.png" width="900px" />
$MARST
$MARST$levels
                                     1                                      2 
                            "Divorced"  "Legally married (and not separated)" 
                                     3                                      4 
"Separated, but still legally married"       "Never legally married (single)" 
                                     5 
                             "Widowed" 

$MARST$label
[1] "Marital status"

$MARST$description
[1] "Marital Status: Refers to the legal marital status of the person."




## EFCNT_PP_R 
<img src="figure-png/marginals-4.png" width="900px" />
$EFCNT_PP_R
$EFCNT_PP_R$levels
                          1                           2                           3 
                 "1 person"          "2 family members"          "3 family members" 
                          4                           5                           6 
         "4 family members"          "5 family members"          "6 family members" 
                          7                           8                           9 
         "7 family members"          "8 family members"          "9 family members" 
                         10 
"10 or more family members" 

$EFCNT_PP_R$label
[1] "Family size"

$EFCNT_PP_R$description
[1] "Number of persons in the family: Refers to the number of persons in the individuals family."




## KID_group 
<img src="figure-png/marginals-5.png" width="900px" />
$KID_group
$KID_group$levels
                       1                        2                        3 
           "no children"    "one or two children" "three or more children" 

$KID_group$label
[1] "Number of children"

$KID_group$description
[1] "Children, total number in family (grouped)"




## PR 
<img src="figure-png/marginals-6.png" width="900px" />
$PR
$PR$levels
                         10                          11                          12 
"Newfoundland and Labrador"      "Prince Edward Island"               "Nova Scotia" 
                         13                          24                          35 
            "New Brunswick"                    "Quebec"                   "Ontario" 
                         46                          47                          48 
                 "Manitoba"              "Saskatchewan"                   "Alberta" 
                         59                          60                          61 
         "British Columbia"                     "Yukon"     "Northwest Territories" 
                         62 
                  "Nunavut" 

$PR$label
[1] "Province of residence"

$PR$description
[1] "Province or territory of residence"




#group( identity )

## FOL 
<img src="figure-png/marginals-7.png" width="900px" />
$FOL
$FOL$levels
                           1                            2                            3 
                  "English "                    "French "        "English and French " 
                           4 
"Neither English nor French" 

$FOL$label
[1] "First language"

$FOL$description
[1] "First official language: First official language spoken\t"




## OLN 
<img src="figure-png/marginals-8.png" width="900px" />
$OLN
$OLN$levels
                           1                            2                            3 
              "English only"                "French only"    "Both English and French" 
                           4 
"Neither English nor French" 

$OLN$label
[1] "Conversational language"

$OLN$description
[1] "Official language: Refers to the ability to conduct a conversation in English only, in French only, in both English and French or in none of the official languages of Canada"




## DVISMIN 
<img src="figure-png/marginals-9.png" width="900px" />
$DVISMIN
$DVISMIN$levels
                          1                           2                           3 
                  "Chinese"               "South Asian"                     "Black" 
                          4                           5                           6 
                 "Filipino"            "Latin American"           "Southeast Asian" 
                          7                           8                           9 
                     "Arab"                "West Asian"                    "Korean" 
                         10                          11                          12 
                 "Japanese"  "Visible minority, n.i.e." "Multiple visible minority" 
                         13                          14 
"Aboriginal self-reporting"    "Not a visible minority" 

$DVISMIN$label
[1] "Visible minority"

$DVISMIN$description
[1] "Visible minority: Refers to the visible minority group to which the respondent belongs. The Employment Equity Act defines visible minorities as 'persons, other than Aboriginal peoples, who are non-Caucasian in race or non-white in colour'."




## ABDERR 
<img src="figure-png/marginals-10.png" width="900px" />
$ABDERR
$ABDERR$levels
                        1                         2 
    "Aboriginal Identity" "Non-Aboriginal Identity" 

$ABDERR$label
[1] "Aboriginal Status"

$ABDERR$description
[1] "Aboriginal identity status (detailed measure): Refers to those persons who reported identifying who reported identifying with at least one Aboriginal group (North American Indian, Métis or Inuit"




## ABIDENT 
<img src="figure-png/marginals-11.png" width="900px" />
$ABIDENT
$ABIDENT$levels
                                            1                                             2 
      "North American Indian single response"                       "Metis single response" 
                                            3                                             4 
                      "Inuit single response"      "Multiple Aboriginal identity responses" 
                                            5                                             6 
"Aboriginal responses not included elsewhere"          "Non-Aboriginal identity population" 

$ABIDENT$label
[1] "Aboriginal Identity (detail)"

$ABIDENT$description
[1] "Aboriginal identity status (detailed measure): Refers to those persons who reported identifying who reported identifying with at least one Aboriginal group (North American Indian, Métis or Inuit)"




#group( economic )

## HCDD 
<img src="figure-png/marginals-12.png" width="900px" />
$HCDD
$HCDD$levels
                                                                                                             1 
                                                                                                        "None" 
                                                                                                             2 
                                               "High school graduation certificate or equivalency certificate" 
                                                                                                             3 
                                                                         "Other trades certificate or diploma" 
                                                                                                             4 
                                                                       "Registered apprenticeship certificate" 
                                                                                                             5 
"College, CEGEP or other non-university certificate or diploma from a program of 3 months to less than 1 year" 
                                                                                                             6 
           "College, CEGEP or other non-university certificate or diploma from a program of 1 year to 2 years" 
                                                                                                             7 
           "College, CEGEP or other non-university certificate or diploma from a program of more than 2 years" 
                                                                                                             8 
                                                      "University certificate or diploma below bachelor level" 
                                                                                                             9 
                                                                                            "Bachelors degree" 
                                                                                                            10 
                                                      "University certificate or diploma above bachelor level" 
                                                                                                            11 
                                             "Degree in medicine, dentistry, veterinary medicine or optometry" 
                                                                                                            12 
                                                                                              "Masters degree" 
                                                                                                            13 
                                                                                     "Earned doctorate degree" 

$HCDD$label
[1] "Highest degree"

$HCDD$description
[1] "Highest certificate, diploma or degree: Information indicating the persons most advanced certificate, diploma or degree."




## COWD 
<img src="figure-png/marginals-13.png" width="900px" />
$COWD
$COWD$levels
                                                                                       1 
"Unpaid family workers - Worked without pay for a relative in a family business or farm" 
                                                                                       2 
                "Paid worker - Originally self-employed without paid help, incorporated" 
                                                                                       3 
                   "Paid worker - Originally self-employed with paid help, incorporated" 
                                                                                       4 
                           "Paid Worker - Working for wages, salary, tips or commission" 
                                                                                       5 
                                     "Self-employed without paid help, not incorporated" 
                                                                                       6 
                                        "Self-employed with paid help, not Incorporated" 
                                                                                       7 
                                                                        "Not applicable" 

$COWD$label
[1] "Class of worker"

$COWD$description
[1] "Class of worker: Refers to the classification of respondents who reported a job"




## NOCSBRD 
<img src="figure-png/marginals-14.png" width="900px" />
$NOCSBRD
$NOCSBRD$levels
                                                                            1 
                                                   "A Management occupations" 
                                                                            2 
                         "B Business, finance and administrative occupations" 
                                                                            3 
                     "C Natural and applied sciences and related occupations" 
                                                                            4 
                                                       "D Health occupations" 
                                                                            5 
"E Occupations in social science, education, government service and religion" 
                                                                            6 
                        "F Occupations in art, culture, recreation and sport" 
                                                                            7 
                                            "G Sales and service occupations" 
                                                                            8 
        "H Trades, transport and equipment operators and related occupations" 
                                                                            9 
                                   "I Occupations unique to primary industry" 
                                                                           10 
            "J Occupations unique to processing, manufacturing and utilities" 
                                                                           11 
                                                             "Not Applicable" 

$NOCSBRD$label
[1] "Occupation (broad)"

$NOCSBRD$description
[1] "Occupation broad categories: Refers to the kind of work persons were doing during the reference week, as determined by their kind of work and the description of the main activities in their job."




## TRMODE 
<img src="figure-png/marginals-15.png" width="900px" />
$TRMODE
$TRMODE$levels
                             1                              2                              3 
                     "Bicycle"    "Car, truck, van as driver"                   "Motorcycle" 
                             4                              5                              6 
                  "Other mode" "Car, truck, van as passenger"                      "Taxicab" 
                             7                              8                              9 
              "Public transit"                       "Walked"               "Not applicable" 

$TRMODE$label
[1] "Ride to work"

$TRMODE$description
[1] "Mode of transportation to work: Refers to the mode of transportation to work of respondents 15 years of age and over who have worked since January 1, 2005."




## LOINCA 
<img src="figure-png/marginals-16.png" width="900px" />
$LOINCA
$LOINCA$levels
                                                                                                                              1 
                                                                                                               "non-low income" 
                                                                                                                              2 
                                                                                                                   "low income" 
                                                                                                                              3 
"Concept not applicable (economic familes, persons not in economic families in the Yukon, NWT, Nunavut and on Indian Reserves)" 

$LOINCA$label
[1] "Low income A"

$LOINCA$description
[1] "Low income status (after taxes): Refers to the low income status of the respondent in relation to Statistics Canadas Low Income before tax cutoffs"




## LOINCB 
<img src="figure-png/marginals-17.png" width="900px" />
$LOINCB
$LOINCB$levels
                                                                                                                              1 
                                                                                                               "non-low income" 
                                                                                                                              2 
                                                                                                                   "low income" 
                                                                                                                              3 
"Concept not applicable (economic familes, persons not in economic families in the Yukon, NWT, Nunavut and on Indian Reserves)" 

$LOINCB$label
[1] "Low income B"

$LOINCB$description
[1] "Low income status (before taxes): Refers to the low income status of the respondent in relation to Statistics Canadas Low Income before tax cutoffs"




## d_licoratio_da_bef 
<img src="figure-png/marginals-18.png" width="900px" />
$d_licoratio_da_bef
$d_licoratio_da_bef$levels
            1             2             3             4             5             6             7 
"1st  decile" "2nd  decile" "3rd  decile" "4th  decile" "5th  decile" "6th  decile" "7th  decile" 
            8             9            10 
"8th  decile" "9th  decile" "10th decile" 

$d_licoratio_da_bef$label
[1] "Low income decile"

$d_licoratio_da_bef$description
[1] "Low-income area-based deciles: The ratio of total income to Statistics Canada low-income cut-offs for the applicable family size and community size. Ratios were calculated by each CMA/CA or by provincial rural residual levels and divided into the regional level deciles for before tax income."




## RUINDFG 
<img src="figure-png/marginals-19.png" width="900px" />
$RUINDFG
$RUINDFG$levels
      1       2 
"Rural" "Urban" 

$RUINDFG$label
[1] "Rural status"

$RUINDFG$description
[1] "Rural urban classification: Blocks falling inside urban areas are classified as urban.  Blocks falling outside of urban areas are classified as rural."




## RPAIR 
<img src="figure-png/marginals-20.png" width="900px" />
$RPAIR
$RPAIR$levels
                               1                                2                                3 
  "No, only regular maintenance"  "Yes, minor repairs are needed" "Yes, major repairs are needed " 
                               4 
                "Not applicable" 

$RPAIR$label
[1] "Need repair of dwelling?"

$RPAIR$description
[1] "Condition of dwelling: Refers to whether, in the judgement of the respondent, the dwelling requires any repairs (excluding desirable remodelling or additions)."




#group( immigration )

## POBDER 
<img src="figure-png/marginals-21.png" width="900px" />
$POBDER
$POBDER$levels
                               1                                2                                3 
" Born in province of residence"      " Born in another province"          " Born outside Canada " 

$POBDER$label
[1] "Place of birth"

$POBDER$description
[1] "Place of birth: Indicates whether the respondent was born in the same province that they lived in at the time of survey, born in a different province than they lived in at the time of the survey or born outside Canada."




## DPOB11N 
<img src="figure-png/marginals-22.png" width="900px" />
$DPOB11N
$DPOB11N$levels
                                          01                                           02 
                             "non-immigrant"               "Latin America and Caribbean " 
                                          03                                           04 
                            "Western Europe"                             "Eastern Europe" 
                                          05                                           06 
                       "Sub-Saharan Africa\t" "North Africa, South West Asia, Middle East" 
                                          07                                           08 
                                "South Asia"                             "Southeast Asia" 
                                          09                                           10 
                "East Asia (incl Singapore)" "Australia, New Zealand, Oceania, Greenland" 

$DPOB11N$label
[1] "Contry of birth"

$DPOB11N$description
[1] "Country of birth: Refers to the country of birth for those respondents not born in Canada"




## IMMDER 
<img src="figure-png/marginals-23.png" width="900px" />
$IMMDER
$IMMDER$levels
                        1                         2                         3 
             "Immigrants" "Non-permanent residents"          "Non-immigrants" 

$IMMDER$label
[1] "Immigration status"

$IMMDER$description
[1] "Immigration status: Indicates whether the respondent is a non-immigrant, an immigrant or a non-permanent resident."




## AGE_IMM_R_group 
<img src="figure-png/marginals-24.png" width="900px" />
$AGE_IMM_R_group
$AGE_IMM_R_group$levels
                                           1                                            2 
                                        "<5"                                 " 5 to < 10" 
                                           3                                            4 
                                "10 to < 15"                                 "15 to < 20" 
                                           5                                            6 
                                "20 to < 25"                                 "25 to < 30" 
                                           7                                            8 
                                "30 to < 35"                                 "35 to < 40" 
                                           9                                           10 
                                "40 to < 45"                                 "45 to < 50" 
                                          11                                           12 
                                "50 to < 55"                                 "55 to < 60" 
                                          13                                           14 
                               "60 and over"                    "Non-permanent residents" 
                                          15 
"Non-immigrants and institutional residents" 

$AGE_IMM_R_group$label
[1] "Age at immigration"

$AGE_IMM_R_group$description
[1] "Age at immigration (grouped): Refers to the age at which the respondent first obtained landed immigrant status. A landed immigrant is a person who has been granted the right to live in Canada permanently by immigration authorities."




## YRIM_group 
<img src="figure-png/marginals-25.png" width="900px" />
$YRIM_group
$YRIM_group$levels
                                           1                                            2 
                             "2002 or later"                      "between 1997 and 2001" 
                                           3                                            4 
                     "between 1996 and 1987"                            "1986 or earlier" 
                                           5                                            6 
                   "Non-permanent residents" "Non-immigrants and institutional residents" 

$YRIM_group$label
[1] "Year came to Canada"

$YRIM_group$description
[1] "Year of immigration: Refers to the year landed immigrant status was first obtained in Canada. Includes immigrants who landed in Canada prior to the survey collection."




## CITSM 
<img src="figure-png/marginals-26.png" width="900px" />
$CITSM
$CITSM$levels
                                1                                 2 
      "Canadian citizen by birth" "Not a Canadian citizen by birth" 

$CITSM$label
[1] "Citizen of Canada"

$CITSM$description
[1] "Citizenship status: Refers to the legal citizenship status of the respondent as being ''Canadian citizen by birth'' or something else."




## GENSTPOB 
<img src="figure-png/marginals-27.png" width="900px" />
$GENSTPOB
$GENSTPOB$levels
                                                                               1 
                               "1st generation - Respondent born outside Canada" 
                                                                               2 
"2nd generation - Respondent born in Canada of at least one foreign-born parent" 
                                                                               3 
    "3rd generation - Respondent born in Canada and both parents born in Canada" 

$GENSTPOB$label
[1] "Generation in Canada"

$GENSTPOB$description
[1] "Generation status: Refers to the generational status of the respondent, that is, 1st generation, 2nd generation or 3rd generation or more.Generation status is derived from place of birth of respondent, place of birth of father and place of birth of mother."




#group( health )

## ADIFCLTY 
<img src="figure-png/marginals-28.png" width="900px" />
$ADIFCLTY
$ADIFCLTY$levels
               1                2                3                4 
            "No"     "Not stated"     "Yes, often" "Yes, sometimes" 

$ADIFCLTY$label
[1] "Problems with ADL"

$ADIFCLTY$description
[1] "Difficulties with activities of daily living: Difficulty with activities of daily living such as hearing, seeing, communicating, walking, climbing stairs, bending, learning or doing any similar activities."




## DISABFL 
<img src="figure-png/marginals-29.png" width="900px" />
$DISABFL
$DISABFL$levels
               1                2                3                4 
            "No"     "Not stated"     "Yes, often" "Yes, sometimes" 

$DISABFL$label
[1] "Problems with ADL"

$DISABFL$description
[1] "Difficulties with activities of daily living: Refers to difficulty with daily activities and/or a physical condition or mental condition or health problem that reduces the amount or kind of activity that a person can do at home, at work or school or in other activities (e.g., transportation, leisure)."




## DISABIL 
<img src="figure-png/marginals-30.png" width="900px" />
$DISABIL
$DISABIL$levels
                                                                                                     1 
               "Difficulty with daily activities & activities reduced at home and in other activities" 
                                                                                                     2 
                    "Difficulty with daily activities & activities reduced at home and at work/school" 
                                                                                                     3 
"Difficulty with daily activities & activities reduced at home at work/school and in other activities" 
                                                                                                     4 
        "Difficulty with daily activities & activities reduced at work/school and in other activities" 
                                                                                                     5 
                                       "Difficulty with daily activities & activities reduced at home" 
                                                                                                     6 
                           "Difficulty with daily activities & activities reduced in other activities" 
                                                                                                     7 
                                "Difficulty with daily activities & activities reduced at work/school" 
                                                                                                     8 
                                                                    "Difficulty with daily activities" 
                                                                                                     9 
                                       "No difficulty with daily activities and no reduced activities" 
                                                                                                    10 
                                                  "Activities reduced at home and in other activities" 
                                                                                                    11 
                                                       "Activities reduced at home and at work/school" 
                                                                                                    12 
                                  "Activities reduced at home, at work/school and in other activities" 
                                                                                                    13 
                                           "Activities reduced at work/school and in other activities" 
                                                                                                    14 
                                                                          "Activities reduced at home" 
                                                                                                    15 
                                                              "Activities reduced in other activities" 
                                                                                                    16 
                                                                   "Activities reduced at work/school" 
                                                                                                    17 
                                                                                          "Not stated" 

$DISABIL$label
[1] "Problems with ADL (by type)"

$DISABIL$description
[1] "Difficulties with activities of daily living by type: Refers to having at least one of the activity difficulties/reductions, or having two or more in different combinations."




## S_DEAD 
<img src="figure-png/marginals-31.png" width="900px" />
$S_DEAD
$S_DEAD$levels
         1          2 
    "Dead" "Not dead" 

$S_DEAD$label
[1] "Dead in X years?"

$S_DEAD$description
[1] "Mortality status: Refers to whether or not the respondent died during the X years following the survey response"




## COD1 
<img src="figure-png/marginals-32.png" width="900px" />
$COD1
$COD1$levels
                                                              1 
"Communicable, maternal, perinatal, and nutritional conditions" 
                                                              2 
                                     "Noncommunicable diseases" 
                                                              3 
                                                     "Injuries" 
                                                              4 
        "Other causes of death or cause of death not available" 
                                                              5 
                                                  "Did not die" 

$COD1$label
[1] "Cause of death (short)"

$COD1$description
[1] "Cause of death according to Global Burden of Disease Level 1 codes (with ICD-10 codes for comparison, see COD1_CODES)"




## COD2 
<img src="figure-png/marginals-33.png" width="900px" />
$COD2
$COD2$levels
                                                      1 
                    "Infectious and parasitic diseases" 
                                                      2 
                               "Respiratory infections" 
                                                      3 
                             "Colon and rectal cancers" 
                                                      4 
                                 "Female Breast cancer" 
                                                      5 
                                    "Diabetes mellitus" 
                                                      6 
              "Alzheimer’s disease and other dementias" 
                                                      7 
                               "Ischemic heart disease" 
                                                      8 
                              "Cerebrovascular disease" 
                                                      9 
                                 "Respiratory diseases" 
                                                     10 
                                   "Digestive diseases" 
                                                     11 
                               "Genitourinary diseases" 
                                                     12 
                               "Unintentional injuries" 
                                                     13 
"Other causes of death or cause of death not available" 
                                                     14 
                                          "Did not die" 

$COD2$label
[1] "Cause of death (long)"

$COD2$description
[1] "Cause of death 2: Select causes of death according to Global Burden of Disease Level 2 codes (with ICD-10 codes for comparison, see COD2_CODES)"








# Session Information
For the sake of documentation and reproducibility, the current report was rendered on a system using the following software.

```
Report rendered by koval at 2018-09-11, 13:17 -0700 in 95 seconds.
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
[1] bindrcpp_0.2.2 knitr_1.20     magrittr_1.5   ggplot2_3.0.0 

loaded via a namespace (and not attached):
 [1] Rcpp_0.12.18                bindr_0.1.1                 munsell_0.5.0              
 [4] tidyselect_0.2.3            testit_0.7                  viridisLite_0.3.0          
 [7] colorspace_1.3-2            R6_2.2.2                    rlang_0.2.0                
[10] plyr_1.8.4                  stringr_1.3.1               dplyr_0.7.6                
[13] tools_3.4.4                 grid_3.4.4                  gtable_0.2.0               
[16] withr_2.1.1                 htmltools_0.3.6             lazyeval_0.2.1             
[19] yaml_2.1.19                 assertthat_0.2.0            digest_0.6.15              
[22] rprojroot_1.3-2             tibble_1.4.2                RColorBrewer_1.1-2         
[25] purrr_0.2.4                 glue_1.2.0                  evaluate_0.10.1            
[28] rmarkdown_1.8               labeling_0.3                stringi_1.1.7              
[31] compiler_3.4.4              pillar_1.2.1                scales_1.0.0               
[34] backports_1.1.2             TabularManifest_0.1-16.9003 pkgconfig_2.0.1            
```
