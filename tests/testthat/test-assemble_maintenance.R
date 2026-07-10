library(testthat)

make_dataset_df <- function() {
  data.frame(
    maintenance_description = "Dataset is updated annually.",
    maintenanceupdatefrequency = "annually",
    stringsAsFactors = FALSE
  )
}

make_changehistory_df <- function() {
  data.frame(
    revision_number = c(1, 2),
    change_scope = c("dataset", "metadata"),
    change_date = c("2026-01-01", "2026-06-01"),
    revision_notes = c("Initial release", "Updated metadata"),
    givenname = c("Induja", "Induja"),
    surname = c("Mohandas", "Mohandas"),
    stringsAsFactors = FALSE
  )
}

test_that("returns no previous revision for revision 1", {
  change <- make_changehistory_df()[1, ]
  
  result <- make_history(change)
  
  expect_equal(result$changeScope, "dataset")
  expect_equal(result$oldValue, "No previous revision")
  expect_equal(result$changeDate, "2026-01-01")
  expect_equal(result$comment, "Induja Mohandas : Initial release")
})

test_that("points to previous revision for revision greater than 1", {
  change <- make_changehistory_df()[2, ]
  
  result <- make_history(change)
  
  expect_equal(result$changeScope, "metadata")
  expect_equal(result$oldValue, "See previous revision 1")
  expect_equal(result$changeDate, "2026-06-01")
  expect_equal(result$comment, "Induja Mohandas : Updated metadata")
})

test_that("expects null comment when revision notes are missing",{
  change <- make_changehistory_df()[1, ]
  
  change$revision_notes <- NA 
  result <- make_history(change)
  
  expect_null(result$comment)
  
})

test_that("assemble_maintenance returns description and update frequency", {
  
  result <- assemble_maintenance(
    dataset_df = make_dataset_df(),
    changehistory_df = make_changehistory_df()
  )
  
  expect_equal(result$description, "Dataset is updated annually.")
  expect_equal(result$maintenanceUpdateFrequency, "annually")
  
})
test_that("assemble_maintenance uses default description when missing", {
  dataset <- make_dataset_df()
  dataset$maintenance_description <- NA
  
  result <- assemble_maintenance(
    dataset_df = dataset,
    changehistory_df = make_changehistory_df()
  )
  
  expect_equal(result$description, "No maintenance description provided.")
})

test_that("assemble_maintenance returns null when missing update frequency",{
  dataset <- make_dataset_df()
  dataset$maintenanceupdatefrequency <- NA
  
  result <- assemble_maintenance(
    dataset_df = dataset,
    changehistory_df = make_changehistory_df()
  
  )
  
  expect_null(result$maintenanceupdatefrequency)
})
test_that("assemble_maintenance includes change history when present", {
  result <- assemble_maintenance(
    dataset_df = make_dataset_df(),
    changehistory_df = make_changehistory_df()
  )
  
  expect_equal(length(result$changeHistory), 2)
  expect_equal(result$changeHistory[[1]]$oldValue, "No previous revision")
  expect_equal(result$changeHistory[[2]]$oldValue, "See previous revision 1")
})
test_that("assemble_maintenance returns NULL change history when none present", {
  empty_changehistory <- make_changehistory_df()[0, ]
  
  result <- assemble_maintenance(
    dataset_df = make_dataset_df(),
    changehistory_df = empty_changehistory
  )
  
  expect_null(result$changeHistory)
})
