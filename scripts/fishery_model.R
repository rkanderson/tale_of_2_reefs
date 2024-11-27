

# run_model()
# runs model and returns a dataframe with all data produced throughout the simulated periods.
# Paramater list:
  # E1: vector of fishing effort for reef 1 throughout all periods
  # E2: vector of fishing effort for reef 2 throughout all periods
  # max_effort: maximum effort allowed across both reefs for any given time period
  # initial_stock: initial stock of fish in each reef (same for both)
  # carrying_capacity: carrying capacity of each reef (same for both)
  # r: intrinsic population growth rate coefficient for the fish species
  # q: catchability coefficient for the fish species
  # z: migration coefficient for the fish species
  # num_periods: number of time periods to simulate
  # rho: discount rate for present utility
  # util_scaling_constant: scaling constant for present utility
# Returns: 
#   dataframe with columns for stock1, stock2, reproductive_growth_1, reproductive
run_model <- function(E1, E2, max_effort, initial_stock, carrying_capacity, 
                      r, q, z, num_periods, rho, util_scaling_constant) {
  # Initialize vectors to track everything we need.
  stock1 <- vector(mode = "numeric", length = num_periods)
  stock2 <- vector(mode = "numeric", length = num_periods)
  reproductive_growth_1 <- vector(mode = "numeric", length = num_periods)
  reproductive_growth_2 <- vector(mode = "numeric", length = num_periods)
  immigration_1 <- vector(mode = "numeric", length = num_periods)
  immigration_2 <- vector(mode = "numeric", length = num_periods)
  harvest_1 <- vector(mode = "numeric", length = num_periods)
  harvest_2 <- vector(mode = "numeric", length = num_periods)
  harvest_total <- vector(mode = "numeric", length = num_periods)
  present_utility <- vector(mode = "numeric", length = num_periods)
  
  # Run the model
  for (i in 1:num_periods){
    
    # Stock updates
    if(i==1) {
      # If it's the first step, set the stock to the initial stock
      stock1[i] <- initial_stock
      stock2[i] <- initial_stock
    } else {
      # Otherwise, update the stock based on the previous stock and the other factors
      stock1[i] <- stock1[i-1] + reproductive_growth_1[i-1] + immigration_1[i-1] - harvest_1[i-1]
      stock2[i] <- stock2[i-1] + reproductive_growth_2[i-1] + immigration_2[i-1] - harvest_2[i-1]
    }
    
    # browser()
    
    # Reproductive growth -- fish that will be added to the stock from offspring
    # of current stock by the END of the current period
    reproductive_growth_1[i] <- r*stock1[i]*(1-stock1[i]/carrying_capacity)
    reproductive_growth_2[i] <- r*stock2[i]*(1-stock2[i]/carrying_capacity)
    
    # Immigration -- fish that will be added to the stock from migration
    # by the END of the current period
    immigration_1[i] <- z*(carrying_capacity-stock1[i])
    immigration_2[i] <- z*(carrying_capacity-stock2[i])
    
    # Harvest -- num fish removed by harvesting by the END of the current period
    harvest_1[i] <- q*E1[i]*stock1[i]
    harvest_2[i] <- q*E2[i]*stock2[i]
    harvest_total[i] <- harvest_1[i] + harvest_2[i]
    
    # Present utility -- defined as the discounted log of the harvest_total
    present_utility[i] <- rho^(i-1)*log(util_scaling_constant * harvest_total[i] + 1)
    
  }
  
  # Return a dataframe with all the data
  return(data.frame(effort1=E1, effort2=E2, stock1, stock2, reproductive_growth_1, reproductive_growth_2,
                    immigration_1, immigration_2, harvest_1, harvest_2,
                    harvest_total, present_utility))
}


# Objective Function
# assume choice is a vector consisting of 2 elements: E1 and E2
objective_function <- function(choice, max_effort, initial_stock, carrying_capacity, r, q, z, num_periods, rho, util_scaling_constant){
  
  
  # Extract E1 and E2
  E1 <- choice[1:num_periods]
  E2 <- choice[(num_periods+1):(2*num_periods)]
  
  
  # Run the model
  model_data <- run_model(E1, E2, max_effort, initial_stock, carrying_capacity, r, q, z, num_periods, rho, util_scaling_constant)
  
  # UTILITY_COST_PER_TRIP <- 100
  # browser()
  
  # Return the sum of present utility
  return(-sum(model_data$present_utility))
}

