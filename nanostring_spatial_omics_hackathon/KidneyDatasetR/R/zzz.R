.onLoad <- function( libname , pkgname )
{
  utils::data( kidney_norm , package = pkgname )
  utils::data( kidney_target , package = pkgname )
  utils::data( kidney_probe , package = pkgname )
}