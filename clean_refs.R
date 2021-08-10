source("main.R")

base_folder = "C:\\Users\\Gabryxx7\\Documents\\GitHub\\bibtext-cleaneR\\"
setwd(base_folder)
# base_folder = "/Users/marinig/Documents/GitHub/tidy_bib_R/"
workers_log_folder = "C:\\Users\\Gabryxx7\\Documents\\GitHub\\bibtext-cleaneR\\workers_log2\\"
filename <- "sample-base"
# filename <- "test"

style <- "acm"
upd_bibkey <- TRUE
upd_title <- TRUE
upd_author <- TRUE
upd_abstract <- TRUE
# sorting_key <- "title"
# sorting_key <- "year"
sorting_key <- NULL
decreasing <- FALSE

in_file <- paste0(base_folder, filename, ".bib")
out_file <- paste0(base_folder, filename, "_out_test_", ".bib", sep="")
bib_df <- updateReferences(in_file, out_file, style=style, upd_bibkey=upd_bibkey, upd_title=upd_title, upd_author=upd_author, upd_abstract=upd_abstract, sorting_key=sorting_key, decreasing=decreasing, multithreaded = TRUE, workers_log_folder=workers_log_folder)
