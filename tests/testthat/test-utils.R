library(testthat)

# ---------------------------------------------------------------------------
# null_if_na()
# ---------------------------------------------------------------------------

test_that("null_if_na returns the column value when it is present", {
  df <- data.frame(
    name = "Induja",
    stringsAsFactors = FALSE
  )
  
  result <- null_if_na(df, "name")
  
  expect_equal(result, "Induja")
})

test_that("null_if_na returns NULL when all values are NA", {
  df <- data.frame(
    name = c(NA_character_, NA_character_)
  )
  
  result <- null_if_na(df, "name")
  
  expect_null(result)
})

test_that("null_if_na returns non-NA values when column contains some NA values", {
  df <- data.frame(
    name = c("Induja", NA_character_),
    stringsAsFactors = FALSE
  )
  
  result <- null_if_na(df, "name")
  
  expect_equal(result, c("Induja", NA_character_))
})

test_that("null_if_na returns NULL when the column does not exist", {
  df <- data.frame(
    name = "Induja",
    stringsAsFactors = FALSE
  )
  
  result <- null_if_na(df, "email")
  
  expect_null(result)
})

# ---------------------------------------------------------------------------
# na_if_empty()
# ---------------------------------------------------------------------------

test_that("na_if_empty trims leading and trailing whitespace", {
  values <- c(" Induja ", " Mohandas")
  
  result <- na_if_empty(values)
  
  expect_equal(result, c("Induja", "Mohandas"))
})

test_that("na_if_empty converts empty strings to NA", {
  values <- c("", "Induja")
  
  result <- na_if_empty(values)
  
  expect_true(is.na(result[1]))
  expect_equal(result[2], "Induja")
})

test_that("na_if_empty converts whitespace-only strings to NA", {
  values <- c("   ", "\t", "Induja")
  
  result <- na_if_empty(values)
  
  expect_true(is.na(result[1]))
  expect_true(is.na(result[2]))
  expect_equal(result[3], "Induja")
})

test_that("na_if_empty preserves existing NA values", {
  values <- c(NA_character_, "Induja")
  
  result <- na_if_empty(values)
  
  expect_true(is.na(result[1]))
  expect_equal(result[2], "Induja")
})

# ---------------------------------------------------------------------------
# subset_dataset()
# ---------------------------------------------------------------------------

make_subset_meta <- function() {
  list(
    dataset = data.frame(
      datasetid = c(1, 2, 2),
      title = c("Dataset 1", "Dataset 2A", "Dataset 2B"),
      stringsAsFactors = FALSE
    )
  )
}

test_that("subset_dataset returns rows for the requested dataset", {
  result <- subset_dataset(
    meta_list = make_subset_meta(),
    list_item = "dataset",
    dataset_id = 2
  )
  
  expect_equal(nrow(result), 2)
  expect_equal(result$title, c("Dataset 2A", "Dataset 2B"))
  expect_true(all(result$datasetid == 2))
})

test_that("subset_dataset returns an empty data frame when no rows match", {
  result <- subset_dataset(
    meta_list = make_subset_meta(),
    list_item = "dataset",
    dataset_id = 99
  )
  
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("subset_dataset returns NULL when the list item does not exist", {
  result <- subset_dataset(
    meta_list = make_subset_meta(),
    list_item = "creator",
    dataset_id = 1
  )
  
  expect_null(result)
})