source("main.R")

base_folder = "C:\\Users\\Gabryxx7\\Documents\\GitHub\\bibtext-cleaneR\\"
# base_folder = "/Users/marinig/Documents/GitHub/tidy_bib_R/"
filename <- "sample-base"
# filename <- "test"

style <- "acm"
upd_bibkey <- FALSE
upd_title <- FALSE
upd_author <- TRUE
# sorting_key <- "title"
# sorting_key <- "year"
sorting_key <- NULL
decreasing <- FALSE

in_file <- paste0(base_folder, filename, ".bib")
out_file <- paste0(base_folder, filename, "_out_m", ".bib", sep="")
bib_df <- updateReferences(in_file, out_file, style=style, upd_bibkey=upd_bibkey, upd_title=upd_title, upd_author=upd_author, sorting_key=sorting_key, decreasing=decreasing, multithreaded = TRUE)
