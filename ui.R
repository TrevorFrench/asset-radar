# k-means only works with numerical variables,
# so don't give the user the option to select
# a categorical variable
# vars <- setdiff(names(iris), "Species")

# NEED TO LAYER OBSERVATIONS
pageWithSidebar(
  headerPanel('Asset Radar'),
  sidebarPanel(
    dateInput("first_date", "Select a date:", value = '2016-01-01'),
    dateInput("last_date", "Select a date:", value = '2023-06-14'),
    checkboxInput("opt_layer", label = "Add your data:", value = FALSE)
  ),
  mainPanel(
    plotOutput('plot1')
  )
)