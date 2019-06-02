# ipdln-2018-hackathon

Demonstrating coloring-book techique of graph production in _ggplot2_ during data linkage hackathong at IPDLN-2018 conference at Banff, Sep 2018.

![part2][part2]

# Relevant talks 

- April, 2016 - Groningen -  Technique orignally developed for 2016 Maelstrom Harmonization Workshop ("_Assessing the impact of different harmonization procedures on the analysis results from several real datasets_"). View the [slides][`ialsa-2016-groningen`][groningen-brief]  presenting the results of the exercise by [Andriy Koval](http://github.com/andkov) and [Will Beasley](http://github.com/wibeasley). Groningen, Netherlands, April 22, 2016. 
- September, 2017 - Banff -  Presentation of the [slide deck of hackathon results][slidedeck] to the  closing plenary of IDPDL-2018 Conference in Banff, September 17 2018.
- October, 2017 - Victoria - Matrix Institue colloquium [2018-10-31][matrix-talk] - slides for my talk [When Notebooks are not Enough][matrix-talk] at the Matrix Institute colloquium at the University of Victoria on October 31, 2018
- November, 2017  Victoria - Popultaion Data BC Webinar [2018-11-01][popdatabc-webinar] -slides for my webinar [Visulizing Logistic Regression][popdatabc-webinar] at the Power of Population Data Science webinar series at PopDatBC on November 1, 2018.

[matrix-talk]:https://raw.githack.com/andkov/ipdln-2018-hackathon/master/libs/materials/2018-10-31-when-notebooks-are-not-enough.pdf
[popdatabc-webinar]:https://raw.githack.com/andkov/ipdln-2018-hackathon/master/libs/materials/2018-11-01-visualizing-logistic-regression.pdf

# How to reproduce
0. Clone this repository (either via git or from the browswer)
1. Lauch RStudio project via .Rproj file
2. Execute [`./manipulation/0-metador.R`](./manipulation/0-metador.R) to generate an object that would store all the metadata
3. Examine [`./manipulation/stitched_output/1-greeter.html`][1-greeter-report] to study the record of how we greeted the data provided to the hackathon participants.  This data set is currently unavailable to the public, but please send a friendly tweet [@StatCan_eng](https://twitter.com/andkovpro/status/1056974611961667584) to let them know there is interest in this data set)
4. Examine [`./reports/technique-demonstration/technique-demonstration-1.html`][tech-demo] to study the record of how models were estimated on the data provided to hackathon participants (really, please send a friendly tweet [@StatCan_eng](https://twitter.com/andkovpro/status/1056974611961667584) #letmydatago )
5. Run [`./reports/graphing-phase-only/graphing-phase-only.R`](./reports/graphing-phase-only/graphing-phase-only.R) to load the model solution and start producing graphs


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
- [`./reports/technique-demonstration/`][tech-demo] - a cleaned, simplified and heavily annotated .R + .Rmd version of [coloring-book-mortality.R][hackathon2018] script. Optimized for learning the workflow with the original data. For full details consult its [stitched_output][tech-demo-stitched]. 
- [`./reports/graphing-phase-only/`][graph-only] - focuses on the graphing phase of production. Fully reproducible: works with the results of the models estimated during [technical-demonstration][graph-only], stored in [`./data-public/dereived/technique-demonstration/`][tech-demo-derived]. For full details consult its [stitched_output][graph-only-stitched]





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


[groningen-brief]:https://raw.githack.com/IALSA/ialsa-2016-groningen-public/master/2016-04-21-groningen-exercise-brief.pdf

## Hackathon-2018 Team
- Stacey Fisher, Ph.D. Candidate, Ottawa Hospital Research Institute; ICES; University of Ottawa
- Gareth Davies, MSc, Research Data Analyst, SAIL Databank, Swansea University
- Andriy Koval, Health System Impact Fellow, BC Observatory for Population & Public Health




