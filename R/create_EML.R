
#' @title Create EML.
#'
#' @description Create an EML package-compatible XML list tree for an EML document, ready to validate and write to .xml file.
#'
#' @param meta_list (list) A list of dataframes containing metadata returned by \code{\link{get_meta}}.
#' @param entity_list (character) A list of entities returned by \code{\link{create_entity_all}}.
#' @param dataset_id (numeric) A dataset ID.
#' @param file_dir (character) Path to directory containing flat files (abstract and method documents). Defaults to current R working directory if NULL.

#' @return (list) An EML package-compatible XML list tree. Supply this list object to \code{\link[EML]{eml_validate}} and \code{\link[EML]{write_eml}} to, in order, validate and write to .xml file.
#'
#' @examples
#' \dontrun{
#' # continued from \code{\link{get_meta}} and \code{\link{create_entity_all}}
#' EML <- create_EML(meta_list = metadata, entity_list = entities, dataset_id = 1, license_path = here::here("documents", "license.docx"))
#' }
#' @export

create_EML <-
  function(meta_list,
             entity_list,
             dataset_id,
             file_dir = NULL) {
    # ----------------------------------------------------------------------------
    # initial check for missing arguments

    if (missing(meta_list)) {
      stop("metadata list missing. use get_meta() to extract from metase")
    }
    if (missing(dataset_id)) {
      stop("please supply a dataset id")
    }
    if (!is.numeric(dataset_id)) {
      stop("please supply a numeric dataset id")
    }
    if (length(dataset_id) > 1) {
      stop("too many dataset ids. only one allowed for each EML document.")
    }

    # -----------------------------------------------------------------------------
    # creators

    creator_list <-
      subset(
        meta_list[["creator"]],
        datasetid == dataset_id
        & authorshiprole == "creator"
      ) # redundant condition

    # sort by authorship order, just to make sure
    creator_list <-
      creator_list[order(creator_list$authorshiporder), ]

    # trim whitespace and convert blank strings to NAs
    creator_list[["givenname"]] <- na_if_empty(creator_list[["givenname"]])

    creator_list[["surname"]] <- na_if_empty(creator_list[["surname"]])

    creators <- assemble_personnel(creator_list)

    # -------------------------------------------------------------------------------
    # associated parties

    parties <-
      subset(meta_list[["parties"]], datasetid == dataset_id & !authorshiprole %in% c("creator", "contact"))

    associated_party <- assemble_personnel(parties)


    # -------------------------------------------------------------------------------
    # methods

    method_section <-
      list(methodStep = create_method_section(meta_list,
        dataset_id = dataset_id,
        file_dir = file_dir
      ))


    # ------------------------------------------------------------------------------
    # abstract

    dataset_meta <-
      subset(meta_list[["dataset"]], datasetid == dataset_id)

    if (is.null(file_dir)) {
      abstract <- set_TextType(dataset_meta$abstract)
    } else {
      abstract <- set_TextType(file.path(file_dir, dataset_meta$abstract))
    }
    
    # -----------------------------------------------------------------------------
    # geo, tempo, taxa coverage

    coverage <- assemble_coverage(meta_list)
    
    # -----------------------------------------------------------------------------
    # keywords

    keywords <-
      subset(meta_list[["keyword"]], datasetid == dataset_id)

    kall <- assemble_keywordset(keywords)

    # -----------------------------------------------------------------------------
    # boilerplate information
    
    meta_list[["bp_people"]][["givenname"]] <- na_if_empty(meta_list[["bp_people"]][["givenname"]])
    meta_list[["bp_people"]][["surname"]] <- na_if_empty(meta_list[["bp_people"]][["surname"]])
    bp <- assemble_boilerplate(meta_list[["boilerplate"]], meta_list[["bp_people"]], dataset_meta[["bp_setting"]])

    # ----------------------------------------------------------------------------
    # maintenance
    change <- subset(meta_list[["changehistory"]], datasetid == dataset_id)
    maintenance <- assemble_maintenance(dataset_df = dataset_meta, changehistory_df = change)
    
    # -----------------------------------------------------------------------------
    # dataset annotation
    if ("annotation" %in% names(meta_list)) {
    ds_annotations <- subset(meta_list[["annotation"]], datasetid == dataset_id & entity_position == 0 & column_position == 0)
    annotations <- apply(ds_annotations, 1, assemble_annotation)
    names(annotations) <- NULL
    } else annotations <- NULL
    # -----------------------------------------------------------------------------
    # put the dataset together

    dataset <-
      list(
        title = dataset_meta[["title"]],
        alternateIdentifier = dataset_meta[["alternateid"]],
        shortName = dataset_meta[["shortname"]],
        creator = creators,
        associatedParty = associated_party,
        metadataProvider = bp[["metadata_provider"]],
        pubDate = as.character(format(as.Date(dataset_meta[["pubdate"]]), "%Y")),
        intellectualRights = bp[["rights"]],
        abstract = abstract,
        keywordSet = kall,
        coverage = coverage,
        contact = bp[["contact"]],
        publisher = bp[["publisher"]],
        distribution = bp[["distribution"]],
        project = bp[["project"]],
        methods = method_section,
        language = "English",
        dataTable = entity_list[["data_tables"]],
        otherEntity = entity_list[["other_entities"]],
        maintenance = maintenance,
        annotation = annotations,
        id = paste0("d", dataset_id)
      )

    # -------------------------------------------------------------------------------------
    # units. return unit_list NULL if no units

    unit <- subset(meta_list[["unit"]], datasetid == dataset_id)

    if (dim(unit)[1] > 0) {
      unit_list <- EML::set_unitList(unit)
      additional_metadata <- list(metadata = list(unitList = unit_list))
    } else additional_metadata <- NULL

    # ------------------------------------------------------------------------------------
    # EML EML EML EML

    eml <-
      list(
        packageId = paste0(bp[["scope"]], ".", dataset_id, ".", dataset_meta[["revision_number"]]),
        system = bp[["system"]],
        schemaLocation = "eml://ecoinformatics.org/eml-2.2.0 http://nis.lternet.edu/schemas/EML/eml-2.2.0/eml.xsd",
        access = bp[["access"]],
        dataset = dataset,
        additionalMetadata = additional_metadata
      )

    return(eml)
  }
