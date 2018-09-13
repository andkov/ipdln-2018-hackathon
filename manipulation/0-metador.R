# this script transcribes the meta data from 
# https://drive.google.com/file/d/10idMxy8eX8nTHr6wr2Q40x4XOP3Y5ck7/view
# and organizes the data documentation in a form convenient for reproducible analytics

# Lines before the first chunk are invisible to Rmd/Rnw callers
# Run to stitch a tech report of this script (used only in RStudio)
# knitr::stitch_rmd(
#   script = "./manipulation/0-metador.R",
#   output = "./manipulation/stitched-output/0-metador.md"
# )

rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. 
# This is not called by knitr, because it's above the first chunk.
cat("\f") # clear console when working in RStudio

# ---- load-packages -----------------------------------------------------------
library(magrittr) #Pipes
requireNamespace("dplyr", quietly=TRUE)

# ---- load-sources ------------------------------------------------------------

# ---- declare-globals ---------------------------------------------------------
# declare where you will store the product of this script
path_save <- "./data-unshared/derived/ls_guide.rds"

# ----- alphabetical-listing --------------------

# ABDERR                 "Aboriginal Status"
# ABIDENT                "Aboriginal Identity (detail)"
# ADIFCLTY               "Problems with ADL"
# AGE_IMM_R_group  "Age at immigration"
# CITSM                  "Citizen of Canada"
# COD1                   "Cause of death (short)"
# COD1_CODES             "Cause of death (short): Codes"
# COD2                   "Cause of death (long)"
# COD2_CODES             "Cause of death (long): Codes"
# COWD                   "Class of worker"
# DISABFL                "Problems with ADL"
# DISABIL                "Problems with ADL (by type)"
# DPOB11N                "Contry of birth"
# DVISMIN                "Visible minority"
# EFCNT_PP_R             "Family size"
# FOL                    "First language"
# GENSTPOB               "Generation in Canada"
# HCDD                   "Highest degree"
# IMMDER                 "Immigration status"
# KID_group              "Number of children"
# LOINCA                 "Low income A"
# LOINCB                 "Low income B"
# MARST                  "Marital status"
# NOCSBRD                "Occupation (broad)"
# OLN                    "Conversational language"
# POBDER                 "Place of birth"
# PR                     "Province of residence"
# RPAIR                  "Need repair of dwelling?"
# RUINDFG                "Rural status" 
# SEX                    "Sex"
# S_DEAD                 "Dead in X years?"
# TRMODE                 "Ride to work"
# YRIM_group             "Year came to Canada"
# age_group              "Age"
# d_licoratio_da_bef     "Low income decile"

# ----- thematic-listing -----------------------------
demographic <- c(
  "SEX"                    # "Sex"                            # demographics      
  ,"age_group"             # "Age"                            #      
  ,"MARST"                 # "Marital status"                 #                 
  ,"EFCNT_PP_R"            # "Family size"                    #              
  ,"KID_group"             # "Number of children"             #                     
  ,"PR"                    # "Province of residence"          #                        
)
identity <- c(
  "FOL"                    # "First language"                 # identity            
  ,"OLN"                   # "Conversational language"        #
  ,"DVISMIN"               # "Visible minority"               #                   
  ,"ABDERR"                # "Aboriginal Status"              #                    
  ,"ABIDENT"               # "Aboriginal Identity (detail)"   #  
)
economic <- c(
  "HCDD"                   # "Highest degree"                 # economic               
  ,"COWD"                  # "Class of worker"                #                  
  ,"NOCSBRD"               # "Occupation (broad)"             #                     
  ,"TRMODE"                # "Ride to work"                   #               
  ,"LOINCA"                # "Low income A"                   #               
  ,"LOINCB"                # "Low income B"                   #               
  ,"d_licoratio_da_bef"    # "Low income decile"              #                    
  ,"RUINDFG"               # "Rural status"                   #                
  ,"RPAIR"                 # "Need repair of dwelling?"       #                           
)
immigration <- c(
  "POBDER"                 # "Place of birth"                 # immigration               
  ,"DPOB11N"               # "Contry of birth"                #                  
  ,"IMMDER"                # "Immigration status"             #                     
  ,"AGE_IMM_R_group" # "Age at immigration"             #                     
  ,"YRIM_group"            # "Year came to Canada"            #                      
  ,"CITSM"                 # "Citizen of Canada"              #                    
  ,"GENSTPOB"              # "Generation in Canada"           #                       
)
health <- c(
  "ADIFCLTY"               # "Problems with ADL"              #  health                  
  ,"DISABFL"               # "Problems with ADL"              #                    
  ,"DISABIL"               # "Problems with ADL (by type)"    #
  ,"S_DEAD"                # "Dead in X years?"               #                   
  ,"COD1"                  # "Cause of death (short)"         #                         
  # ,"COD1_CODES"            # "Cause of death (short): Codes"  #
  ,"COD2"                  # "Cause of death (long)"          #                        
  # ,"COD2_CODES"            # "Cause of death (long): Codes"   #                           
)

