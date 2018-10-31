# ipdln-2018-hackathon

Demonstrating coloring-book techique of graph production in ggplot2 during data linkage hackathong at IPDLN-2018 conference at Banff, Sep 2018.

![part2][part2]

# How to reproduce
- 0. Clone this repository (either via git or from the browswer)
- 1. Lauch RStudio project via .Rproj file
- 2. Execute `./manipulation/0-metador.R` to generate object with meta data
- 3. Examine [`./reports/technique-demonstration/`][tech-demo] to see how models were estimated.
- 4. Run [`./reports/graphing-phase-only/graphing-phase-only.R`] to load the model solution and start producing graphs


# Background 
- [Information for Participants][info_participants] 
- [Data Codebook][data_codebook]

[info_participants]:data-public/raw/IPDLN_Hackathon_Information_August2018.pdf
[data_codebook]:data-public/raw/IPDLN_Hackathon_Synth_Data_Codebook_Final.pdf
    
    
# Dynamic Documentation on Data Cleaning
 
- [`./manipulation/0-metador.R`][0-meta-report] records the definition of available variables, their factor levels, labels, description, as well as additional meta data (e.g. colors, fonts, themes). 
- [`./manipulation/1-greeter.R`][1-greeter-report] imports the raw data and perform general tweaks.


The product of these two scripts define the foundation of every subsequent analytic report. 
```r
ls_guide <- readRDS("./data-unshared/derived/0-metador.rds")
ds0      <- readRDS("./data-unshared/derived/1-greeted.rds")
```

# Analytics during Hackathon

- [`./reports/eda-1/eda-1`][eda1] - prints frequency distributions of all variables. 
- [`./reports/eda-1/eda-1a-first-gen-immigrant`][eda1a] - repeats [eda1][eda1] but for subsample of first-generation immigrants

Resulst  of these two EDAs informed development of the script to estimate and to graph models of immigrant mortality: 

- [`./reports/coloring-book-mortality/coloring-book-mortality.R`][hackathon2018] - implements analysis in the historic context of the IPDLN-2018-hackathon. Not a report, but a bare R script. Need to know the options before running. More for archeological purposes.  

This script yeilded a collection of printed graphs stored in `./reports/coloring-book-mortality/prints/`, visualizing three different collection of predictors from the same model. There were put together into this [slide deck][slidedeck] and presented during the closing plenary of IDPDL-2018 Conference in Banff. 

[slidedeck]:https://rawgit.com/andkov/ipdln-2018-hackathon/master/reports/coloring-book-mortality/ipdln-2018-banff-hackathon-results-2018-09-14.pdf

# Technique demonstration


- [`./reports/technique-demonstration/`][tech-demo] - a cleaned, simplified and heavily annotated version of [coloring-book-mortality][hackathon2018] report. Optimized for learning the workflow with the original data. For full details consult its [stitched_output][tech-demo-stitched]. 
- [`./reports/graphing-phase-only/`][graph-only] - focuses on the graphing phase of production. Fully reproducible: works with the results of the models estimated during [technical-demonstration][graph-only], stored in [`./data-public/dereived/technique-demonstration/`][tech-demo-derived]. For full details consult its [stitched_output][graph-only-stitched]


# Communication

- Presentation of the [slide deck of hackathon results][slidedeck] to the  closing plenary of IDPDL-2018 Conference in Banff, September 17 2018.
- Matrix Institue colloquium [2018-10-31][matrix-col]
- Popultaion Data BC Webinar [2018-11-01][popdatabc-webinar]

[matrix-talk]:libs/materials/talks/2018-10-31-when-notebooks-are-not-enough.pdf
[popdatabc-webinar]:libs/materials/talks/2018-11-01-coloring-book-technique.pdf



[hackathon2018]:https://github.com/andkov/ipdln-2018-hackathon/blob/master/reports/coloring-book-mortality/coloring-book-mortality.R

[tech-demo]:https://raw.githack.com/andkov/ipdln-2018-hackathon/master/reports/technique-demonstration/technique-demonstration-1.html
[tech-demo-stitched]:https://raw.githack.com/andkov/ipdln-2018-hackathon/master/reports/technique-demonstration/stitched_output/technique-demonstration.html
[graph-only]:https://raw.githack.com/andkov/ipdln-2018-hackathon/master/reports/graphing-phase-only/graphing-phase-only-1.html
[graph-only-stitched]:https://raw.githack.com/andkov/ipdln-2018-hackathon/master/reports/graphing-phase-only/stitched_output/graphing-phase-only.html
[tech-demo-derived]:./data-public/derived/technique-demonstration/



[governor]:https://github.com/andkov/ipdln-2018-hackathon/blob/master/manipulation/governor.R
[0-meta-report]:https://raw.githack.com/andkov/ipdln-2018-hackathon/master/manipulation/stitched-output/0-metador.html
[1-greeter-report]:https://raw.githack.com/andkov/ipdln-2018-hackathon/master/manipulation/stitched-output/1-greeter.html
[eda1]:https://raw.githack.com/andkov/ipdln-2018-hackathon/master/reports/eda-1/eda-1.html
[eda1a]:https://raw.githack.com/andkov/ipdln-2018-hackathon/master/reports/eda-1/eda-1a-first-gen-immigrant.html

[part1]:https://raw.githubusercontent.com/andkov/ipdln-2018-hackathon/master/reports/coloring-book-mortality/results-part-1.gif
[part2]:https://raw.githubusercontent.com/andkov/ipdln-2018-hackathon/master/reports/coloring-book-mortality/results-part-2.gif

# History

- technique orignally developed for `ialsa-2016-groningen` exercise by Andriy Koval and Will Beasley
- currently maintained by Andriy Koval

## Hackathon-2018 Team
- Stacey Fisher, Ph.D. Candidate, Ottawa Hospital Research Institute; ICES; University of Ottawa
- Gareth Davies, MSc, Research Data Analyst, SAIL Databank, Swansea University
- Andriy Koval, Health System Impact Fellow, BC Observatory for Population & Public Health




