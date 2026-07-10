
library(testthat)

make_person_df <- function() {
  data.frame(
    nameid = c(1, 2),
    givenname = c("Induja", "Nathan"),
    givenname2 = c(NA, NA),
    surname = c("Mohandas", "NA"),
    address1 = c("Center for water and environment", NA),
    address2 = c(NA, NA),
    address3 = c(NA, NA),
    city = c("Austin", NA),
    state = c("TX", NA),
    zipcode = c("78701", NA),
    country = c("USA", NA),
    position = c("Information Manager", "PI"),
    organization = c("UT Austin", "UT Austin"),
    phone1 = c("555-210-1111", NA),
    email = c("induja@example.org", "nathan@example.org"),
    userid = c("https://orcid.org/0000-0000-0000-0001", NA),
    userid_type = c("ORCID", NA),
    authorshiprole = c("Information Manager", "PI"),
    online_url = c("https://example.org/induja", NA),
    stringsAsFactors = FALSE
  )
}

test_that("creates userId when userid is present", {
  person <- make_person_df()[1, ]
  
  result <- assemble_userid(person)
  
  expect_equal(result[[1]], "https://orcid.org/0000-0000-0000-0001")
  expect_equal(result$directory, "ORCID")
})

test_that("returns NULL when user id is missing",{
  person <- make_person_df()[2,]
  
  result <- assemble_userid(person)
  expect_null(result)
  })

test_that("handles missing given name", {
  person <- make_person_df()[1, ]
  person$givenname <- NA
  
  result <- assemble_person(person)
  
  expect_equal(result$individualName$surName, "Mohandas")
})
test_that("assemble_person handles missing surname", {
  person <- make_person_df()[1, ]
  person$surname <- NA
  
  result <- assemble_person(person)
  
  expect_equal(result$individualName$givenName, "Induja")
})

test_that("assemble_person returns NULL individualName when names missing", {
  person <- make_person_df()[1, ]
  
  person$givenname <- NA
  person$surname <- NA
  
  result <- assemble_person(person)
  
  expect_null(result$individualName)
})
test_that("combines both givenname and givenname2",{
  person <- make_person_df()[1, ]
  person$givenname2<- "M"
  result <- assemble_person(person)
  
  expect_equal(result$individualName$givenName, "Induja M")
})

test_that("stores position and organization name",{
  
  person <- make_person_df()[1, ]
  
  result <- assemble_person(person)
  
  expect_equal(result$position, "Information Manager")
  expect_equal(result$organization, "UT Austin")
})

test_that("groups rows by nameid", {
  
  people <- rbind(
    make_person_df()[1, ],
    make_person_df()[1, ]
  )
  
  result <- assemble_personnel(people)
  
  expect_equal(length(result), 1)
})

test_that("stores online URL",{
  
  person <- make_person_df()[1, ]
  result <- assemble_person(person)
  
  expect_equal(result$onlineUrl, "https://example.org/induja")
})

test_that("excludes authorship role",{
  person <- make_person_df()[1, ]
  
  person$authorshiprole <- "creator"
  result <- assemble_person(person)
  expect_null(result$role)
})
test_that("returns NULL for empty personnel data frame", {
  
  people <- make_person_df()[0, ]
  
  result <- assemble_personnel(people)
  
  expect_null(result)
})