context("getting metadata from ble_metabase")

# skip tests if connection and/or query fails
# in case tests are run on different machine

skip_if_no_db <- function() {
  tryCatch(
    expr = {
          DBI::dbConnect(
          drv = RPostgres::Postgres(),
          dbname = "ble_metabase",
          host = "10.157.18.129",
          port = 5432,
          user = "metaegress_user",
          password = "usedinMetaEgress"
        )
    },
    error = function(e) {
      skip(
        paste(
          "Error(s) with connecting to and/or getting metadata from database. Tests will be skipped. Original error message(s): ",
          print(e)
        )
      )
    },
    warning = function(w) {
      message(
        paste(
          "Warning(s) with connecting to and/or getting metadata from database. Tests will NOT be skipped. Original waring message(s): ",
          print(w)
        )
      )
    }
  )
}


test_that("function returns a list of dataframes", {
  skip_if_no_db()
  
  metadata <- get_meta(
    dbname = "ble_metabase",
    dataset_ids = 1,
    host = "10.157.18.129",
    port = 5432,
    user = "metaegress_user",
    password = "usedinMetaEgress"
  )

  expect_is(metadata, class = "list")
  
  for (i in 1:length(metadata)) {
    expect_s3_class(metadata[[i]], class = "data.frame")
  }
})
