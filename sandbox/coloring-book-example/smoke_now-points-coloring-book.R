# This report conducts harmonization procedure 
# knitr::stitch_rmd(script="./___/___.R", output="./___/___/___.md")
#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
cat("\f") # clear console 

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.
source("./scripts/common-functions.R") # used in multiple reports
source("./scripts/graph-presets.R") # fonts, colors, themes 
source("./scripts/graph-logistic.R")

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr) # enables piping : %>% 
library(ggplot2)
# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("ggplot2") # graphing
requireNamespace("tidyr") # data manipulation
requireNamespace("dplyr") # Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("plyr")
requireNamespace("testit")# For asserting conditions meet expected patterns.
requireNamespace("car") # For it's `recode()` function.

# ---- declare-globals ---------------------------------------------------------

# ---- load-data ---------------------------------------------------------------
# load the product of 0-ellis-island.R,  a list object containing data and metadata
dto <- readRDS("./data/unshared/derived/dto.rds")
# ---- inspect-data -------------------------------------------------------------
# the list is composed of the following elements
names(dto)
# 1st element - names of the studies as character vector
dto[["studyName"]]
# 2nd element - file paths of the data files for each study as character vector
dto[["filePath"]]
# 3rd element - is a list object containing the following elements
names(dto[["unitData"]])
# each of these elements is a raw data set of a corresponding study, for example
dplyr::tbl_df(dto[["unitData"]][["lbsl"]]) 
# ---- meta-table --------------------------------------------------------
# 4th element - a dataset names and labels of raw variables + added metadata for all studies
# dto[["metaData"]] %>% dplyr::select(study_name, name, item, construct, type, categories, label_short, label) %>%
#   DT::datatable(
#     class   = 'cell-border stripe',
#     caption = "This is the primary metadata file. Edit at `./data/shared/meta-data-map.csv",
#     filter  = "top",
#     options = list(pageLength = 6, autoWidth = TRUE)
#   )

# ---- tweak-data --------------------------------------------------------------

# ---- basic-table --------------------------------------------------------------

# ---- basic-graph --------------------------------------------------------------


# ---- combine-from-dto ------------------
dmls <- list() # dummy list
for(s in dto[["studyName"]]){
  ds <- dto[["unitData"]][[s]] # get study data from dto
  (varnames <- names(ds)) # see what variables there are
  (get_these_variables <- c("id",
                            "year_of_wave","age_in_years","year_born",
                            "female",
                            "marital",
                            "educ3",
                            "smoke_now","smoked_ever",
                            "current_work_2",
                            "current_drink",
                            "sedentary",
                            "poor_health",
                            "bmi")) 
  (variables_present <- varnames %in% get_these_variables) # variables on the list
  dmls[[s]] <- ds[,variables_present] # keep only them
}
lapply(dmls, names) # view the contents of the list object

ds <- plyr::ldply(dmls,data.frame,.id = "study_name")
ds$id <- 1:nrow(ds) # some ids values might be identical, replace
head(ds)

# ---- save-for-Mplus ---------------------------

# write.table(ds,"./data/unshared/derived/combined-harmonized-data-set.dat", row.names=F, col.names=F)
# write(names(ds), "./data/unshared/derived/variable-names.txt", sep=" ")


# ---- assemble ------------------------
dv_name <- "smoke_now"
dv_label_prob <- "P(Smoke Now)"
dv_label_odds <- "Odds(Smoke Now)"
covar_order_values <- c("female","marital_f","educ3_f","poor_health")

# age summary across studies
ds %>%  
  dplyr::group_by(study_name) %>%
  na.omit() %>% 
  dplyr::summarize(mean_age = round(mean(age_in_years),1),
                   sd_age = round(sd(age_in_years),2),
                   observed = n(),
                   min_born = min(year_born),
                   med_born = median(year_born),
                   max_born = max(year_born)) 
                   
# see counts across age groups and studies 
t <- table(
  cut(ds$age_in_years,breaks = c(-Inf,seq(from=40,to=100,by=5), Inf)),
  ds$study_name, 
  useNA = "always"
); t[t==0] <- "."; t

