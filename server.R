options(shiny.maxRequestSize=50*1024^2)

library("shiny")
library("phyloseqExtend")
library("ggplot2")

shinyServer(function(input, output) {
  phylo_data <- reactive({
    get(load(input$data$datapath))
  })
  plot_input <- reactive({
    cur_data <- phylo_data()

    # Filter by date
    dates <- as.Date(cur_data@sam_data$Date, "%m/%d/%y")
    rm_dates <- (dates > input$date_range[2]) | (dates < input$date_range[1])
    rm_dates[is.na(rm_dates)] <- TRUE # remove the NA dates...
    if(length(rm_dates) > 0) {
      cur_data@spectra@.Data <- cur_data@spectra[!rm_dates,,drop=F]
      cur_data@sam_data@.Data <- cur_data@sam_data[!rm_dates,,drop=F]
    }

    for(filter_var in c("Sample.Label", "Class", "Class.1", "Subject")) {
      if(input[[filter_var]][1] == "All") {
        filter_ix <- 1:nrow(cur_data@spectra)
      } else {
        filter_ix <- which(cur_data@sam_data[[filter_var]] %in% factor(input[[filter_var]]))
      }
      if(length(filter_ix) > 0) {
        cur_data@spectra@.Data <- cur_data@spectra[filter_ix,,drop=F]
        cur_data@sam_data@.Data <- cur_data@sam_data[filter_ix,,drop=F]
      } else {
        warning("Cannot filter all groups.")
        print(filter_var)
      }
    }

    # change y-values
    cur_data@spectra[which(cur_data@spectra < input$y_range_lower)] <- input$y_range_lower
    cur_data@spectra[which(cur_data@spectra > input$y_range_upper)] <- input$y_range_upper

    # set aesthetics
    color <- input$color
    linetype <- input$linetype
    facet_cols <- c(input$facet_1, input$facet_2)
    if(input$color == "None") color <- NULL
    if(input$linetype == "None") linetype  <- NULL
    facet_cols <- facet_cols[which(facet_cols != "None")]
    if(length(facet_cols) == 0) facet_cols <- NULL

    p <- plot_spectra(cur_data, method = "ggplot2", x_min = input$x_range[1],
                      x_max = input$x_range[2], subsample_frac = input$subsample_frac,
                      col = color, linetype = linetype, facet_cols = facet_cols,
                      log_scale = input$log_scale, alpha = input$line_alpha,
                      line_thickness = input$line_thickness) +
      theme_bw()
    print(p)
  })
  output$spectraPlot <- renderPlot(plot_input())
  output$downloadPlot <- downloadHandler(
    filename = function() { paste('spectra_', format(Sys.time(), "%Y%m%d%s"),'.png', sep='') },
    content = function(file) {
      png(file)
      print(plot_input())
      dev.off()
    })
})