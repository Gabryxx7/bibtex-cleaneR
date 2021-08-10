library(fulltext)
library(bib2df)
library(bibtex)
library(RefManageR)
# library(readtext)
library(doi2bib)
library(dplyr)
library(curl)
library(stringr)
library(RecordLinkage)
library(rcrossref)
library(aRxiv)
library(foreach)
library(doParallel)
library(doSNOW)

getAbstractFromDOI <- function(doi){
  cat("\nGetting abstract for DOI: ", doi)
  tryCatch({
    abstr <- cr_abstract(doi =doi)
    return(abstr)
  },
  error = function(e){ 
    cat("\nError getting abstract for doi: ", paste0(e))
    return(NULL)
  },
  warning  = function(e){ 
    cat("\nWarning getting abstract for doi: ", paste0(e))
    return(NULL)
  })
  return(NULL)
}

getCitationFromDOI <- function(doi,  style="acm", locale="en-US"){
  cat("\nGetting citation for DOI: ", doi, "\tStyle: ", style, "\tLocale: ", locale)
  tryCatch({
    tmp_file <- tempfile(fileext = ".bib")
    cr_cn(dois = doi, format = "bibtex", style=style, locale="en-US") %>%
      write(file = tmp_file, append = FALSE)
    new_citation <- ReadBib(tmp_file, check=FALSE)
    return(new_citation)
  },
  error = function(e){ 
    cat("\nError getting citation for doi: ", paste0(e))
    return(NULL)
  },
  warning  = function(e){ 
    cat("\nWarning getting citation for doi: ", paste0(e))
    return(NULL)
  })
  return(NULL)
}

getTitleSimilarity <- function(old_title, new_title, sim_threshold=0.8){
  tryCatch({
    clean_old <- tolower(gsub("[^0-9A-Za-z ]","" ,old_title, ignore.case = TRUE))
    clean_new <- tolower(gsub("[^0-9A-Za-z ]","" ,new_title, ignore.case = TRUE))
    sim <- levenshteinSim(clean_new, clean_old)
    if(sim >= sim_threshold){
      cat("\n- Same title: YES! (Similarity: ", sim, " >= ", sim_threshold, "\n")
      return(TRUE)
    }
    else if(grepl(clean_new, clean_old, fixed = FALSE)){
      cat("\n- Same title: YES! (New title included fully in old title)\n")
      return(TRUE)
    }
  }, error = function(e){
    cat("\n- Same title: ERROR, ", paste0(e), "\n")
    return(FALSE)
  })
  cat("\n- Same title: NO!\n")
  return(FALSE)
}

getReferenceListData <- function(bibentry){
  list_data <- list()
  if(class(bibentry)[1] != "list"){
    bibentry <- unclass(bibentry)[[1]]
  }
  fields <- names(bibentry)
  for(field in fields){
    field_txt <- tolower(paste0(field))
    data <- paste0(bibentry[[field]], collapse =" and ")
    data <- str_replace(data, "%2F", "/")
    list_data[[field]] <- data
  }
  list_data[["bibtype"]] <- attr(bibentry, "bibtype")
  list_data[["bibkey"]] <- attr(bibentry, "key")
  return(list_data)
  
}

getReferenceString <- function(bibentry, bibtype, bibkey){
  if(tolower(class(bibentry)[1] == "bibentry")){
    bibentry <- unclass(bibentry)[[1]]
  }
  fields <- names(bibentry)
  attr_data <- ""
  fields <- fields[fields != "r_updated"]
  fields <- c(fields, "r_updated")
  for(field in fields){
    field_txt <- tolower(paste0(field))
    data <- bibentry[[field]]
    if(!is.na(data) && str_length(data) > 0){
      data <- paste0(bibentry[[field]], collapse =" and ")
      data <- str_replace(data, "%2F", "/")
      tabs_n <- 2
      if(str_length(field_txt) <= 3){
        tabs_n <- tabs_n+1
      }
      if(str_length(field_txt) >= 9){
        tabs_n <- tabs_n - 1
      }
      attr_data <- paste0(attr_data, "    ",field_txt,paste0(rep("\t", tabs_n), collapse=""), "= {",data, "},\n")
    }
  }
  ref_str <- paste0("@", bibtype, "{", bibkey, ",\n", attr_data, "}")
  return(ref_str)
}

mergeReferencesClass <- function(old_bib, new_bib, upd_bibkey=FALSE, upd_title=FALSE, upd_authors=TRUE, verbose=FALSE){
  fields <- unique(RefManageR::fields(new_bib)[[1]])
  # fields <- unique(c(RefManageR::fields(old_bib)[[1]], RefManageR::fields(new_bib)[[1]]))
  old_bib_unclassed <- unclass(old_bib)[[1]]
  new_bib <- unclass(new_bib)[[1]]
  for(field in fields){
    if(field == "title" && !upd_title || field == "author" && !upd_authors){
      cat("\n--Not Updating ", field)
      next
    }
    if(verbose){
      cat("Updating field", field, "\tOld: ", paste0(old_bib_unclassed[[field]]), "\tNew: ", paste0(new_bib[[field]]), "\n")
    }
    if(!is.null(new_bib[[field]]) && !is.na(new_bib[[field]])){
      old_bib_unclassed[[field]] <- str_replace_all(new_bib[[field]], "[{|}]", "")
    }
  }
  if(upd_bibkey){
    cat("\n--Updating bibkey: ", attr(old_bib_unclassed, "key"), "=>", attr(new_bib, "key") )
    attr(old_bib_unclassed, "key") <- attr(new_bib, "key") 
  }
  return(old_bib_unclassed)
}

