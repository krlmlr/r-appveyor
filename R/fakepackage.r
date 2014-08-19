#' Returns 3.
three <- function() {
  3
}

#' Check to see if our argument is three.
is_three <- function(x) {
  see_if(are_equal(3, x))
}

#' Use something from MASS
MASS_huber <- MASS::huber
