#include <Rcpp.h>

// [[Rcpp::export]]
RcppExport SEXP hello(SEXP a) {
  return Rcpp::wrap("Hello, Rcpp!");
}
