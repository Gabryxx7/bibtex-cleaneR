source("main.R")
source("references_cleane.R")

base_folder = dirname(rstudioapi::getActiveDocumentContext()$path)
base_folder = paste0(base_folder, "/")
setwd(base_folder)

sorting_key <- NULL # or even "title" or "year"
in_file <- "JMIR_bib.bib"
bib_df_clean <- cleanUpdateReferences(in_file, base_folder=base_folder, style="acm")
bib_df <- readBibAsDf(paste0(base_folder, in_file), encoding = "UTF-8") # You can compare the two


# If you change anything afterwards you can always re-write the file
# writeReferencesDf(bib_df_clean, paste0(base_folder, filename, "_out_test_new", ".bib", sep=""), append=FALSE)