# basic counts
table(ds$study_name, ds$smoke_now, useNA = "always")
table(ds$study_name, ds$smoked_ever, useNA = "always")
table(ds$study_name, ds$female, useNA = "always")
table(ds$study_name, ds$marital, useNA = "always")
table(ds$study_name, ds$educ3, useNA = "always")


# ---- fit-model ----------------------------------------
ds2 <- ds %>% 
  dplyr::select_("id", "study_name", "smoke_now", "smoked_ever",
                 "age_in_years", "female", "marital", "educ3","poor_health") %>% 
  na.omit() %>% 
  dplyr::mutate(
    marital_f         = as.factor(marital),
    educ3_f           = as.factor(educ3)
  ) %>% 
  dplyr::rename_(
    "dv" = dv_name
  ) 
#eq <- as.formula(paste0("smoke_now ~ -1 + study_name + age_in_years + female + marital_f + educ3_f + poor_health"))
# eq <- as.formula(paste0("smoke_now ~ -1 + age_in_years + female + educ3_f + poor_health"))
eq_global_string <- paste0(
  # "smoke_now ~ -1 + study_name + age_in_years + female + marital_f + educ3_f + poor_health + female:marital_f + female:educ3_f + female:poor_health + marital_f:educ3_f + marital_f:poor_health"
  "dv ~ -1 + study_name + age_in_years + female + marital_f + educ3_f + poor_health"
)
eq_global <- as.formula(eq_global_string)

eq_local_string <- paste0(
  # "smoke_now ~ -1 + age_in_years + female + marital_f + educ3_f + poor_health + female:marital_f + female:educ3_f + female:poor_health + marital_f:educ3_f + marital_f:poor_health"
  "dv ~ -1 + age_in_years + female + marital_f + educ3_f + poor_health"
)

eq_local <- as.formula(eq_local_string)
# eq <- as.formula(paste0("smoke_now ~ -1 + age_in_years"))
model_global <- glm(
  eq_global,
  data = ds2, 
  family = binomial(link="logit")
) 
summary(model_global)
coefficients(model_global)
ds2$dv_p <- predict(model_global)

# ds_predicted_global <- expand.grid(
#   study_name      = sort(unique(ds2$study_name)), #For the sake of repeating the same global line in all studies/panels in the facetted graphs
#   age_in_years    = seq.int(40, 100, 10),
#   female        = sort(unique(ds2$female)),
#   educ3_f       = sort(unique(ds2$educ3_f)),
#   # marital_f     = sort(unique(d$marital_f)),
#   poor_health   = sort(unique(ds2$poor_health)),
#   stringsAsFactors = FALSE
# ) 

ds_predicted_global <- ds2 %>% 
  dplyr::select_(
    "study_name",
    "age_in_years", 
    "female",        
    "educ3_f",       
    "marital_f" ,
    "poor_health"  
  ) 

ds_predicted_global$dv_hat    <- as.numeric(predict(model_global, newdata=ds_predicted_global)) #logged-odds of probability (ie, linear)
ds_predicted_global$dv_hat_p  <- plogis(ds_predicted_global$dv_hat) 



ds_predicted_study_list <- list()
model_study_list <- list()
for( study_name_ in dto[["studyName"]] ) {
  d_study <- ds2[ds2$study_name==study_name_, ]
  model_study <- glm(eq_local, data=d_study,  family=binomial(link="logit")) 
  model_study_list[[study_name_]] <- model_study
  
  # d_predicted <- expand.grid(
  #   age_in_years  = seq.int(40, 100, 10),
  #   female        = sort(unique(ds2$female)),
  #   educ3_f       = sort(unique(ds2$educ3_f)),
  #   # marital_f     = sort(unique(ds2$marital_f)),
  #   poor_health   = sort(unique(ds2$poor_health)),
  #   #TODO: add more predictors -possibly as ranges (instead of fixed values)
  #   stringsAsFactors = FALSE
  # ) 
  
  d_predicted <- ds2 %>% dplyr::select_(
    "age_in_years", 
    "female",        
    "educ3_f",       
    "marital_f" ,
    "poor_health"  
  ) 
  
  d_predicted$dv_hat      <- as.numeric(predict(model_study, newdata=d_predicted)) #logged-odds of probability (ie, linear)
  d_predicted$dv_hat_p    <- plogis(d_predicted$dv_hat)                         #probability (ie, s-curve)
  ds_predicted_study_list[[study_name_]] <- d_predicted
  # ggplot(d_predicted, aes(x=age_in_years, y=dv_p))  +
  #   geom_line()
}

