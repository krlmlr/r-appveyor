#' Returns 3.
#' @export
three <- function() {
  3
}

#' Check to see if our argument is three.
#' @export
is_three <- function(x) {
  see_if(are_equal(3, x))
}

#' Use something from MASS
#' @import MASS
#' @import assertthat
MASS_huber <- function() MASS::huber
