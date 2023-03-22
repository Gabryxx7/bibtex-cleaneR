base_folder = dirname(rstudioapi::getActiveDocumentContext()$path)
base_folder = paste0(base_folder, "/")
setwd(base_folder)

source("main.R")
source("references_cleane.R")


style <- "acm"
upd_bibkey <- FALSE
upd_title <- TRUE
upd_author <- TRUE
upd_abstract <- TRUE
sorting_key <- NULL # or even "title" or "year"
decreasing <- FALSE



filename <- "sample-base"
workers_log_folder = paste0(base_folder, "workers_log_", filename, "/")
in_file <- paste0(base_folder, filename, ".bib")
out_file <- paste0(base_folder, filename, "_out", ".bib", sep="")
test_bib_df <- readBibAsDf(in_file, encoding = "UTF-8")
test_bib_df_clean <- cleanUpdateReferences(test_bib_df, out_file, style=style,
                                           upd_bibkey=upd_bibkey, upd_title=upd_title, upd_author=upd_author, upd_abstract=upd_abstract,
                                           sorting_key=sorting_key, decreasing=decreasing,
                                           multithreaded = TRUE, workers_log_folder=workers_log_folder)

# 
# filename <- "sample-base"
# workers_log_folder = paste0(base_folder, "workers_log_", filename, "\\")
# in_file <- paste0(base_folder, filename, ".bib")
# out_file <- paste0(base_folder, filename, "_out", ".bib", sep="")
# sample_bib_df <- readBibAsDf(in_file, encoding = "UTF-8")
# sample_bib_df_clean <- cleanUpdateReferences(sample_bib_df, out_file, style=style,
#                                              upd_bibkey=upd_bibkey, upd_title=upd_title, upd_author=upd_author, upd_abstract=upd_abstract,
#                                              sorting_key=sorting_key, decreasing=decreasing,
#                                              multithreaded = TRUE, workers_log_folder=workers_log_folder)

# If you change anything afterwards you can always re-write the file
# writeReferencesDf(bib_df_clean, paste0(base_folder, filename, "_out_test_new", ".bib", sep=""), append=FALSE)

