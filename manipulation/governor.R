rm(list=ls(all=TRUE)) # clear environment
cat("\f") # clear console 

# This is the manipulation governor

# Arrival: Raw data are greeted into the reproducible system
knitr::stitch_rmd(
  script = "./manipulation/0-greeter.R",
  output = "./manipulation/stitched-output/0-greeter.md"
)

# Description : meta data are transcribed from the supplied documentation
# https://drive.google.com/file/d/10idMxy8eX8nTHr6wr2Q40x4XOP3Y5ck7/view
knitr::stitch_rmd(
  script = "./manipulation/0-metador.R",
  output = "./manipulation/stitched-output/0-metador.md"
)
 
# look into knitr::spin() http://www.r-bloggers.com/knitrs-best-hidden-gem-spin/
