
library(testthat)

make_annotation_row <- function(
    propertyuri       = "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType",
    propertyuri_label = "contains measurements of type",
    valueuri          = "http://purl.dataone.org/odo/ECSO_00001243",
    valueuri_label    = "Water Temperature"
) {
  data.frame(
    propertyuri       = propertyuri,
    propertyuri_label = propertyuri_label,
    valueuri          = valueuri,
    valueuri_label    = valueuri_label,
    stringsAsFactors  = FALSE
  )
}

test_that("returns a list with propertyURI and valueURI keys", {
  result <- assemble_annotation(make_annotation_row())
  expect_type(result, "list")
  expect_true(all(c("propertyURI", "valueURI") %in% names(result)))
})

test_that("propertyURI value is correct", {
  result <- assemble_annotation(make_annotation_row())
  expect_equal(result$propertyURI[[1]],
               "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType")
})

test_that("propertyURI label is correct", {
  result <- assemble_annotation(make_annotation_row())
  expect_equal(result$propertyURI$label, "contains measurements of type")
})

test_that("valueURI is correct", {
  result <- assemble_annotation(make_annotation_row())
  expect_equal(result$valueURI[[1]], "http://purl.dataone.org/odo/ECSO_00001243")
})

test_that("valueURI label is correct", {
  result <- assemble_annotation(make_annotation_row())
  expect_equal(result$valueURI$label, "Water Temperature")
})

test_that("different inputs produce different annotations", {
  a1 <- assemble_annotation(make_annotation_row(valueuri = "http://example.org/A",
                                                valueuri_label = "A"))
  a2 <- assemble_annotation(make_annotation_row(valueuri = "http://example.org/B",
                                                valueuri_label = "B"))
  expect_false(identical(a1, a2))
})