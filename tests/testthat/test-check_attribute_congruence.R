library(testthat)

make_meta <- function(
    entity_name = "test_table",
    filename = "test.csv",
    attrs = c("site", "season"),
    factors = data.frame(
      datasetid = c(1, 1),
      entity_position = c(1, 1),
      attributeName = c("season", "season"),
      code = c("summer", "winter")
    ),
    missing = data.frame(
      datasetid = numeric(),
      entity_position = numeric(),
      attributeName = character(),
      code = character()
    )
) {
  list(
    entities = data.frame(
      datasetid = 1,
      entity_position = 1,
      filename = filename,
      entityname = entity_name
    ),
    attributes = data.frame(
      datasetid = rep(1, length(attrs)),
      entity_position = rep(1, length(attrs)),
      attributeName = attrs
    ),
    factors = factors,
    missing = missing
  )
}

test_that("returns success message when attributes and metadata match", {
  write.csv(
    data.frame(site = c("A", "B"), season = c("summer", "winter")),
    file.path(tempdir(), "test.csv"),
    row.names = FALSE
  )
  
  result <- check_attribute_congruence(make_meta(), 1, 1, tempdir())
  
  expect_match(result, "Attributes congruence checked")
})

test_that("detects wrong number of columns", {
  write.csv(
    data.frame(site = c("A", "B")),
    file.path(tempdir(), "test.csv"),
    row.names = FALSE
  )
  
  result <- check_attribute_congruence(make_meta(), 1, 1, tempdir())
  
  expect_match(result, "Number of attributes in metadata not matching")
})

test_that("detects misspelled column name", {
  write.csv(
    data.frame(site_wrong = c("A", "B"), season = c("summer", "winter")),
    file.path(tempdir(), "test.csv"),
    row.names = FALSE
  )
  
  result <- check_attribute_congruence(make_meta(), 1, 1, tempdir())
  
  expect_match(result, "Spelling of attribute names")
})

test_that("detects wrong column order", {
  write.csv(
    data.frame(season = c("summer", "winter"), site = c("A", "B")),
    file.path(tempdir(), "test.csv"),
    row.names = FALSE
  )
  
  result <- check_attribute_congruence(make_meta(), 1, 1, tempdir())
  
  expect_match(result, "Order of attributes")
})

test_that("detects value in data not in metadata", {
  write.csv(
    data.frame(site = c("A", "B"), season = c("summer", "spring")),
    file.path(tempdir(), "test.csv"),
    row.names = FALSE
  )
  
  result <- check_attribute_congruence(make_meta(), 1, 1, tempdir())
  
  expect_true(any(grepl("Value in data not in metadata", result)))
  expect_true(any(grepl("spring", result)))
})
test_that("detects value in metadata not in data", {
  write.csv(
    data.frame(site = c("A", "B"), season = c("summer", "summer")),
    file.path(tempdir(), "test.csv"),
    row.names = FALSE
  )
  
  result <- check_attribute_congruence(make_meta(), 1, 1, tempdir())
  
  expect_true(any(grepl("Value in metadata for DataSetAttributeEnumeration not in data", result)))
  expect_true(any(grepl("winter", result)))
})

test_that("detects missing code in metadata not in data", {
  write.csv(
    data.frame(site = c("A", "B"), season = c("summer", "winter")),
    file.path(tempdir(), "test.csv"),
    row.names = FALSE
  )
  
  meta <- make_meta(
    missing = data.frame(
      datasetid = 1,
      entity_position = 1,
      attributeName = "season",
      code = "NA"
    )
  )
  
  result <- check_attribute_congruence(meta, 1, 1, tempdir())
  
  expect_true(any(grepl("Value in metadata for DataSetAttributeMissingCodes not in data", result)))
})

test_that("detects NA in data not listed in missing metadata", {
  write.csv(
    data.frame(site = c("A", "B"), season = c("summer", NA)),
    file.path(tempdir(), "test.csv"),
    row.names = FALSE
  )
  
  result <- check_attribute_congruence(make_meta(), 1, 1, tempdir())
  
  expect_true(any(grepl("Value in data not in metadata for DataSetAttributeMissingCodes", result)))
})

test_that("detects value listed in both enumeration and missing codes", {
  write.csv(
    data.frame(site = c("A", "B"), season = c("summer", "winter")),
    file.path(tempdir(), "test.csv"),
    row.names = FALSE
  )
  
  meta <- make_meta(
    factors = data.frame(
      datasetid = c(1, 1),
      entity_position = c(1, 1),
      attributeName = c("season", "season"),
      code = c("summer", "winter")
    ),
    missing = data.frame(
      datasetid = 1,
      entity_position = 1,
      attributeName = "season",
      code = "summer"
    )
  )
  
  result <- check_attribute_congruence(meta, 1, 1, tempdir())
  
  expect_true(any(grepl("appear in the metadata for both", result)))
  expect_true(any(grepl("summer", result)))
})

test_that("passes when there are no factor rows", {
  write.csv(
    data.frame(site = c("A", "B"), season = c("summer", "winter")),
    file.path(tempdir(), "test.csv"),
    row.names = FALSE
  )
  
  meta <- make_meta(
    factors = data.frame(
      datasetid = numeric(),
      entity_position = numeric(),
      attributeName = character(),
      code = character()
    )
  )
  
  result <- check_attribute_congruence(meta, 1, 1, tempdir())
  
  expect_match(result, "Attributes congruence checked")
})