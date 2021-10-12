
rm(list = ls())

source("project_support.R")

##########

pars <- list(
  N_obs = 100,
  N_grp = 10,
  n_chains = 1,
  iter_sampling = 2000
)

pars <- sim_multilevel_regression(pars)

tic.clearlog()

tic("run the model once")
fit <- multilevel_regression$sample(parallel_chains = pars$n_chains, chains = pars$n_chains,
  iter_warmup = pars$iter_sampling/2, iter_sampling = pars$iter_sampling, adapt_delta = 0.8,
  max_treedepth = 10, data = pars, step_size = 0.1, seed = 1, refresh = 0
)
toc(log = TRUE)

tic("run the model in a source call")
source("source_fit.R")
toc(log = TRUE)

tic("run five fits in a for loop")
for (i in 1:5) {
  fit <- multilevel_regression$sample(parallel_chains = pars$n_chains, chains = pars$n_chains,
    iter_warmup = pars$iter_sampling/2, iter_sampling = pars$iter_sampling, adapt_delta = 0.8,
    max_treedepth = 10, data = pars, step_size = 0.1, seed = 1, refresh = 0
  )
}
toc(log = TRUE)

tic("run five fits in lapply")
x <- lapply(1:5, function(z) {
  fit <- multilevel_regression$sample(parallel_chains = pars$n_chains, chains = pars$n_chains,
    iter_warmup = pars$iter_sampling/2, iter_sampling = pars$iter_sampling, adapt_delta = 0.8,
    max_treedepth = 10, data = pars, step_size = 0.1, seed = 1, refresh = 0
  )
})
toc(log = TRUE)

tic("run five fits in mclapply with 1 core")
x <- mclapply(1:5, function(z) {
  fit <- multilevel_regression$sample(parallel_chains = pars$n_chains, chains = pars$n_chains,
    iter_warmup = pars$iter_sampling/2, iter_sampling = pars$iter_sampling, adapt_delta = 0.8,
    max_treedepth = 10, data = pars, step_size = 0.1, seed = 1, refresh = 0
  )
}, mc.cores = 1)
toc(log = TRUE)

tic("run five fits in mclapply with 5 core")
x <- mclapply(1:5, function(z) {
  fit <- multilevel_regression$sample(parallel_chains = pars$n_chains, chains = pars$n_chains,
    iter_warmup = pars$iter_sampling/2, iter_sampling = pars$iter_sampling, adapt_delta = 0.8,
    max_treedepth = 10, data = pars, step_size = 0.1, seed = 1, refresh = 0
  )
}, mc.cores = 5)
toc(log = TRUE)


tic("run ten fits in a for loop")
for (i in 1:10) {
  fit <- multilevel_regression$sample(parallel_chains = pars$n_chains, chains = pars$n_chains,
    iter_warmup = pars$iter_sampling/2, iter_sampling = pars$iter_sampling, adapt_delta = 0.8,
    max_treedepth = 10, data = pars, step_size = 0.1, seed = 1, refresh = 0
  )
}
toc(log = TRUE)

tic("run ten fits in lapply")
x <- lapply(1:10, function(z) {
  fit <- multilevel_regression$sample(parallel_chains = pars$n_chains, chains = pars$n_chains,
    iter_warmup = pars$iter_sampling/2, iter_sampling = pars$iter_sampling, adapt_delta = 0.8,
    max_treedepth = 10, data = pars, step_size = 0.1, seed = 1, refresh = 0
  )
})
toc(log = TRUE)

tic("run ten fits in mclapply with 1 core")
x <- mclapply(1:10, function(z) {
  fit <- multilevel_regression$sample(parallel_chains = pars$n_chains, chains = pars$n_chains,
    iter_warmup = pars$iter_sampling/2, iter_sampling = pars$iter_sampling, adapt_delta = 0.8,
    max_treedepth = 10, data = pars, step_size = 0.1, seed = 1, refresh = 0
  )
}, mc.cores = 1)
toc(log = TRUE)

tic("run ten fits in mclapply with 5 core")
x <- mclapply(1:10, function(z) {
  fit <- multilevel_regression$sample(parallel_chains = pars$n_chains, chains = pars$n_chains,
    iter_warmup = pars$iter_sampling/2, iter_sampling = pars$iter_sampling, adapt_delta = 0.8,
    max_treedepth = 10, data = pars, step_size = 0.1, seed = 1, refresh = 0
  )
}, mc.cores = 5)
toc(log = TRUE)

tic("run the model once, again")
  fit <- multilevel_regression$sample(parallel_chains = pars$n_chains, chains = pars$n_chains,
    iter_warmup = pars$iter_sampling/2, iter_sampling = pars$iter_sampling, adapt_delta = 0.8,
    max_treedepth = 10, data = pars, step_size = 0.1, seed = 1, refresh = 0
  )
toc(log = TRUE)


############ write report ############

tic.log(format = TRUE)
msg_log <- unlist(tic.log())

task <- msg_log
task <- gsub(":.*$", "", task)

time_min <- msg_log
time_min <- gsub("^.*: ", "", time_min)
time_min <- gsub(" sec elapsed", "", time_min)
time_min <- round(as.numeric(time_min)/60, 2)

report <- data.frame(
  machine = "imac",
  task = task,
  time_min = time_min
)

write.csv(report, "timing-report-imac.csv", row.names = FALSE)


########## gather reports ############

files <- list.files(pattern = "^timing-report*")

dat <- vector("list", length(files))
for (i in 1:length(files)) dat[[i]] <- read.csv(files[i])

out <- data.frame(
  task = dat[[1]]$task
)
for (i in 1:length(dat)) {
  out[[dat[[i]]$machine[1]]] <- dat[[i]]$time_min
}

write.csv(out, "all-timing-reports.csv", row.names = FALSE)