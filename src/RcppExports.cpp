// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

#ifdef RCPP_USE_GLOBAL_ROSTREAM
Rcpp::Rostream<true>&  Rcpp::Rcout = Rcpp::Rcpp_cout_get();
Rcpp::Rostream<false>& Rcpp::Rcerr = Rcpp::Rcpp_cerr_get();
#endif

// symm_distance_matrix
NumericMatrix symm_distance_matrix(NumericMatrix m1);
RcppExport SEXP _gpbart_symm_distance_matrix(SEXP m1SEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericMatrix >::type m1(m1SEXP);
    rcpp_result_gen = Rcpp::wrap(symm_distance_matrix(m1));
    return rcpp_result_gen;
END_RCPP
}
// distance_matrix
NumericMatrix distance_matrix(NumericMatrix m1, NumericMatrix m2);
RcppExport SEXP _gpbart_distance_matrix(SEXP m1SEXP, SEXP m2SEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericMatrix >::type m1(m1SEXP);
    Rcpp::traits::input_parameter< NumericMatrix >::type m2(m2SEXP);
    rcpp_result_gen = Rcpp::wrap(distance_matrix(m1, m2));
    return rcpp_result_gen;
END_RCPP
}

static const R_CallMethodDef CallEntries[] = {
    {"_gpbart_symm_distance_matrix", (DL_FUNC) &_gpbart_symm_distance_matrix, 1},
    {"_gpbart_distance_matrix", (DL_FUNC) &_gpbart_distance_matrix, 2},
    {NULL, NULL, 0}
};

RcppExport void R_init_gpbart(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
