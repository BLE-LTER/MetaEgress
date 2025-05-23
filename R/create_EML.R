
#' @title Create EML.
#'
#' @description Create an EML package-compatible XML list tree for an EML document, ready to validate and write to .xml file.
#'
#' @param meta_list (list) A list of dataframes containing metadata returned by \code{\link{get_meta}}.
#' @param entity_list (character) A list of entities returned by \code{\link{create_entity_all}}.
#' @param dataset_id (numeric) A dataset ID.
#' @param file_dir (character) Path to directory containing flat files (abstract and method documents). Defaults current R working directory.
#' @param ble_options (logical) Whether to perform tasks specific to BLE-LTER: add an additional metadata snippet to facilitate replication to the Arctic Data Center. Defaults to FALSE.
#' @param skip_taxa (logical) Whether to skip the call to \code{assemble_taxonomic}. Provided in case assemble_taxonomic fails in some way -- taxonomies are tricky; one option is to manually insert in a text editor a snippet of EML generated elsewhere, into the complete EML output from MetaEgress. Defaults to FALSE.
#' @param expand_taxa (logical) TRUE/FALSE on whether assemble_taxonomic will lookup and fully expand a leaf node taxon's full taxonomic classification (kingdom to the lowest rank provided) into nested EML taxonomicCoverage elements (TRUE) or simply make a taxonomic coverage module based on the information provided in metabase (FALSE). This assumes, of course, that the taxa provided are only the leaf nodes. If so, setting this to TRUE and having the full classification may help your dataset be more discover-able, however the lookup process may be more prone to errors. If this is set to TRUE, rows containing taxa from unsupported providers, or from supported providers but whose classification lookups fail, will not be expanded. The function will use information from the taxonid, taxonrankvalue, taxonid_provider, and (if you have it) providerurl columns from the vw_eml_taxonomy view queried from metabase. It expects taxonid to contain the correct identifier for the taxon from the listed taxonomic authority/provider, taxonrankvalue to contain the taxon's name, taxonid_provider to provide a correctly spelled name or commonly used ID for the taxonomic provider/authority (e.g. ITIS for the Integrated Taxonomy Information System), and providerurl to contain a working url to the same.
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
           expand_taxa = FALSE,
           skip_taxa = FALSE,
           ble_options = FALSE) {
    # ------------------------------------------------------------------------
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

    # -------------------------------------------------------------------------
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

    # -------------------------------------------------------------------------
    # associated parties

    parties <-
      subset(meta_list[["parties"]], datasetid == dataset_id & !authorshiprole %in% c("creator", "contact"))

    associated_party <- assemble_personnel(parties)


    # -------------------------------------------------------------------------
    # methods

    method_section <-
      list(methodStep = create_method_section(meta_list,
        dataset_id = dataset_id,
        file_dir = file_dir
      ))


    # -------------------------------------------------------------------------
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
    
    # -------------------------------------------------------------------------
    # geo, tempo, taxa coverage

    coverage <- assemble_coverage(meta_list,
                                  expand_taxa = expand_taxa,
                                  skip_taxa = skip_taxa)
    
    # -------------------------------------------------------------------------
    # keywords

    keywords <-
      subset(meta_list[["keyword"]], datasetid == dataset_id)

    kall <- assemble_keywordset(keywords)

    # -------------------------------------------------------------------------
    # boilerplate information
    
    meta_list[["bp_people"]][["givenname"]] <- na_if_empty(meta_list[["bp_people"]][["givenname"]])
    meta_list[["bp_people"]][["surname"]] <- na_if_empty(meta_list[["bp_people"]][["surname"]])
    bp <- assemble_boilerplate(meta_list[["boilerplate"]], meta_list[["bp_people"]], dataset_meta[["bp_setting"]])

    # ------------------------------------------------------------------------
    # maintenance
    change <- subset(meta_list[["changehistory"]], datasetid == dataset_id)
    maintenance <- assemble_maintenance(dataset_df = dataset_meta, changehistory_df = change)
    
    # -------------------------------------------------------------------------
    # dataset annotation
    if ("annotation" %in% names(meta_list)) {
    ds_annotations <- subset(meta_list[["annotation"]], datasetid == dataset_id & entity_position == 0 & column_position == 0)
    if (nrow(ds_annotations) > 0) {
    annotations <- apply(ds_annotations, 1, assemble_annotation)
    names(annotations) <- NULL
    } else annotations <- NULL
    } else annotations <- NULL

    # -------------------------------------------------------------------------
    # publication info
    if ("publication" %in% names(meta_list)) {
      ds_publications <- subset(meta_list[["publication"]], datasetid == dataset_id)
      if (nrow(ds_publications) > 0) {
        pubs <- assemble_publications(ds_publications)
      } else pubs <- NULL
    } else pubs <- NULL

    # -------------------------------------------------------------------------
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
        id = paste0("d", dataset_id),
        literatureCited = pubs[["lit_cited"]],
        usageCitation = pubs[["usage_citation"]],
        referencePublication = pubs[["ref_pub"]]
      )

    # --------------------------------------------------------------------------
    # custom units and other options in additionalMetadata
    # return NULL for units if no attributes present (unit df empty)

    unit <- subset(meta_list[["unit"]], datasetid == dataset_id)

    if (dim(unit)[1] > 0) {
      # If units are described add a unitList to additionalMetadata$metadata
      additional_metadata <- list(metadata = list(unitList =
                                                  EML::set_unitList(unit)))
      # If not make additionalMetadata$metadata NULL so it won't be in the EML
    } else additional_metadata <- list(metadata = NULL)

    # If BLE options are selected do some special DAtaONE stuff
    if (ble_options) { 
      replication <- list(preferredMemberNode = "urn:node:ADC",
                          numberReplicas = "1",
                          "xmlns:d1v1" = "http://ns.dataone.org/service/types/v1",
                          replicationAllowed = "true")
      schema_location <- "https://eml.ecoinformatics.org/eml-2.2.0 https://eml.ecoinformatics.org/eml-2.2.0/eml.xsd http://ns.dataone.org/service/types/v1"
      d1_namespace <- "http://ns.dataone.org/service/types/v1"
      # Append the BLE replication policy to additionalMetadata$metadata
      additional_metadata$metadata <- append(additional_metadata$metadata,
                                             list(`d1v1:ReplicationPolicy` = replication))

    } else {
      schema_location <- "https://eml.ecoinformatics.org/eml-2.2.0 https://eml.ecoinformatics.org/eml-2.2.0/eml.xsd"
    }

    # --------------------------------------------------------------------------
    # create the EML list
    
    eml <-
      list(
        packageId = paste0(bp[["scope"]], ".", dataset_id, ".",
                           dataset_meta[["revision_number"]]),
        system = bp[["system"]],
        schemaLocation = schema_location,
        access = bp[["access"]],
        dataset = dataset,
        additionalMetadata = additional_metadata
        )

    # This was in an earlier version but throws a no-namespace error
    # when validating
    # 
    # if (ble_options) {
    #   eml[["xmlns:d1v1"]] <- d1_namespace
    # }

    # -------------------------------------------------------------------------
    # EML EML EML EML

    return(eml)
  }