ds_predicted_study <- ds_predicted_study_list %>% 
  dplyr::bind_rows(.id="study_name")

# summary(model_study_list[["alsa"]])
lapply(model_study_list, summary)
sapply(model_study_list, coefficients)
# graph_logistic_point_complex_4(
#   ds = ds_predicted_global,
#   x_name = "age_in_years",
#   y_name = "dv_hat_p",
#   covar_order = c("female","marital_f","educ3_f","poor_health"),
#   alpha_level = .3)

assign_color <- function(color_group){
  if( color_group == "female") {
    # http://colrd.com/image-dna/25114/
    palette_color <- c("TRUE"=reference_color, "FALSE"=increased_risk_1) # 98aab9
  } else if( color_group %in% c("educ3", "educ3_f") ) { 
    # http://colrd.com/image-dna/24382/
    palette_color <- c("high school"=reference_color, "less than high school"=increased_risk_1, "more than high school"=descreased_risk_1) # 54a992, e8c571
  } else if( color_group %in% c("marital_f") ) {
    # http://colrd.com/image-dna/23318/
    palette_color <- c("mar_cohab"=descreased_risk_1, "sep_divorced"= increased_risk_2, "single"=reference_color, "widowed"=increased_risk_1)
  } else if( color_group %in% c("poor_health") ) {
    # http://colrd.com/palette/18841/
    palette_color <- c("FALSE"=reference_color, "TRUE"=descreased_risk_2)
  } else {
    stop("The palette for this variable is not defined.")
  }
  
}

# ---- palette-color-1 ---------------------------

# ---- 1-global-probability ----------------------
# 1 step of color logic:
increased_risk_2 <- "#bdbdbd"  # red - further increased risk factor
increased_risk_1 <- "#bdbdbd"  # organge - increased risk factor
reference_color <- "#bdbdbd"   # green  - REFERENCE  category
descreased_risk_1 <-"#bdbdbd"  # blue - descreased risk factor
descreased_risk_2 <- "#bdbdbd" # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
# increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
# reference_color <- "#4daf4a"   # green  - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor

graph_logistic_point_complex_4(
  ds = ds_predicted_global,
  x_name = "age_in_years",
  y_name = "dv_hat_p",
  covar_order = covar_order_values,
  alpha_level = .4,
  y_title = dv_label_prob,
  y_range = c(0, .8)) 
summary(ds_predicted_study_list)

# 2 step of color logic:
increased_risk_2 <- "#bdbdbd"  # red - further increased risk factor
increased_risk_1 <- "#bdbdbd"  # organge - increased risk factor
reference_color <- "#bdbdbd"   # green  - REFERENCE  category
descreased_risk_1 <-"#bdbdbd"  # blue - descreased risk factor
descreased_risk_2 <- "#bdbdbd" # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
# increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
reference_color <- "#4daf4a"   # green  - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor


graph_logistic_point_complex_4(
  ds = ds_predicted_global,
  x_name = "age_in_years",
  y_name = "dv_hat_p",
  covar_order = covar_order_values,
  alpha_level = .4,
  y_title = dv_label_prob,
  y_range = c(0, .8)) 
summary(ds_predicted_study_list)

# 3 step of color logic:
increased_risk_2 <- "#bdbdbd"  # red - further increased risk factor
increased_risk_1 <- "#bdbdbd"  # organge - increased risk factor
reference_color <- "#bdbdbd"   # green  - REFERENCE  category
descreased_risk_1 <-"#bdbdbd"  # blue - descreased risk factor
descreased_risk_2 <- "#bdbdbd" # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
reference_color <- "#4daf4a"   # green  - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor



