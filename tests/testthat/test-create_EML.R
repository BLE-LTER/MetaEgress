library(testthat)

# ---------------------------------------------------------------------------
# Stubs
# ---------------------------------------------------------------------------

if (!exists("null_if_na")) {
  null_if_na <- function(df, col) {
    val <- df[[col]]
    if (is.null(val) || (length(val) == 1 && is.na(val))) NULL else val
  }
}

if (!exists("na_if_empty")) {
  na_if_empty <- function(x) {
    x[stringr::str_trim(x) == ""] <- NA
    x
  }
}

# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

make_dataset_df <- function(dataset_id      = 36,
                            title           = "BLE LTER Test Dataset",
                            alternateid     = NA_character_,
                            shortname       = "BLE Test",
                            abstract        = "This is a plain text abstract.",
                            abstract_type   = "plaintext",
                            pubdate         = "2025-03-01",
                            revision_number = 2,
                            bp_setting      = "default",
                            maintenance_description    = "Updated annually.",
                            maintenanceupdatefrequency = "annually") {
  data.frame(
    datasetid                  = dataset_id,
    title                      = title,
    alternateid                = alternateid,
    shortname                  = shortname,
    abstract                   = abstract,
    abstract_type              = abstract_type,
    pubdate                    = pubdate,
    revision_number            = revision_number,
    bp_setting                 = bp_setting,
    maintenance_description    = maintenance_description,
    maintenanceupdatefrequency = maintenanceupdatefrequency,
    stringsAsFactors           = FALSE
  )
}

make_creator_df <- function(dataset_id = 36) {
  data.frame(
    datasetid       = rep(dataset_id, 2),
    authorshiprole  = rep("creator", 2),
    authorshiporder = c(1, 2),
    nameid          = c(1, 2),
    givenname       = c("Induja", "Nathan"),
    givenname2      = c(NA, NA),
    surname         = c("Mohandas", "Jones"),
    address1        = c(NA, NA),
    address2        = c(NA, NA),
    address3        = c(NA, NA),
    city            = c(NA, NA),
    state           = c(NA, NA),
    zipcode         = c(NA, NA),
    country         = c(NA, NA),
    position        = c(NA, NA),
    organization    = c("UT Austin", "UT Austin"),
    phone1          = c(NA, NA),
    email           = c("induja@example.org", "nathan@example.org"),
    userid          = c(NA, NA),
    userid_type     = c(NA, NA),
    online_url      = c(NA, NA),
    stringsAsFactors = FALSE
  )
}

make_parties_df <- function(dataset_id = 36) {
  data.frame(
    datasetid       = c(dataset_id, dataset_id, dataset_id),
    authorshiprole  = c("processor", "contact", "creator"),
    authorshiporder = c(1, 2, 3),
    nameid          = c(3, 4, 5),
    givenname       = c("Carol", "Dana", "Eve"),
    givenname2      = c(NA, NA, NA),
    surname         = c("White", "Black", "Green"),
    address1        = c(NA, NA, NA),
    address2        = c(NA, NA, NA),
    address3        = c(NA, NA, NA),
    city            = c(NA, NA, NA),
    state           = c(NA, NA, NA),
    zipcode         = c(NA, NA, NA),
    country         = c(NA, NA, NA),
    position        = c(NA, NA, NA),
    organization    = c("UT Austin", "UT Austin", "UT Austin"),
    phone1          = c(NA, NA, NA),
    email           = c("carol@example.org", "dana@example.org", "eve@example.org"),
    userid          = c(NA, NA, NA),
    userid_type     = c(NA, NA, NA),
    online_url      = c(NA, NA, NA),
    stringsAsFactors = FALSE
  )
}

make_keyword_df <- function(dataset_id = 36) {
  data.frame(
    datasetid         = rep(dataset_id, 2),
    keyword           = c("climate", "temperature"),
    keyword_thesaurus = c("LTER CVS", "LTER CVS"),
    keywordtype       = c("theme", "theme"),
    stringsAsFactors  = FALSE
  )
}

