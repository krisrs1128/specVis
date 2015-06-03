library("shiny")

shinyUI(fluidPage(
  titlePanel("SpectraVis"),
  sidebarLayout(
    sidebarPanel(
      fileInput("data", "File to visualize"),
      downloadButton('downloadPlot', 'save plot'),
      sliderInput("x_range", "ppm range:", round = FALSE, step = 0.001,
                  min = 0.0, max = 10.0, value = c(4.0, 6.0)),
      numericInput("y_range_upper", "intensity-upper-bound", value = 5e3),
      numericInput("y_range_lower", "intensity-lower-bound", value = -100),
      checkboxInput("log_scale", "Log scale"),
      sliderInput("subsample_frac", "subsampling density:",
                  min = 0, max = 1, value = 0.1),
      dateRangeInput("date_range", "Date Range", start = "2013-05-10",
                     end = "2014-10-02"),
      checkboxGroupInput("Class", "Filter by class", choices = 0:3,
                         selected = 0:3),
      checkboxGroupInput("Class.1", "Filter by class 1", choices = c("QC", "Pre", "Post"),
                         selected = c("QC", "Pre", "Post")),
      checkboxGroupInput("Subject", "Filter by subject", choices = c("99", "I", "D", "B", "F", "G"),
                         selected = c("99", "I", "D", "B", "F", "G")),
      selectInput("color", "Color variable", choices = c("None", "Class", "Subject",
                                                         "Relman.ID", "Class.1", "Date")),
      selectInput("linetype", "Linetype variable", choices = c("None", "Class", "Subject",
                                                               "Relman.ID", "Class.1", "Date")),
      sliderInput("line_thickness", "Line thickness", 0, 2, .5, 0.05),
      sliderInput("line_alpha", "Line darkness", 0, 1, 1),
      selectInput("facet_1", "faceting x", choices = c("None", "Class", "Subject", "Class.1")),
      selectInput("facet_2", "faceting y", choices = c("None", "Class", "Subject", "Class.1")),
      selectInput("Sample.Label", "Filter by sample label", choices = c("All", 1:48, 50:236, 991:999, 9910:9924),
                         selected = "All", multiple = T)
    ),
    mainPanel(
      plotOutput("spectraPlot"),
      h2("Usage"),
      h3("File Input"),
      p("You need to upload phylo_clean.RData for this app to work. A lot of the
        features here are hard-coded to work for only this data set, but in principle
        it could be generalized to arbitrary spectra-with-features."),
      h3("Saving"),
      p("You can save the current state of the plot whenever you want by clicking this."),
      h3("Resizing window"),
      p("The first group of parameters specifies the values of ppm and intensity to display.
        The max y value is 5000 because that lets you see the outlier. I picked the default
        ppm arbitrarily, let me know if there would be a better choice."),
      h3("Subsampling"),
      p("To speed up plotting, especially on large ppm ranges, it is convenient to
        subsample ppms. This parameter controls the depth of subsampling. If the
        subsampling density is .1, every 10th ppm will be included, if it is 1, all
        the ppm will be included."),
      h3("Filtering spectra"),
      p("We can try to filter the spectra based on their sample data features.
        I'm not exactly sure what all the variables mean (what is Class?), but
        these were given in the file PilotMater.csv. These do pretty much
        what you would expect -- we can filter down to samples collected in certain
        dates, and based on the class and subject id's. Note that I'm not plotting
        any variables with missing date entries, but I could include them (or include them
        with a checkbox) if that would be interesting.

        Caution: When viewing a few spectra at a time, if a filtering option would
        remove all the spectra, the filtering action is NOT executed. This behavior
        is difficult to change, unfortunately, since it's built into the software I'm
        building on top of."),
      h3("Aesthetics"),
      p("It can be useful to plot features of the spectra on the spectra
        themselves. For now, we allow the user to specify the color, linetype,
        and faceting features. Note that some of the allowed variables have many
        levels, this will result in a long list of colors / linetypes, which
        can slow down plotting."),
      h3("Line thickness / darkness"),
      p("This is self-explanatory."),
      h3("Faceting"),
      p("We can arrange plots into grids based on their membership in different groups.
        This is only implemented for the ggplot plotting method (see below). If you try
        to use it for speaq, it will just change the color aesthetic."),
      h3("Plotting method"),
      p("Behind the scenes, we are using two R packages for the plotting, ggplot and speaq.
        The speaq plotter is faster, but doesn't let you customize as much (e.g., faceting)."),
      h3("Filtering by sample label"),
      p("If we want to view small sets of spectra, un-select 'All' and select the samples (you can
        select more than one) that you want to visualize.")
    )
  )
))