# ---- define-objects -----------------------
ABDERR <- list(
  "levels" = c(
    "1"  = "Aboriginal Identity"
    ,"2" = "Non-Aboriginal Identity"
    )
  ,"label" = "Aboriginal Status"
  ,"description"= "Aboriginal identity status (detailed measure): Refers to those persons who reported identifying who reported identifying with at least one Aboriginal group (North American Indian, Métis or Inuit"
  )
ABIDENT <- list(
  "levels" = c(
    "1"= "North American Indian single response"
    ,"2" = "Metis single response"    
    ,"3" = "Inuit single response"    
    ,"4" = "Multiple Aboriginal identity responses"                     
    ,"5" = "Aboriginal responses not included elsewhere"                           
    ,"6" = "Non-Aboriginal identity population" 
  )
  ,"label" = "Aboriginal Identity (detail)"
  ,"description"= "Aboriginal identity status (detailed measure): Refers to those persons who reported identifying who reported identifying with at least one Aboriginal group (North American Indian, Métis or Inuit)"
  )
ADIFCLTY <- list(
  "levels" = c(
    "1" = "No" 
    ,"2" = "Not stated" 
    ,"3" = "Yes, often"  
    ,"4" = "Yes, sometimes"
  )
  ,"label" = "Problems with ADL"
  ,"description"= "Difficulties with activities of daily living: Difficulty with activities of daily living such as hearing, seeing, communicating, walking, climbing stairs, bending, learning or doing any similar activities."
)
AGE_IMM_R_group <- list(
  "levels" = c(
    "1"  = "<5"
    ,"2"  = " 5 to < 10"
    ,"3"  = "10 to < 15"
    ,"4"  = "15 to < 20"
    ,"5"  = "20 to < 25" 
    ,"6"  = "25 to < 30"
    ,"7"  = "30 to < 35"
    ,"8"  = "35 to < 40" 
    ,"9"  = "40 to < 45"
    ,"10" = "45 to < 50"
    ,"11" = "50 to < 55"
    ,"12" = "55 to < 60"
    ,"13" = "60 and over"
    ,"14" = "Non-permanent residents"
    ,"15" = "Non-immigrants and institutional residents"
  )
  ,"label" = "Age at immigration"
  ,"description"= "Age at immigration (grouped): Refers to the age at which the respondent first obtained landed immigrant status. A landed immigrant is a person who has been granted the right to live in Canada permanently by immigration authorities."
)
CITSM <- list(
  "levels" = c(
    "1" = "Canadian citizen by birth"
    ,"2" = "Not a Canadian citizen by birth"	
  )
  ,"label" = "Citizen of Canada"
  ,"description"= "Citizenship status: Refers to the legal citizenship status of the respondent as being ''Canadian citizen by birth'' or something else."
)
COD1 <- list(
  "levels" = c(
    "1" = "Communicable, maternal, perinatal, and nutritional conditions"
    ,"2" = "Noncommunicable diseases"
    ,"3" = "Injuries"
    ,"4" = "Other causes of death or cause of death not available"
    ,"5" = "Did not die"
    )
  ,"label" = "Cause of death (short)"
  ,"description"= "Cause of death according to Global Burden of Disease Level 1 codes (with ICD-10 codes for comparison, see COD1_CODES)"
)
COD1_CODES <- list(
  "levels" = c(
    "1" = "GBD: U001; ICD-10: A00–B99, G00–G04, N70–N73, J00–J06, J10–J18, J20–J22, H65–H66, O00–O99, P00–P96, E00–E02, E40–E46, E50, D50–D53, D64.9, E51–64"
    ,"2" = "GBD: U059; ICD-10: C00–C97, D00–D48, D55–D64 (minus D 64.9) D65–D89, E03–E07, E10–E16, E20–E34, E65–E88, F01–F99, G06–G98, H00–H61, H68–H93, I00–I99, J30–J98, K00–K92, N00–N64, N75–N98, L00–L98, M00–M99, Q00–Q99"
    ,"3" = "GBD: U148; ICD-10: V01–Y89"
    ,"4" = NA
    ,"5" = NA
  )
  ,"label" = "Cause of death (short): Codes"
  ,"description"= "Respective GBD & ICD-10 codes of COD1"
)
COD2 <- list(
  "levels" = c(
    "1"  = "Infectious and parasitic diseases"                    
    ,"2"  = "Respiratory infections"                               
    ,"3"  = "Colon and rectal cancers"                             
    ,"4"  = "Female Breast cancer"                                 
    ,"5"  = "Diabetes mellitus"                                    
    ,"6"  = "Alzheimer’s disease and other dementias"              
    ,"7"  = "Ischemic heart disease"                               
    ,"8"  = "Cerebrovascular disease"                              
    ,"9"  = "Respiratory diseases"                                 
    ,"10" = "Digestive diseases"                                   
    ,"11" = "Genitourinary diseases"                               
    ,"12" = "Unintentional injuries"                               
    ,"13" = "Other causes of death or cause of death not available"
    ,"14" = "Did not die"
  )
  ,"label" = "Cause of death (long)"
  ,"description"= "Cause of death 2: Select causes of death according to Global Burden of Disease Level 2 codes (with ICD-10 codes for comparison, see COD2_CODES)"
)
COD2_CODES <- list(
  "levels" = c(
    "1"  = "GBD: U002; A00–B99, G00, G03–G04, N70–N73"
    ,"2"  = "GBD: U038; J00–J06, J10–J18, J20–J22, H65–H66"
    ,"3"  = "GBD: U064; C18–C21"
    ,"4"  = "GBD: U069; C50 "
    ,"5"  = "GBD: U079; E10–E14"
    ,"6"  = "GBD: U087; F01, F03, G30–G31"
    ,"7"  = "GBD: U107; I20–I25"
    ,"8"  = "GBD: U108; I60–I69"
    ,"9"  = "GBD: U111; J30–J98"
    ,"10" = "GBD: U115; K20–K92"
    ,"11" = "GBD: U120; N00–N64, N75–N98"
    ,"12" = "GBD: U149; V01–X59, Y40–Y86, Y88, Y89"
    ,"13" = "GBD: U999"
    ,"14" = NA
  )
  ,"label" = "Cause of death (long): Codes"
  ,"description"= "Respective GBD & ICD-10 codes of COD2"
)
COWD <- list(
  "levels" = c(
    "1" = "Unpaid family workers - Worked without pay for a relative in a family business or farm"
    ,"2" = "Paid worker - Originally self-employed without paid help, incorporated"
    ,"3" = "Paid worker - Originally self-employed with paid help, incorporated"
    ,"4" = "Paid Worker - Working for wages, salary, tips or commission"
    ,"5" = "Self-employed without paid help, not incorporated"
    ,"6" = "Self-employed with paid help, not Incorporated"
    ,"7" = "Not applicable"
  )
  ,"label" = "Class of worker"
  ,"description"= "Class of worker: Refers to the classification of respondents who reported a job"
)
DISABFL <- list(
  "levels" = c(
    "1" = "No"
    ,"2" = "Not stated"
    ,"3" = "Yes, often"
    ,"4" = "Yes, sometimes"
  )
  ,"label" = "Problems with ADL"
  ,"description"= "Difficulties with activities of daily living: Refers to difficulty with daily activities and/or a physical condition or mental condition or health problem that reduces the amount or kind of activity that a person can do at home, at work or school or in other activities (e.g., transportation, leisure)."
)

