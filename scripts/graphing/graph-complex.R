
#########################################################
### Declare functions to build complex graphs
#########################################################
# frequently, using products of elemental graphs as constituents

complex_line <- function(
  ds, 
  variable_name,
  line_size   =.5, 
  line_alpha  =.5,
  # top_y = max(ds[,variable_name]),  
  # bottom_y = min(ds[,variable_name]),  
  # by_y = round(top_y/10,0),
  bottom_age  = 60,
  top_age     = 100,
  bottom_time = 0,
  top_time    = 20
){
  # d <- dto[["unitData"]]
  d <- ds
  # browser()
  g11 <- elemental_line(d, variable_name, "age_at_visit", "black", line_alpha, line_size, F)
  g21 <- elemental_line(d, variable_name, "age_at_visit", "salmon", line_alpha, line_size, T)
  g12 <- elemental_line(d, variable_name, "fu_year", "black", line_alpha, line_size, F)
  g22 <- elemental_line(d, variable_name, "fu_year", "salmon", line_alpha, line_size, T)
  
  g13 <- elemental_line(d, variable_name, "date_at_visit", "black", line_alpha, line_size, F)
  g23 <- elemental_line(d, variable_name, "date_at_visit", "salmon", line_alpha, line_size, T)
  # d_observed,
  # variable_name = "cogn_global",
  # time_metric, 
  # color_name="black",
  # line_alpha=.5,
  # line_size =.5, 
  # smoothed = FALSE,
  # main_title     = variable_name,
  # x_title        = paste0("Time metric: ", time_metric),
  # y_title        = variable_name,
  # rounded_digits = 0L
  # 
  
  
  
  g11 <- g11 + labs(x="Age at visit")
  g21 <- g21 + labs(x="Age at visit")
  
  g12 <- g12 + labs(x="Follow-up year")
  g22 <- g22 + labs(x="Follow-up year")
  
  g13 <- g13 + labs(x="Date at visit")
  g23 <- g23 + labs(x="Date at visit")
  
  # bottom_age <- 60
  # top_age <- 100
  # bottom_time <- 0
  # top_time <- 20
  
  g11 <- g11 + scale_x_continuous(breaks=seq(bottom_age,top_age,by=5), limits=c(bottom_age,top_age))
  g21 <- g21 + scale_x_continuous(breaks=seq(bottom_age,top_age,by=5), limits=c(bottom_age,top_age))
  
  g12 <- g12 + scale_x_continuous(breaks=seq(bottom_time,top_time,by=5), limits=c(bottom_time,top_time))
  g22 <- g22 + scale_x_continuous(breaks=seq(bottom_time,top_time,by=5), limits=c(bottom_time,top_time))
  
  # top_y <- 10
  # bottom_y <- 0
  # by_y <- 1
  
  # g11 <- g11 + scale_y_continuous(breaks=seq(bottom_y,top_y,by=by_y), limits=c(bottom_y,top_y))
  # g21 <- g21 + scale_y_continuous(breaks=seq(bottom_y,top_y,by=by_y), limits=c(bottom_y,top_y))
  # g12 <- g12 + scale_y_continuous(breaks=seq(bottom_y,top_y,by=by_y), limits=c(bottom_y,top_y))
  # g22 <- g22 + scale_y_continuous(breaks=seq(bottom_y,top_y,by=by_y), limits=c(bottom_y,top_y))
  # 
  
  # b <- b + scale_y_continuous(limits=c(-5,5 )) 
  grid::grid.newpage()    
  #Defnie the relative proportions among the panels in the mosaic.
  layout <- grid::grid.layout(nrow=2, ncol=3,
                              widths=grid::unit(c(.33, .33, .34) ,c("null","null", "null")),
                              heights=grid::unit(c(.5, .5), c("null","null"))
  )
  grid::pushViewport(grid::viewport(layout=layout))
  print(g11, vp=grid::viewport(layout.pos.row=1, layout.pos.col=1 ))
  print(g21, vp=grid::viewport(layout.pos.row=2, layout.pos.col=1 ))
  
  print(g12, vp=grid::viewport(layout.pos.row=1, layout.pos.col=2 ))
  print(g22, vp=grid::viewport(layout.pos.row=2, layout.pos.col=2 ))
  
  print(g13, vp=grid::viewport(layout.pos.row=1, layout.pos.col=3 ))
  print(g23, vp=grid::viewport(layout.pos.row=2, layout.pos.col=3 ))
  
  grid::popViewport(0)
  
} 
