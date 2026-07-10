library(testthat)
make_geo_df <- function() {
  data.frame(
    geographicdescription = "Beaufort Lagoon",
    westboundingcoordinate = -150.1,
    eastboundingcoordinate = -149.2,
    northboundingcoordinate = 71.3,
    southboundingcoordinate = 70.4,
    altitudeminimum = NA,
    altitudemaximum = NA,
    altitudeunits = NA,
    stringsAsFactors = FALSE
  )
}
make_temporal_df <- function() {
  data.frame(
    begindate = as.Date("2020-01-01"),
    enddate = as.Date("2020-12-31"),
    stringsAsFactors = FALSE
  )
}

make_taxonomy_df <- function() {
  data.frame(
    taxonrankname = "species",
    taxonrankvalue = "Gadus morhua",
    commonname = "Atlantic cod",
    taxonid = "126436",
    providerid = "worms",
    providerurl = NA,
    taxonid_provider = "worms",
    stringsAsFactors = FALSE
  )
}

make_meta_list <- function() {
  list(
    geo = make_geo_df(),
    temporal = make_temporal_df(),
    taxonomy = make_taxonomy_df()
  )
}
test_that("assemble_coverage skips taxonomy when skip_taxa is TRUE", {
  result <- assemble_coverage(make_meta_list(), skip_taxa = TRUE)
  
  expect_null(result$taxonomicCoverage)
  expect_false(is.null(result$geographicCoverage))
  expect_false(is.null(result$temporalCoverage))
})

test_that("assemble_coverage returns NULL taxonomicCoverage when taxonomy is empty", {
  meta_list <- make_meta_list()
  meta_list$taxonomy <- make_taxonomy_df()[0, ]
  
  result <- assemble_coverage(meta_list)
  
  expect_null(result$taxonomicCoverage)
})