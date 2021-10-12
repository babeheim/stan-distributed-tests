data {
  int<lower=0> N_obs;
  int id[N_obs];
  vector[N_obs] x;
  vector[N_obs] y;
  int<lower=0> N_grp;
}
transformed data {
  real<lower=0> a_grp_sigma_rate = 1;
  real<lower=0> b_grp_sigma_rate = 1;
  real<lower=0> sigma_rate = 1;
  vector[2] ab_grp_mu[N_grp];
  for (i in 1:N_grp) {
    ab_grp_mu[i] = rep_vector(0, 2);
  }
}
parameters {
  real a_pop;
  real<lower=0> a_grp_sigma;
  real b_pop;
  real<lower=0> b_grp_sigma;
  vector[2] ab_grp[N_grp];
  real<lower=0> sigma;
  corr_matrix[2] ab_grp_Omega;
}
transformed parameters {
  vector[N_grp] a = a_pop + to_vector(ab_grp[,1]) * a_grp_sigma;
  vector[N_grp] b = b_pop + to_vector(ab_grp[,2]) * b_grp_sigma;
}
model {
  a_pop ~ normal(0, 1);
  a_grp_sigma ~ exponential(a_grp_sigma_rate);
  b_pop ~ normal(1, 1);
  b_grp_sigma ~ exponential(b_grp_sigma_rate);
  ab_grp_Omega ~ lkj_corr(2); // prior on the correlation matrix
  ab_grp ~ multi_normal(ab_grp_mu, ab_grp_Omega); // joint prior
  sigma ~ exponential(sigma_rate);
  for (i in 1:N_obs) {
    real mu = a[id[i]] + b[id[i]] * x[i];
    target += normal_lpdf(y[i] | mu, sigma);
  }
}
generated quantities {
  real ab_grp_rho = ab_grp_Omega[2,1];
}