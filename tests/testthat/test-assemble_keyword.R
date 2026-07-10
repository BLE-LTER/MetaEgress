library(testthat)
make_keyword_df <- function() {
  data.frame(
    keyword = c("Arctic", "lagoon", "temperature", "salinity"),
    keyword_thesaurus = c("LTER", "LTER", "GCMD", "GCMD"),
    keywordtype = c("theme", "theme", "theme", NA),
    stringsAsFactors = FALSE
  )
}

test_that("assemble_keyword creates a single keyword with type",{
  
  keyword <- make_keyword_df()[1,]
  result <- assemble_keyword(keyword)
  expect_equal(result[[1]], "Arctic")
  expect_equal(result$keywordType, "theme")
})

test_that("assemble_keyword returns NULL keywordType when missing",{
  
  keyword <- make_keyword_df()[4,]
  result <- assemble_keyword(keyword)
  expect_equal(result[[1]],"salinity")
  expect_null(result$keywordType)
})

test_that("assemble_thesaurus creates one keywordset",{
  
  thesaurus <- make_keyword_df()[make_keyword_df()$keyword_thesaurus == "LTER", ]
  
  result <- assemble_thesaurus(thesaurus)
  
  expect_type(result,"list")
  expect_equal(result$keywordThesaurus,"LTER")
  expect_equal(length(result$keyword), 2)
  expect_equal(result$keyword[[1]][[1]], "Arctic")
  expect_equal(result$keyword[[2]][[1]],"lagoon")
})

