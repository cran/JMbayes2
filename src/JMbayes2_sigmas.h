#ifndef JMBAYES2SIGMAS_H
#define JMBAYES2SIGMAS_H

#include <Rcpp.h>
#include <RcppArmadillo.h>
#include "JMbayes2_Funs.h"
#include "JMbayes2_LogDens.h"
// [[Rcpp::depends("RcppArmadillo")]]

using namespace Rcpp;
using namespace arma;

vec logPrior_sigmas(const vec &sigmas, const bool &gamma_prior,
                    const vec &sigmas_sigmas, const double &sigmas_df,
                    const vec &sigmas_mean, const double &sigmas_shape) {
  vec out(sigmas.n_rows);
  if (gamma_prior) {
    out = log_dgamma(sigmas, sigmas_shape, sigmas_mean / sigmas_shape);
  } else {
    out = log_dht(sigmas, sigmas_sigmas, sigmas_df);
  }
  return out;
}


void update_sigmas (vec &sigmas, const uvec &has_sigmas,
                    const field<mat> &y, const field<vec> &eta,
                    const vec &extra_parms, const CharacterVector &families,
                    const CharacterVector &links, const field<uvec> &idFast,
                    const bool &gamma_prior,
                    const double &sigmas_df, const vec &sigmas_sigmas,
                    const double &sigmas_shape, const vec &sigmas_mean,
                    const uword &it, mat &res_sigmas, vec &scale_sigmas,
                    mat &acceptance_sigmas) {
  uword n_sigmas = sigmas.n_rows;
  for (uword i = 0; i < n_sigmas; ++i) {
    if (!has_sigmas.at(i)) continue;
    vec logLik_long_i =
      log_long_i(y.at(i), eta.at(i), sigmas.at(i), extra_parms.at(i),
                 std::string(families[i]), std::string(links[i]), idFast.at(i));
    double denominator = sum(logLik_long_i) +
      sum(logPrior_sigmas(sigmas, gamma_prior, sigmas_sigmas, sigmas_df,
                          sigmas_mean, sigmas_shape));
    //
    double SS = 0.5 * std::pow(scale_sigmas.at(i), 2.0);
    double log_mu_current = std::log(sigmas.at(i)) - SS;
    vec proposed_sigmas = propose_lnorm(sigmas, log_mu_current, scale_sigmas, i);
    vec logLik_long_proposed_i =
      log_long_i(y.at(i), eta.at(i), proposed_sigmas.at(i), extra_parms.at(i),
                 std::string(families[i]), std::string(links[i]), idFast.at(i));
    double numerator = sum(logLik_long_proposed_i) +
      sum(logPrior_sigmas(proposed_sigmas, gamma_prior, sigmas_sigmas, sigmas_df,
                          sigmas_mean, sigmas_shape));
    double log_mu_proposed = std::log(proposed_sigmas.at(i)) - SS;
    double log_ratio = numerator - denominator +
      R::dlnorm(sigmas.at(i), log_mu_proposed, scale_sigmas.at(i), true) -
      R::dlnorm(proposed_sigmas.at(i), log_mu_current, scale_sigmas.at(i), true);
    if (std::isfinite(log_ratio) && std::exp(log_ratio) > R::runif(0.0, 1.0)) {
      sigmas = proposed_sigmas;
      acceptance_sigmas.at(it, i) = 1;
    }
    if (it > 119) {
      scale_sigmas.at(i) =
        robbins_monro(scale_sigmas.at(i), acceptance_sigmas.at(it, i), it - 100);
    }
    res_sigmas.at(it, i) = sigmas.at(i);
  }
}

#endif
