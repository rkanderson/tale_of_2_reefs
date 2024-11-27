

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

# Set up the BAU constraint
constraint_function_BAU <- function(choice, max_effort, initial_stock, carrying_capacity, r, q, z, num_periods, rho, util_scaling_constant){
  # Define the gamma constant, or critical threshold for stock depletion switching under BAU
  GAMMA <- 200
  ONE_REEF_ONLY_PENALTY <- 1.8
  DEPLETION_SWITCHING_PENALTY <- 50
  # Extract E1 and E2.
  # this will require subindexing the vector
  E1 <- choice[1:num_periods]
  E2 <- choice[(num_periods+1):(2*num_periods)]
  
  # run model
  model_data <- run_model(E1, E2, max_effort, initial_stock, carrying_capacity, 
                          r, q, z, num_periods, rho, util_scaling_constant)
  
  # "one reef at a time" criterion
  # taking product of E1 and E2 will give us a vector consisting entirely
  # of zeroes if it is one reef at a time
  one_reef_only <- E1 * E2 * ONE_REEF_ONLY_PENALTY
  
  # "switching beneath appropriate threshold" criterion
  # we'll loop through the model data, and find points where a switch happens
  # ie if an effort vector becomes zero, then it should be because the
  # stock in the last period is below a certain threshold
  depletion_switching <- rep(0, num_periods)
  for(i in 2:num_periods){

   if(E1[i] == 0 & E1[i-1] > 0 & model_data$stock1[i-1] > GAMMA){
     depletion_switching[i] <- DEPLETION_SWITCHING_PENALTY
   }
   if(E2[i] == 0 & E2[i-1] > 0 & model_data$stock2[i-1] > GAMMA){
     depletion_switching[i] <- DEPLETION_SWITCHING_PENALTY
   }
  }
  
  # Return the difference between the sum of the two choices and the max effort
  # also add the one_reef_only and depletion_switching vectors, so that the quantity
  # can increase beyond zero if the constraints are violated
  return(E1 + E2 - max_effort + one_reef_only + depletion_switching)
}