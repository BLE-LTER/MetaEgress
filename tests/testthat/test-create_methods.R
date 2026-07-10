library(testthat)

make_meta_list <- function(dataset_id     = 1,
                           step_id        = 1,
                           desc_type      = "plaintext",
                           desc_content   = "Sample collection.",
                           n_provenance   = 0,
                           n_protocols    = 0,
                           n_instruments  = 0,
                           n_software     = 0) {
  
  methodstep <- data.frame(
    datasetid        = dataset_id,
    methodstep_id    = step_id,
    description_type = desc_type,
    description      = desc_content,
    stringsAsFactors = FALSE
  )
  
  provenance <- if (n_provenance > 0) {
    data.frame(
      datasetid            = dataset_id,
      methodstep_id        = step_id,
      data_source_packageId = paste0("edi.", seq_len(n_provenance), ".1"),
      stringsAsFactors     = FALSE
    )
  } else {
    data.frame(
      datasetid = integer(0), methodstep_id = integer(0),
      data_source_packageId = character(0), stringsAsFactors = FALSE
    )
  }
  
  protocols <- if (n_protocols > 0) {
    data.frame(
      datasetid     = dataset_id,
      methodstep_id = step_id,
      title         = paste0("Protocol ", seq_len(n_protocols)),
      givenname     = paste0("Alice",     seq_len(n_protocols)),
      surname       = paste0("Smith",     seq_len(n_protocols)),
      url           = paste0("https://example.org/protocol/", seq_len(n_protocols)),
      stringsAsFactors = FALSE
    )
  } else {
    data.frame(
      datasetid = integer(0), methodstep_id = integer(0),
      title = character(0), givenname = character(0),
      surname = character(0), url = character(0),
      stringsAsFactors = FALSE
    )
  }
  
  instruments <- if (n_instruments > 0) {
    data.frame(
      datasetid     = dataset_id,
      methodstep_id = step_id,
      instrument    = paste0("CTD sensor ", seq_len(n_instruments)),
      stringsAsFactors = FALSE
    )
  } else {
    data.frame(
      datasetid = integer(0), methodstep_id = integer(0),
      instrument = character(0), stringsAsFactors = FALSE
    )
  }
  
  software <- if (n_software > 0) {
    data.frame(
      datasetid     = dataset_id,
      methodstep_id = step_id,
      title         = paste0("R ", seq_len(n_software)),
      surName       = paste0("Ihaka",    seq_len(n_software)),
      abstract      = paste0("Stats software ", seq_len(n_software)),
      url           = paste0("https://r-project.org/", seq_len(n_software)),
      version       = paste0("4.", seq_len(n_software), ".0"),
      stringsAsFactors = FALSE
    )
  } else {
    data.frame(
      datasetid = integer(0), methodstep_id = integer(0),
      title = character(0), surName = character(0),
      abstract = character(0), url = character(0),
      version = character(0), stringsAsFactors = FALSE
    )
  }
  
  list(
    methodstep  = methodstep,
    provenance  = provenance,
    protocols   = protocols,
    instruments = instruments,
    software    = software
  )
}

# ---------------------------------------------------------------------------
# create_method_section
# ---------------------------------------------------------------------------

test_that("returns a list", {
  result <- create_method_section(make_meta_list(), dataset_id = 1)
  expect_type(result, "list")
})

test_that("returns one step per methodstep row for the dataset", {
  ml <- make_meta_list()
  # Add a second step
  ml$methodstep <- rbind(
    ml$methodstep,
    data.frame(datasetid = 1, methodstep_id = 2,
               description_type = "plaintext", description = "Step 2.",
               stringsAsFactors = FALSE)
  )
  result <- create_method_section(ml, dataset_id = 1)
  expect_equal(length(result), 2)
})

test_that("filters steps by dataset_id", {
  ml <- make_meta_list()
  # Add a step for a different dataset
  ml$methodstep <- rbind(
    ml$methodstep,
    data.frame(datasetid = 99, methodstep_id = 1,
               description_type = "plaintext", description = "Other dataset.",
               stringsAsFactors = FALSE)
  )
  result <- create_method_section(ml, dataset_id = 1)
  expect_equal(length(result), 1)
})

