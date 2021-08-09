writeReferencesStr <- function(str_list, out_filename){
  foreach(i=1:length(bib_data)) %do% {
    tryCatch({
      bib_key <- names(bib_data[[i]])
      entry_str <- str_list[[bib_key]]
      write(entry_str, file = out_filename, append = TRUE)
    }, error = function(e){
      cat("\nError printing reference", bib_key, ":", paste0(e))
    })
  }
}

writeReferencesDf <- function(bib_df, out_filename){
  foreach(i=1:nrow(bib_df)) %do% {
    tryCatch({
      bib_key <- bib_df[[i, "bibkey"]]
      bib_type <- bib_df[[i, "bibtype"]]
      entry_str <- getReferenceString(bib_df[i,-c("bibtype", "bibkey")], bib_type, bib_key)
      write(entry_str, file = out_filename, append = TRUE)
    }, error = function(e){
      cat("\nError printing reference", bib_key, ":", paste0(e))
    })
  }
}

updateReferences <- function(bib_filename, out_filename, style="acm", upd_bibkey=FALSE, upd_title=FALSE, upd_author=TRUE, sorting_key=NULL, decreasing=FALSE, multithreaded=TRUE){
  source("references_cleane.R")
  start_time <- Sys.time()
  bib_data <- ReadBib(bib_filename, check=FALSE) # best way to parse
  cat("\nTotal references in ", bib_filename, ": ", length(bib_data))
  write("", file = out_filename, append = FALSE)
  
  if(!multithreaded){
    method <- "Single"
    str_list <- foreach(i=1:length(bib_data)) %do% {
      tryCatch({
        updateBibEntry(bib_data, i, out_filename, style, upd_bibkey, upd_title, upd_author, is_cluster=FALSE)
      },error= function(e){
        cat("\nError in updating bib entry ", names(bib_data[[i]]), ":", paste0(e))
      })
    }
  }
  else{
    method <- "Multi"
    cores=detectCores()
    cl <- makeCluster(cores[1]-1) #not to overload your computer
    registerDoParallel(cl)
    errors <- c()
    str_list <- foreach(i=1:length(bib_data)) %dopar% {
      source("references_cleane.R")
      tryCatch({
        updateBibEntry(bib_data, i, out_filename, style,upd_bibkey, upd_title, upd_author, is_cluster=TRUE)
      },error= function(e){
        errors <- c(errors, paste0(e))
        cat("\nError in updating bib entry ", names(bib_data[[i]]), ":", paste0(e))
      })
    }
    cat(paste0(errors, collapse="\n\n-"))
    stopCluster(cl)
  }
  
  cat("\nTotal Refs before sorting: ", length(str_list))
  ref_list <- unlist(str_list, recursive=FALSE)
  cat("\nTotal unlisted Refs before sorting: ", length(ref_list))
  df <- data.table::rbindlist(ref_list, fill=TRUE)
  sorting_key <- tolower(sorting_key)
  if(length(sorting_key) > 0 && sorting_key != "file"){
    df <- df[order(df[[sorting_key]], decreasing = decreasing)]
  }
  
  # writeReferences(str_list, out_filename)
  writeReferencesDf(df, out_filename)
  
  end_time <- Sys.time()
  cat("\n\n", method, "threaded execution time: ", end_time - start_time, "\n\n")
  return(df)
}