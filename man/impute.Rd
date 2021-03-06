% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data_manip.R
\name{impute}
\alias{impute}
\title{Impute missing data.}
\usage{
impute(X)
}
\arguments{
\item{X}{Vector of log(N) through time.}
}
\description{
From \href{https://arxiv.org/abs/1510.03924}{Moritz et al. (2015)}, the
seasonal kalman filter from the \code{zoo} package works well, so I'm creating this function
here to impute missing values below.
We're only missing 1 or 2 time points across a time series of >15, so this
shouldn't have too big an impact on our results.
}
