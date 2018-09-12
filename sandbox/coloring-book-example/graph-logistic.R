# # this script contain definition of graphing functions for logistic regression
# ds <- ds_predicted_global
# x_name = "age_in_years"
# y_name = "smoke_now"
# color_group = "female"
# alpha_level = .5

# ---- simple-curve-plot -------------------------------

binomial_smooth <- function(...) {
  geom_smooth(
    method = "glm", 
    method.args = list(family = "binomial"),
    ...
    )
}

graph_logitstic_curve_simple <- function(
  ds, 
  x_name, 
  y_name, 
  color_group, 
  alpha_level=.5
){
  # To fit a logistic regression, you need to coerce the values to
  # a numeric vector lying between 0 and 1.
  d[,y_name] <- as.numeric(d[,y_name])
  
  ggplot(d, aes_string(x_name,y_name,color=color_group )) +
    geom_jitter(height = 0.2, shape=21, fill=NA) +
    binomial_smooth() +
    facet_grid(. ~ study_name) +
    main_theme +
    theme(
      legend.position="right"
    )
}
# graph_logitstic_curve_simple(x_name = "age_in_years",
#                              y_name = "smoke_now",
#                              color_group = "female",
#                              alpha_level = .5)

# ---- complex-curve-plot-4 -----------------------
# covar_order <- c("female","marital","educ3","poor_health")

graph_logitstic_curve_complex_4 <- function(
  ds, 
  x_name, 
  y_name, 
  covar_order,
  alpha_level
){
  g_1 <- graph_logitstic_curve_simple(ds,x_name, y_name, covar_order[1], alpha_level)
  g_2 <- graph_logitstic_curve_simple(ds,x_name, y_name, covar_order[2], alpha_level)
  g_3 <- graph_logitstic_curve_simple(ds,x_name, y_name, covar_order[3], alpha_level)
  g_4 <- graph_logitstic_curve_simple(ds,x_name, y_name, covar_order[4], alpha_level)
  
  grid::grid.newpage()    
  #Defnie the relative proportions among the panels in the mosaic.
  layout <- grid::grid.layout(nrow=4, ncol=1,
                              widths=grid::unit(c(1), c("null")),
                              heights=grid::unit(c(.2, .2, .2,.2,.2) ,c("null","null","null","null","null"))
  )
  grid::pushViewport(grid::viewport(layout=layout))
  print(g_1,  vp=grid::viewport(layout.pos.row=1, layout.pos.col=1 ))
  print(g_2,  vp=grid::viewport(layout.pos.row=2, layout.pos.col=1 ))
  print(g_3,  vp=grid::viewport(layout.pos.row=3, layout.pos.col=1 ))
  print(g_4,  vp=grid::viewport(layout.pos.row=4, layout.pos.col=1 ))
  grid::popViewport(0)
  
} 
# graph_logitstic_curve_complex_4(
#   ds = d,
#   x_name = "age_in_years",
#   y_name = "smoke_now",
#   covar_order = c("female","marital","educ3","poor_health"),
#   alpha_level = .3)
# 






# ---- simple-point-plot ------------------------------------
# ds = ds_predicted_global
# x_name = "age_in_years"
# y_name = "smoke_now_hat"
# color_group = "female"
# alpha_level=.5
graph_logistic_point_simple <- function(
  ds, 
  x_name, 
  y_name, 
  color_group, 
  alpha_level=.5,
  x_title = x_name,
  y_title = y_name,
  color_title = color_group
){
  palette_color <- assign_color(color_group)
  g <- ggplot2::ggplot(ds, aes_string(x=x_name)) +
    geom_point(aes_string(y=y_name, color=color_group), shape=16, alpha=alpha_level) +
    scale_color_manual(values = palette_color) +
    facet_grid(. ~ study_name) + 
    main_theme +
    theme(
      legend.position="right"
    ) +
    labs(x=x_title, y = y_title, color = color_title) +
    guides(color = guide_legend(override.aes = list(alpha=1, size=6, shape=15)))
  # return(g)
}

# g <- graph_logistic_point_simple(
#   ds = ds_predicted_global,
#   x_name = "age_in_years",
#   y_name = "smoke_now_hat",
#   color_group = "female",
#   alpha_level = .5
# )

# ---- complex-point-plot-4 -----------------------
# covar_order <- c("female","educ3_f","marital_f", "poor_health")

