// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <RcppArmadillo.h>
#include <Rcpp.h>

using namespace Rcpp;

// mcmc_cpp
List mcmc_cpp(List model_data, List model_info, List initial_values, List priors, List control);
RcppExport SEXP _JMbayes2_mcmc_cpp(SEXP model_dataSEXP, SEXP model_infoSEXP, SEXP initial_valuesSEXP, SEXP priorsSEXP, SEXP controlSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type model_data(model_dataSEXP);
    Rcpp::traits::input_parameter< List >::type model_info(model_infoSEXP);
    Rcpp::traits::input_parameter< List >::type initial_values(initial_valuesSEXP);
    Rcpp::traits::input_parameter< List >::type priors(priorsSEXP);
    Rcpp::traits::input_parameter< List >::type control(controlSEXP);
    rcpp_result_gen = Rcpp::wrap(mcmc_cpp(model_data, model_info, initial_values, priors, control));
    return rcpp_result_gen;
END_RCPP
}
// logLik_jm
arma::vec logLik_jm(List thetas, List model_data, List model_info, List control);
RcppExport SEXP _JMbayes2_logLik_jm(SEXP thetasSEXP, SEXP model_dataSEXP, SEXP model_infoSEXP, SEXP controlSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type thetas(thetasSEXP);
    Rcpp::traits::input_parameter< List >::type model_data(model_dataSEXP);
    Rcpp::traits::input_parameter< List >::type model_info(model_infoSEXP);
    Rcpp::traits::input_parameter< List >::type control(controlSEXP);
    rcpp_result_gen = Rcpp::wrap(logLik_jm(thetas, model_data, model_info, control));
    return rcpp_result_gen;
END_RCPP
}
// mlogLik_jm
arma::mat mlogLik_jm(List res_thetas, arma::mat mean_b_mat, arma::cube post_vars, List model_data, List model_info, List control);
RcppExport SEXP _JMbayes2_mlogLik_jm(SEXP res_thetasSEXP, SEXP mean_b_matSEXP, SEXP post_varsSEXP, SEXP model_dataSEXP, SEXP model_infoSEXP, SEXP controlSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< List >::type res_thetas(res_thetasSEXP);
    Rcpp::traits::input_parameter< arma::mat >::type mean_b_mat(mean_b_matSEXP);
    Rcpp::traits::input_parameter< arma::cube >::type post_vars(post_varsSEXP);
    Rcpp::traits::input_parameter< List >::type model_data(model_dataSEXP);
    Rcpp::traits::input_parameter< List >::type model_info(model_infoSEXP);
    Rcpp::traits::input_parameter< List >::type control(controlSEXP);
    rcpp_result_gen = Rcpp::wrap(mlogLik_jm(res_thetas, mean_b_mat, post_vars, model_data, model_info, control));
    return rcpp_result_gen;
END_RCPP
}