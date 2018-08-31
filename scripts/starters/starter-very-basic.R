## This script 
options(width=160)
rm(list=ls())
cat("\f")

## @knitr load_packages
library(dplyr)

## @knitr load_data
ds0 <- readRDS("./data/derived/ds0.rds")
ds <- ds0
str(ds)
