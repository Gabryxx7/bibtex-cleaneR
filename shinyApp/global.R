Sys.setlocale(category = "LC_ALL", locale = "en_US.UTF-8")
# options(encoding = 'UTF-8')
library(shiny)
library(stringi)
library(shinyAce)
library(rcrossref)
init <- paste(readLines('example.bib', encoding = "UTF-8"), collapse = "\n")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
setwd("../")
cat(getwd())

source("main.R")
source("references_cleane.R")

modes <- getAceModes()
themes <- getAceThemes()

aceTheme <- "ambiance"
mode <- "r"
size <- 4

styles <- get_styles()
defStyle <- "acm-sigchi-proceedings"
upd_bibkey <- FALSE
upd_title <- TRUE
upd_author <- TRUE
upd_abstract <- TRUE
sorting_key <- NULL # or even "title" or "year"
decreasing <- FALSE
