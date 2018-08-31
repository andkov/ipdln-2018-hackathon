missing_summary <- function(x){
  ms <- x %>% naniar::miss_summary() %>% as.list()
  cat("\nOverall % of missing data: ",sprintf("%.2f",ms$miss_df_pct),"%")
  cat("\nVariables that contain missing data: ",sprintf("%.2f",ms$miss_var_pct),"%")
  cat("\nCases that contain missing data: ",sprintf("%.2f",ms$miss_case_pct),"%")
}
# d %>% missing_summary()

# scatter
show_missing_points <- function(
  d,
  xvar,
  yvar
){
  g <- ggplot2::ggplot(data=d, aes_string(x=xvar,y=yvar))+
    naniar::geom_missing_point()+
    theme_bw()
  g
}

# composite graph
expose_missing <- function(
  x,
  pivot,
  varname
){
  # varname = "agriculture"
  # pivot   = "mortality_kid_log"
  varname_na <- paste0(varname,"_NA")

  d_shadow <- naniar::bind_shadow(x)

  p1 <- ggplot2::ggplot(d_shadow,aes_string(x=pivot))+
    geom_histogram()
  cstring <- paste0("p1 <- p1 + facet_wrap(~",varname_na,",ncol=1)")
  eval(parse(text=cstring)) # evaluates the content of the command string
  p1 <- p1 + theme_minimal()
  p1

  p2 <- ggplot2::ggplot(d_shadow,aes_string(x=pivot))
  cstring <- paste0("p2 <- p2 + geom_density(aes(color=",varname_na,",fill=",varname_na,"),alpha=.3)")
  eval(parse(text=cstring))
  p2 <- p2 + theme_bw()
  p2 <- p2 + theme(legend.position="bottom")

  p3 <- show_missing_points(d_shadow,pivot,varname)+
    theme(legend.position="bottom")

  gridExtra::grid.arrange( p1,p2,p3,nrow=1)
}

# bar graph of number of missing in each variable
missing_counts_var <- function(
  x,
  print_table=FALSE,
  sort=TRUE
){

  # x <- ds %>%
  #   dplyr::select_(.dots = c(outcome_name,main_effects))
  #
  if(sort){
    d <- x %>%
      naniar::miss_var_summary() %>%
      dplyr::arrange(n_missing)
  }else{
    d <- x %>%
      naniar::miss_var_summary() %>%
      dplyr::arrange(variable)
  }
  if(print_table){
    knitr::kable(d)
  }

  g <- d %>%
    dplyr::mutate(
      percent_pretty = paste0(sprintf("%.1f",percent),"%")
    ) %>%
    dplyr::mutate(
      percent_pretty = paste0(sprintf("%.1f",percent),"%")
    ) %>%
    # ggplot2::ggplot(aes(x=reorder(variable,percent),y=n_missing))+
    ggplot2::ggplot(aes(y=reorder(variable,percent),x=n_missing))+
    geom_point(shape=124, size=5)+
    theme_bw()+
    # geom_segment(aes(xend=n_missing), yend=0, colour="grey50")+
    # geom_segment(aes(yend=n_missing), xend=0, colour="grey50")+
    geom_text(aes(label=percent_pretty), hjust = -.1, vjust=.4, colour="black")#+
  # coord_flip()
  g

}
# d %>% missing_counts_var()


# raster graph to reveal co-missingines patterns
comissing_raster <- function(x,cluster=TRUE, sort_miss=TRUE){
  g <- x %>%
    naniar::vis_miss(cluster=cluster, sort_miss = sort_miss)+
    coord_flip()
  g
}


