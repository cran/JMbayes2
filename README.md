
# JMbayes2: Extended Joint Models for Longitudinal and Time-to-Event Data <img src="man/figures/logo.png" align="right" alt="" width="160" />

<!-- badges: start -->

[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version-last-release/JMbayes2)](https://cran.r-project.org/package=JMbayes2)
[![](https://cranlogs.r-pkg.org/badges/grand-total/JMbayes2)](https://cran.r-project.org/package=JMbayes2)
[![Download
counter](https://cranlogs.r-pkg.org/badges/JMbayes2)](https://cran.r-project.org/package=JMbayes2)
[![R build
status](https://github.com/drizopoulos/JMbayes2/workflows/R-CMD-check/badge.svg)](https://github.com/drizopoulos/JMbayes/actions)
<!-- badges: end -->

The package **JMbayes2** fits joint models for longitudinal and
time-to-event data. It can accommodate multiple longitudinal outcomes of
different type (e.g., continuous, dichotomous, ordinal, counts), and
assuming different distributions, i.e., Gaussian, Student’s-t, Gamma,
Beta, unit Lindley, censored Normal, Binomial, Poisson, Negative
Binomial, and Beta-Binomial. For the event time process, right, left and
interval censored data can be handled, while competing risks,
multi-state and recurrent event processes are also covered.

**JMbayes2** fits joint models using Markov chain Monte Carlo algorithms
implemented in C++. Besides the main modeling function, the package also
provides a number of functions to summarize and visualize the results.

## Installation

**JMbayes2** can be installed from [CRAN](https://cran.r-project.org/):

``` r
install.packages("JMbayes2")
```

The development version can be installed from GitHub:

``` r
# install.packages("remotes")
remotes::install_github("drizopoulos/jmbayes2")
```

## Minimal Example

To fit a joint model in **JMbayes2** we first need to fit separately the
mixed-effects models for the longitudinal outcomes and a Cox or
accelerated failure time (AFT) model for the event process. The mixed
models need to be fitted with function `lme()` from the
[**nlme**](https://cran.r-project.org/package=nlme) package or function
`mixed_model()` from the
[**GLMMadaptive**](https://cran.r-project.org/package=GLMMadaptive)
package. The Cox or AFT model need to be fitted with function `coxph()`
or function `survreg()` from the
[**survival**](https://cran.r-project.org/package=survival) package. The
resulting model objects are passed as arguments in the `jm()` function
that fits the corresponding joint model. We illustrate this procedure
for a joint model with three longitudinal outcomes using the PBC
dataset:

``` r
# Cox model for the composite event death or transplantation
pbc2.id$status2 <- as.numeric(pbc2.id$status != 'alive')
CoxFit <- coxph(Surv(years, status2) ~ sex, data = pbc2.id)

# a linear mixed model for log serum bilirubin
fm1 <- lme(log(serBilir) ~ year * sex, data = pbc2, random = ~ year | id)

# a linear mixed model for the prothrombin time
fm2 <- lme(prothrombin ~ year * sex, data = pbc2, random = ~ year | id)

# a mixed effects logistic regression model for ascites
fm3 <- mixed_model(ascites ~ year + sex, data = pbc2,
                   random = ~ year | id, family = binomial())

# the joint model that links all sub-models
jointFit <- jm(CoxFit, list(fm1, fm2, fm3), time_var = "year",
                n_iter = 12000L, n_burnin = 2000L, n_thin = 5L)
summary(jointFit)
```
