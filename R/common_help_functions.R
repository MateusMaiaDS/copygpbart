### All helper functions which are common to bart.R & gpbart.R & some other helper functions
# other common functions related to tree structures are found in

tree_prior <- function(tree, alpha, beta) {

  # Selecting terminal nodes names
  names_terminal_nodes <- names(which(vapply(tree, "[[", numeric(1), "terminal") == 1))

  # Selecting internal nodes names
  names_internal_nodes <- names(which(vapply(tree, "[[", numeric(1), "terminal") == 0))

  # Selecting the depth of the terminal nodes
  depth_terminal <- vapply(tree[names_terminal_nodes], "[[", numeric(1), "depth_node")

  # Selecting the depth of the internal nodes
  depth_internal <- vapply(tree[names_internal_nodes], "[[", numeric(1), "depth_node")

  # Case for stump (No internal node)
  if(length(depth_internal) == 0) {
    log_p <- log(1 - alpha)
  } else {
    # Calculating the log-likelihood
    log_p <- sum(log(1 - alpha * (1 + depth_terminal)^(-beta))) + sum(log(alpha) - beta * log1p(depth_internal))
  }
    return(log_p)
}

# Update tau_j values
update_tau <- function(x,
                       y,
                       a_tau,
                       d_tau,
                       predictions) {

  # Calculating the values of a and d
  n <- nrow(x)

  # Getting the shape parameter from the posterior
  shape_tau_post <- 0.5 * n + a_tau

  # Getting the ratio parameter
  rate_tau_post <- 0.5 * crossprod(y - predictions) + d_tau

  # Updating the \tau
  tau_sample <- stats::rgamma(n = 1, shape = shape_tau_post, rate = rate_tau_post)
    return(tau_sample)
}

dh_cauchy <- function(x,location,sigma){

  if(x>=location){
    return ((2/(pi*sigma))*(1/(1+((x-location)^2)/(sigma^2))))
  } else
    return(0)
}

# Check the appendix of Linero SoftBART for more details
update_tau_linero <- function(x_train,
                              y,
                              y_hat,
                              curr_tau){
  # Getting number of observations
  n <- length(y)
  # Calculating current sigma
  curr_sigma <- curr_tau^(-1/2)

  sigma_naive <- naive_sigma(x = x_train,y = y)

  proposal_tau <- stats::rgamma(n = 1,shape = 0.5*n+1,rate = 0.5*crossprod( (y-y_hat) ))

  proposal_sigma <- proposal_tau^(-1/2)

  acceptance <- exp(log(dh_cauchy(x = proposal_sigma,location = 0,sigma = sigma_naive)) +
                3*log(proposal_sigma) -
                log(dh_cauchy(x = curr_sigma,location = 0,sigma = sigma_naive)) -
                3*log(curr_sigma))

  if(stats::runif(n = 1)<acceptance){
    return(proposal_sigma^(-2))
  } else {
    return(curr_tau)
  }

}

# Functions to find the zero for tau
zero_tau_prob <- function(x, naive_tau_value, prob, shape) {

  # Find the zero to the function P(tau < tau_ols) = 0.1, for a defined
  return(stats::pgamma(naive_tau_value,
                shape = shape,
                rate = x) - (1 - prob))
}

zero_tau_prob_squared <- function(x, naive_tau_value, prob, shape) {

  # Find the zero to the function P(tau < tau_ols) = 0.1, for a defined
  return((stats::pgamma(naive_tau_value,
                 shape = shape,
                 rate = x) - (1 - prob))^2)
}

# Naive tau_estimation
naive_tau <- function(x, y) {

  # Getting the valus from n and p
  n <- length(y)

  # Getting the value from p
  p <- ifelse(is.null(ncol(x)), 1, ncol(x))

  # Adjusting the df
  df <- data.frame(x,y)
  colnames(df)<- c(colnames(x),"y")

  # Naive lm_mod
  lm_mod <- stats::lm(formula = y ~ ., data =  df)

  # Getting sigma
  sigma <- stats::sigma(lm_mod)

  # Using naive tau
  # sigma <- sd(y)

  # Getting \tau back
  tau <- sigma^(-2)
  return(tau)
}

# Naive sigma_estimation
naive_sigma <- function(x,y){

  # Getting the valus from n and p
  n <- length(y)

  # Getting the value from p
  p <- ifelse(is.null(ncol(x)), 1, ncol(x))

  # Adjusting the df
  df <- data.frame(x,y)
  colnames(df)<- c(colnames(x),"y")

  # Naive lm_mod
  lm_mod <- stats::lm(formula = y ~ ., data =  df)

  # Getting sigma
  sigma <- stats::sigma(lm_mod)


  # sigma <- sqrt(sum((lm_mod$residuals)^2)/(n - p))
  # sigma <- stats::sd(y)
  sigma <- stats::sigma(lm_mod)

  return(sigma)
}

