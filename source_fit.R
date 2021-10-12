
fit <- multilevel_regression$sample(parallel_chains = pars$n_chains, chains = pars$n_chains,
  iter_warmup = pars$iter_sampling/2, iter_sampling = pars$iter_sampling, adapt_delta = 0.8,
  max_treedepth = 10, data = pars, step_size = 0.1, seed = 1, refresh = 0
)
