// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// symm_distance_matrix
NumericMatrix symm_distance_matrix(NumericMatrix m1, NumericVector phi_vector);
RcppExport SEXP _copygpbart_symm_distance_matrix(SEXP m1SEXP, SEXP phi_vectorSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericMatrix >::type m1(m1SEXP);
    Rcpp::traits::input_parameter< NumericVector >::type phi_vector(phi_vectorSEXP);
    rcpp_result_gen = Rcpp::wrap(symm_distance_matrix(m1, phi_vector));
    return rcpp_result_gen;
END_RCPP
}
// distance_matrix
NumericMatrix distance_matrix(NumericMatrix m1, NumericMatrix m2, NumericVector phi_vector);
RcppExport SEXP _copygpbart_distance_matrix(SEXP m1SEXP, SEXP m2SEXP, SEXP phi_vectorSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericMatrix >::type m1(m1SEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type m2(m2SEXP);
    Rcpp::traits::input_parameter< NumericVector >::type phi_vector(phi_vectorSEXP);
    rcpp_result_gen = Rcpp::wrap(distance_matrix(m1, m2, phi_vector));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_copygpbart_symm_distance_matrix", (DL_FUNC) &_copygpbart_symm_distance_matrix, 2},
    {"_copygpbart_distance_matrix", (DL_FUNC) &_copygpbart_distance_matrix, 3},
    {NULL, NULL, 0}
};

RcppExport void R_init_copygpbart(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
