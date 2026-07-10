library(testthat)

make_taxa_tree_df <- function() {
  data.frame(
    kingdom = c("Animalia", "Animalia"),
    phylum = c("Chordata", "Chordata"),
    class = c("Actinopterygii", "Mammalia"),
    species = c("Gadus morhua", "Homo sapiens"),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

test_that("structurize returns NULL for empty data frame", {
  taxa_df <- make_taxa_tree_df()[0, ]
  
  result <- structurize(taxa_df)
  
  expect_null(result)
})

test_that("structurize creates top-level taxonomicClassification", {
  result <- structurize(make_taxa_tree_df())
  
  expect_type(result, "list")
  expect_equal(length(result), 1)
  expect_equal(result[[1]]$taxonRankName, "kingdom")
  expect_equal(result[[1]]$taxonRankValue, "Animalia")
})

test_that("structurize creates nested taxonomic classifications", {
  result <- structurize(make_taxa_tree_df())
  
  expect_equal(
    result[[1]]$taxonomicClassification[[1]]$taxonRankName,
    "phylum"
  )
  
  expect_equal(
    result[[1]]$taxonomicClassification[[1]]$taxonRankValue,
    "Chordata"
  )
})

test_that("structurize creates separate branches for different values at same rank", {
  result <- structurize(make_taxa_tree_df())
  
  classes <- result[[1]]$taxonomicClassification[[1]]$taxonomicClassification
  
  class_values <- vapply(classes, function(x) x$taxonRankValue, character(1))
  
  expect_true("Actinopterygii" %in% class_values)
  expect_true("Mammalia" %in% class_values)
})

test_that("structurize removes leading all-NA columns", {
  taxa_df <- make_taxa_tree_df()
  taxa_df <- cbind(
    empty_rank = NA_character_,
    taxa_df,
    stringsAsFactors = FALSE
  )
  
  result <- structurize(taxa_df)
  
  expect_equal(result[[1]]$taxonRankName, "kingdom")
  expect_equal(result[[1]]$taxonRankValue, "Animalia")
})