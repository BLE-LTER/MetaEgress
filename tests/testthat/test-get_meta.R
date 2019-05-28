context("getting metadata from ble_metabase")
metadata <-
  get_meta("ble_metabase", dataset_ids = 1, host = "10.157.18.129", port = 5432, user = "metaegress_user", password = "usedinMetaEgress")

test_that("function returns a list", {
  expect_is(metadata, "list")
})

test_that("function returns a list of dataframes", {
  for (i in 1:length(metadata)) {
    expect_s3_class(metadata[[1]], class = "data.frame")
  }
})

