% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dev_helpers.R
\name{is_dateless_SL_tibble}
\alias{is_dateless_SL_tibble}
\title{is_dateless_SL_tibble}
\usage{
is_dateless_SL_tibble(x)
}
\arguments{
\item{x}{Any object}
}
\value{
Logical
}
\description{
Confirm that an object is a
dateless StudentLife tibble
}
\examples{
d <- tempdir()
download_studentlife(location = d, url = "testdata")

tab_S <- load_SL_tibble(
  schema = "survey", table = "BigFive", location = d)

# Returns TRUE
is_dateless_SL_tibble(tab_S)

}