graph_logistic_point_complex_4(
  ds = ds_predicted_global,
  x_name = "age_in_years",
  y_name = "dv_hat_p",
  covar_order = covar_order_values,
  alpha_level = .4,
  y_title = dv_label_prob,
  y_range = c(0, .8)) 
summary(ds_predicted_study_list)

# 4 step of color logic:
increased_risk_2 <- "#bdbdbd"  # red - further increased risk factor
increased_risk_1 <- "#bdbdbd"  # organge - increased risk factor
reference_color <- "#bdbdbd"   # green  - REFERENCE  category
descreased_risk_1 <-"#bdbdbd"  # blue - descreased risk factor
descreased_risk_2 <- "#bdbdbd" # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
reference_color <- "#4daf4a"   # green  - REFERENCE  category
descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor


graph_logistic_point_complex_4(
  ds = ds_predicted_global,
  x_name = "age_in_years",
  y_name = "dv_hat_p",
  covar_order = covar_order_values,
  alpha_level = .4,
  y_title = dv_label_prob,
  y_range = c(0, .8)) 
summary(ds_predicted_study_list)

# 5 step of color logic:
increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
reference_color <- "#4daf4a"   # green  - REFERENCE  category
descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor

graph_logistic_point_complex_4(
  ds = ds_predicted_global,
  x_name = "age_in_years",
  y_name = "dv_hat_p",
  covar_order = covar_order_values,
  alpha_level = .4,
  y_title = dv_label_prob,
  y_range = c(0, .8)) 
summary(ds_predicted_study_list)


# ---- 2-local-probability ----------------------
# 1 step of color logic:
increased_risk_2 <- "#bdbdbd"  # red - further increased risk factor
increased_risk_1 <- "#bdbdbd"  # organge - increased risk factor
reference_color <- "#bdbdbd"   # green  - REFERENCE  category
descreased_risk_1 <-"#bdbdbd"  # blue - descreased risk factor
descreased_risk_2 <- "#bdbdbd" # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
# increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
# reference_color <- "#4daf4a"   # green  - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor


graph_logistic_point_complex_4(
  ds = ds_predicted_study,
  x_name = "age_in_years",
  y_name = "dv_hat_p",
  covar_order = covar_order_values,
  alpha_level = .3,
  y_title = dv_label_prob,
  y_range = c(0, .8)) 

# 2 step of color logic:
increased_risk_2 <- "#bdbdbd"  # red - further increased risk factor
increased_risk_1 <- "#bdbdbd"  # organge - increased risk factor
reference_color <- "#bdbdbd"   # green  - REFERENCE  category
descreased_risk_1 <-"#bdbdbd"  # blue - descreased risk factor
descreased_risk_2 <- "#bdbdbd" # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
# increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
reference_color <- "#4daf4a"   # green  - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor

graph_logistic_point_complex_4(
  ds = ds_predicted_study,
  x_name = "age_in_years",
  y_name = "dv_hat_p",
  covar_order = covar_order_values,
  alpha_level = .3,
  y_title = dv_label_prob,
  y_range = c(0, .8)) 


# 3 step of color logic:
increased_risk_2 <- "#bdbdbd"  # red - further increased risk factor
increased_risk_1 <- "#bdbdbd"  # organge - increased risk factor
reference_color <- "#bdbdbd"   # green  - REFERENCE  category
descreased_risk_1 <-"#bdbdbd"  # blue - descreased risk factor
descreased_risk_2 <- "#bdbdbd" # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
reference_color <- "#4daf4a"   # green  - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor



graph_logistic_point_complex_4(
  ds = ds_predicted_study,
  x_name = "age_in_years",
  y_name = "dv_hat_p",
  covar_order = covar_order_values,
  alpha_level = .3,
  y_title = dv_label_prob,
  y_range = c(0, .8)) 

# 4 step of color logic:
increased_risk_2 <- "#bdbdbd"  # red - further increased risk factor
increased_risk_1 <- "#bdbdbd"  # organge - increased risk factor
reference_color <- "#bdbdbd"   # green  - REFERENCE  category
descreased_risk_1 <-"#bdbdbd"  # blue - descreased risk factor
descreased_risk_2 <- "#bdbdbd" # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
reference_color <- "#4daf4a"   # green  - REFERENCE  category
descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor

