if(!requireNamespace("remotes", quietly = TRUE)) { install.packages("remotes") }
if(!requireNamespace("remotes", quietly = TRUE)) { install.packages("devtools") }
remotes::install_github("wkmor1/doi2bib", upgrade ="never")
remotes::install_github("ropensci/fulltext", upgrade ="never")
remotes::install_github("ropensci/bibtex", upgrade ="never")
devtools::install_github("quanteda/readtext", upgrade ="never") 
remotes::install_github("ropensci/rcrossref", upgrade ="never")
remotes::install_github("ropensci/rplos", upgrade ="never")
remotes:install_github("ropensci/aRxiv", upgrade ="never")
remotes::install.packages("RecordLinkage", upgrade ="never")
devtools::install_github("ropensci/bib2df", upgrade ="never")
install.packages(c("foreach", "doParallel"))
