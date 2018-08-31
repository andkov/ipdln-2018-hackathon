# load common object definitions
source("./manipulation/object-glossary.R")

# function to compute a summary of unique combinations
count_unique_addresses <- function(d, keys=FALSE){
  # d <- ds_location_map
  # d <- ds_map
  # d <- ds
  
  if(!keys){
    cerner_address <- cerner_address_names
  }else{
    cerner_address <- cerner_address_keys
  }
  # assemble the coordinates into unique EHR address
  ehr_address_names <- c( cerner_address,  data_warehouse_address  )
  # count unique values in each elements of the EHR address
  counts <- c()
  for( i in ehr_address_names){
    # counts[i] <- length(unique(d[,i]))
   counts[i] <- as.data.frame(d)[,i] %>% unique() %>% length()
  }
  counts
  counts["sfbu"] <- d %>% 
    dplyr::group_by_(.dots=cerner_address) %>% 
    dplyr::count() %>% 
    dplyr::arrange(desc(n)) %>% 
    nrow()
  
  counts["cgt"] <- d %>% 
    dplyr::group_by_(.dots=data_warehouse_address) %>% 
    dplyr::count() %>% 
    dplyr::arrange(desc(n)) %>% 
    nrow()
  
  counts["sfbucgt"] <- d %>% 
    dplyr::group_by_(.dots=ehr_address_names) %>% 
    dplyr::count() %>% 
    dplyr::arrange(desc(n)) %>% 
    nrow()
  l_cerner <- length(cerner_address_names)
  l_dw     <- length(data_warehouse_address)
  d <- data.frame( 
     "system"         = c(rep("CERNER",l_cerner), rep("DW",l_dw))
    ,"source"          = ehr_address_names
    ,"source_unique"   = counts[ehr_address_names]
    ,"system_unique"   = c(rep(counts["sfbu"],l_cerner),rep(counts["cgt"],l_dw))
    ,"unique"          = rep(counts["sfbucgt"],sum(l_cerner,l_dw))
  )
  rownames(d) <- NULL
  return(d)
}
# ds_map %>% count_unique_addresses()


# function to count uniuqe program ids (values on compressors)
# count_unique_program_ids <- function(d){
count_unique_classes <- function(d){
  # d <- ds_map
  compressor_names <- c(
    "intensity_type",
    "intensity_severity_risk",
    "clinical_focus",
    "service_type",
    "service_location",
    "population_age"
  )
  counts <- c()
  for(i in compressor_names){
    # counts[i]         <- length(unique(d[,i]))
    counts[i] <- as.data.frame(d)[,i] %>% unique() %>% length()
  }
  # count the number of unique combinations of values on compressors
  counts["compressor"] <- d %>% 
    dplyr::group_by_(.dots=compressor_names) %>% 
    dplyr::count() %>% 
    dplyr::arrange(desc(n)) %>% 
    nrow()
  
  d2 <- data.frame(
    "compressor"         = compressor_names
    ,"compressor_unique" = counts[compressor_names]
    ,"unique"            = rep(counts["compressor"],length(compressor_names)) 
  ) 
  rownames(d2) <- NULL
  return(d2)
}


# function to count frequency of unique colors on a palette
# I don't think this function is necessary
count_unique_colours <- function(d){
  grouping_names <- c(ehr_address,compressor_names,program_types, palette_colours)
  # d_counts <- d %>% 
  #   dplyr::group_by_(.dots = group_by_names ) %>% 
  #   dplyr::summarize(
  #     n_unique = n()#,
  #     # n_locatins = sum(location_count),
  #     # n_all = sum(all_encounter_count),
  #     # n_t3  = sum(t3_encounter_count),
  #     # n_mh  = sum(mh_encounter_count)
  #   )
  
  # d_counts %>% DT::datatable()
  
  # d %>% dplyr::group_by(location_count) %>% dplyr::count()
  # stem(d$location_count,scale = 1 )
  
  # table(d$location_count)
  # compressor_names <- c(
  #   "intensity_type",         
  #   "intensity_severity_risk",
  #   "clinical_focus",         
  #   "service_type",           
  #   "service_location",       
  #   "population_age"         
  # )
  counts <- c()
  for(i in compressor_names){
    counts[i]         <- length(unique(d[,i]))
  }
  
  counts["compressor"] <- d %>% 
    dplyr::group_by_(.dots=grouping_names) %>% 
    dplyr::count() %>% 
    dplyr::arrange(desc(n)) %>% 
    nrow()
  
  
  d <- data.frame(
    "compressor"   = compressor_names
    ,"compressor_unique"   = counts[compressor_names]
    ,"unique"  = rep(counts["compressor"],6)
  )
  rownames(d) <- NULL
  return(d)
}

# Some variables have different character codes for missing values
# Translate various character values into NA values
replace_with_na <- function(x){
  # x <- ds_location_map$facility_name
  na_tokens <- c(
    "^NULL$"
    ,"^-$"
    ,"^NA$"
    ,"^\\{blank\\}$"
    ,"^n/a$"
    ,"\\{Unknown\\}"
    ,"\\{Undefined\\}"
    ,"\\{No Event Detail\\}"
  )
  for(token in na_tokens){
    if(is.character(x)){
      x <- gsub(token,NA,x)
    }
  }
  return(x)
}
# Usage:
# ds_patient_profiles <- ds_patient_profiles %>% 
  # dplyr::mutate_all(dplyr::funs(replace_with_na) )

# function to get a sample of ids from an intensity ranges
# measured as the segment of percintile rank of number of available records 
get_ids <- function(d, bottom=.1, top=.9, n_people=1){
  # d <- ds
  # bottom=.1
  # top=.9
  # n_people=1
  ids <- d %>% 
    # dplyr::arrange(desc(n_encounter)) %>% 
    # dplyr::distinct(id) %>% 
    dplyr::group_by(id) %>% 
    dplyr::summarize(n_records = n() ) %>% # number of rows of data a person has
    dplyr::mutate(
      pct_rank = dplyr::percent_rank(n_records) # unqiue events
    ) %>% 
    dplyr::distinct(id, pct_rank) %>% 
    dplyr::arrange(desc(id)) %>% 
    dplyr::filter(pct_rank > bottom & pct_rank < top) %>% 
    dplyr::select(id) %>% 
    as.data.frame() 
  nrow(ids)
  sample_size <- ifelse( nrow(ids) <= n_people, nrow(ids),n_people)
  ids <- sample(ids$id,size = sample_size, replace=F ) #%>% as.numeric()
  return(ids)
}

# function to count patients, encounters, and events in unique combinations
unique_sums <- function(
  d #
  ,group_by_vars # = c("event_type","encounter_class")
){
  # d <- ds
  # group_by_vars  = c("event_type","encounter_class")
  d_out <- d %>% 
    dplyr::group_by_(.dots = group_by_vars) %>% 
    dplyr::summarize(
      n_people     = length(unique(id)),
      n_encounters = length(unique(encounter_id)),
      n_events     = sum(event_count) 
    )
  return(d_out)
}
# Usage:
# ds %>% unique_sums(c("event_type","encounter_class")) 
