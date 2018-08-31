## The script demonstrates and explains the use of main functions in the this repository
## You can think of this as a serires of reproducible examples that summarize
## what has been learned during the development of this project

## @knitr cycle_functions

## Compute length(unique(ds)) for each of the column/variables of the dataset
Compose <- function(x, ...)
{
    lst <- list(...)
    for(i in rev(seq_along(lst)))
        x <- lst[[i]](x)
    x
}

sapply(ds, Compose, length,unique)