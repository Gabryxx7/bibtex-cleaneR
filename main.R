writeReferencesStr <- function(str_list, out_filename, append=FALSE){
  if(!append) write("", file = out_filename, append = FALSE)
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

writeReferencesDf <- function(bib_df, out_filename=NULL, append=FALSE){
  if(!append && !is.null(out_filename))
    write("", file = out_filename, append = FALSE)
  out_str <- ""
  foreach(i=1:nrow(bib_df)) %do% {
    tryCatch({
      bib_key <- bib_df[[i, "bibkey"]]
      bib_type <- bib_df[[i, "bibtype"]]
      entry_str <- getReferenceString(bib_df[i,-c("bibtype", "bibkey")], bib_type, bib_key)
      if(!is.null(out_filename)){
        write(entry_str, file = out_filename, append = TRUE)
      }
      else{
        out_str <- paste0(out_str, entry_str,"\n")
      }
    }, error = function(e){
      cat("\nError printing reference", bib_key, ":", paste0(e))
    })
  }
  if(!is.null(out_filename)){
    cat("\n", nrow(bib_df), "References written to file: ", out_filename, "\n")
  }
  else{
    cat("\n", nrow(bib_df), "References exported to string \n")
    return(out_str)
  }
}
#
# combineProgress <- function(iterator){
#   pb <- txtProgressBar(min = 1, max = iterator - 1, style = 3)
#   count <- 0
#   function(...) {
#     count <<- count + length(list(...)) - 1
#     setTxtProgressBar(pb, count)
#     flush.console()
#     cbind(...) # this can feed into .combine option of foreach
#   }
# }

readBibAsDf <- function(bib_filename, encoding = "UTF-8"){
  bib_data <- ReadBib(bib_filename, .Encoding=encoding, check=FALSE) # best way to parse
  cat("\nTotal Refs in bib file: ", length(bib_data))
  str_list <- foreach(i=1:length(bib_data)) %do% {
    tryCatch({
      entry_data <- getReferenceListData(bib_data[[i]])
      ret_list <- list(bib_key=entry_data)
      names(ret_list) <- names(bib_data[[i]])
      return(ret_list)
    },error= function(e){
      cat("\nError in getting bib entry ", names(bib_data[[i]]), ":", paste0(e))
    })
  }
  ref_list <- unlist(str_list, recursive=FALSE)
  bib_df <- data.table::rbindlist(ref_list, fill=TRUE)
  cat("\nTotal Refs in dataframe: ", nrow(bib_df))
  bib_df <- unique(bib_df, by = "title")
  cat("\nTotal UNIQUE Refs in dataframe: ", nrow(bib_df))
  return(bib_df)
}

cleanUpdateReferences <- function(in_filename, out_filename=NULL, style="acm", upd_bibkey=FALSE, upd_title=TRUE, upd_author=TRUE, upd_abstract=TRUE, sorting_key=NULL, decreasing=FALSE, multithreaded=TRUE, base_folder=".\\", wd=NA){
  if(!is.na(wd)){
    cat("\n")
    cat(wd)
    setwd(wd)
    cat("\n")
    cat(getwd())
  }
  source("references_cleane.R")
  start_time <- Sys.time()
  if(!grepl('\\.bib',  in_filename)){
    in_filename <- paste0(in_filename, '.bib')
  }
  if(is.null(out_filename)){
    out_filename <- str_replace(in_filename, "\\.bib", "_out.bib")
  }
  else if(!grepl('\\.bib',  out_filename)){
    out_filename <- paste0(out_filename, '.bib')
  }
  in_filename <- paste0(base_folder, in_filename)
  out_filename <- paste0(base_folder, out_filename)
  cat(paste0("\n- Input File: ", in_filename))
  cat(paste0("\n- Output File: ", out_filename))
  bib_df <- readBibAsDf(in_filename, encoding = "UTF-8")
  if(!multithreaded){
    method <- "Single"
    str_list <- foreach(i=1:nrow(bib_df)) %do% {
      tryCatch({
        updateBibEntry(bib_df, i, out_filename, style, upd_bibkey, upd_title, upd_author, upd_abstract, is_cluster=FALSE, wd=wd)
      },error= function(e){
        cat("\nError in updating bib entry ", bib_df[1, "bibkey"][[1]], ":", paste0(e))
      })
    }
  }
  else{
    method <- "Multi"
    cat("\nCores: ", detectCores(), "\tRefs: ", nrow(bib_df))
    cores=min(detectCores()[1]-1, nrow(bib_df))
    logs_folder <- paste0(base_folder, "logs", "/")
    dir.create(file.path(logs_folder), showWarnings = FALSE)
    workers_log_folder <- paste0(logs_folder, "workers_log_", filename, "/")
    cat("\n",cores," Workers log to: ", workers_log_folder, "\n- Cleaning up folder...")
    dir.create(file.path(workers_log_folder), showWarnings = FALSE)
    do.call(file.remove, list(list.files(workers_log_folder, full.names = TRUE, pattern="*.log")))
    cl <- makeCluster(cores) #not to overload your computer
    registerDoParallel(cl)
    cat("\n- Starting ref cleaning...")
    str_list <- foreach(i=1:nrow(bib_df)) %dopar% {
      if(!is.na(wd)){
        setwd(wd)
      }
      source("references_cleane.R")
      if(!exists("log_file_initialized")){
        log_filename <- paste0(length(list.files(workers_log_folder, full.names = FALSE))+1, ".log")
        file.create(paste0(workers_log_folder, log_filename))
        sink(paste0(workers_log_folder, log_filename), append = FALSE)
        log_file_initialized <- TRUE
      }
      tryCatch({
        entry <- updateBibEntry(bib_df, i, out_filename, style, upd_bibkey, upd_title, upd_author, upd_abstract, is_cluster=TRUE, wd=wd)
        return(entry)
      },error= function(e){
        cat("\nError in updating bib entry ", bib_df[1, "bibkey"][[1]], ":", paste0(e))
      })
    }
    stopCluster(cl)
  }

  cat("\nTotal Refs before sorting: ", length(str_list))
  ref_list <- unlist(str_list, recursive=FALSE)
  cat("\nTotal unlisted Refs before sorting: ", length(ref_list))
  df <- data.table::rbindlist(ref_list, fill=TRUE)
  sorting_key <- tolower(sorting_key)
  df[is.na(df$r_updated)]$r_updated <- "NO"

  df <- sort_references(df, sorting_key, decreasing)

  # writeReferences(str_list, out_filename)
  writeReferencesDf(df, out_filename, append=FALSE)

  end_time <- Sys.time()
  cat("\n\n", method, "threaded execution time: ", end_time - start_time, "\n\n")
  return(df)
}

sort_references <- function(df, sorting_key, decreasing){
  if(length(sorting_key) > 0 && sorting_key != "file"){
    # df <- setorder(df[, .r := order(to_lower(df[[sorting_key]]))], .r)[, .r := NULL]
    # df <- setorderv(DT, c("Year", "memberID", "month"), c(1,1,-1))
    df <- df[order(tolower(df[[sorting_key]]), decreasing=decreasing)]
  }
  return(df)
}