graph_logistic_point_complex_4(
  ds = ds_predicted_study,
  x_name = "age_in_years",
  y_name = "dv_hat_p",
  covar_order = covar_order_values,
  alpha_level = .3,
  y_title = dv_label_prob,
  y_range = c(0, .8)) 

# 5 step of color logic:
increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
reference_color <- "#4daf4a"   # green  - REFERENCE  category
descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor

graph_logistic_point_complex_4(
  ds = ds_predicted_study,
  x_name = "age_in_years",
  y_name = "dv_hat_p",
  covar_order = covar_order_values,
  alpha_level = .3,
  y_title = dv_label_prob,
  y_range = c(0, .8)) 


# ---- 3-global-odds ----------------------
# 1 step of color logic:
increased_risk_2 <- "#bdbdbd"  # red - further increased risk factor
increased_risk_1 <- "#bdbdbd"  # organge - increased risk factor
reference_color <- "#bdbdbd"   # green  - REFERENCE  category
descreased_risk_1 <-"#bdbdbd"  # blue - descreased risk factor
descreased_risk_2 <- "#bdbdbd" # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
# increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
# reference_color <- "#4daf4a"   # green  - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor

graph_logistic_point_complex_4(
  ds = ds_predicted_global,
  x_name = "age_in_years",
  y_name = "dv_hat",
  covar_order = covar_order_values,
  alpha_level = .3,
  y_title = dv_label_odds,
  y_range = c(-3.5, 1))

# 2 step of color logic:
increased_risk_2 <- "#bdbdbd"  # red - further increased risk factor
increased_risk_1 <- "#bdbdbd"  # organge - increased risk factor
reference_color <- "#bdbdbd"   # green  - REFERENCE  category
descreased_risk_1 <-"#bdbdbd"  # blue - descreased risk factor
descreased_risk_2 <- "#bdbdbd" # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
# increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
reference_color <- "#4daf4a"   # green  - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor

graph_logistic_point_complex_4(
  ds = ds_predicted_global,
  x_name = "age_in_years",
  y_name = "dv_hat",
  covar_order = covar_order_values,
  alpha_level = .3,
  y_title = dv_label_odds,
  y_range = c(-3.5, 1))


# 3 step of color logic:
increased_risk_2 <- "#bdbdbd"  # red - further increased risk factor
increased_risk_1 <- "#bdbdbd"  # organge - increased risk factor
reference_color <- "#bdbdbd"   # green  - REFERENCE  category
descreased_risk_1 <-"#bdbdbd"  # blue - descreased risk factor
descreased_risk_2 <- "#bdbdbd" # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
reference_color <- "#4daf4a"   # green  - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor

graph_logistic_point_complex_4(
  ds = ds_predicted_global,
  x_name = "age_in_years",
  y_name = "dv_hat",
  covar_order = covar_order_values,
  alpha_level = .3,
  y_title = dv_label_odds,
  y_range = c(-3.5, 1))

# 4 step of color logic:
increased_risk_2 <- "#bdbdbd"  # red - further increased risk factor
increased_risk_1 <- "#bdbdbd"  # organge - increased risk factor
reference_color <- "#bdbdbd"   # green  - REFERENCE  category
descreased_risk_1 <-"#bdbdbd"  # blue - descreased risk factor
descreased_risk_2 <- "#bdbdbd" # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
reference_color <- "#4daf4a"   # green  - REFERENCE  category
descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor

graph_logistic_point_complex_4(
  ds = ds_predicted_global,
  x_name = "age_in_years",
  y_name = "dv_hat",
  covar_order = covar_order_values,
  alpha_level = .3,
  y_title = dv_label_odds,
  y_range = c(-3.5, 1))

# 5 step of color logic:
increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
reference_color <- "#4daf4a"   # green  - REFERENCE  category
descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor

graph_logistic_point_complex_4(
  ds = ds_predicted_global,
  x_name = "age_in_years",
  y_name = "dv_hat",
  covar_order = covar_order_values,
  alpha_level = .3,
  y_title = dv_label_odds,
  y_range = c(-3.5, 1))

