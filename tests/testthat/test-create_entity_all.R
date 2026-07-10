library(testthat)

make_meta_list <- function() {
  list(
    entities = data.frame(
      datasetid = c(38, 38, 38, 99),
      entity_position = c(1, 2, 3, 1),
      entitytype = c("dataTable", "otherEntity", "data table", "dataTable"),
      stringsAsFactors = FALSE
    ),
    factors = data.frame(datasetid = integer(0), entity_position = integer(0)),
    attributes = data.frame(datasetid = integer(0), entity_position = integer(0)),
    missing = data.frame(datasetid = integer(0), entity_position = integer(0))
  )
}

test_that("returns a list with data_tables and other_entities keys", {
  local_mocked_bindings(
    create_entity = function(entity, ...) list(entity_position = entity),
    .package = "MetaEgress"
  )
  
  result <- create_entity_all(make_meta_list(), dataset_id = 38, skip_checks = TRUE)
  
  expect_type(result, "list")
  expect_named(result, c("data_tables", "other_entities"))
})

test_that("groups data tables and other entities correctly", {
  local_mocked_bindings(
    create_entity = function(entity, ...) list(entity_position = entity),
    .package = "MetaEgress"
  )
  
  result <- create_entity_all(make_meta_list(), dataset_id = 38, skip_checks = TRUE)
  
  expect_equal(length(result$data_tables), 2)
  expect_equal(length(result$other_entities), 1)
  expect_null(names(result$data_tables))
  expect_null(names(result$other_entities))
})

test_that("only entities matching dataset_id are included", {
  local_mocked_bindings(
    create_entity = function(entity, ...) list(entity_position = entity),
    .package = "MetaEgress"
  )
  
  result <- create_entity_all(make_meta_list(), dataset_id = 38, skip_checks = TRUE)
  
  positions <- c(
    vapply(result$data_tables, function(x) x$entity_position, numeric(1)),
    vapply(result$other_entities, function(x) x$entity_position, numeric(1))
  )

  expect_equal(sort(positions), c(1, 2, 3))
})

test_that("uses all entity_positions when entity_numbers is NULL", {
  called_with <- numeric(0)
  
  local_mocked_bindings(
    create_entity = function(entity, ...) {
      called_with <<- c(called_with, entity)
      list(entity_position = entity)
    },
    .package = "MetaEgress"
  )
  
  create_entity_all(make_meta_list(), dataset_id = 38, entity_numbers = NULL, skip_checks = TRUE)
  
  expect_equal(sort(called_with), c(1, 2, 3))
})

test_that("uses only supplied entity_numbers when provided", {
  called_with <- numeric(0)
  
  local_mocked_bindings(
    create_entity = function(entity, ...) {
      called_with <<- c(called_with, entity)
      list(entity_position = entity)
    },
    .package = "MetaEgress"
  )
  
  create_entity_all(make_meta_list(), dataset_id = 38, entity_numbers = c(1, 3), skip_checks = TRUE)
  
  expect_equal(sort(called_with), c(1, 3))
})