make_bp_df <- function() {
  data.frame(
    bp_setting          = "default",
    scope               = "ble",
    system              = "https://eml.ecoinformatics.org/eml-2.2.0",
    access              = NA_character_,
    distribution        = NA_character_,
    project             = NA_character_,
    intellectual_rights = NA_character_,
    licensed            = NA_character_,
    stringsAsFactors    = FALSE
  )
}

make_bp_people_df <- function() {
  data.frame(
    bp_setting   = rep("default", 3),
    bp_role      = c("contact", "publisher", "metadata_provider"),
    nameid       = c(10, 11, 12),
    givenname    = c("Alice", "Bob", "Carol"),
    givenname2   = c(NA, NA, NA),
    surname      = c("Smith", "Jones", "White"),
    address1     = c(NA, NA, NA),
    address2     = c(NA, NA, NA),
    address3     = c(NA, NA, NA),
    city         = c(NA, NA, NA),
    state        = c(NA, NA, NA),
    zipcode      = c(NA, NA, NA),
    country      = c(NA, NA, NA),
    position     = c(NA, NA, NA),
    organization = c("UT Austin", "UT Austin", "UT Austin"),
    phone1       = c(NA, NA, NA),
    email        = c("alice@example.org", "bob@example.org", "carol@example.org"),
    userid       = c(NA, NA, NA),
    userid_type  = c(NA, NA, NA),
    online_url   = c(NA, NA, NA),
    stringsAsFactors = FALSE
  )
}

# One minimal methodstep row — gives create_method_section something to work with
make_methodstep_df <- function(dataset_id = 36) {
  data.frame(
    datasetid        = dataset_id,
    methodstep_id    = 1,
    description_type = "plaintext",
    description      = "Sample collection and processing.",
    stringsAsFactors = FALSE
  )
}

# Zero-row helpers for the five tables create_method_step subsets
empty_provenance  <- function() data.frame(datasetid = integer(0), methodstep_id = integer(0), data_source_packageId = character(0), stringsAsFactors = FALSE)
empty_protocols   <- function() data.frame(datasetid = integer(0), methodstep_id = integer(0), title = character(0), givenname = character(0), surname = character(0), url = character(0), stringsAsFactors = FALSE)
empty_instruments <- function() data.frame(datasetid = integer(0), methodstep_id = integer(0), instrument = character(0), stringsAsFactors = FALSE)
empty_software    <- function() data.frame(datasetid = integer(0), methodstep_id = integer(0), title = character(0), surName = character(0), abstract = character(0), url = character(0), version = character(0), stringsAsFactors = FALSE)

