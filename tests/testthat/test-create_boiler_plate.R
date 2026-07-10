library(testthat)

# ---------------------------------------------------------------------------
# No mocking: every call here goes through the REAL assemble_person(),
# xml2::read_xml(), and as_emld(). Nothing is stubbed.
#
# make_bp_people_full()'s columns are verified against R/assemble_person.R
# (lowercase nameid/givenname/surname/address1-3/city/state/zipcode/country/
# position/organization/phone1/email/userid/userid_type/authorshiprole/
# online_url) -- assemble_person() indexes these directly with
# person[["colname"]], so every column must exist even where the value is NA.
# ---------------------------------------------------------------------------

# ---- minimal fixtures (mirrors the "empty" baseline) -----------------------

make_bp_df <- function() {
  data.frame(
    bp_setting = "default",
    scope = "edi",
    system = "https://eml.ecoinformatics.org/eml-2.2.0",
    access = NA,
    distribution = NA,
    project = NA,
    intellectual_rights = NA,
    licensed = NA,
    stringsAsFactors = FALSE
  )
}

make_bp_people_empty <- function() {
  data.frame(
    bp_setting = character(),
    bp_role = character(),
    stringsAsFactors = FALSE
  )
}

# ---- fixtures with real content, for exercising the "true" branches --------

# Genuine minimal EML/EDI-style access XML. Real enough for xml2::read_xml()
# and as_emld() to parse without mocking.
access_xml <- '<access xmlns:xsi="https://www.w3.org/2001/XMLSchema-instance"
  authSystem="https://pasta.edirepository.org/authentication"
  order="allowFirst" scope="document" system="https://pasta.edirepository.org">
  <allow>
    <principal>uid=TEST_USER,o=LTER,dc=ecoinformatics,dc=org</principal>
    <permission>all</permission>
  </allow>
  <allow>
    <principal>public</principal>
    <permission>read</permission>
  </allow>
</access>'

distribution_xml <- '<distribution>
  <online>
    <url>https://portal.edirepository.org/nis/mapbrowse?scope=edi&amp;identifier=1</url>
  </online>
</distribution>'

project_xml <- '<project>
  <title>Test Project</title>
  <personnel>
    <individualName><surName>Lovelace</surName></individualName>
    <role>Principal Investigator</role>
  </personnel>
</project>'

rights_xml <- '<intellectualRights>
  <para>This dataset is released under the CC0 waiver.</para>
</intellectualRights>'

licensed_xml <- '<licensed>
  <licenseName>CC0 1.0 Universal</licenseName>
  <url>https://creativecommons.org/publicdomain/zero/1.0/</url>
  <identifier>CC0-1.0</identifier>
</licensed>'

make_bp_df_full <- function() {
  df <- make_bp_df()
  df$access <- access_xml
  df$distribution <- distribution_xml
  df$project <- project_xml
  df$intellectual_rights <- rights_xml
  df$licensed <- licensed_xml
  df
}

# Columns verified against the real assemble_person()/assemble_userid():
# nameid, givenname, givenname2, surname, address1-3, city, state, zipcode,
# country, position, organization, phone1, email, userid, userid_type,
# authorshiprole (optional), online_url. All must exist (as NA where unused)
# because assemble_person() indexes them directly with person[["colname"]].
make_bp_people_full <- function() {
  data.frame(
    bp_setting = rep("default", 3),
    bp_role = c("contact", "publisher", "metadata_provider"),
    nameid = c("N001", "N002", "N003"),
    givenname = c("Ada", "Grace", "Alan"),
    givenname2 = NA_character_,
    surname = c("Lovelace", "Hopper", "Turing"),
    address1 = NA_character_,
    address2 = NA_character_,
    address3 = NA_character_,
    city = NA_character_,
    state = NA_character_,
    zipcode = NA_character_,
    country = NA_character_,
    position = NA_character_,
    organization = c("EDI", "EDI", "EDI"),
    phone1 = NA_character_,
    email = c("ada@example.org", "grace@example.org", "alan@example.org"),
    userid = NA_character_,
    userid_type = NA_character_,
    authorshiprole = NA_character_,
    online_url = NA_character_,
    stringsAsFactors = FALSE
  )
}

# ============================= BASELINE (empty/NA) =========================

