

# work only when includeobjects = T in the glmulti call
# given a subset object shows the top five models
show_best_subset <- function(
  subset_object,
  top_n = 5
){
  (top_models <- basic_model_info(subset_object@objects[[1]]))
  for(i in 2:top_n){
    top_models <- rbind(top_models, basic_model_info(subset_object@objects[[i]]))
  }
  print(knitr::kable(top_models))
  cat("\n")
  for(i in 1:top_n){
    cat("Model ",i," : ", sep="")
    print(subset_object@formulas[[i]], showEnv = F)
  }
}

# work only when includeobjects = T in the glmulti call
# Print model report comparing a custom model with a subset object
model_report <- function(
  model_object,
  subset_object,
  top_n = 5
){
  # cat("Fitted model || ")
  print(model_object$formula, showEnv = F)
  # cat("Model Information \n")
  print(knitr::kable(basic_model_info(model_object)))
  cat("\n Best subset selection using the same predictors : \n\n")
  print(show_best_subset(subset_object, top_n))
}


# ----- tabulating-functions -------------------------------------
make_within_set_table <- function(
  model_object, # object of class lm,glm, lmer or the like | fixed set model
  subset_object, # object of class glmulti | subset of competing models
  set_id, # character(s) identifying the type of predictor set
  top_n = 3, # number of top models to include
  return_list=F # should return list object instead of a data table?
){
  # Values for testing and development
  # model_object <- ls_mA$m
  # subset_object <- ls_mA$bs
  # set_id = "A"
  # top_n = 3
  
  null_model_name  <- paste0(set_id,"_",0)
  best_model_names <- paste0(set_id,"_", 1:top_n)
  
  (model_names <- c(null_model_name, best_model_names))
  
  ls_model <- list()
  ls_model[[null_model_name]] <- model_object
  for(i in seq_along(best_model_names) ){
    ls_model[[ best_model_names[i] ]] <- subset_object@objects[[i]]
  }
  if(return_list){
    return(ls_model)
  }else{
    ls_table <- list()
    for(i in model_names){ls_table[[i]] <- make_result_table(ls_model[[i]])}
    d_results <- plyr::ldply(ls_table, .id = "model_type")
    return(d_results)
  }
}
# Usage
# ls_mA <- readRDS("./data-phi-free/derived/models/glm/mA.rds")
# ds_results <- make_within_set_table(
#   model_object = ls_mA$m,
#   subset_object = ls_mA$bs,
#   set_id = "A",
#   top_n = 2,
#   return_list = F
# )

# make a between table for a single set
# takes in the output of make_within_set_table()
display_within_set_table <- function(ds_results){
  x <- ds_results
  x$dense <- sprintf("%5s(%4s)%s", x$est, x$se, x$sign)
  x$dense <- format(x$dense, align="left")
  x <- x[, c("model_type", "coef_name", "dense")]
  # x <- plyr::rename(x, replace = c("dense" = model_label))
  d <- tidyr::spread(x, model_type, dense)
  d[is.na(d)] <- ""
  return(d)
}
# Usage:
# display_within_set_table(ds_results)


# function creates a column of dense display from a table of results for a single model
display_one_model <- function(model_object, model_label){
  x <- make_result_table(model_object)
  x$dense <- sprintf("%5s(%4s)%s", x$est, x$se, x$sign)
  x$dense <- format(x$dense, align="left")
  x <- x[, c("coef_name", "dense")]
  x <- plyr::rename(x, replace = c("dense" = model_label))
  return(x)
}
#Usage:
# display_one_model(model_object,"A")


# funtion to remove leading zero
numformat <- function(val) { sub("^(-?)0.", "\\1.", sprintf("%.2f", val)) }

###################################
#### ESTIMATION FUNCTIONS ####################
#########################################


# Custom model estimation
estimate_pooled_model <- function(data, predictors){
  eq_formula <- as.formula(paste0(pooled_stem, predictors))
  print(eq_formula, showEnv = FALSE)
  models <- glm(eq_formula, data = data, family = binomial(link="logit"))
  basic_model_info(models)
  return(models)
}

# estimate model locally within each study
estimate_local_models <- function(data, predictors){
  eq_formula <- as.formula(paste0(local_stem, predictors))
  print(eq_formula, showEnv = FALSE)
  model_study_list <- list()
  for(study_name_ in dto[["studyName"]]){
    d_study <- data[data$study_name==study_name_, ]
    model_study <- glm(eq_formula, data=d_study,  family=binomial(link="logit"))
    model_study_list[[study_name_]] <- model_study
  }
  return(model_study_list)
}



# Best Subset estimation

# Define a general function
estimate_best_subset <- function(data, predictors, eq_formula, level, method, plotty, includeobjects){
  # eq_formula <- as.formula(paste0(local_stem, predictors))
  best_subset_local <- glmulti::glmulti(
    eq_formula,
    data = data,
    level = level,           # 1 = No interaction considered
    method = method,            # Exhaustive approach
    crit = "aicc",            # AIC as criteria
    confsetsize = 100,         # Keep 5 best models
    plotty = plotty, report = T,  # No plot or interim reports
    fitfunction = "glm",     # glm function
    family = binomial,       # binomial family for logistic regression family=binomial(link="logit")
    includeobjects = includeobjects
  )
}
# Define specific function for (pooled)
estimate_pooled_model_best_subset <- function(data, predictors, level, method, plotty, includeobjects){
  eq_formula <- as.formula(paste0(pooled_stem, predictors))
  print(eq_formula, showEnv = FALSE)
  best_subset <- estimate_best_subset(data=data,predictors,eq_formula, level, method, plotty, includeobjects)
  if(length(best_subset@objects)>1L ){
    show_best_subset(best_subset)
  }
  return(best_subset)
}
# Define specific function for (study local)
estimate_local_models_best_subset <- function(data, predictors, level, method, plotty, includeobjects){
  eq_formula <- as.formula(paste0(local_stem, predictors))
  print(eq_formula, showEnv = FALSE)
  model_study_list <- list()
  for(study_name_ in as.character(sort(unique(data$study_name)))){
    d_study <- data[data$study_name==study_name_, ]
    # browser()
    best_subset_local <- estimate_best_subset(data=d_study,predictors,eq_formula, level, method, plotty, includeobjects)
    model_study_list[[study_name_]] <- best_subset_local
  }
  return(model_study_list)
}

# for(i in 1:5){
#   cat("Model ",i," : ", sep="")
#   print(models@formulas[[i]], showEnv = F)
# }
# for(i in 1:5){
#   basic_model_info(models@objects[[i]])
# }




# # Print local model report
# local_model_report <- function(data, model_object, best_subset){
#   for(study_name_ in as.character(sort(unique(data$study_name))) ){
#     cat("Study : ", study_name_, "\n",sep="")
#     # model_object = local_A[[study_name_]]
#     # best_subset  = local_A_bs[[study_name_]]
#     model_report(model_object= model_object, best_subset = best_subset)
#     cat("\n\n")
#   }
# }