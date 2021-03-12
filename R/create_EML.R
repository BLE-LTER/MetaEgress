
#' @title Create EML.
#'
#' @description Create an EML package-compatible XML list tree for an EML document, ready to validate and write to .xml file.
#'
#' @param meta_list (list) A list of dataframes containing metadata returned by \code{\link{get_meta}}.
#' @param entity_list (character) A list of entities returned by \code{\link{create_entity_all}}.
#' @param dataset_id (numeric) A dataset ID.
#' @param file_dir (character) Path to directory containing flat files (abstract and method documents). Defaults current R working directory.
#' @param ble_options (logical) Whether to perform tasks specific to BLE-LTER: add an additional metadata snippet to facilitate replication to the Arctic Data Center. Defaults to FALSE.

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
             file_dir = getwd(),
             ble_options = FALSE) {
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
    # assemble abstract

    dataset_meta <-
      subset(meta_list[["dataset"]], datasetid == dataset_id)

    abstract_type <- dataset_meta[["abstract_type"]]
    abstract_content <- dataset_meta[["abstract"]]
    
      if (abstract_type == "file") {
        abstract <- set_TextType(file = file.path(file_dir, abstract_content))
      } else if (abstract_type == "md") {
        abstract <- list(markdown = abstract_content)
      } else if (abstract_type == "docbook") {
        abstract <- as_emld(xml2::read_xml(as.character(abstract_content)))
        abstract <- abstract[!names(abstract) %in% c("@context", "@type")]
      } else if (abstract_type == "plaintext") abstract <- set_TextType(text = abstract_content)
    
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
    if (nrow(ds_annotations) > 0) {
    annotations <- apply(ds_annotations, 1, assemble_annotation)
    names(annotations) <- NULL
    } else annotations <- NULL
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
        licensed = bp[["licensed"]],
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
    } else unit_list <- NULL
    
    if (ble_options) { 
      replication <- list(preferredMemberNode = "urn:node:ADC",
                                         numberReplicas = "1",
                                        "xmlns:d1v1" = "http://ns.dataone.org/service/types/v1",
                                         replicationAllowed = "true")
      schema_location <- "https://eml.ecoinformatics.org/eml-2.2.0 https://eml.ecoinformatics.org/eml-2.2.0/eml.xsd http://ns.dataone.org/service/types/v1"
      d1_namespace <- "http://ns.dataone.org/service/types/v1"
      additional_metadata <- list(metadata = list(unitList = unit_list,
                                                  `d1v1:ReplicationPolicy` = replication))
      eml <-
        list(
          packageId = paste0(bp[["scope"]], ".", dataset_id, ".", dataset_meta[["revision_number"]]),
          "xmlns:d1v1" = d1_namespace,
          system = bp[["system"]],
          schemaLocation = schema_location,
          access = bp[["access"]],
          dataset = dataset,
          additionalMetadata = additional_metadata
        )
    } else {
      schema_location <- "https://eml.ecoinformatics.org/eml-2.2.0 https://eml.ecoinformatics.org/eml-2.2.0/eml.xsd"
      additional_metadata <- list(metadata = list(unitList = unit_list))
      eml <-
        list(
          packageId = paste0(bp[["scope"]], ".", dataset_id, ".", dataset_meta[["revision_number"]]),
          "xmlns:d1v1" = d1_namespace,
          system = bp[["system"]],
          schemaLocation = schema_location,
          access = bp[["access"]],
          dataset = dataset,
          additionalMetadata = additional_metadata
        )
    }


    # ------------------------------------------------------------------------------------
    # EML EML EML EML

    

    return(eml)
  }
