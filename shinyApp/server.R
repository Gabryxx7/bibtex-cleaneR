# define server logic required to generate simple ace editor
shinyServer(function(input, output, session) {
  in_bibtex <- init
  out_bibtex <- ""
  # test_bib_df <- NULL
  observe({
    # print all editor content to the R console
    in_bibtex <<- input$aceFrom
    # cat(input$aceFrom, "\n")
  })
  observe({
    # print all editor content to the R console
    out_bibtex <<- input$aceTo
    # cat(input$aceTo, "\n")
  })
  # 
  # observe({
  #   # print only selected editor content to the R console
  #   # to access content of `selectionId` use `ace_selection`
  #   # i.e., the outputId is prepended to the selectionId for
  #   # use with Shiny modules
  #   cat(input$ace_selection, "\n")
  # })
  # 
  observe({
    updateAceEditor(
      session,
      "aceFrom",
      theme = input$theme,
      mode = input$mode,
      tabSize = size,
    )
    updateAceEditor(
      session,
      "aceTo",
      theme = input$theme,
      mode = input$mode,
      tabSize = input$size,
    )
  })
  
  observeEvent(input$run, {
    base_folder <- tempdir() 
    wd=getwd()
    cat(base_folder)
    cat("\n")
    cat(getwd())
    cat(input$sorting)
    cat("\n")
    in_file <- tempfile(fileext = ".bib", tmpdir  = base_folder)
    out_file <-tempfile(fileext = ".bib", tmpdir  = base_folder)
    workers_log_folder = paste0(base_folder, "\\workers_log_", "\\")
    write(input$aceFrom, file = in_file, append = FALSE)
    test_bib_df <<- readBibAsDf(in_file, encoding = "UTF-8")
    test_bib_df_clean <<- cleanUpdateReferences(test_bib_df,
                                               out_file,
                                               style=input$citStyle,
                                               upd_bibkey=input$upd_bibkey,
                                               upd_title=input$upd_title,
                                               upd_author=input$upd_author,
                                               upd_abstract=input$upd_abstract,
                                               sorting_key=input$sorting,
                                               decreasing=input$sorting_order,
                                               multithreaded = TRUE,
                                               workers_log_folder=workers_log_folder,
                                               wd=paste0(wd, "/../"))
    setwd(wd)
    in_bibtex <<-  enc2native(paste(readLines(in_file, encoding = "UTF-8"), collapse = "\n"))
    out_bibtex <<-  enc2native(paste(readLines(out_file, encoding = "UTF-8"), collapse = "\n"))
    refreshEditor()
    unlink(in_file)
    unlink(out_file)
    unlink(base_folder)
  })
  
  refreshEditor <- function(){
    tryCatch({
      updateAceEditor(session, "aceTo", value = out_bibtex)
    },
    error=function(cond) {
      cat(paste("Error in updating ACE editor"))
      cat("Here's the original error message:")
      cat(cond)
    },
    warning=function(cond) {
      cat(paste("Warning in updating ACE editor"))
      cat("Here's the original error message:")
      cat(cond)
    }
    )
  }
  
  
  observeEvent(input$reorder, {
      test_bib_df_clean <- sort_references(test_bib_df_clean, input$sorting, input$sorting_order)
      out_str <<- writeReferencesDf(test_bib_df_clean, out_filename=NULL, append=FALSE)
      out_bibtex <<-  enc2native(out_str)
      refreshEditor()
  })
  
  observeEvent(input$refresh, {
    refreshEditor()
  })
  
  observeEvent(input$clear, {
    updateAceEditor(session, "aceFrom", value = "")
    updateAceEditor(session, "aceTo", value = "")
  })
})