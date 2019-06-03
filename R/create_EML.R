
#' create_eml
#' 
#' Function to create ready-to-validate-and-write EML list object
#' 
#' @param meta_list A list of dataframes containing metadata returned by [get_meta()].
#' @param dataset_id A number for dataset ID.
#' @param boilerplate_path A system path to XML file containing boilerplate items.
#' @param license_path A system path to pandoc compatible file containing intellectual rights statement.
#' @param data_table A list of one or many dataTable objects returned by [create_entity()].
#' @param other_entity A list of one or many otherEntity objects returned by [create_entity()].
#' 
#' @examples
#' \dontrun{continued from [get_meta()] and [create_entity()]
#' metadata <- get_meta(dbname = "ble_metabase", dataset_ids = c(1, 2))
#' entity_1 <- create_entity(meta_list = metadata, dataset_id = 1, entity = 1)
#' 
#' use lapply to loop through many entities. Separate data tables from other entities.
#' dt <- c(1:4)
#' other <- c(5:7)
#' data_tables <- lapply(dt, create_entity, meta_list = metadata, dataset_id = 1)
#' other_entities <- lapply(other, create_entity, meta_list = metadata, dataset_id = 1)
#' }
#' 
#' @export

create_EML <-
  function(meta_list,
           entity_list,
           dataset_id,
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
        if (!is.na(creator[["orcid"]])) {
          list(paste0("https://orcid.org/",
                      creator[["orcid"]]),
               `directory` = list("https://orcid.org/"))
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
    # need a rewrite? right now works
    
    method <- subset(meta_list[["method"]], datasetid == dataset_id)
    methodnum <- unique(method$methodDocument)
    
    for (ii in 1:length(methodnum)) {
      method_s <- subset(method, method$methodDocument == methodnum[ii])
      
      software <- if (is.na(method_s$softwareDescription[1])) {
        NULL
      } else {
        list(
          title = if (is.na(method_s$softwareTitle)[1]) {
            NULL
          } else {
            method_s$softwareTitle[1]
          },
          creator = if (is.na(method_s$softwareOwner[1])) {
            NULL
          } else {
            list(individualName = list(surName = method_s$softwareOwner[1]))
          },
          implementation = list(distribution = list(online = list(
            url = list(
              method_s$softwareDescription[1],
              `function` = list("download")
            )
          ))),
          version = method_s$softwareVersion[1]
        )
      }
      
      instrument <-
        if (is.na(method_s$instrumentDescription[1])) {
          NULL
        } else {
          list(
            title = if (is.na(method_s$instrumentTitle[1])) {
              NULL
            } else {
              method_s$instrumentTitle[1]
            },
            creator = if (is.na(method_s$instrumentOwner[1])) {
              NULL
            } else {
              list(individualName = list(surName = method_s$instrumentOwner[1]))
            },
            distribution = list(online = list(
              url = list(
                method_s$instrumentDescription[1],
                `function` = list("download")
              )
            ))
          )
        }
      if (!is.na(method_s$protocolDescription)) {
        for (kk in 1:nrow(method_s)) {
          protocol <- if (is.na(method_s$protocolDescription[kk])) {
            NULL
          } else {
            list(
              title = if (is.na(method_s$protocolTitle[kk])) {
                NULL
              } else {
                method_s$protocolTitle[kk]
              },
              creator = if (is.na(method_s$protocolOwner[kk])) {
                NULL
              } else {
                list(individualName = list(surName = method_s$protocolOwner[kk]))
              },
              distribution = list(online = list(
                url = list(
                  method_s$protocolDescription[kk],
                  `function` = list("download")
                )
              ))
            )
          }
          if (kk == 1) {
            protocolall <- list(protocol)
          } else {
            protocolall <- c(protocolall, list(protocol))
          }
        }
      } else {
        protocolall <- NULL
      }
      
      methodstep <-
        list(
          description = set_TextType(methodnum[[ii]]),
          instrumentation = instrument,
          software = software,
          protocol = protocolall
        )
      
      if (ii == 1) {
        methodall <- list(methodstep)
      } else {
        methodall <- c(methodall, list(methodstep))
      }
    }
    
    
    method_xml <- list(methodStep = methodall)
    
    
    # ------------------------------------------------------------------------------
    # abstract
    
    dataset_meta <-
      subset(meta_list[["dataset"]], datasetid == dataset_id)
    abstract <- set_TextType(dataset_meta$abstract)
    
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
            southBoundingCoordinate = as.character(geo_list[["southboundingcoordinate"]])
          )
        )
      return(geo)
    }
    
    geoall <- apply(geo, 1, geo_func)
    names(geoall) <- NULL
    
    # -----------------------------------------------------------------------------
    # overall coverage
    
    coverage <-
      list(geographicCoverage = geoall,
           temporalCoverage = tempcover)
    
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
        otherEntity = entity_list[["other_entities"]]
      )
    
    # -------------------------------------------------------------------------------------
    # units. return unit_list NULL if no units
    
    unit <- subset(meta_list[["unit"]], datasetid == dataset_id)
    
    if (dim(unit)[1] > 0) {
      unit_list <- EML::set_unitList(unit)
    } else {
      unit_list <- NULL
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
        additionalMetadata = list(metadata = list(unitList = unit_list))
      )
    
    
    return(eml)
  }
