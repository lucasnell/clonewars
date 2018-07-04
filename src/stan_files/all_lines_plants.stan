
/*
    This version differs from `all_lines.stan` because it also models a parameter
    for each plant's affect on the line's alpha parameter.

    `beta` is meant to center on 1 so that it indicates how a plant changes `alpha`
    compared to the average plant.
*/

data {
    int<lower=1> N_ts;                          // Number of time series (line + rep)
    int<lower=1> max_reps;                      // Max reps per time series
    int<lower=1> n_lines;                       // number of aphid lines
    int<lower=1> nobs_ts[N_ts];                 // # observations for each time series
    int<lower=1, upper=n_lines> line_ts[N_ts];  // aphid line for each time series
    matrix<lower=0>[max_reps, N_ts] X;          // log(N_t)
}
parameters {
    // Means:
    real<lower=0> mean_R0;
    real<lower=0> mean_alpha;
    // real<lower=0> mean_beta;                 // forcing this to be ~1
    // SDs:
    real<lower=0> sigma_R0;
    real<lower=0> sigma_alpha;
    real<lower=0> sigma_beta;
    // Z-transforms:
    vector[n_lines] Z_R0;
    vector[n_lines] Z_alpha;
    vector[N_ts] Z_beta;

    real<lower=0> process;
}
transformed parameters {

    vector<lower=0>[n_lines] R0;            // estimated growth rate
    vector<lower=0>[n_lines] alpha;         // estimated density dependence
    vector<lower=0>[N_ts] beta;             // effects of plants on alpha
    matrix<lower=0>[max_reps, N_ts] X_pred; // predicted X not including process error

    R0 = mean_R0 + sigma_R0 * Z_R0;
    alpha = mean_alpha + sigma_alpha * Z_alpha;
    beta = 1 + sigma_beta * Z_beta;

    for (i in 1:N_ts) {
        X_pred[1, i] = X[1, i];
        X_pred[2:nobs_ts[i], i] = X[1:(nobs_ts[i]-1), i] + R0[line_ts[i]] *
            (1 - beta[i] * alpha[line_ts[i]] * exp(X[1:(nobs_ts[i]-1), i]));
        if (nobs_ts[i] < max_reps) {
            for (j in (nobs_ts[i]+1):max_reps) X_pred[j, i] = 0;
        }
    }

}
model {

    // Inputs here are your priors:
    // Means
    mean_R0 ~ normal(0.2711385, 0.01517227)T[0,];
    mean_alpha ~ normal(0.002, 0.0005)T[0,];
    // SDs
    sigma_R0 ~ cauchy(0.02145683, 0.005)T[0,];
    sigma_alpha ~ cauchy(0.001, 0.0005)T[0,];
    sigma_beta ~ cauchy(0.005, 0.001)T[0,];
    // Z-transforms
    Z_R0 ~ normal(0,1);
    Z_alpha ~ normal(0,1);
    Z_beta ~ normal(0,1);

    process ~ cauchy(0.1, 0.1)T[0,];

    for (i in 1:N_ts) {
        X[2:nobs_ts[i], i] ~ normal(X_pred[2:nobs_ts[i], i], process);
    }

}