make_meta_list <- function(dataset_id       = 36,
                           abstract_type    = "plaintext",
                           abstract         = "This is a plain text abstract.",
                           with_annotation  = FALSE,
                           with_publication = FALSE) {
  ds <- make_dataset_df(dataset_id    = dataset_id,
                        abstract_type = abstract_type,
                        abstract      = abstract)
  ml <- list(
    dataset       = ds,
    creator       = make_creator_df(dataset_id),
    parties       = make_parties_df(dataset_id),
    keyword       = make_keyword_df(dataset_id),
    boilerplate   = make_bp_df(),
    bp_people     = make_bp_people_df(),
    # method tables — real create_method_section uses all five
    methodstep    = make_methodstep_df(dataset_id),
    provenance    = empty_provenance(),
    protocols     = empty_protocols(),
    instruments   = empty_instruments(),
    software      = empty_software(),
    # maintenance
    changehistory = data.frame(
      datasetid       = integer(0),
      change_scope    = character(0),
      revision_number = numeric(0),
      change_date     = character(0),
      revision_notes  = character(0),
      givenname       = character(0),
      surname         = character(0),
      stringsAsFactors = FALSE
    ),
    # coverage — all zero-row so assemble_coverage returns NULLs
    geo      = data.frame(
      geographicdescription   = character(0),
      westboundingcoordinate  = numeric(0),
      eastboundingcoordinate  = numeric(0),
      northboundingcoordinate = numeric(0),
      southboundingcoordinate = numeric(0),
      altitudeminimum         = numeric(0),
      altitudemaximum         = numeric(0),
      altitudeunits           = character(0),
      stringsAsFactors = FALSE
    ),
    temporal = data.frame(
      begindate = character(0),
      enddate   = character(0),
      stringsAsFactors = FALSE
    ),
    taxonomy = data.frame(
      taxonrankname    = character(0),
      taxonrankvalue   = character(0),
      commonname       = character(0),
      taxonid          = character(0),
      taxonid_provider = character(0),
      providerurl      = character(0),
      providerid       = character(0),
      stringsAsFactors = FALSE
    ),
    # units — zero-row so additionalMetadata$metadata is NULL
    unit = data.frame(
      datasetid = integer(0),
      stringsAsFactors = FALSE
    )
  )
  
  if (with_annotation) {
    ml[["annotation"]] <- data.frame(
      datasetid         = dataset_id,
      entity_position   = 0,
      column_position   = 0,
      propertyuri       = "http://ecoinformatics.org/oboe/oboe.1.2/oboe-core.owl#containsMeasurementsOfType",
      propertyuri_label = "contains measurements of type",
      valueuri          = "http://purl.dataone.org/odo/ECSO_00001243",
      valueuri_label    = "Water Temperature",
      stringsAsFactors  = FALSE
    )
  }
  
  if (with_publication) {
    ml[["publication"]] <- data.frame(
      datasetid    = dataset_id,
      relationship = "literatureCited",
      bibtex       = "@article{Smith2020, title={Test}}",
      stringsAsFactors = FALSE
    )
  }
  
  return(ml)
}

make_entity_list <- function() {
  list(data_tables = NULL, other_entities = NULL)
}

# ---------------------------------------------------------------------------
# 1. Validation
# ---------------------------------------------------------------------------

test_that("errors when meta_list is missing", {
  expect_error(
    create_EML(entity_list = make_entity_list(), dataset_id = 36),
    "metadata list missing"
  )
})

test_that("errors when dataset_id is missing", {
  expect_error(
    create_EML(meta_list = make_meta_list(), entity_list = make_entity_list()),
    "please supply a dataset id"
  )
})

test_that("errors when dataset_id is non-numeric", {
  expect_error(
    create_EML(meta_list = make_meta_list(), entity_list = make_entity_list(), dataset_id = "36"),
    "please supply a numeric dataset id"
  )
})

test_that("errors when more than one dataset_id supplied", {
  expect_error(
    create_EML(meta_list = make_meta_list(), entity_list = make_entity_list(), dataset_id = c(36, 37)),
    "too many dataset ids"
  )
})

# ---------------------------------------------------------------------------
# 2. Top-level EML structure
# ---------------------------------------------------------------------------

test_that("returns a list with expected top-level keys", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_type(result, "list")
  expect_true(all(c("packageId", "system", "schemaLocation", "dataset",
                    "additionalMetadata") %in% names(result)))
})

test_that("packageId is assembled from scope, dataset_id, and revision_number", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_equal(result$packageId, "ble.36.2")
})

test_that("system comes from boilerplate", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_equal(result$system, "https://eml.ecoinformatics.org/eml-2.2.0")
})

# ---------------------------------------------------------------------------
# 3. dataset sub-keys
# ---------------------------------------------------------------------------

test_that("dataset$title is set correctly", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_equal(result$dataset$title, "BLE LTER Test Dataset")
})

test_that("dataset$id is paste0('d', dataset_id)", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_equal(result$dataset$id, "d36")
})

test_that("dataset$pubDate is year only", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_equal(result$dataset$pubDate, "2025")
})

test_that("dataset$language is 'English'", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_equal(result$dataset$language, "English")
})

# ---------------------------------------------------------------------------
# 4. Creators — filtering and sorting
# ---------------------------------------------------------------------------

test_that("creators are assembled and non-NULL", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_false(is.null(result$dataset$creator))
})