DISABIL <- list(
  "levels" = c(
     "1"  = "Difficulty with daily activities & activities reduced at home and in other activities"
    ,"2"  = "Difficulty with daily activities & activities reduced at home and at work/school"
    ,"3"  = "Difficulty with daily activities & activities reduced at home at work/school and in other activities"
    ,"4"  = "Difficulty with daily activities & activities reduced at work/school and in other activities"
    ,"5"  = "Difficulty with daily activities & activities reduced at home"
    ,"6"  = "Difficulty with daily activities & activities reduced in other activities"
    ,"7"  = "Difficulty with daily activities & activities reduced at work/school"
    ,"8"  = "Difficulty with daily activities"
    ,"9"  = "No difficulty with daily activities and no reduced activities"
    ,"10" = "Activities reduced at home and in other activities"
    ,"11" = "Activities reduced at home and at work/school"
    ,"12" = "Activities reduced at home, at work/school and in other activities"
    ,"13" = "Activities reduced at work/school and in other activities"
    ,"14" = "Activities reduced at home"
    ,"15" = "Activities reduced in other activities"
    ,"16" = "Activities reduced at work/school"
    ,"17" = "Not stated"
  )
  ,"label" = "Problems with ADL (by type)"
  ,"description"= "Difficulties with activities of daily living by type: Refers to having at least one of the activity difficulties/reductions, or having two or more in different combinations."
)
DPOB11N	 <- list(
  "levels" = c(
    "01"= "non-immigrant"
    ,"02"= "Latin America and Caribbean "
    ,"03"= "Western Europe"
    ,"04"= "Eastern Europe"
    ,"05"= "Sub-Saharan Africa	"
    ,"06"= "North Africa, South West Asia, Middle East"
    ,"07"= "South Asia"
    ,"08"= "Southeast Asia"
    ,"09"= "East Asia (incl Singapore)"
    ,"10"= "Australia, New Zealand, Oceania, Greenland" 	
  )
  ,"label" = "Contry of birth"
  ,"description"= "Country of birth: Refers to the country of birth for those respondents not born in Canada"
)
DVISMIN	 <- list(
  "levels" = c(
     "1"  =   "Chinese"
    ,"2"  =   "South Asian"
    ,"3"  =   "Black"
    ,"4"  =   "Filipino"
    ,"5"  =   "Latin American"
    ,"6"  =   "Southeast Asian"
    ,"7"  =   "Arab"
    ,"8"  =   "West Asian"
    ,"9"  =   "Korean"
    ,"10"  =  "Japanese"
    ,"11"  =  "Visible minority, n.i.e."
    ,"12"  =  "Multiple visible minority"
    ,"13"  =  "Aboriginal self-reporting"
    ,"14"  =  "Not a visible minority"
  )
  ,"label" = "Visible minority"
  ,"description"= "Visible minority: Refers to the visible minority group to which the respondent belongs. The Employment Equity Act defines visible minorities as 'persons, other than Aboriginal peoples, who are non-Caucasian in race or non-white in colour'."
)
EFCNT_PP_R <- list(
  "levels" = c(
    "1"  = "1 person"
    ,"2"  = "2 family members"
    ,"3"  = "3 family members"
    ,"4"  = "4 family members"
    ,"5"  = "5 family members"
    ,"6"  = "6 family members"
    ,"7"  = "7 family members"
    ,"8"  = "8 family members"
    ,"9"  = "9 family members"
    ,"10" = "10 or more family members"	  
  )
  ,"label" = "Family size"
  ,"description"= "Number of persons in the family: Refers to the number of persons in the individuals family."
)
FOL	 <- list(
  "levels" = c(
    "1" = "English only"
    ,"2" = "French only"
    ,"3" = "Both English and French"
    ,"4" = "Neither English nor French"
  )
  ,"label" = "First language"
  ,"description"= "First official language: First official language spoken	"
)
FPTIM	 <- list(
  "levels" = c(
    "1" = "Worked mainly full-time weeks"
    ,"2" = "Worked mainly part-time weeks"
    ,"3" = "Not applicable (didn’t work)"
  )
  ,"label" = "Employment last year"
  ,"description"= "Labour Market Activities: Full and part time employment. Persons were asked to report whether the weeks they worked in the year prior to the survey were full-time weeks (30 hours or more per week) or not, on the basis of all jobs held."
)
GENSTPOB <- list(
  "levels" = c(
    "1" = "1st generation - Respondent born outside Canada"
    ,"2" = "2nd generation - Respondent born in Canada of at least one foreign-born parent"
    ,"3" = "3rd generation - Respondent born in Canada and both parents born in Canada"
  )
  ,"label" = "Generation in Canada"
  ,"description"= "Generation status: Refers to the generational status of the respondent, that is, 1st generation, 2nd generation or 3rd generation or more.Generation status is derived from place of birth of respondent, place of birth of father and place of birth of mother."
)
HCDD <- list(
  "levels" = c(
     "1"  = "None"
    ,"2"  = "High school graduation certificate or equivalency certificate"
    ,"3"  = "Other trades certificate or diploma"
    ,"4"  = "Registered apprenticeship certificate"
    ,"5"  = "College, CEGEP or other non-university certificate or diploma from a program of 3 months to less than 1 year"
    ,"6"  = "College, CEGEP or other non-university certificate or diploma from a program of 1 year to 2 years"
    ,"7"  = "College, CEGEP or other non-university certificate or diploma from a program of more than 2 years"
    ,"8"  = "University certificate or diploma below bachelor level"
    ,"9"  = "Bachelors degree"
    ,"10" = "University certificate or diploma above bachelor level"
    ,"11" = "Degree in medicine, dentistry, veterinary medicine or optometry"
    ,"12" = "Masters degree"
    ,"13" = "Earned doctorate degree"	
  )
  ,"label" = "Highest degree"
  ,"description"= "Highest certificate, diploma or degree: Information indicating the persons most advanced certificate, diploma or degree."
)	
IMMDER <- list(
  "levels" = c(
    "1" = "Immigrants"
    ,"2" = "Non-permanent residents"
    ,"3" = "Non-immigrants"
  )
  ,"label" = "Immigration status"
  ,"description"= "Immigration status: Indicates whether the respondent is a non-immigrant, an immigrant or a non-permanent resident."
)
KID_group	<- list(
  "levels" = c(
    "1" = "no children"
    ,"2" = "one or two children"
    ,"3" = "three or more children"	
  )
  ,"label" = "Number of children"
  ,"description"= "Children, total number in family (grouped)"
)
LOINCA <- list(
  "levels" = c(
    "1" = "non-low income"
    ,"2" = "low income"
    ,"3" = "Concept not applicable (economic familes, persons not in economic families in the Yukon, NWT, Nunavut and on Indian Reserves)"
  )
  ,"label" = "Low income A"
  ,"description"= "Low income status (after taxes): Refers to the low income status of the respondent in relation to Statistics Canadas Low Income before tax cutoffs"
)
LOINCB <- list(
  "levels" = c(
    "1" = "non-low income"
    ,"2" = "low income"
    ,"3" = "Concept not applicable (economic familes, persons not in economic families in the Yukon, NWT, Nunavut and on Indian Reserves)"
    )
  ,"label" = "Low income B"
  ,"description"= "Low income status (before taxes): Refers to the low income status of the respondent in relation to Statistics Canadas Low Income before tax cutoffs"
)	
MARST	<- list(
  "levels" = c(
    "1" = "Divorced"
    ,"2" = "Legally married (and not separated)"
    ,"3" = "Separated, but still legally married"
    ,"4" = "Never legally married (single)"
    ,"5" = "Widowed"
  )
  ,"label" = "Marital status"
  ,"description"= "Marital Status: Refers to the legal marital status of the person."
)
NOCSBRD	<- list(
  "levels" = c(
    "1"  = "A Management occupations"
    ,"2"  = "B Business, finance and administrative occupations"
    ,"3"  = "C Natural and applied sciences and related occupations"
    ,"4"  = "D Health occupations"
    ,"5"  = "E Occupations in social science, education, government service and religion"
    ,"6"  = "F Occupations in art, culture, recreation and sport"
    ,"7"  = "G Sales and service occupations"
    ,"8"  = "H Trades, transport and equipment operators and related occupations"
    ,"9"  = "I Occupations unique to primary industry"
    ,"10" = "J Occupations unique to processing, manufacturing and utilities"
    ,"11" = "Not Applicable"
    )
  ,"label" = "Occupation (broad)"
  ,"description"= "Occupation broad categories: Refers to the kind of work persons were doing during the reference week, as determined by their kind of work and the description of the main activities in their job."
)
OLN	<- list(
  "levels" = c(
    "1" = "English only"
    ,"2" = "French only"
    ,"3" = "Both English and French"
    ,"4" = "Neither English nor French"
  )
  ,"label" = "Conversational language"
  ,"description"= "Official language: Refers to the ability to conduct a conversation in English only, in French only, in both English and French or in none of the official languages of Canada"
)
POBDER <- list(
  "levels" = c(
    "1" = " Born in province of residence"
    ,"2" = " Born in another province"
    ,"3" = " Born outside Canada "
  )
  ,"label" = "Place of birth"
  ,"description"= "Place of birth: Indicates whether the respondent was born in the same province that they lived in at the time of survey, born in a different province than they lived in at the time of the survey or born outside Canada."
)	
PR <- list(
  "levels" = c(
    "10" = "Newfoundland and Labrador"
    ,"11" = "Prince Edward Island"
    ,"12" = "Nova Scotia"
    ,"13" = "New Brunswick"
    ,"24" = "Quebec"
    ,"35" = "Ontario"
    ,"46" = "Manitoba"
    ,"47" = "Saskatchewan"
    ,"48" = "Alberta"
    ,"59" = "British Columbia"
    ,"60" = "Yukon"
    ,"61" = "Northwest Territories"
    ,"62" = "Nunavut"	
  )
  ,"label" = "Province of residence"
  ,"description"= "Province or territory of residence"
)
RPAIR	<- list(
  "levels" = c(
    "1" = "No, only regular maintenance"
    ,"2" = "Yes, minor repairs are needed"
    ,"3" = "Yes, major repairs are needed "
    ,"4" = "Not applicable"
  )
  ,"label" = "Need repair of dwelling?"
  ,"description"= "Condition of dwelling: Refers to whether, in the judgement of the respondent, the dwelling requires any repairs (excluding desirable remodelling or additions)."
)
RUINDFG	<- list(
  "levels" = c(
    "1" = "Rural" 
    ,"2" = "Urban" 	
  )
  ,"label" = "Rural status" 
  ,"description"= "Rural urban classification: Blocks falling inside urban areas are classified as urban.  Blocks falling outside of urban areas are classified as rural."
)
SEX	<- list(
  "levels" = c(
    "1" = "Female" 
    ,"2" = "Male"
  )
  ,"label" = "Sex"
  ,"description"= "Sex"
  )
