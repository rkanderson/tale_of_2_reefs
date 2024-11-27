# Load required libraries
library(shiny)

# Source the necessary scripts
source(here("scripts", "fishery_model.R"))
source(here("scripts", "optimization.R"))
source(here("scripts", "model_viz.R"))

# Default parameter values
SIMULATION_LENGTH <- 24
INITIAL_STOCK <- 1000
CARRYING_CAPACITY <- 2000
GROWTH_RATE <- 0.1
EFFORT_CAP <- 15
HARVEST_CONSTANT <- 0.05
MIGRATION_CONSTANT <- 0
UTIL_SCALING_CONSTANT <- 0.01
RHO <- 0.95

# Define UI
ui <- fluidPage(
  titlePanel("Fishery Model Optimization"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Model Parameters"),
      sliderInput("x0", "Initial Effort (x0)", min = 0, max = 20, value = 5, step = 0.1),
      sliderInput("max_effort", "Maximum Effort (Effort Cap)", min = 1, max = 50, value = EFFORT_CAP, step = 1.0),
      sliderInput("initial_stock", "Initial Stock", min = 100, max = 5000, value = INITIAL_STOCK, step = 100.0),
      sliderInput("carrying_capacity", "Carrying Capacity", min = 500, max = 5000, value = CARRYING_CAPACITY, step = 100.0),
      sliderInput("r", "Growth Rate (r)", min = 0.01, max = 1, value = GROWTH_RATE, step = 0.01),
      sliderInput("q", "Harvest Constant (q)", min = 0.01, max = 0.5, value = HARVEST_CONSTANT, step = 0.01),
      sliderInput("z", "Migration Constant (z)", min = -1, max = 1, value = MIGRATION_CONSTANT, step = 0.001),
      sliderInput("num_periods", "Simulation Length", min = 12, max = 60, value = SIMULATION_LENGTH, step = 1.0),
      sliderInput("rho", "Discount Rate (rho)", min = 0, max = 1, value = RHO, step = 0.05),
      sliderInput("util_scaling_constant", "Utility Scaling Constant", min = 0.001, max = 2, value = UTIL_SCALING_CONSTANT, step = 0.001),
      checkboxInput("use_BAU", "Use Business as Usual"),
      sliderInput("gamma", "BAU Threshold", min = 10, max = 10000, value = 500, step = 1.0)
    ),
    
    mainPanel(
      h3("Optimization Results"),
      plotOutput("stock_plot"),
      plotOutput("harvest_plot"),
      plotOutput("effort_plot")
    )
  )
)

# Define server
server <- function(input, output) {
  # Reactive optimization result based on inputs
  optimization_result <- reactive({
    
    optimize_fishery_model(
      x0 = input$x0,
      max_effort = input$max_effort,
      initial_stock = input$initial_stock,
      carrying_capacity = input$carrying_capacity,
      r = input$r,
      q = input$q,
      z = input$z,
      num_periods = input$num_periods,
      rho = input$rho,
      util_scaling_constant = input$util_scaling_constant
    )
  })
  
  # run_model_BAU <- function(gamma, max_effort, 
  #                           initial_stock, carrying_capacity, 
  #                           r, q, z, num_periods, rho, util_scaling_constant) {
  bau_result <- reactive({
    run_model_BAU(
      gamma = input$gamma,
      max_effort = input$max_effort,
      initial_stock = input$initial_stock,
      carrying_capacity = input$carrying_capacity,
      r = input$r,
      q = input$q,
      z = input$z,
      num_periods = input$num_periods,
      rho = input$rho,
      util_scaling_constant = input$util_scaling_constant
    )
  })
  
  # Render plots
  output$stock_plot <- renderPlot({
    if (input$use_BAU) {
      viz <- vizualize_fishery_model_run(bau_result())
    } else {
      viz <- vizualize_fishery_model_run(optimization_result()$optimal_run)
    }
    viz$stock_plot
  })
  
  output$harvest_plot <- renderPlot({
    if (input$use_BAU) {
      viz <- vizualize_fishery_model_run(bau_result())
    } else {
      viz <- vizualize_fishery_model_run(optimization_result()$optimal_run)
    }
    viz$harvest_plot
  })
  
  output$effort_plot <- renderPlot({
    if (input$use_BAU) {
      viz <- vizualize_fishery_model_run(bau_result())
    } else {
      viz <- vizualize_fishery_model_run(optimization_result()$optimal_run)
    }
    viz$effort_plot
  })
}

# Run the application
shinyApp(ui = ui, server = server)