test_that("creators are sorted by authorshiporder", {
  ml <- make_meta_list()
  # Deliberately reverse order to prove sorting fires
  ml$creator <- ml$creator[order(-ml$creator$authorshiporder), ]
  result     <- create_EML(ml, make_entity_list(), dataset_id = 36)
  first_surname <- result$dataset$creator[[1]]$individualName$surName
  expect_equal(first_surname, "Mohandas")  # authorshiporder=1, not Nathan (order=2)
})

test_that("only authorshiprole == 'creator' rows become creators", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_equal(length(result$dataset$creator), 2)
})

# ---------------------------------------------------------------------------
# 5. Associated parties — exclusion logic
# ---------------------------------------------------------------------------

test_that("associatedParty excludes 'creator' and 'contact' roles", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  # parties fixture: processor (keep), contact (exclude), creator (exclude) -> 1 survives
  expect_equal(length(result$dataset$associatedParty), 1)
})

test_that("associatedParty is NULL when all parties have excluded roles", {
  ml <- make_meta_list()
  ml$parties <- ml$parties[ml$parties$authorshiprole %in% c("creator", "contact"), ]
  result <- create_EML(ml, make_entity_list(), dataset_id = 36)
  expect_null(result$dataset$associatedParty)
})

# ---------------------------------------------------------------------------
# 6. Abstract — branch types
# ---------------------------------------------------------------------------

test_that("plaintext abstract is non-NULL", {
  result <- create_EML(make_meta_list(abstract_type = "plaintext",
                                      abstract = "Plain abstract."),
                       make_entity_list(), dataset_id = 36)
  expect_false(is.null(result$dataset$abstract))
})

test_that("md abstract is list(markdown = content)", {
  result <- create_EML(make_meta_list(abstract_type = "md",
                                      abstract = "## Heading\nContent."),
                       make_entity_list(), dataset_id = 36)
  expect_equal(result$dataset$abstract, list(markdown = "## Heading\nContent."))
})

test_that("docbook abstract is parsed and @context/@type stripped", {
  docbook_xml <- "<abstract><para>Docbook abstract.</para></abstract>"
  result <- create_EML(make_meta_list(abstract_type = "docbook",
                                      abstract = docbook_xml),
                       make_entity_list(), dataset_id = 36)
  expect_false(is.null(result$dataset$abstract))
  expect_false("@context" %in% names(result$dataset$abstract))
  expect_false("@type"    %in% names(result$dataset$abstract))
})

# ---------------------------------------------------------------------------
# 7. Methods
# ---------------------------------------------------------------------------

test_that("method_section is a list", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_type(result$dataset$methods, "list")
})

test_that("method_section has one step per methodstep row", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  # fixture has one methodstep row -> one methodStep entry
  expect_equal(length(result$dataset$methods$methodStep), 1)
})

test_that("methodStep description is populated from plaintext", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_false(is.null(result$dataset$methods$methodStep[[1]]$description))
})

test_that("methodStep dataSource is NULL when no provenance rows", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_null(result$dataset$methods$methodStep[[1]]$dataSource)
})

test_that("methodStep protocol is NULL when no protocol rows", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_null(result$dataset$methods$methodStep[[1]]$protocol)
})

test_that("methodStep instrumentation is NULL when no instrument rows", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_null(result$dataset$methods$methodStep[[1]]$instrumentation)
})

test_that("methodStep software is NULL when no software rows", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_null(result$dataset$methods$methodStep[[1]]$software)
})

# ---------------------------------------------------------------------------
# 8. Keywords
# ---------------------------------------------------------------------------

test_that("keywordSet is assembled and non-NULL", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_false(is.null(result$dataset$keywordSet))
})

test_that("keywordSet filters to the correct dataset_id", {
  ml <- make_meta_list()
  extra <- data.frame(datasetid = 99, keyword = "interloper",
                      keyword_thesaurus = "Other", keywordtype = "theme",
                      stringsAsFactors = FALSE)
  ml$keyword <- rbind(ml$keyword, extra)
  result   <- create_EML(ml, make_entity_list(), dataset_id = 36)
  thesauri <- sapply(result$dataset$keywordSet, function(x) x$keywordThesaurus)
  expect_false("Other" %in% thesauri)
})

