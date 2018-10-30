
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
  # browser()
  set.seed(42) # for constant jitter
  palette_color <- assign_color(color_group)
  g <- ggplot2::ggplot(ds, aes_string(x=x_name)) +
    # geom_point(aes_string(y=y_name, color=color_group), shape=16, alpha=alpha_level) +
    geom_jitter(
      aes_string(
        y      = y_name
        ,fill = color_group
        # ,color = color_group
      )
      # ,shape = 16, alpha = alpha_level) +
      # ,shape = 21, alpha = alpha_level, color = "grey70") +
      ,shape = 21, alpha = alpha_level, size = 5 ) +

    # scale_color_manual(values = palette_color) +
    scale_fill_manual(values = palette_color) +
    facet_grid(. ~ PR) + 
    main_theme +
    theme(
      legend.position="right"
      ,legend.title = element_text(size = baseSize + 20)
      ,legend.text  = element_text(size = baseSize + 16 )
      ,strip.text = element_text(size = baseSize + 10) 
      ,strip.background =element_rect(fill="white", color = "white")
      ,axis.text.y  = element_text(size=baseSize + 8)
      ,axis.text.x  = element_text(size=baseSize + 2)
      ,axis.title.y = element_text(size=baseSize + 12, color = "grey50")
      ,axis.title.x = element_text(size=baseSize + 20, color = "grey50", vjust = 1)
      
    ) + 
    labs(
      x=x_title
      , y = y_title
      # , color = color_title
      , fill = color_title
      )+
    guides(
    fill = guide_legend(override.aes = list(alpha=1, size=16))
    # color = guide_legend(override.aes = list(alpha=1, size=6, shape=15))
    )
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
  # browser()
  # function for stripping legends from plots
  g_legend<-function(a.gplot){
    tmp <- ggplot_gtable(ggplot_build(a.gplot))
    leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
    legend <- tmp$grobs[[leg]]
    legend
  }
  
  matrix_row_labels <- covar_order
  plot1 <- graph_logistic_point_simple(ds,x_name, y_name, covar_order[1], alpha_level, x_title ="", y_title = y_title, color_title = matrix_row_labels[1])
  plot2 <- graph_logistic_point_simple(ds,x_name, y_name, covar_order[2], alpha_level, x_title ="", y_title = y_title, color_title = matrix_row_labels[2])
  plot3 <- graph_logistic_point_simple(ds,x_name, y_name, covar_order[3], alpha_level, x_title ="", y_title = y_title, color_title = matrix_row_labels[3])
  plot4 <- graph_logistic_point_simple(ds,x_name, y_name, covar_order[4], alpha_level, x_title = "Age (floor of a 5-year group)", y_title = y_title, color_title = matrix_row_labels[4])
  
  # # manual overwrite for two cases (not advised, but may be necessary)
  # # case 1 : female marital educ3 poor_health
  # plot1 <- graph_logistic_point_simple(ds,x_name, y_name, covar_order[1], alpha_level, x_title ="", y_title = y_title, color_title = "Female")
  # plot2 <- graph_logistic_point_simple(ds,x_name, y_name, covar_order[2], alpha_level, x_title ="", y_title = y_title, color_title = "Marital Status")
  # plot3 <- graph_logistic_point_simple(ds,x_name, y_name, covar_order[3], alpha_level, x_title ="", y_title = y_title, color_title = "Education")
  # plot4 <- graph_logistic_point_simple(ds,x_name, y_name, covar_order[4], alpha_level, x_title = "Age (floor of a 5-year group)", y_title = y_title, color_title = "Poor health")
  # 
  # # case 2 : educ poor_health first conversational
  # plot1 <- graph_logistic_point_simple(ds,x_name, y_name, covar_order[1], alpha_level, x_title ="", y_title = y_title, color_title = "Marital Status")
  # plot2 <- graph_logistic_point_simple(ds,x_name, y_name, covar_order[2], alpha_level, x_title ="", y_title = y_title, color_title = "Education")
  # plot3 <- graph_logistic_point_simple(ds,x_name, y_name, covar_order[3], alpha_level, x_title ="", y_title = y_title, color_title = "Poor Health")
  # plot4 <- graph_logistic_point_simple(ds,x_name, y_name, covar_order[4], alpha_level, x_title = "Age (floor of a 5-year group)", y_title = y_title, color_title = "First Language")

  # corrections
  legend1 <- g_legend(plot1)
  plot1 <- plot1 + theme(legend.position="none") + coord_cartesian(ylim = y_range) + theme(axis.title.x = element_blank()) 
  
  legend2 <- g_legend(plot2)
  plot2 <- plot2 + theme(legend.position="none")+ coord_cartesian(ylim = y_range) 
  
  legend3 <- g_legend(plot3)
  plot3 <- plot3 + theme(legend.position="none")+ coord_cartesian(ylim =y_range) 
  
  legend4 <- g_legend(plot4)
  plot4 <- plot4 + theme(legend.position="none")+ coord_cartesian(ylim = y_range) 
  
  blankPlot <- ggplot()+geom_blank(aes(1,1)) +
    	  cowplot::theme_nothing()
  
  main_title <- cowplot::ggdraw() + cowplot::draw_label(eq_global_string, fontface='bold',size = baseSize + 16)
  
  # gridExtra::grid.arrange( plot1, legend1, plot2, legend2, plot3, legend3, plot4, legend4,
  #                          ncol=2,  nrow=4,
  #                          widths=c(9,1.5)
  #                          # hieghts=c(1)
  # )
  cowplot::plot_grid( main_title,blankPlot, plot1, legend1, plot2, legend2, plot3, legend3, plot4, legend4,
                           ncol=2,  nrow=5,
                           rel_widths = c(9,3), align = "left", 
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
    facet_grid(. ~ PR) +
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