# ---- 4-local-odds ----------------------

# 1 step of color logic:
increased_risk_2 <- "#bdbdbd"  # red - further increased risk factor
increased_risk_1 <- "#bdbdbd"  # organge - increased risk factor
reference_color <- "#bdbdbd"   # green  - REFERENCE  category
descreased_risk_1 <-"#bdbdbd"  # blue - descreased risk factor
descreased_risk_2 <- "#bdbdbd" # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
# increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
# reference_color <- "#4daf4a"   # green  - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor


graph_logistic_point_complex_4(
  ds = ds_predicted_study,
  x_name = "age_in_years",
  y_name = "dv_hat",
  covar_order = covar_order_values,
  alpha_level = .3,
  y_title = dv_label_odds,
  y_range = c(-3.5, 1))


# 2 step of color logic:
increased_risk_2 <- "#bdbdbd"  # red - further increased risk factor
increased_risk_1 <- "#bdbdbd"  # organge - increased risk factor
reference_color <- "#bdbdbd"   # green  - REFERENCE  category
descreased_risk_1 <-"#bdbdbd"  # blue - descreased risk factor
descreased_risk_2 <- "#bdbdbd" # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
# increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
reference_color <- "#4daf4a"   # green  - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor


graph_logistic_point_complex_4(
  ds = ds_predicted_study,
  x_name = "age_in_years",
  y_name = "dv_hat",
  covar_order = covar_order_values,
  alpha_level = .3,
  y_title = dv_label_odds,
  y_range = c(-3.5, 1))

# 3 step of color logic:
increased_risk_2 <- "#bdbdbd"  # red - further increased risk factor
increased_risk_1 <- "#bdbdbd"  # organge - increased risk factor
reference_color <- "#bdbdbd"   # green  - REFERENCE  category
descreased_risk_1 <-"#bdbdbd"  # blue - descreased risk factor
descreased_risk_2 <- "#bdbdbd" # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
reference_color <- "#4daf4a"   # green  - REFERENCE  category
# descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor



graph_logistic_point_complex_4(
  ds = ds_predicted_study,
  x_name = "age_in_years",
  y_name = "dv_hat",
  covar_order = covar_order_values,
  alpha_level = .3,
  y_title = dv_label_odds,
  y_range = c(-3.5, 1))


# 4 step of color logic:
increased_risk_2 <- "#bdbdbd"  # red - further increased risk factor
increased_risk_1 <- "#bdbdbd"  # organge - increased risk factor
reference_color <- "#bdbdbd"   # green  - REFERENCE  category
descreased_risk_1 <-"#bdbdbd"  # blue - descreased risk factor
descreased_risk_2 <- "#bdbdbd" # purple - further descrease in risk factor

# increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
reference_color <- "#4daf4a"   # green  - REFERENCE  category
descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
# descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor


graph_logistic_point_complex_4(
  ds = ds_predicted_study,
  x_name = "age_in_years",
  y_name = "dv_hat",
  covar_order = covar_order_values,
  alpha_level = .3,
  y_title = dv_label_odds,
  y_range = c(-3.5, 1))

# 5 step of color logic:
increased_risk_2 <- "#e41a1c"  # red - further increased risk factor
increased_risk_1 <- "#ff7f00"  # organge - increased risk factor
reference_color <- "#4daf4a"   # green  - REFERENCE  category
descreased_risk_1 <-"#377eb8"  # blue - descreased risk factor
descreased_risk_2 <- "#984ea3" # purple - further descrease in risk factor

graph_logistic_point_complex_4(
  ds = ds_predicted_study,
  x_name = "age_in_years",
  y_name = "dv_hat",
  covar_order = covar_order_values,
  alpha_level = .3,
  y_title = dv_label_odds,
  y_range = c(-3.5, 1))



# ---- reproduce ---------------------------------------
rmarkdown::render(
  input = "./sandbox/visualizing-logistic/visualizing-logistic.Rmd" , 
  output_format="html_document", clean=TRUE
)


















