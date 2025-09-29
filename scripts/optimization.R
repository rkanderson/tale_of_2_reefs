
# This script contains a function that runs the optimization of the fishery model
# with a set of parameters, and then returns the solution along with an optimal model_run

# the needed parameters are:


optimize_fishery_model <- function(x0, max_effort, initial_stock, carrying_capacity, 
                                   r, q, z, num_periods, 
                                   rho, util_scaling_constant, util_cost_per_trip) {
  # Set seed first
  set.seed(1234)

  # Options
  local_opts<-list("algorithm"="NLOPT_LN_COBYLA",xtol_rel=1e-15)
  options=list("algorithm"="NLOPT_LN_AUGLAG",xtol_rel=1e-15,maxeval=32000,"local_opts"=local_opts)
  
  # Before putting in the variables, make sure they're all numeric type, do conversions if needed
  x0 <- as.numeric(x0)
  max_effort <- as.numeric(max_effort)
  initial_stock <- as.numeric(initial_stock)
  carrying_capacity <- as.numeric(carrying_capacity)
  r <- as.numeric(r)
  q <- as.numeric(q)
  z <- as.numeric(z)
  num_periods <- as.numeric(num_periods)
  rho <- as.numeric(rho)
  util_scaling_constant <- as.numeric(util_scaling_constant)
  util_cost_per_trip <- as.numeric(util_cost_per_trip)
  
  
  
  # Run optimization with supplied parameters
  result <- nloptr(x0 = c(rep(x0, num_periods), rep(1, num_periods)), eval_f = objective_function, lb = c(rep(0, num_periods), rep(0, num_periods)), ub = c(rep(max_effort, num_periods), rep(max_effort, num_periods)),
                   eval_g_ineq = constraint_function, opts = options, 
                   max_effort = max_effort, initial_stock = initial_stock, 
                   carrying_capacity = carrying_capacity, r = r, 
                   q = q, z = z, 
                   num_periods = num_periods, rho=rho, 
                   util_scaling_constant = util_scaling_constant, util_cost_per_trip = util_cost_per_trip)
  
  # Extract the optimal values
  optimal_values <- result$solution
  
  # Run the model with opimal values
  optimal_run <- run_model(optimal_values[1:num_periods], optimal_values[(num_periods+1):(2*num_periods)], max_effort, initial_stock, carrying_capacity, r, q, z, num_periods, rho, util_scaling_constant, util_cost_per_trip)
  
  return(list(optimal_values = optimal_values, optimal_run = optimal_run))
  
}