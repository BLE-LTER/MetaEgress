library(testthat)

make_entity_meta <- function(entitytype = "dataTable") {
  list(
    entities = data.frame(
      datasetid = 36,
      entity_position = 1,
      filename = "test.csv",
      filesize = "100",
      filesize_units = "byte",
      checksum = "abc123",
      entitytype = entitytype,
      entityname = "Test Entity",
      entitydescription = "A test entity",
      urlpath = NA,
      headerlines = 1,
      footerlines = NA,
      recorddelimiter = "\\n",
      fielddlimiter = ",",
      quotecharacter = "\"",
      encoding = "UTF-8",
      entityrecords = "10",
      formatname = "CSV",
      stringsAsFactors = FALSE
    ),
    attributes = data.frame(
      datasetid = 36,
      entity_position = 1,
      attributeName = "temperature",
      attributeDefinition = "Water temperature",
      precision = NA,
      dateTimePrecision = NA,
      stringsAsFactors = FALSE
    ),
    factors = data.frame(
      datasetid = numeric(),
      entity_position = numeric(),
      stringsAsFactors = FALSE
    ),
    missing = data.frame(
      datasetid = numeric(),
      entity_position = numeric(),
      stringsAsFactors = FALSE
    )
  )
}

test_that("create_entity creates dataTable entity", {
  local_mocked_bindings(
    check_attribute_congruence = function(...) "checks passed",
    set_physical = function(...) list(objectName = list(...)$objectName),
    set_attributes = function(...) {
      list(attribute = list(list(attributeName = "temperature")))
    },
    .package = utils::packageName()
  )
  
  result <- create_entity(
    meta_list = make_entity_meta("dataTable"),
    file_dir = tempdir(),
    dataset_id = 36,
    entity = 1,
    skip_checks = TRUE
  )
  
  expect_type(result, "list")
  expect_equal(result$entityName, "Test Entity")
  expect_equal(result$entityDescription, "A test entity")
  expect_equal(result$numberOfRecords, "10")
  expect_equal(result$attributeList$attribute[[1]]$id, "d36-e1-att1")
})

test_that("create_entity creates otherEntity when entitytype is not dataTable", {
  result <- create_entity(
    meta_list = make_entity_meta("otherEntity"),
    file_dir = tempdir(),
    dataset_id = 36,
    entity = 1,
    skip_checks = TRUE
  )
  
  expect_type(result, "list")
  expect_equal(result$entityName, "Test Entity")
  expect_equal(result$entityType, "otherEntity")
  expect_equal(result$physical$objectName, "test.csv")
  expect_equal(result$physical$authentication[[1]], "abc123")
})

test_that("create_entity adds download URL when urlpath is provided", {
  meta <- make_entity_meta("otherEntity")
  meta$entities$urlpath <- "https://example.org/data/"
  
  result <- create_entity(
    meta_list = meta,
    file_dir = tempdir(),
    dataset_id = 36,
    entity = 1,
    skip_checks = TRUE
  )
  
  expect_equal(
    result$physical$distribution$online$url[[1]],
    "https://example.org/data/test.csv"
  )
})