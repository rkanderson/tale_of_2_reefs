
## Context

This project was completed for a course -- ESM 242 Natural Resource Economics, taught in Fall quarter of 2024 at the Bren School, UCSB.
Professor was Dr. Andrew Plantinga. For the final project, we were to look at a natural resource optimization problem of our choice.

This project was inspired by a real experience of my peer Jackson Hayes, who is a very outdoorsy person and loves spearfishing (among many other ocean activities).

At county line in Malibu, he would go to a nearshore reef, and found the fish populations had been drastically reduced. He noticed that the local fishing charter boat company was taking trips out to the same reef repeatedly. Jackson had the idea to suggest that the captain alternate reefs to give the fish populations time to recover, a suggestion which was rejected. And so we began this project to model the situation and conduct some more quantitative-heavy invistegitation. 


Under the realistic ranges of parameters we tested, we actually found that harvesting a single reef was the optimal solution, contradicting our initial hypothesis. Our realistic parameters were just derived from Jackson's intuition based on what he'd seen, so that's definitely a caveat. 


## Link to interactive shiny app
https://rkanderson.shinyapps.io/tale_of_2_reefs/

## Link to our slides presentation
https://docs.google.com/presentation/d/1reWezVA3fjr1qzyvOK9XN3tgUJsTUQMyKtnIr2PzJhQ/edit?slide=id.g319e17b3570_0_32#slide=id.g319e17b3570_0_32

## Credits to my Bren colleagues who worked on this project with me during Fall Quarter of 2024

Jackson Hayes: https://www.linkedin.com/in/jackson-hayes-234aa6134/


Emma Tao: https://www.linkedin.com/in/emma-tao-8580861a6/


## Stock Dynamics
The basic stock dynamic equation is

$$X_{t+1} = X_t + F(X_t) - H_t + M(X_t)$$
where
- $F(X)$ is the amount of fish added to the stock at period t due to reproductive growth
- $H_t$, is fish harvested in period t
- $M(X_t)$ is the number of fish added to the stock in period $t$ due to migration

We'll model $F(X)$ as follows:

$$ F(X) = rX_t(1-\frac{X_t}{K})$$

We'll model M (Xt) as follows:

$$M(X) = z(K-X_t)$$

where z is some set parameter corresponding to the rate at which migration occurs. If z = 0, no migration occurs. If z = 1, the entire carrying capacity of the reef is filled within a single time period. The amount of harvest that occurs in a given period will be the sum of the harvests that occur at the two individual reefs:


Harvest Equations
$$H_t=q(E_{1t}X_{1t}+E_{2t}X_{2t})$$
where q is a catchability coefficient, and E1t it and E2t are the fishing efforts at reef 1 and reef 2 respectively.
To represent the limited resources available to our hypothetical recreational fishing company, we'll impose a constraint on the total fishing effortthat can go across the 2 reefs during any time period (E_max):

$$ E1t + E2t <= Emax$$
^Fix the format of this

Objective Function: Our objective is going to be to maximize

$$Obj(E_1,E_2) = \sum_{t=1}^T \rho^{t-1} (ln(aH_t+1)-c(E_{1t}+E_{2t})) $$

We are treating the natural log as a sort of utility function, with it's concavity representing the diminishing returns of harvesting more fish. The +1
term is to bound the utility function to be zero at the minimum when H_t = 0. The constant a is a parameter chosen to scale values of H, such that the differences will be ideal for optimization.


## A Parameter Table

<TODO WILL ADD>


