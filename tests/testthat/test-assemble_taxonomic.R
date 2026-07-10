library(testthat)

make_taxa <- function() {
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

test_that("returns known URL from providerid", {
  taxa <- make_taxa()
  
  result <- match_provider(taxa, type = "url")
  
  expect_equal(result, "https://marinespecies.org")
})
test_that("returns known provider id", {
  taxa <- make_taxa()
  
  result <- match_provider(taxa, type = "id")
  
  expect_equal(result, "worms")
})

test_that("returns unknown when provider is missing", {
  taxa <- make_taxa()
  taxa$providerid <- NA
  taxa$providerurl <- NA
  
  result <- match_provider(taxa, type = "url")
  
  expect_equal(result, "unknown")
})
test_that("assemble_taxon creates a single taxonomicClassification node", {
  taxa <- make_taxa()
  
  result <- assemble_taxon(taxa)
  
  expect_equal(result$taxonRankName, "species")
  expect_equal(result$taxonRankValue, "Gadus morhua")
  expect_equal(result$commonName, "Atlantic cod")
  expect_equal(result$taxonId[[1]], "126436")
  expect_equal(result$taxonId$provider, "https://marinespecies.org")
})

test_that("assemble_taxonomic returns NULL for empty taxa data frame", {
  taxa <- make_taxa()
  taxa <- taxa[0, ]
  
  result <- assemble_taxonomic(taxa, expand_taxa = FALSE)
  
  expect_null(result)
})

test_that("trims whitespace and ignores case", {
  taxa <- make_taxa()
  taxa$providerid <- " WoRMS "
  
  result <- match_provider(taxa, type = "id")
  
  expect_equal(result, "worms")
})
test_that ("rejects invalid type",{
  taxa <- make_taxa()
  expect_error(match_provider(taxa, type = "name"))

})

test_that ("returns unknown for unrcognized provider",{
  taxa <- make_taxa()
  taxa$providerid <- "not_a_provider"
  taxa$providerurl <- NA
  result <- match_provider(taxa, type = "url")
  
  expect_equal(result, "not_a_provider")
  
})
test_that ("uses provider url when provided", {
  taxa <- make_taxa()
  taxa$providerurl <- "https://itis.gov"
  result <- match_provider(taxa, type = "url")
  expect_equal(result, "https://itis.gov")
})
