# install.packages(c("remotes", "devtools"), upgrade ="never")
install.packages(c("foreach", "doParallel", "RecordLinkage"), upgrade ="never")

github_pkgs <- c(
  "doi2bib" = "wkmor1/doi2bib",
  "readtext" = "quanteda/readtext",
  "fulltext" = "ropensci/fulltext",
  "bibtex" = "ropensci/bibtex",
  "rcrossref" = "ropensci/rcrossref",
  "rplos" = "ropensci/rplos",
  "aRxiv" = "ropensci/aRxiv",
  "bib2df" = "ropensci/bib2df"
)
for(pkg in names(github_pkgs)){
  devtools::install_github(github_pkgs[[pkg]], upgrade ="never")
}
