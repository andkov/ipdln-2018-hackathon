
###################################
#### REPORTING FUNCTIONS ####################
#########################################

# ---- model-solution-table ---------------------------------------

# given a glm object produces a table of model information indices
basic_model_info <- function(
  model_object,
  eq=F
){
  if(eq){
    cat("Model equation :")
    print(model_object$formula, showEnv = F)
    cat("\n")
  }
  (logLik<-logLik(model_object))
  (dev<-deviance(model_object))
  (AIC <- round(AIC(model_object),1))
  (BIC <- round(BIC(model_object),1))
  (dfF <- round(model_object$df.residual,0))
  (dfR <- round(model_object$df.null,0))
  (dfD <- dfR - dfF)
  (model_Info <- t(c("logLik"=logLik,"dev"=dev,"AIC"=AIC,"BIC"=BIC, "df_Null"=dfR, "df_Model"=dfF, "df_drop"=dfD)))
  # return(model_Info)
  model_Info <- as.data.frame(model_Info)
  return(model_Info)
  # print(knitr::kable(model_Info))
  # print(model_Info)
}


# given a glm object computes odds and creates a results table
make_result_table <- function(
  model_object
){
  (cf <- summary(model_object)$coefficients)
  # (cf <- model_object$coefficients)
  # (ci <- exp(cbind(coef(model_object), confint(model_object))))
  # (ci <- exp(cbind(coef(model_object), confint(model_object))))

  # if(ncol(ci)==2L){
  #   (ci <- t(ci)[1,])
  #   ds_table <- cbind.data.frame("coef_name" = rownames(cf), cf,"V1"=NA,"2.5 %" = ci[1], "97.5 %"=ci[2])
  # }else{
    # ds_table <- cbind.data.frame("coef_name" = rownames(cf), cf,ci)
  # }
  ds_table <- cbind.data.frame("coef_name" = rownames(cf), cf)
  row.names(ds_table) <- NULL
  ds_table <- plyr::rename(ds_table, replace = c(
    "Estimate" = "estimate",
    "Std. Error"="sderr",
    # "z value" ="zvalue",
    "t value" ="tvalue",
    "Pr(>|t|)"="pvalue"
    # "V1"="odds",
    # "2.5 %"  = "ci95_low",
    # "97.5 %"  ="ci95_high"
  ))
  # prepare for display
  ds_table$est <- gsub("^([+-])?(0)?(\\.\\d+)$", "\\1\\3", round(ds_table$estimate, 2))
  ds_table$se <- gsub("^([+-])?(0)?(\\.\\d+)$", "\\1\\3", round(ds_table$sderr, 2))
  ds_table$t <- gsub("^([+-])?(0)?(\\.\\d+)$", "\\1\\3", round(ds_table$tvalue, 3))
  # ds_table$z <- gsub("^([+-])?(0)?(\\.\\d+)$", "\\1\\3", round(ds_table$zvalue, 3))
  # ds_table$p <- gsub("^([+-])?(0)?(\\.\\d+)$", "\\1\\3", round(ds_table$pvalue, 4))
  ds_table$p <- as.numeric(round(ds_table$pvalue, 4))
  # ds_table$odds <- gsub("^([+-])?(0)?(\\.\\d+)$", "\\1\\3", round(ds_table$odds, 2))
  # ds_table$odds_ci <- paste0("(",
  #                            gsub("^([+-])?(0)?(\\.\\d+)$", "\\1\\3", round(ds_table$ci95_low,2)), ",",
  #                            gsub("^([+-])?(0)?(\\.\\d+)$", "\\1\\3", round(ds_table$ci95_high,2)), ")"
  # )

  ds_table$sign_ <- cut(
    x = ds_table$pvalue,
    breaks = c(-Inf, .001, .01, .05, .10, Inf),
    labels = c("<=.001", "<=.01", "<=.05", "<=.10", "> .10"), #These need to coordinate with the color specs.
    right = TRUE, ordered_result = TRUE
  )
  ds_table$sign <- cut(
    x = ds_table$pvalue,
    breaks = c(-Inf, .001, .01, .05, .10, Inf),
    labels = c("***", "**", "*", ".", " "), #These need to coordinate with the color specs.
    right = TRUE, ordered_result = TRUE
  )
  # ds_table$display_odds <- paste0(ds_table$odds," ",ds_table$sign , "\n",  ds_table$odds_ci)

  ds_table <- ds_table %>%
    dplyr::select_(
      "sign",
      "coef_name",
      # "odds",
      # "odds_ci",
      "est",
      "se",
      "p",
      "sign_"
    )

  return(ds_table)
}