test_that("returned list is unnamed", {
  ml <- make_meta_list()
  ml$methodstep <- rbind(
    ml$methodstep,
    data.frame(datasetid = 1, methodstep_id = 2,
               description_type = "plaintext", description = "Step 2.",
               stringsAsFactors = FALSE)
  )
  result <- create_method_section(ml, dataset_id = 1)
  expect_null(names(result))
})

test_that("each element has description, dataSource, protocol, instrumentation, software", {
  result <- create_method_section(make_meta_list(), dataset_id = 1)
  step <- result[[1]]
  expect_true(all(c("description", "dataSource", "protocol",
                    "instrumentation", "software") %in% names(step)))
})

# ---------------------------------------------------------------------------
# create_method_step — description branch types
# ---------------------------------------------------------------------------

test_that("plaintext description is assembled via set_TextType", {
  result <- create_method_step(1, make_meta_list(desc_type = "plaintext",
                                                 desc_content = "Plain text."),
                               dataset_id = 1)
  expect_false(is.null(result$description))
})

test_that("md description is list(markdown = content)", {
  result <- create_method_step(1, make_meta_list(desc_type = "md",
                                                 desc_content = "## Heading"),
                               dataset_id = 1)
  expect_equal(result$description, list(markdown = "## Heading"))
})

test_that("docbook description is parsed and @context/@type stripped", {
  xml <- "<description><para>Docbook method.</para></description>"
  result <- create_method_step(1, make_meta_list(desc_type = "docbook",
                                                 desc_content = xml),
                               dataset_id = 1)
  expect_false(is.null(result$description))
  expect_false("@context" %in% names(result$description))
  expect_false("@type"    %in% names(result$description))
})

# ---------------------------------------------------------------------------
# create_method_step — NULL when empty
# ---------------------------------------------------------------------------

test_that("dataSource is NULL when no provenance rows", {
  result <- create_method_step(1, make_meta_list(n_provenance = 0),
                               dataset_id = 1)
  expect_null(result$dataSource)
})

test_that("protocol is NULL when no protocol rows", {
  result <- create_method_step(1, make_meta_list(n_protocols = 0),
                               dataset_id = 1)
  expect_null(result$protocol)
})

test_that("instrumentation is NULL when no instrument rows", {
  result <- create_method_step(1, make_meta_list(n_instruments = 0),
                               dataset_id = 1)
  expect_null(result$instrumentation)
})

test_that("software is NULL when no software rows", {
  result <- create_method_step(1, make_meta_list(n_software = 0),
                               dataset_id = 1)
  expect_null(result$software)
})

# ---------------------------------------------------------------------------
# create_method_step — protocols
# ---------------------------------------------------------------------------

test_that("protocol list has one entry per protocol row", {
  result <- create_method_step(1, make_meta_list(n_protocols = 2),
                               dataset_id = 1)
  expect_equal(length(result$protocol), 2)
})

test_that("protocol entry has title, creator, distribution", {
  result <- create_method_step(1, make_meta_list(n_protocols = 1),
                               dataset_id = 1)
  proto <- result$protocol[[1]]
  expect_true("title"        %in% names(proto))
  expect_true("creator"      %in% names(proto))
  expect_true("distribution" %in% names(proto))
})

test_that("protocol title is correct", {
  result <- create_method_step(1, make_meta_list(n_protocols = 1),
                               dataset_id = 1)
  expect_equal(result$protocol[[1]]$title, "Protocol 1")
})

test_that("protocol creator givenName and surName are correct", {
  result <- create_method_step(1, make_meta_list(n_protocols = 1),
                               dataset_id = 1)
  creator <- result$protocol[[1]]$creator$individualName
  expect_equal(creator$givenName, "Alice1")
  expect_equal(creator$surName,   "Smith1")
})

test_that("protocol distribution url is correct", {
  result <- create_method_step(1, make_meta_list(n_protocols = 1),
                               dataset_id = 1)
  url <- result$protocol[[1]]$distribution$online$url[[1]]
  expect_equal(url, "https://example.org/protocol/1")
})

test_that("protocol url function attribute is 'download'", {
  result <- create_method_step(1, make_meta_list(n_protocols = 1),
                               dataset_id = 1)
  fn <- result$protocol[[1]]$distribution$online$url[["function"]]
  expect_equal(fn, "download")
})

