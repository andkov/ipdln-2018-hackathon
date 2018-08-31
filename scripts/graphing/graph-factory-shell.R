# the following script is to be used as a starting point for graph production

# create three functions that collectivelly will consitute the graphing tool

# Graphing Tool:
# 1. Prepare Data - `prepare_data_code_name()`
# 2. Make    Plot -    `make_plot_code_name()`
# 3. Print   Plot -   `print_plot_code_name()`

# We will use the list object `l_support` to accrue all relevant objects for display production

# ----- function-prepare-data ---------------
# enter data description here
prepare_data_code_name <- function(
  d_input
  ,...
){ 
  # values for testing
  d_input <- ds_total
  # support functions
  
  d1 <- d_input
  
  l_support <- list()
  l_support[["dataframe"]] <- d1
  
  return(l_support)
} # how to use:
l_support <- ds_input %>%
  # dplyr::filter(...) %>% # optional filtering to scope application
  prepare_data_code_name(
    ...
)

# ----- function-make-plot ---------------
# enter plot description here
make_plot_code_name <- function(
  l_support
){
  
  # get data frame from the support object
  d1 <- l_support[["dataframe"]]
  
  # script the plot
  g1 <- d1 %>% 
    ggplot2::ggplot()  
  # add layers
  g2 <- g1 + theme()
  
  # add the plot to the support object 
  l_support[["plots"]][["metric_scatter"]] <- g2 # `metric_scatter` is an example of label
  
  return(l_support)
}
# how to use: 
# Technically, we are adding an object (plot) to the support list object created by prepare_data_*() function
l_support <- ds_input %>%
  # dplyr::filter(...) %>% # optional filtering to scope application
  prepare_data_code_name(...) %>%
  make_plot_code_name(...)

# ----- function-print-plot ---------------
print_plot_code_name <- function(
  l_support
  ,path_output_folder = "./reports/report-code-name/prints/"
  ,plot_to_print# = "fx_groups",
  # ,width_value  = 2000
  # ,hieght_value = 2000
  # ,units_value  = "px"
  # ,dpi_value    = 2000
){
  
  # path_output_folder = "./reports/report-code-name/prints/"
  # plot_to_print = "fx_groups"
  # width_px      = 1200
  # height_px     = 1200
  # dpi = 300
  # create a file path to save the print
  
  path_save_plot <- paste0(...) %>% print()
  
  # png(
  #   filename = paste0(path_save_plot, ".png")
  #   ,width = 1700
  #   ,height = 1100
  #   ,units = "px"
  #   ,res = 600
  # )
  # print the graphical object using jpeg device
  jpeg(
    filename = paste0(path_save_plot, ".jpg")
    ,width = 3400
    ,height = 2200
    ,units = "px"
    # ,pointsize =
    ,quality = 100
    ,res = 200
  )
  # jpeg(
  #   filename  = paste0(path_save_plot, ".jpg")
  #   width     = width_value,
  #   height    = hieght_value, # or some formula (e.g. height_base + height_step*l_support$specs$n_rows)
  #   # width     = width_px,
  #   # height    = height_px, # or some formula (e.g. height_base + height_step*l_support$specs$n_rows)
  #   # units     = "px",
  #   units     = units_value,
  #   quality   = dpi
  #   # res   = dpi
  #   pointsize = 6,
  # )
  # print using pdf device
  # pdf(
  #   file = paste0(path_save_plot, ".pdf")
  #   ,width = width_value
  #   ,height = hieght_value
  #   ,pointsize = 12
  #
  # )
  
  l_support$plots[[plot_to_print]] %>% print() # reach into the custom object we made for graphing
  dev.off() # close the device
}
# how to use:
l_support <-
  ds_class_patient %>%
  # dplyr::filter(...) %>%
  prepare_data_code_name(...) %>%
  make_plot_code_name(...)
l_support %>% print_plot_(...)

# ---- serial-application -------------------------

# demonstration of a serial application
(service_location_names <- ds_location_map %>% distinct(service_location, na.rm=T))
for(s in service_location_names){
  s = "Hospital"
  coh = "schizo"
  
  l_support <- ds_class_patient %>% 
    dplyr::filter(service_location == s) %>% 
    dplyr::filter(id %in% ls_cohort_definitions[[coh]] ) %>% 
    
    prepare_data_class_panorama() %>% 
    make_plot_class_panorama()
  # overwrite the plot's title to add secondary groupping componnet
  l_support$plots$fx_groups <- l_support$plots$fx_groups+
    labs(
      title = paste0(l_support$specs$main_title_fx_group, " | ","service_location = ", toupper(s))
    )
  l_support %>% 
    print_plot_class_panorama("./reports/cohort-class-panorama/prints/", "fx_groups")
  
  
}