test_that("assemble_boilerplate returns expected list structure", {
  result <- assemble_boilerplate(
    bp_df = make_bp_df(),
    bp_people = make_bp_people_empty(),
    bp_setting = "default"
  )
  expect_type(result, "list")
  expect_named(
    result,
    c("scope", "system", "access", "project", "distribution",
      "contact", "metadata_provider", "publisher", "rights", "licensed")
  )
})

test_that("assemble_boilerplate keeps scope and system", {
  result <- assemble_boilerplate(
    bp_df = make_bp_df(),
    bp_people = make_bp_people_empty(),
    bp_setting = "default"
  )
  expect_equal(result$scope, "edi")
  expect_equal(result$system, "https://eml.ecoinformatics.org/eml-2.2.0")
})

test_that("assemble_boilerplate returns NULL for missing XML fields", {
  result <- assemble_boilerplate(
    bp_df = make_bp_df(),
    bp_people = make_bp_people_empty(),
    bp_setting = "default"
  )
  expect_null(result$access)
  expect_null(result$distribution)
  expect_null(result$project)
  expect_null(result$rights)
  expect_null(result$licensed)
})

test_that("assemble_boilerplate returns NULL people fields when people are missing", {
  result <- assemble_boilerplate(
    bp_df = make_bp_df(),
    bp_people = make_bp_people_empty(),
    bp_setting = "default"
  )
  expect_null(result$contact)
  expect_null(result$publisher)
  expect_null(result$metadata_provider)
})

test_that("assemble_boilerplate filters by bp_setting", {
  bp_df <- rbind(
    make_bp_df(),
    transform(make_bp_df(), bp_setting = "custom",
              scope = "custom_scope", system = "custom_system")
  )
  result <- assemble_boilerplate(
    bp_df = bp_df,
    bp_people = make_bp_people_empty(),
    bp_setting = "custom"
  )
  expect_equal(result$scope, "custom_scope")
  expect_equal(result$system, "custom_system")
})

# ============================= TRUE-BRANCH TESTS ============================
# These are the branches the baseline tests above never touch: real XML
# actually getting parsed, and real people actually getting assembled.

test_that("real XML fields are parsed and stripped of @context/@type", {
  result <- assemble_boilerplate(
    bp_df = make_bp_df_full(),
    bp_people = make_bp_people_empty(),
    bp_setting = "default"
  )
  
  expect_false(is.null(result$access))
  expect_false("@context" %in% names(result$access))
  expect_false("@type" %in% names(result$access))
  
  expect_false(is.null(result$distribution))
  expect_false("@context" %in% names(result$distribution))
  
  expect_false(is.null(result$project))
  expect_false("@context" %in% names(result$project))
  
  expect_false(is.null(result$rights))
  expect_false("@context" %in% names(result$rights))
  
  expect_false(is.null(result$licensed))
  expect_false("@context" %in% names(result$licensed))
})

test_that("real people rows are assembled into the correct role slots", {
  result <- assemble_boilerplate(
    bp_df = make_bp_df(),
    bp_people = make_bp_people_full(),
    bp_setting = "default"
  )
  
  expect_false(is.null(result$contact))
  expect_false(is.null(result$publisher))
  expect_false(is.null(result$metadata_provider))
  
  # each role should carry its own person's data, not another role's
  expect_false(identical(result$contact, result$publisher))
  expect_false(identical(result$publisher, result$metadata_provider))
  
  # values landed where assemble_person() is expected to put them
  expect_equal(result$contact$individualName$givenName, "Ada")
  expect_equal(result$contact$individualName$surName, "Lovelace")
  expect_equal(result$publisher$organizationName, "EDI")
  expect_equal(result$metadata_provider$electronicMailAddress, "alan@example.org")
})

test_that("authorshiprole is dropped for creator/contact but kept otherwise", {
  bp_people <- make_bp_people_full()
  bp_people$authorshiprole <- c("contact", "coPI", "creator")
  
  result <- assemble_boilerplate(
    bp_df = make_bp_df(),
    bp_people = bp_people,
    bp_setting = "default"
  )
  
  # role "contact" -> excluded per assemble_person()'s c("creator","contact") check
  expect_null(result$contact$role)
  # role "coPI" -> not in the exclusion list, should be kept
  expect_equal(result$publisher$role, "coPI")
  # role "creator" -> excluded
  expect_null(result$metadata_provider$role)
})