# ---------------------------------------------------------------------------
# create_method_step — instruments
# ---------------------------------------------------------------------------

test_that("instrumentation list has one entry per instrument row", {
  result <- create_method_step(1, make_meta_list(n_instruments = 3),
                               dataset_id = 1)
  expect_equal(length(result$instrumentation), 3)
})

test_that("instrumentation entry contains the instrument string", {
  result <- create_method_step(1, make_meta_list(n_instruments = 1),
                               dataset_id = 1)
  expect_equal(result$instrumentation[[1]], "CTD sensor 1")
})

# ---------------------------------------------------------------------------
# create_method_step — software
# ---------------------------------------------------------------------------

test_that("software list has one entry per software row", {
  result <- create_method_step(1, make_meta_list(n_software = 2),
                               dataset_id = 1)
  expect_equal(length(result$software), 2)
})

test_that("software entry has title, creator, abstract, implementation, version", {
  result <- create_method_step(1, make_meta_list(n_software = 1),
                               dataset_id = 1)
  sw <- result$software[[1]]
  expect_true(all(c("title", "creator", "abstract",
                    "implementation", "version") %in% names(sw)))
})

test_that("software title is correct", {
  result <- create_method_step(1, make_meta_list(n_software = 1),
                               dataset_id = 1)
  expect_equal(result$software[[1]]$title, "R 1")
})

test_that("software creator surName is correct", {
  result <- create_method_step(1, make_meta_list(n_software = 1),
                               dataset_id = 1)
  expect_equal(result$software[[1]]$creator$individualName$surName, "Ihaka1")
})

test_that("software version is correct", {
  result <- create_method_step(1, make_meta_list(n_software = 1),
                               dataset_id = 1)
  expect_equal(result$software[[1]]$version, "4.1.0")
})

test_that("software url function attribute is 'information'", {
  result <- create_method_step(1, make_meta_list(n_software = 1),
                               dataset_id = 1)
  fn <- result$software[[1]]$implementation$distribution$online$url[["function"]]
  expect_equal(fn, "information")
})

# ---------------------------------------------------------------------------
# create_method_step — provenance (mocked — hits EDI API)
# ---------------------------------------------------------------------------

test_that("dataSource is populated when provenance rows exist", {
  fake_prov_emld <- list(
    dataSource  = list(title = "Source dataset"),
    description = list(para = "Provenance description.")
  )
  local_mocked_bindings(
    get_provenance_metadata = function(packageId, ...) fake_prov_emld,
    as_emld                 = function(x, ...) x,
    .package = "MetaEgress"
  )
  result <- create_method_step(
    1,
    make_meta_list(n_provenance = 1,
                   desc_type    = "md",
                   desc_content = "## Base description."),
    dataset_id = 1
  )
  expect_false(is.null(result$dataSource))
  expect_equal(length(result$dataSource), 1)
})

test_that("provenance description is appended to step description", {
  fake_prov_emld <- list(
    dataSource  = list(title = "Source dataset"),
    description = list(para = "Provenance text.")
  )
  local_mocked_bindings(
    get_provenance_metadata = function(packageId, ...) fake_prov_emld,
    as_emld                 = function(x, ...) x,
    .package = "MetaEgress"
  )
  result <- create_method_step(
    1,
    make_meta_list(n_provenance = 1,
                   desc_type    = "md",
                   desc_content = "## Base description."),
    dataset_id = 1
  )
  expect_true(length(result$description$para) > 0)
})

test_that("multiple provenance rows produce multiple dataSource entries", {
  fake_prov_emld <- list(
    dataSource  = list(title = "Source dataset"),
    description = list(para = "Provenance text.")
  )
  local_mocked_bindings(
    get_provenance_metadata = function(packageId, ...) fake_prov_emld,
    as_emld                 = function(x, ...) x,
    .package = "MetaEgress"
  )
  result <- create_method_step(
    1,
    make_meta_list(n_provenance = 2,
                   desc_type    = "md",
                   desc_content = "## Base description."),
    dataset_id = 1
  )
  expect_equal(length(result$dataSource), 2)
})