mergeReferencesDF <- function(old_bib, new_bib, upd_title=FALSE, upd_authors=TRUE){
  old_title <- str_replace_all(tolower(old_title),"[:|{|}]", "")
  new_title <- str_replace_all(tolower(new_bib$title),"[:|{|}]", "")
  for(col in colnames(new_bib)){
    if(is.na(old_bib[col])){
      old_bib[col] <- str_replace_all(new_bib[col], "[{|}]", "")
    }
    if(col == "TITLE" && upd_title){
      old_bib[col] <- str_replace_all(new_bib[col], "[{|}]", "")
    }else if(col == "AUTHOR" && upd_authors){
      old_bib[col] <- str_replace_all(new_bib[col], "[{|}]", "")
    }
  }
  return(old_bib)
}

cleanDoiUrl <- function(doi=NULL, url=NULL){
  if(!is.null(doi))
    doi_url <- doi
  else
    doi_url <- url
  
  doi_url <- str_replace_all(doi_url,"[{|}]", "")
  if(!is.null(doi_url) && length(doi_url) > 0){
    if(grepl("doi", doi_url)){
      last_slash_idx <- str_locate_all(doi_url,"/")[[1]][3]
      doi_url <- substr(doi_url, last_slash_idx+1, str_length(doi_url))
      return(doi_url)
    }
  }
  if(!is.null(url))
    stop("The URL is not a doi")
  return(doi_url)
}


updateBibEntry <- function(bib_data, index, out_file, style="acm", upd_bibkey=FALSE, upd_title=FALSE, upd_author=TRUE, upd_abstract=FALSE, is_cluster=FALSE){
  if(is_cluster){
    source("references_cleane.R")
  }
  bib_entry <- bib_data[[index]]
  bib_key <- names(bib_entry)
  new_entry <- NULL
  cat("\n----------- Exporting", index, "/", length(bib_data), ". ", bib_key, ": ", bib_entry$title, "-----------")
  field <- "doi"
  doi <- cleanDoiUrl(doi=bib_entry$doi)
  title <- str_replace_all(bib_entry$title, "[{|}]", "")
  if(is.null(doi) || length(doi) <= 0 ){
    tryCatch({
      field <- "url"
      doi <- cleanDoiUrl(url=bib_entry$url)
    }, error = function(e){
      doi <- NULL
      url <- NULL
    })
  }
  if(is.null(doi) || length(doi) <= 0 ){
    if(is.null(title) || length(title) <= 0 ){
      cat(paste0("\nNo DOI and no TITLE found, skipping\n"))
    }
    else{
      cat(paste0("\nNo DOI FOUND, looking for it on CrossRef and ARXIV, query: ", title, "\n"))
      resCR <- cr_works(query = title, format = "text", style = "acm", limit=10) # https://docs.ropensci.org/rcrossref/reference/cr_works.html
      # resPlos <- ft_search(query = title, from="plos")
      resArxiv <- arxiv_search(query = noquote(paste0('ti:\"', title, '\"')), limit=10)
      dois <- list(c(resArxiv$doi, resCR$data$doi))
      dois <- lapply(dois, function(z){ z[!is.na(z) & z != ""]})[[1]]
      cat("ARXIV DOIS: ", length(resArxiv$doi), "CR DOIS: ", length(resCR$data$doi), "Total: ", length(dois))
      similarity_threshold <- 0.8
      for(j in 1:length(dois)){
        doi <- dois[[j]]
        cat("\nGetting data for DOI ", j, " of ", length(dois), ":\t", doi, "\n")
        ref <- getCitationFromDOI(doi, style)
        if(!is.null(ref)){
          cat("\n- Current Title: ", bib_entry$title,"\n- New Title: ", ref$title)
          same_title <- getTitleSimilarity(bib_entry$title, ref$title, similarity_threshold)
          if(same_title){
            cat("\nGetting new Reference")
            new_entry <- ref
            break
          }
        }
      }
    }
  }
  else{
    cat("\nFOUND DOI in field", field, ", looking for data")
    new_entry <- getCitationFromDOI(doi, style)
  }
  
  updated <- FALSE
  if(!is.null(new_entry) && length(new_entry) > 0){
    tryCatch({
      bib_entry <- mergeReferencesClass(bib_entry, new_entry, upd_bibkey, upd_title, upd_author, verbose=FALSE)
      if(upd_abstract){
        new_abstr <- getAbstractFromDOI(bib_entry$doi)
        tryCatch({
          bib_entry[["abstract"]] <- new_abstr
        }, error = function(e) {
          cat("\nError updating abstract: ", paste0(e))
        })
      }
      bib_entry[["r_updated"]] <- "YES"
      cat("\nUpdating OLD Reference")
      updated <- TRUE
    }, error = function(e) {
      cat("\nError merging references: ", paste0(e))
      updated <- FALSE
    })
  }
  
  if(!updated){
    cat("\nNOT UPDATING")
    tryCatch({
      bib_entry$r_updated <- "NO"
    }, error = function(e){
      cat("\nError updating entry: ", paste0(e))
    })
  }
  # entry_str <- getReferenceString(bib_entry, tolower(attr(bibentry, "bibtype")), tolower(attr(bibentry, "key")))
  # write(entry_str, file = out_file, append = TRUE)
  cat("\n-----------------------------------------\n")
  entry_data <- getReferenceListData(bib_entry)
  ret_list <- list(bib_key=entry_data)
  names(ret_list) <- bib_key
  return(ret_list)
}

