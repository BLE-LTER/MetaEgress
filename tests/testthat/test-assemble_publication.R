library(testthat)
make_publication_df <- function() {
  data.frame(
    relationship = c(
      "literatureCited",
      "usageCitation",
      "referencePublication"
    ),
    bibtex = c(
      "@article{lit1}",
      "@article{usage1}",
      "@article{ref1}"
    ),
    stringsAsFactors = FALSE
  )
}
test_that("assemble publications returns expected top level structure", {
  pubs <- assemble_publications(make_publication_df())
  
  expect_type(pubs, "list")
  expect_named(pubs, c("lit_cited", "usage_citation", "ref_pub"))
})

test_that("assemble_publications stores literatureCited publications", {
  pubs <- assemble_publications(make_publication_df())
  
  expect_equal(
    pubs$lit_cited$citation[[1]]$bibtex,
    "@article{lit1}"
  )
})

test_that("assemble_publications stores usageCitation publications", {
  pubs <- assemble_publications(make_publication_df())
  
  expect_equal(
    pubs$usage_citation[[2]]$bibtex,
    "@article{usage1}"
  )
})

test_that("assemble publication stores reference publication bibtex", {
  pubs <- assemble_publications(make_publication_df())
  
  expect_true(grepl("@article\\{ref1\\}", pubs$ref_pub$bibtex))
})

test_that("assemble_publications combines multiple referencePublication entries", {
  publication_df <- data.frame(
    relationship = c(
      "referencePublication",
      "referencePublication"
    ),
    bibtex = c(
      "@article{ref1}",
      "@article{ref2}"
    ),
    stringsAsFactors = FALSE
  )
  
  pubs <- assemble_publications(publication_df)
  
  expect_true(grepl("@article\\{ref1\\}", pubs$ref_pub$bibtex))
  expect_true(grepl("@article\\{ref2\\}", pubs$ref_pub$bibtex))
})


