# ipdln-2018-hackathon
Repository to accompany a hackathon at IPDLN conference at Banff, Sep 2018

# Shared google docs

- [Information for Participants][info_participants] 
- [Data Codebook][data_codebook]

# Dynamic Documentation
- [`./manipulation/0-metador.R`][0-meta-report] records the definition of available variables, their factor levels, labels, description, as well as additional meta data (e.g. colors, fonts, themes). 
- [`./manipulation/0-greeter.R`][0-greeter-report] imports the raw data and perform general tweaks.

The product of these two scripts define the foundation of every subsequent analytic report. 
```r
ds0 <- readRDS("./data-unshared/derived/0-greeted.rds")
ls_guide <- readRDS(

```

[info_participants]:https://drive.google.com/open?id=1OwqD0gHfuTQeBwqh4fkgkR7r-jUXuSzM
[data_codebook]:https://drive.google.com/open?id=10idMxy8eX8nTHr6wr2Q40x4XOP3Y5ck7

[0-meta-report]:https://rawgit.com/andkov/ipdln-2018-hackathon/master/manipulation/stitched-output/0-assemble-meta-data.html
[0-greeter-report]:https://rawgit.com/andkov/ipdln-2018-hackathon/master/manipulation/stitched-output/0-greeter.html