# Return rate parameter from the tau prior
rate_tau <- function(x, # X value
                     y, # Y value
                     prob = 0.9,
                     shape) {
  # Find the tau_ols
  tau_ols <- naive_tau(x = x,
                       y = y)

  # Getting the root
  min_root <-  try(stats::uniroot(f = zero_tau_prob, interval = c(1e-3, 1000),
                           naive_tau_value = tau_ols,
                           prob = prob, shape = shape)$root, silent = TRUE)

  if(inherits(min_root, "try-error")) {
    # Verifying the squared version
    min_root <- stats::optim(par = stats::runif(1), fn = zero_tau_prob_squared,
                      method = "L-BFGS-B", lower = 0,
                      naive_tau_value = tau_ols,
                      prob = prob, shape = shape)$par
  }
    return(min_root)
}

# Normalize BART function (Same way as theOdds code)
normalize_bart <- function(y, a = NULL, b = NULL) {

  # Defining the a and b
  if( is.null(a) & is.null(b)){
    a <- min(y)
    b <- max(y)
  }
  # This will normalize y between -0.5 and 0.5
  y  <- (y - a)/(b - a) - 0.5
    return(y)
}

# Now a function to return everything back to the normal scale

unnormalize_bart <- function(z, a, b) {
  # Just getting back to the regular BART
  y <- (b - a) * (z + 0.5) + a
    return(y)
}
# Calculating RMSE
#' @export
rmse <- function(obs, pred) {
  return(sqrt(mean((obs - pred)^2)))
}


# Normalize BART function (Same way ONLY THE COVARIATE NOW)
normalize_covariates_bart <- function(y, a = NULL, b = NULL) {
  
  # Defining the a and b
  if( is.null(a) & is.null(b)){
    a <- min(y)
    b <- max(y)
  }
  # This will normalize y between -0.5 and 0.5
  y  <- (y - a)/(b - a) 
  return(y)
}

# Now a function to return everything back to the normal scale

unnormalize_covariates_bart <- function(z, a, b) {
  # Just getting back to the regular BART
  y <- (b - a) * (z) + a
  return(y)
}


# Calculating RMSE
#' @export
rmse <- function(obs, pred) {
  return(sqrt(mean((obs - pred)^2)))
}

rMVN_var <- function(mean, Sigma) {
  if(length(mean) == 1){
    mean <- rep(mean,nrow(Sigma))
  }
  if(is.matrix(Sigma)) {
    drop(mean + crossprod(PD_chol(Sigma), stats::rnorm(length(mean))))
  } else {
    mean + sqrt(Sigma) * stats::rnorm(length(mean))
  }
}

is_diag_matrix <- function(m) all(m[!diag(nrow(m))] == 0)

PD_chol  <- function(x, ...) tryCatch(chol(x, ...), error=function(e) {
    d    <- nrow(x)
    eigs <- eigen(x, symmetric = TRUE)
    eval <- eigs$values
    evec <- eigs$vectors
      return(chol(x + evec %*% tcrossprod(diag(pmax.int(1e-8, 2 * max(abs(eval)) * d * .Machine$double.eps - eval), d), evec), ...))
  }
)

# Calculating CRPS from (https://arxiv.org/pdf/1709.04743.pdf)
#' @export
crps <- function(y,means,sds){

  # scaling the observed y
  z <- (y-means)/sds

  crps_vector <- sds*(z*(2*stats::pnorm(q = z,mean = 0,sd = 1)-1) + 2*stats::dnorm(x = z,mean = 0,sd = 1) - 1/(sqrt(pi)) )

  return(list(CRPS = mean(crps_vector), crps = crps_vector))
}

# Calculate optim \phi value
log_like_partial_length_parameter <- function(phi,
                                              squared_distance_matrix,
                                              nu,
                                              tau,
                                              y){
  
  # Find the omega first
  omega <- kernel_function(squared_distance_matrix = squared_distance_matrix,nu = nu,phi = phi) 
  K_y <- omega + diag(1/tau, nrow = nrow(squared_distance_matrix))
  
  # Calculating alpha  = solve(K_y,y)
  alpha <- solve(K_y,y)
  
  # Calculating the partial matrix
  K_partial_l <- -(phi^-3)*omega*squared_distance_matrix
  
  
  # THE MINUS HERE IS JUST BECAUSE THE optim FUNCTION ONLY MINIMIZES
  return(- 0.5*sum(diag( crossprod(tcrossprod(alpha)-chol2inv(chol(K_y)),K_partial_l ))) )
}


# sq_dist_matrix <- symm_distance_matrix(m1 = x)
# nu <- 16*10
# y_vec <- normalize_bart(y)
# tau <- 100
# min_dist <- sqrt(min(sq_dist_matrix))
# max_dist <- sqrt(max(sq_dist_matrix))
# 
# phi_max <- numeric()
# optim_length <- optim(par = runif(n = 1,
#                                   min = min_dist,
#                                   max = max_dist),
#                       method = "L-BFGS-B",
#                       lower = min_dist+.Machine$double.eps,
#                       upper = max_dist,
#                       fn = log_like_partial_length_parameter,
#                       squared_distance_matrix = sq_dist_matrix,
#                       nu = nu,
#                       tau = tau,
#                       y = y_vec )
# 
# optim_length$par                      