S_DEAD	<- list(
  "levels" = c(
    "1" = "Dead"
    ,"2" = "Not dead"
  )
  ,"label" = "Dead in X years?"
  ,"description"= "Mortality status: Refers to whether or not the respondent died during the X years following the survey response"
)
TRMODE <- list(
  "levels" = c(
    "1" = "Bicycle"
    ,"2" = "Car, truck, van as driver"
    ,"3" = "Motorcycle"
    ,"4" = "Other mode"
    ,"5" = "Car, truck, van as passenger"
    ,"6" = "Taxicab"
    ,"7" = "Public transit"
    ,"8" = "Walked"
    ,"9" = "Not applicable"
  )
  ,"label" = "Ride to work"
  ,"description"= "Mode of transportation to work: Refers to the mode of transportation to work of respondents 15 years of age and over who have worked since January 1, 2005."
)	
YRIM_group <- list(
  "levels" = c(
    "1" = "2002 or later"
    ,"2" = "between 1997 and 2001"
    ,"3" = "between 1996 and 1987"
    ,"4" = "1986 or earlier"
    ,"5" = "Non-permanent residents"
    ,"6" = "Non-immigrants and institutional residents")
  ,"label" = "Year came to Canada"
  ,"description"= "Year of immigration: Refers to the year landed immigrant status was first obtained in Canada. Includes immigrants who landed in Canada prior to the survey collection."
)	
age_group	<- list(
  "levels" = c(
    "1"  = "19 to 24"
    ,"2"  = "25 to 29"
    ,"3"  = "30 to 34"
    ,"4"  = "35 to 39"
    ,"5"  = "40 to 44"
    ,"6"  = "45 to 49"
    ,"7"  = "50 to 54"
    ,"8"  = "55 to 59"
    ,"9"  = "60 to 64"
    ,"10" = "65 to 69"
    ,"11" = "70 to 74"
    ,"12" = "75 to 79"
    ,"13" = "80 to 84"
    ,"14" = "85 to 89"
    ,"15" = "90 and older"
  )
  ,"label" = "Age"
  ,"description"= "Age: grouped"
)
d_licoratio_da_bef <- list(
  "levels" = c(
     "1"  = "1st  decile"   
    ,"2"  = "2nd  decile"   
    ,"3"  = "3rd  decile"   
    ,"4"  = "4th  decile"   
    ,"5"  = "5th  decile"   
    ,"6"  = "6th  decile"   
    ,"7"  = "7th  decile"   
    ,"8"  = "8th  decile"   
    ,"9"  = "9th  decile"   
    ,"10" = "10th decile"    
  )
  ,"label" = "Low income decile"
  ,"description"= "Low-income area-based deciles: The ratio of total income to Statistics Canada low-income cut-offs for the applicable family size and community size. Ratios were calculated by each CMA/CA or by provincial rural residual levels and divided into the regional level deciles for before tax income."
)	

# ----- assemble-target-objects ------------------
# create vector with names    
block_names <- c("demographic", "identity", "economic", "immigration","health")
item_names  <- c(demographic,    identity,   economic,   immigration,  health)
# create a list object to hold all available metadata 
ls_guide            <- list()
ls_guide[["block"]] <- mget(block_names, envir = globalenv())
ls_guide[["item"]]  <- mget(item_names,  envir = globalenv())

# ---- review-assembled-object ---------------------
# show components of this list object 
ls_guide %>% lapply(names)
# show contents of an arbitrary `block` component
ls_guide$block$demographic %>% str()
# show contents of an arbitrary `item` component
ls_guide$item$KID_group %>% str()

# ---- save-to-disk ------------------------
cat("Save results to ",path_save)
saveRDS(ls_guide, path_save)


























