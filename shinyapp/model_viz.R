
# This script will contain a series of functions that can be used to visualize the results of our fishery model.
# It will accomplish this with ggplot2 and other visualization tools, and accepting a single list object containing
# the results of a model run

# Recall the properties of a model run object:

# "stock1" "stock2" "reproductive_growth_1" "reproductive_growth_2" "immigration_1"
# "immigration_2" "harvest 1" "harvest_2" "harvest_total" "present_utility"
# effort1, effort2

# Let's define a function that takes in a model run objects and returns
# a list containing figures for each of the properties
# we'll want a figure that shows the 2 stock trends over time, 
# the 2 harvest trends over time.

vizualize_fishery_model_run <- function(model_run) {
  # Extract the data
  stock1 <- model_run$stock1
  stock2 <- model_run$stock2
  harvest_1 <- model_run$harvest_1
  harvest_2 <- model_run$harvest_2
  effort1 <- model_run$effort1
  effort2 <- model_run$effort2
  
  # browser()n
  
  # Create the plots
  stock_plot <- ggplot(data = data.frame(time = 1:length(stock1), stock1 = stock1, stock2 = stock2), aes(x = time)) +
    geom_line(aes(y = stock1), color = "blue") +
    geom_line(aes(y = stock2), color = "red") +
    labs(title = "Stock Over Time", x = "Time", y = "Stock") +
    scale_color_manual(values = c("blue", "red"), labels = c("Reef 1", "Reef 2")) +
    theme_minimal()
  
  harvest_plot <- ggplot(data = data.frame(time = 1:length(harvest_1), harvest_1 = harvest_1, harvest_2 = harvest_2), aes(x = time)) +
    geom_line(aes(y = harvest_1), color = "blue") +
    geom_line(aes(y = harvest_2), color = "red") +
    labs(title = "Harvest Over Time", x = "Time", y = "Harvest") +
    theme_minimal()
  
  effort_plot <- ggplot(data = data.frame(time = 1:length(model_run$effort1), effort1 = model_run$effort1, effort2 = model_run$effort2), aes(x = time)) +
    geom_line(aes(y = effort1), color = "blue") +
    geom_line(aes(y = effort2), color = "red") +
    labs(title = "Effort Over Time", x = "Time", y = "Effort") +
    theme_minimal()
  
  # Redo the plots, but have legends for what the colors mean (corresponding to the 2 reefs)
  # stock_plot <- stock_plot + scale_color_manual(values = c("blue", "red"), labels = c("Reef 1", "Reef 2"))
  # harvest_plot <- harvest_plot + scale_color_manual(values = c("blue", "red"), labels = c("Reef 1", "Reef 2"))
  # effort_plot <- effort_plot + scale_color_manual(values = c("blue", "red"), labels = c("Reef 1", "Reef 2"))
  # 
  # Return the plots
  # return(list(stock_plot, harvest_plot, effort_plot))
  return(list(stock_plot = stock_plot, harvest_plot = harvest_plot, effort_plot = effort_plot))
}