# Constraint Function
# require that the sum of the two choices is equal to the max effort
# assume choice is a vector consisting of 2 subvectors: E1 and E2
constraint_function <- function(choice, max_effort, initial_stock, carrying_capacity, r, q, z, num_periods, rho, util_scaling_constant){
  # Extract E1 and E2.
  # this will require subindexing the vector
  E1 <- choice[1:num_periods]
  E2 <- choice[(num_periods+1):(2*num_periods)]
  
  # Return the difference between the sum of the two choices and the max effort
  return(E1 + E2 - max_effort)
}


## Business as Usual ## 
# For business as usual, we'll have a simple way to run the model where effort 
# is not passed in as a parameter. Rather, effort is maximized on one of the reefs
# until it reaches depleteion (less than the gamma threshold) at which point we switch to the other reef.
# This will be done in a loop until the end of the simulation period.
run_model_BAU <- function(gamma, max_effort, 
                          initial_stock, carrying_capacity, 
                          r, q, z, num_periods, rho, util_scaling_constant) {
  # Initialize vectors to track everything we need.
  stock1 <- vector(mode = "numeric", length = num_periods)
  stock2 <- vector(mode = "numeric", length = num_periods)
  reproductive_growth_1 <- vector(mode = "numeric", length = num_periods)
  reproductive_growth_2 <- vector(mode = "numeric", length = num_periods)
  immigration_1 <- vector(mode = "numeric", length = num_periods)
  immigration_2 <- vector(mode = "numeric", length = num_periods)
  harvest_1 <- vector(mode = "numeric", length = num_periods)
  harvest_2 <- vector(mode = "numeric", length = num_periods)
  harvest_total <- vector(mode = "numeric", length = num_periods)
  present_utility <- vector(mode = "numeric", length = num_periods)
  effort1 <- vector(mode = "numeric", length = num_periods)
  effort2 <- vector(mode = "numeric", length = num_periods)
  
  # browser()
  
  # Run the model
  for (i in 1:num_periods){
    
    # Stock updates
    if(i==1) {
      # If it's the first step, set the stock to the initial stock
      stock1[i] <- initial_stock
      stock2[i] <- initial_stock
    } else {
      # Otherwise, update the stock based on the previous stock and the other factors
      stock1[i] <- stock1[i-1] + reproductive_growth_1[i-1] + immigration_1[i-1] - harvest_1[i-1]
      stock2[i] <- stock2[i-1] + reproductive_growth_2[i-1] + immigration_2[i-1] - harvest_2[i-1]
    }
    
    
    # Reproductive growth -- fish that will be added to the stock from offspring
    # of current stock by the END of the current period
    reproductive_growth_1[i] <- r*stock1[i]*(1-stock1[i]/carrying_capacity)
    reproductive_growth_2[i] <- r*stock2[i]*(1-stock2[i]/carrying_capacity)
    
    # Immigration -- fish that will be added to the stock from migration
    # by the END of the current period
    immigration_1[i] <- z*(carrying_capacity-stock1[i])
    immigration_2[i] <- z*(carrying_capacity-stock2[i])
    
    # browser()
    
    # Harvest -- num fish removed by harvesting by the END of the current period
    # This is where we differ from an optimized solution.
    if(i==1) {
      # If it's the first step, set the stock to the initial stock
      harvest_1[i] <- q*max_effort*stock1[i]
      harvest_2[i] <- 0
      effort1[i] <- max_effort
      effort2[i] <- 0
    } else if(harvest_1[i-1] > 0) {
      if(stock1[i] > gamma) {
        harvest_1[i] <- q*max_effort*stock1[i]
        harvest_2[i] <- 0
        effort1[i] <- max_effort
        effort2[i] <- 0
      } else {
        harvest_1[i] <- 0
        harvest_2[i] <- q*max_effort*stock2[i]
        effort1[i] <- 0
        effort2[i] <- max_effort
      }
    } else if(harvest_2[i-1] > 0) {
      if(stock2[i] > gamma) {
        harvest_1[i] <- 0
        harvest_2[i] <- q*max_effort*stock2[i]
        effort1[i] <- 0
        effort2[i] <- max_effort
      } else {
        harvest_1[i] <- q*max_effort*stock1[i]
        harvest_2[i] <- 0
        effort1[i] <- max_effort
        effort2[i] <- 0
      }
    } else {
      harvest_1[i] <- 0
      harvest_2[i] <- 0
      effort1[i] <- 0
      effort2[i] <- 0
    }
    
    # Present utility -- defined as the discounted log of the harvest_total
    present_utility[i] <- rho^(i-1)*log(util_scaling_constant * harvest_total[i] + 1)
    
  }
  
  # Return a dataframe with all the data
  return(data.frame(effort1, effort2, stock1, stock2, reproductive_growth_1, reproductive_growth_2,
                    immigration_1, immigration_2, harvest_1, harvest_2,
                    harvest_total, present_utility))
}

