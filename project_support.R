
library(tictoc)
library(cmdstanr)
library(parallel)
library(mvtnorm)

set.seed(1)

sim_multilevel_regression <- function(pars) {

  N_obs <- pars$N_obs
  N_grp <- pars$N_grp

  # prior parameters
  a_pop_mu = 0
  a_pop_sigma = 1
  a_grp_sigma_mu = 1
  b_pop_mu = 1
  b_pop_sigma = 1
  b_grp_sigma_mu = 1
  sigma_mu = 1
  ab_grp_eta = 2

  id <- sample(1:N_grp, N_obs, replace = TRUE)
  a_grp_sigma <- rexp(1, 1/a_grp_sigma_mu)
  b_grp_sigma <- rexp(1, 1/b_grp_sigma_mu)
  a_pop <- rnorm(1, a_pop_mu, a_pop_sigma)
  b_pop <- rnorm(1, b_pop_mu, b_pop_sigma)
  ab_mu <- c(a_pop, b_pop)
  ab_grp_rho <- 2 * rbeta(1, ab_grp_eta, ab_grp_eta) - 1 # gotta rescale!
  ab_grp_Omega <- matrix(c(1, ab_grp_rho, ab_grp_rho, 1), ncol = 2)
  ab_grp <- rmvnorm(N_grp, ab_mu, ab_grp_Omega)

  a <- a_pop + ab_grp[,1] * a_grp_sigma
  b <- b_pop + ab_grp[,2] * b_grp_sigma

  sigma <- rexp(1, 1/sigma_mu)
  x <- rnorm(N_obs, 0, 1)
  mu <- a[id] + b[id] * x
  y <- rnorm(N_obs, mu, sigma)

  out <- c(
    pars,
    list(
      x = x,
      id = id,
      y = y
    )
  )
  return(out)

}

multilevel_regression <- cmdstan_model("multilevel_regression.stan")
