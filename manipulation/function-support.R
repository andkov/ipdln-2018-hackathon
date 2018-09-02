# load common object definitions
source("./manipulation/object-glossary.R")
# Count frequencies of unique values in each column (helpful to see scale)
col_freqs <- function(d, pandoc=F){
  for(i in names(d)){
    d %>% 
      group_by_(.dots = i) %>% 
      dplyr::summarize(n = n()) %>% 
      dplyr::arrange(desc(n)) 
    if(pandoc){
      d %>% knitr::kable(format = "pandoc") %>% print()
    }else{
      d %>% print()
    }
  }  
} 
# how to use:
# ds %>% col_freqs()

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
