base_folder = "C:\\Users\\Gabryxx7\\Documents\\GitHub\\bibtext-cleaneR\\"
setwd(base_folder)

source("main.R")
source("references_cleane.R")

# base_folder = "/Users/marinig/Documents/GitHub/tidy_bib_R/"
workers_log_folder = "C:\\Users\\Gabryxx7\\Documents\\GitHub\\bibtext-cleaneR\\workers_log2\\"
# filename <- "sample-base"
filename <- "test"

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

bib_df_clean <- readBibAsDf(in_file, encoding = "UTF-8") %>%
                cleanUpdateReferences(out_file, style=style,
                                  upd_bibkey=upd_bibkey, upd_title=upd_title, upd_author=upd_author, upd_abstract=upd_abstract,
                                  sorting_key=sorting_key, decreasing=decreasing,
                                  multithreaded = TRUE, workers_log_folder=workers_log_folder)
  
# If you change anything afterwards you can always re-write the file
# writeReferencesDf(bib_df_clean, paste0(base_folder, filename, "_out_test_new", ".bib", sep=""), append=FALSE)