# ---------------------------------------------------------------------------
# 9. Maintenance
# ---------------------------------------------------------------------------

test_that("maintenance description is set from dataset_meta", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_equal(result$dataset$maintenance$description, "Updated annually.")
})

test_that("changeHistory is NULL when no change history rows for dataset", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_null(result$dataset$maintenance$changeHistory)
})

# ---------------------------------------------------------------------------
# 10. Annotation — present and absent branches
# ---------------------------------------------------------------------------

test_that("annotation is NULL when 'annotation' key absent from meta_list", {
  result <- create_EML(make_meta_list(with_annotation = FALSE),
                       make_entity_list(), dataset_id = 36)
  expect_null(result$dataset$annotation)
})

test_that("annotation is assembled and unnamed when present", {
  result <- create_EML(make_meta_list(with_annotation = TRUE),
                       make_entity_list(), dataset_id = 36)
  expect_false(is.null(result$dataset$annotation))
  expect_null(names(result$dataset$annotation))
})

test_that("annotation is NULL when rows exist but none match dataset_id/entity/column", {
  ml <- make_meta_list()
  ml[["annotation"]] <- data.frame(
    datasetid = 99, entity_position = 0, column_position = 0,
    propertyuri = "http://example.org/p", propertyuri_label = "p",
    valueuri    = "http://example.org/v", valueuri_label    = "v",
    stringsAsFactors = FALSE
  )
  result <- create_EML(ml, make_entity_list(), dataset_id = 36)
  expect_null(result$dataset$annotation)
})

# ---------------------------------------------------------------------------
# 11. Publications — present and absent branches
# ---------------------------------------------------------------------------

test_that("pub slots are NULL when 'publication' key absent from meta_list", {
  result <- create_EML(make_meta_list(with_publication = FALSE),
                       make_entity_list(), dataset_id = 36)
  expect_null(result$dataset$literatureCited)
  expect_null(result$dataset$usageCitation)
  expect_null(result$dataset$referencePublication)
})

test_that("literatureCited is populated when publication present", {
  result <- create_EML(make_meta_list(with_publication = TRUE),
                       make_entity_list(), dataset_id = 36)
  expect_false(is.null(result$dataset$literatureCited))
})

# ---------------------------------------------------------------------------
# 12. additionalMetadata — units and ble_options
# ---------------------------------------------------------------------------

test_that("additionalMetadata$metadata is NULL when unit df is empty", {
  result <- create_EML(make_meta_list(), make_entity_list(), dataset_id = 36)
  expect_null(result$additionalMetadata$metadata)
})

test_that("schemaLocation does not contain DataONE namespace when ble_options = FALSE", {
  result <- create_EML(make_meta_list(), make_entity_list(),
                       dataset_id = 36, ble_options = FALSE)
  expect_false(grepl("dataone", result$schemaLocation, ignore.case = TRUE))
})

test_that("ble_options = TRUE adds d1v1:ReplicationPolicy to additionalMetadata", {
  result <- create_EML(make_meta_list(), make_entity_list(),
                       dataset_id = 36, ble_options = TRUE)
  expect_true("d1v1:ReplicationPolicy" %in% names(result$additionalMetadata$metadata))
})

test_that("ble_options = TRUE adds DataONE namespace to schemaLocation", {
  result <- create_EML(make_meta_list(), make_entity_list(),
                       dataset_id = 36, ble_options = TRUE)
  expect_true(grepl("dataone", result$schemaLocation, ignore.case = TRUE))
})

test_that("ble_options replication policy has correct values", {
  result <- create_EML(make_meta_list(), make_entity_list(),
                       dataset_id = 36, ble_options = TRUE)
  policy <- result$additionalMetadata$metadata[["d1v1:ReplicationPolicy"]]
  expect_equal(policy$preferredMemberNode, "urn:node:ADC")
  expect_equal(policy$numberReplicas,      "1")
  expect_equal(policy$replicationAllowed,  "true")
})