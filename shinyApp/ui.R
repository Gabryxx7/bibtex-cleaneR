library(shinythemes)

ui <- fluidPage(
  theme = shinytheme("slate"),
  title  = "BibTex References Cleaner",
  
  fluidRow(style='height:25vh',
    column(4,
           selectizeInput("citStyle", "Citation Style: ", choices = styles, selected = defStyle),
           checkboxInput("upd_bibkey", "Update Bib Key?: ", value = FALSE),
           checkboxInput("upd_title", "Update title?: ", value = FALSE),
           checkboxInput("upd_author", "Update authors?: ", value = FALSE),
           checkboxInput("upd_abstract", "Update abstract?: ", value = FALSE),
           # selectInput("mode", "Mode: ", choices = modes, selected = "r"),
           # selectInput("theme", "Theme: ", choices = themes, selected = "ambience"),
           # numericInput("size", "Tab size:", 4)
    ),
    column(4,
           selectInput("sorting", "Sorting: ", choices = c("Original"="file", "Title"="title", "Bib Key"="bibkey", "Author"="author", "Year"="year", "Bib Type"="bibtype", "Doi"="doi")),
           checkboxInput("sorting_order", "Decreasing: ", value = FALSE),
           actionButton("run", "Clean BibTex!"),
           actionButton("clear", "Clear text"),
           actionButton("refresh", "Refresh"),
           actionButton("reorder", "Reorder")
    ),
    column(3,
           selectInput("mode", "Mode: ", choices = modes, selected = "r"),
           selectInput("theme", "Theme: ", choices = themes, selected = "ambience"),
           numericInput("size", "Tab size:", 4),
           radioButtons("soft", NULL, c("Soft tabs" = TRUE, "Hard tabs" = FALSE), inline = TRUE),
           radioButtons("invisible", NULL, c("Hide invisibles" = FALSE, "Show invisibles" = TRUE), inline = TRUE),
           radioButtons("linenr", NULL, c("Show line #" = TRUE, "Hide line #" = FALSE), inline = TRUE)
    )
  ),
  
  fluidRow(style='height:70vh',
    column(6,
           titlePanel("Original BibTex"),
           aceEditor(
             height="100vh",
             maxLines="Infinity",
             outputId = "aceFrom",
             mode = "r",
             theme = aceTheme,
             # to access content of `selectionId` in server.R use `ace_selection`
             # i.e., the outputId is prepended to the selectionId for use
             # with Shiny modules
             selectionId = "selection",
             value = in_bibtex,
             placeholder = "Show a placeholder when the editor is empty ..."
           )
    ),
    column(6,
           titlePanel("Clean BibTex"),
           aceEditor(
             height="100vh",
             maxLines="Infinity",
             outputId = "aceTo",
             theme = aceTheme,
             mode = "r",
             # to access content of `selectionId` in server.R use `ace_selection`
             # i.e., the outputId is prepended to the selectionId for use
             # with Shiny modules
             selectionId = "selection",
             value = out_bibtex,
             placeholder = "Show a placeholder when the editor is empty ..."
           )
    )
  )
)