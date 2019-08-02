
#' @title Create EML list object.
#' 
#' @description Create ready-to-validate-and-write EML list object.
#'
#' @param meta_list A list of dataframes containing metadata returned by \code{\link{get_meta}}.
#' @param entity_list (character) A list of entities returned by \code{\link{create_entity_all}}.
#' @param dataset_id (numeric) A dataset ID.
#' @param file_dir (character) Path to directory containing flat files (abstract and method documents). Defaults to current R working directory if NULL.
#' @param boilerplate_path (character) System path to XML file containing boilerplate items.
#' @param license_path (character) System path to pandoc compatible file containing intellectual rights statement.
#' 
#' @return (list) A list containing all EML elements. Supply this list object to \code{\link[EML]{eml_validate}} and \code{\link[EML]{write_eml}} to validate and write to .xml file.
#' 
#' @examples
#' \dontrun{
#' # continued from \code{\link{get_meta}} and \code{\link{create_entity_all}}
#' EML <- create_EML(meta_list = metadata, entity_list = entities, dataset_id = 1, boilerplate_path = here::here("documents", "boilerplate.xml"), license_path = here::here("documents", "license.docx"))
#' }
#' @export

create_EML <-
  function(meta_list,
           entity_list,
           dataset_id,
           file_dir = NULL,
           boilerplate_path,
           license_path) {
    # ----------------------------------------------------------------------------
    # initial check for missing arguments
    
    if (missing(meta_list)) {
      stop('metadata list missing. use get_meta() to extract from metase')
    }
    if (missing(dataset_id)) {
      stop('please supply a dataset id')
    }
    if (!is.numeric(dataset_id)) {
      stop('please supply a numeric dataset id')
    }
    if (length(dataset_id) > 1) {
      stop('too many dataset ids. only one allowed for each EML document.')
    }
    
    # ----------------------------------------------------------------------------
    # 
    check_empty_and_insert <- function(df){
      if (nrow(df) == 0){
        
        df[1, "datasetid"] <- dataset_id
      } else {
        df <- df
      }
      
      return(df)
    }
    
    meta_list[c("attributes", "factors", "entities")] <- NULL
    
    meta_list <- lapply(meta_list, check_empty_and_insert)
    
    # -----------------------------------------------------------------------------
    # creators
    
    creator_list <-
      subset(meta_list[["creator"]],
             datasetid == dataset_id
             & authorshiprole == "creator") # redundant condition
    
    # sort by authorship order, just to make sure
    creator_list <-
      creator_list[order(creator_list$authorshiporder), ]
    
    # trim whitespace and convert blank strings to NAs
    creator_list[["givenname"]] <- trimws(creator_list[["givenname"]])
    creator_list[["givenname"]][creator_list[["givenname"]] == ""] <- NA 
    
    creator_list[["surname"]] <- trimws(creator_list[["surname"]])
    creator_list[["surname"]][creator_list[["surname"]] == ""] <- NA 
    
    # function to create a creator object
    
    creator_func <- function(creator) {
      # check for organization
      
      if (!is.na(creator[["givenname"]]) ||
          !is.na(creator[["surname"]])) {
        # trim whitespace, fix for odd paste() behavior
        if (!is.na(creator[["givenname"]]) || !is.na(creator[["givenname2"]])){
          given_name <- trimws(paste(
            replace(creator[["givenname"]],
                    is.na(creator[["givenname"]]), ""), replace(creator[["givenname2"]],
                                                                is.na(creator[["givenname2"]]), ""), sep = " "
          ))
        } else {
          given_name <- NULL
        }
        individual_name <- list(givenName = given_name,
                                surName = if (is.na(creator[["surname"]]))
                                  NULL
                                else
                                  creator[["surname"]])
      } else {
        individual_name <- NULL
      }
      
      # check for empty address
      
      if(is.na(creator[["address1"]]) & is.na(creator[["address2"]]) & is.na(creator[["address3"]])) 
        delivery_point <- NULL
      else
        delivery_point <- trimws(paste(
          creator[["address1"]],
          replace(creator[["address2"]], is.na(creator[["address2"]]), ""),
          replace(creator[["address3"]], is.na(creator[["address3"]]), ""),
          " "
        ))
      
      address <- list(
        deliveryPoint = delivery_point,
        city = creator[["city"]],
        administrativeArea = creator[["state"]],
        postalCode = creator[["zipcode"]],
        country = creator[["country"]]
      )
      
      user_id <-
        if (!is.na(creator[["userid"]])) {
          list(creator[["userid"]],
               `directory` = if (!is.na(creator[["userid_type"]]))
                 creator[["userid_type"]]
               else
                 NULL)
        }
      else
        NULL
      
      p <- list(
        individualName = individual_name,
        organizationName = if (is.na(creator[["organization"]]))
          NULL
        else
          creator[["organization"]],
        address = address,
        phone = if (is.na(creator[["phone1"]]))
          NULL
        else
          creator[["phone1"]],
        electronicMailAddress = if (is.na(creator[["email"]]))
          NULL
        else
          creator[["email"]],
        userId = user_id
      )
      return(p)
    }
    
    # loop over all creators
    creators <- apply(creator_list, 1, creator_func)
    
    # for EML elements with possible multiple sub-elements
    # list items must be unnamed for valid EML.
    # here, list item names were inherited from row names in meta_list
    
    names(creators) <- NULL
    
    # -------------------------------------------------------------------------------
    # associated parties
    
    parties <-
      subset(meta_list[["parties"]], datasetid == dataset_id)
    
    party_func <- function(party) {
      p <- creator_func(party)
      p[["role"]] <- party[["authorshiprole"]]
      return(p)
    }
    
    if(length(parties[[1]] > 0))
      associated_party <- apply(parties, 1, party_func)
    else 
      associated_party <- NULL
    
    names(associated_party) <- NULL
    
    # -------------------------------------------------------------------------------
    # methods


    # ------------------------------------------------------------------------------
    # abstract
    
    dataset_meta <-
      subset(meta_list[["dataset"]], datasetid == dataset_id)
    
    if (is.null(file_dir)) {
    abstract <- set_TextType(dataset_meta$abstract)
    } else {
      abstract <- set_TextType(file.path(file_dir, dataset_meta$abstract))
    }
    # ------------------------------------------------------------------------------
    # temporal coverage, assume one range
    
    tempo <-
      subset(meta_list[["temporal"]], datasetid == dataset_id)
    
    if (is.na(tempo[["begindate"]]) & is.na(tempo[["enddate"]])){
      tempcover <- NULL
    } else{
      tempcover <-
        list(rangeOfDates = list(
          beginDate = list(calendarDate = as.character(tempo[, "begindate"])),
          endDate = list(calendarDate = as.character(tempo[, "enddate"]))
        ))
    }
    # -----------------------------------------------------------------------------
    # spatial coverage, list
    
    geo <- subset(meta_list[["geo"]], datasetid == dataset_id)
    geo_func <- function(geo_list) {
      geo <-
        list(
          geographicDescription = geo_list[["geographicdescription"]],
          boundingCoordinates = list(
            westBoundingCoordinate = as.character(geo_list[["westboundingcoordinate"]]),
            eastBoundingCoordinate = as.character(geo_list[["eastboundingcoordinate"]]),
            northBoundingCoordinate = as.character(geo_list[["northboundingcoordinate"]]),
            southBoundingCoordinate = as.character(geo_list[["southboundingcoordinate"]]),
            boundingAltitudes = list(
              altitudeMinimum = if(!is.na(geo_list[["altitudeminimum"]])) geo_list[["altitudeminimum"]] else NULL,
              altitudeMaximum = if(!is.na(geo_list[["altitudemaximum"]])) geo_list[["altitudemaximum"]] else NULL,
              altitudeUnits = if(!is.na(geo_list[["altitudeunits"]])) geo_list[["altitudeunits"]] else NULL
            )
            )
          )
      return(geo)
    }
    
    geoall <- apply(geo, 1, geo_func)
    names(geoall) <- NULL
    
    # -----------------------------------------------------------------------------
    # taxonomic coverage
    
    taxa <- subset(meta_list[["taxonomy"]], datasetid == dataset_id)
    
    if (nrow(taxa) > 0) {
      taxcov <- set_taxonomicCoverage(taxa[["taxonrankvalue"]], expand = T)
      names(taxcov[[1]]) <- NULL
    } else
      taxcov <- NULL
    # -----------------------------------------------------------------------------
    # overall coverage
    
    coverage <-
      list(geographicCoverage = geoall,
           temporalCoverage = tempcover,
           taxonomicCoverage = taxcov)
    
    # -----------------------------------------------------------------------------
    # keywords grouped by keywordThesaurus and with keywordType attribute
    
    keywords <-
      subset(meta_list[["keyword"]], datasetid == dataset_id)
    
    # trim whitespace, convert empty string or "none" to NA
    # doesn't work
    # keywords <- lapply(keywords, stringr::str_trim)
    # keywords["keyword_thesaurus" %in% c("", "none")] <- NA
    
    # for each unique thesaurus, create keywordSet
    keyset_func <- function(thesaurus) {
      set <- subset(keywords, keyword_thesaurus == thesaurus)
      
      key_func <- function(key) {
        key <- list(key,
                    `keywordType` = list(subset(set$keywordtype, set$keyword == key)))
        return(key)
      }
      
      keys <- lapply(unique(set$keyword), key_func)
      
      keywordSet <- list(keyword = keys,
                         keywordThesaurus =
                           if (is.na(set[["keyword_thesaurus"]][[1]]))
                             NULL
                         else
                           set[["keyword_thesaurus"]][[1]])
      return(keywordSet)
    }
    
    kall <- lapply(unique(keywords$keyword_thesaurus), keyset_func)
    names(kall) <- NULL
    
    # -----------------------------------------------------------------------------
    # boilerplate information
    boilerplate <- EML::read_eml(boilerplate_path)
    
    access <- EML::eml_get(boilerplate, element = "access")
    contact <- EML::eml_get(boilerplate$dataset, element = "contact")
    distribution <-
      EML::eml_get(boilerplate$dataset, element = "distribution")
    metadata_provider <-
      EML::eml_get(boilerplate$dataset, element = "metadataProvider")
    publisher <- EML::eml_get(boilerplate$dataset, element = "publisher")
    project <- EML::eml_get(boilerplate$dataset, element = "project")
    system <- boilerplate$system
    
    # ----------------------------------------------------------------------------
    # maintenance
    
    maint_desc <-
      if (!is.na(dataset_meta$maintenance_desc))
        dataset_meta$maintenance_desc
    else
      "No maintenance description provided."
    update_freq <-
      if (!is.na(dataset_meta$update_frequency))
        dataset_meta$update_frequency
    else
      NULL
    
    change_hist <- subset(meta_list[["changehistory"]], datasetid == dataset_id)
    
    make_history <- function(row) {
      one_change <- list(
        changeScope = if (!is.na(row[["change_scope"]]))
          row[["change_scope"]]
        else
          NULL,
        oldValue = if (row[["revision_number"]] == 1)
          "No previous revision"
        else
          paste("See previous revision", as.numeric(row[["revision_number"]]) - 1),
        changeDate = row[["change_date"]],
        comment = if (!is.na(row[["revision_notes"]]))
          paste(row[["givenname"]], row[["surname"]], ":", row[["revision_notes"]])
        else
          NULL
      )
    }
    if (nrow(change_hist) > 0) {
      change_history <- apply(change_hist, 1, make_history)
      names(change_history) <- NULL
    } else change_history <- NULL
    
    maintenance <- list(
      description = maint_desc,
      maintenanceUpdateFrequency = update_freq,
      changeHistory = change_history
    )

    
    
    # -----------------------------------------------------------------------------
    # put the dataset together
    
    dataset <-
      list(
        title = dataset_meta[["title"]],
        alternateIdentifier = dataset_meta[["alternateid"]],
        shortName = dataset_meta[["shortname"]],
        creator = creators,
        associatedParty  = associated_party,
        metadataProvider = metadata_provider,
        pubDate = as.character(format(as.Date(dataset_meta[["pubdate"]]), '%Y')),
        intellectualRights = EML::set_TextType(license_path),
        abstract = abstract,
        keywordSet = kall,
        coverage = coverage,
        contact = contact,
        publisher = publisher,
        distribution = distribution,
        project = project,
        methods = method_xml,
        language = "English",
        dataTable = entity_list[["data_tables"]],
        otherEntity = entity_list[["other_entities"]],
        maintenance = maintenance
      )
    
    # -------------------------------------------------------------------------------------
    # units. return unit_list NULL if no units
    
    unit <- subset(meta_list[["unit"]], datasetid == dataset_id)
    
    if (dim(unit)[1] > 0) {
      unit_list <- EML::set_unitList(unit)
      additional_metadata <- list(metadata = list(unitList = unit_list))
    } else {
      additional_metadata <- NULL
    }
    
    # ------------------------------------------------------------------------------------
    # EML EML EML EML
    
    eml <-
      list(
        packageId = dataset_meta[["edinum"]],
        system = system,
        schemaLocation = "eml://ecoinformatics.org/eml-2.1.1 http://nis.lternet.edu/schemas/EML/eml-2.1.1/eml.xsd",
        access = access,
        dataset = dataset,
        additionalMetadata = additional_metadata
      )
    
    
    return(eml)
  }
