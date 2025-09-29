
# Model Specification

## Objective

We are going to model the fishing efforts of a recreational fishing company
on two hypothetical reefs. The objective is going to be to maximize the total
number of fish caught throughout the entire time-span simulated.

The constraint is that there will be a finite amount of fishing trips that can
occur in any given month.

This problem was inspired by 2 real reefs of approximate equal size (1 acre) in the Santa Barbara channel.

## Stock Dynamics

The basic stock dynamic equation is 

$$ X_{t+1} = X_t + F(X_t) - H_t + M(X_t) $$

- $F(X_t)$ is the amount of fish added to the stock at period t due to reproductive growth
- $H_t$ is fish harvested in period $t$
- $M(X_t)$ is the number of fish added to the stock in period t due to migration

We'll model $F(X_t)$ as follows:

$$ F(X_t) = rX_t(1-\frac{X_t}{K})$$

We'll model $M(X_t)$ as follows:

$$ M(X_t) = z(K-X_t) $$

where $z$ is some set parameter corresponding to the rate at which migration occurs.
If $z=0$, no migration occurs. If $z=1$, the entire carrying capacity of the reef is filled within a single time period.

The amount of harvest that occurs in a given period will be the sum of the harvests that occur at 
the two individual reefs:

## Harvest Equations

$$ H_t = q(E_{1t}X_{1t} + E_{2t}X_{2t}) $$

where q is a catchability coefficient, and $E_{1t}$ and $E_{2t}$ are the fishing efforts at reef 1 and reef 2 respectively.

To represent the limited resources available to our hypothetical recreational fishing company, we'll impose a constraint on the total fishing effort that can go across the 2 reefs during any time period ($E_{max}$):

$$ E_{1t} + E_{2t} \le E_{max} $$


## Objective Function

Our objective is going to be to maximize

$$ Obj(E_{1}, E_{2}) = \sum_{t=1}^T \rho^{t-1} \{ln(aH_t+1) - c(E_{1t}+E_{2t})\} $$

We are treating the natural log as a sort of utility function, with it's concavity representing the diminishing returns of harvesting more fish. The +1 term is to bound the utility function to be zero at the minimum when $H_t=0$. The constant $a$ is a parameter chosen to scale values of $H_t$ such that the differences will be ideal for optimization.

We also build in a utility cost term in this model. This term is linear in the fishing effort, and is meant to represent the cost of running a fishing trip. The constant $c$ is a parameter chosen to scale the cost of fishing to our "utility" unit.

## Business as Usual

Business as usual is a pattern we'll define as maximum effort being targeted on one reef until that reef is depleted (we'll consider the reef to be depleted when the stock drops below some threshold), at which point effort is targeted toward the 2nd reef until that other reef is depleted, and so on.

## Model Parameter Table

Unless otherwise stated, all parameter estimates were obtained by a best-judgement approach by a group member who has had first-hand experience witnessing both of the reefs in the real world over time and the effects of recreational fishing on them.

| **Name**                | **Symbol** | **Estimate**        | **Description**                                      |
|-------------------------|------------|---------------------|------------------------------------------------------|
| Initial Stock           | $X_0$      | ~1000 fish          | Same starting value for both reefs.                 |
| Carrying Capacity       | $K$        | ~2000 fish          | Max population the environment supports.            |
| Growth Rate             | $r$        | 0.1-0.5 $yr^{-1}$   | Intrinsic growth rate for whitefish populations.     |
| Fishing Effort Cap      | $E_{max}$  | ~15 fishing days    | Max monthly fishing days.                           |
| Harvest Constant        | $q$        | ~0.05             | Effectiveness of fishing effort; currently calculated assuming 50 fish caught per trip, with 15 trips per week (when stock is 1000 fish) |
| Migration Constant      | $z$        | 0.2                 | Proportion of remaining carrying capacity that becomes occupied by immigrating fish in the next period.         |
| Simulation Time         | $T$        | 24                 | Periods (months) to simulate.                       |
| Discount Term           | $\rho$     | 0.9                 | Discount term for objective function.                |
| Utility Scaling Constant| $a$        | 1                   | Scaling constant for objective function.             |
| Threshold for reef switching | $\gamma$        | 200?                   | The threshold that the stock needs to dip below in order to cause reef switching in a BAU scenario.             |
| Utility cost per fishing trip | $c$        | ?                  | The amount of utility cost associated with doing a fishing trip            |