graph_logistic_point_complex_4 <- function(
  ds, 
  x_name, 
  y_name, 
  covar_order,
  alpha_level,
  y_title = y_name,
  color_title = "predictor",
  y_range =NULL
){
  # function for stripping legends from plots
  g_legend<-function(a.gplot){
    tmp <- ggplot_gtable(ggplot_build(a.gplot))
    leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
    legend <- tmp$grobs[[leg]]
    legend
  }
  
  plot1 <- graph_logistic_point_simple(ds,x_name, y_name, covar_order[1], alpha_level, x_title ="", y_title = y_title, color_title = "Female") 
  legend1 <- g_legend(plot1)
  plot1 <- plot1 + theme(legend.position="none") + coord_cartesian(ylim = y_range) 
  
  plot2 <- graph_logistic_point_simple(ds,x_name, y_name, covar_order[2], alpha_level, x_title ="", y_title = y_title, color_title = "Education") 
  legend2 <- g_legend(plot2)
  plot2 <- plot2 + theme(legend.position="none")+ coord_cartesian(ylim = y_range) 
  
  
  plot3 <- graph_logistic_point_simple(ds,x_name, y_name, covar_order[3], alpha_level, x_title ="", y_title = y_title, color_title = "Marital") 
  legend3 <- g_legend(plot3)
  plot3 <- plot3 + theme(legend.position="none")+ coord_cartesian(ylim =y_range) 
  
  
  plot4 <- graph_logistic_point_simple(ds,x_name, y_name, covar_order[4], alpha_level, x_title = "Age", y_title = y_title, color_title = "Poor health") 
  legend4 <- g_legend(plot4)
  plot4 <- plot4 + theme(legend.position="none")+ coord_cartesian(ylim = y_range) 
  
  blankPlot <- ggplot()+geom_blank(aes(1,1)) +
    	  cowplot::theme_nothing()
  
  main_title <- cowplot::ggdraw() + cowplot::draw_label(eq_global_string, fontface='bold')
  
  # gridExtra::grid.arrange( plot1, legend1, plot2, legend2, plot3, legend3, plot4, legend4,
  #                          ncol=2,  nrow=4,
  #                          widths=c(9,1.5)
  #                          # hieghts=c(1)
  # )
  cowplot::plot_grid( main_title,blankPlot, plot1, legend1, plot2, legend2, plot3, legend3, plot4, legend4,
                           ncol=2,  nrow=5,
                           rel_widths = c(9,1.5), align = "none", 
                           rel_heights=c(.2, 1, 1, 1, 1)
  )
} # close function
# graph_logistic_point_complex_4(
#   ds = ds_predicted_global,
#   x_name = "age_in_years",
#   y_name = "smoke_now_hat_p",
#   covar_order = c("female","marital_f","educ3_f","poor_health"),
#   alpha_level = .3,
#   y_title = "P(smoke_now)",
#   y_low = 0,
#   y_hi = 1)

# 
# x_title = "b"
# y_title ="c"






















###### OLD GRAPH BELOW = STUDY AS ROWS ################
graph_logistic_simple_vfacet <- function(ds, x_name, y_name, color_group, alpha_level=.5){
  g <- ggplot2::ggplot(ds, aes_string(x=x_name)) +
    geom_point(aes_string(y=y_name, color=color_group), shape=16, alpha=alpha_level) +
    facet_grid(study_name ~ .) + 
    main_theme +
    theme(
      legend.position="top"
    )
  # return(g)
}
# g <- graph_logistic_simple(ds=ds,"age_in_years", "smoke_now_p", "sex", .3)
# g





# ---- define-complex-3-graph-function-study-row -----------------------

graph_logistic_complex_3 <- function(
  ds, 
  x_name, 
  y_name, 
  alpha_level
){
  g_female <- graph_logistic_simple(ds,x_name, y_name, "female", alpha_level)
  g_marital <- graph_logistic_simple(ds,x_name, y_name, "marital", alpha_level)
  g_educ <- graph_logistic_simple(ds,x_name, y_name, "educ3", alpha_level)
  
  grid::grid.newpage()    
  #Defnie the relative proportions among the panels in the mosaic.
  layout <- grid::grid.layout(nrow=1, ncol=3,
                              widths=grid::unit(c(.333, .333, .333) ,c("null","null","null")),
                              heights=grid::unit(c(1), c("null"))
  )
  grid::pushViewport(grid::viewport(layout=layout))
  print(g_female,     vp=grid::viewport(layout.pos.row=1, layout.pos.col=1 ))
  print(g_marital, vp=grid::viewport(layout.pos.row=1, layout.pos.col=2 ))
  print(g_educ,    vp=grid::viewport(layout.pos.row=1, layout.pos.col=3 ))
  grid::popViewport(0)
  
} 
# graph_logistic_complex_3(ds=d,"age_in_years", "smoke_now_p", .3)


# ---- define-complex-8-graph-function-study-row -----------------------
graph_logistic_complex_8 <- function(
  ds, 
  x_name, 
  y_name, 
  alpha_level
){
  g_sex <- graph_logistic_simple(ds,x_name, y_name, "sex", alpha_level)
  g_marital <- graph_logistic_simple(ds,x_name, y_name, "marital", alpha_level)
  g_educ <- graph_logistic_simple(ds,x_name, y_name, "educ3", alpha_level)
  
  grid::grid.newpage()    
  #Defnie the relative proportions among the panels in the mosaic.
  layout <- grid::grid.layout(nrow=1, ncol=8,
                              widths=grid::unit(c(.125, .125, .125, .125,
                                                  .125, .125, .125, .125) ,
                                                c("null","null","null","null",
                                                  "null","null","null","null")),
                              heights=grid::unit(c(1), c("null"))
  )
  grid::pushViewport(grid::viewport(layout=layout))
  print(g_sex,     vp=grid::viewport(layout.pos.row=1, layout.pos.col=1 ))
  print(g_marital, vp=grid::viewport(layout.pos.row=1, layout.pos.col=2 ))
  print(g_educ,    vp=grid::viewport(layout.pos.row=1, layout.pos.col=3 ))
  grid::popViewport(0)
  
} 
# graph_logistic_complex_8(ds=d,"age_in_years", "smoke_now_p", .3)
