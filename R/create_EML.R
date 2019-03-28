

# create ready-to-validate-and-write EML list object

create_EML <-
  function(meta_list,
           dataset_id,
           boilerplate,
           license,
           data_table,
           other_entity = NULL) {
    # ----------------------------------------------------------------------------
    # check arguments
    
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
    
    # -----------------------------------------------------------------------------
    # creators
    # need associated parties once there's view for that
    
    creator_list <-
      subset(meta_list[["creator"]],
             datasetid == dataset_id
             & authorshiprole == "creator") # redundant condition
    
    # sort by authorship order, just to make sure
    creator_list <-
      creator_list[order(creator_list$authorshiporder),]
    
    # function to create a creator object
    
    creator_func <- function(creator) {
      
      # check for organization
      
      if (!is.na(creator[["givenname"]]) ||
          !is.na(creator[["surname"]])) {
        
        # trim whitespace, fix for odd paste() behavior
        individual_name <- list(givenName = trimws(paste(
          creator[["givenname"]], replace(creator[["givenname2"]],
                                          is.na(creator[["givenname2"]]), ""), " "
        )),
        surName = if (is.na(creator[["surname"]]))
          NULL
        else
          creator[["surname"]])
      } else {
        individual_name <- NULL
      }
      
      
      address <- list(
        deliveryPoint = trimws(
          paste(
            creator[["address1"]],
            replace(creator[["address2"]], is.na(creator[["address2"]]), ""),
            replace(creator[["address3"]], is.na(creator[["address3"]]), ""),
            ", "
          )),
          city = creator[["city"]],
          administrativeArea = creator[["state"]],
          postalCode = creator[["zipcode"]],
          country = creator[["country"]]
      )
      
      user_id <- if (("orcid" %in% colnames(creator))) {
        if (!is.na(creator[["orcid"]])) {
          list(paste0("https://orcid.org/",
                      creator[["orcid"]]),
               `directory` = list("https://orcid.org/"))
        }
        else
          NULL
      } else
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
    
    parties <- subset(meta_list[["parties"]], datasetid == dataset_id)
    
    party_func <- function(party){
      p <- creator_func(party)
      p[["role"]] <- party[["role"]]
      return(p)
    }
    
    parties <- apply(parties, 1, party_func)
    names(parties) <- NULL
    
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
    tempcover <-
      list(rangeOfDates = list(
        beginDate = list(calendarDate = as.character(tempo[, "begindate"])),
        endDate = list(calendarDate = as.character(tempo[, "enddate"]))
      ))
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
    
    access <- eml_get(boilerplate, element = "access")
    contact <- eml_get(boilerplate$dataset, element = "contact")
    distribution <-
      eml_get(boilerplate$dataset, element = "distribution")
    metadata_provider <- eml_get(boilerplate$dataset, element = "metadataProvider")
    publisher <- eml_get(boilerplate$dataset, element = "publisher")
    project <- eml_get(boilerplate$dataset, element = "project")
    system <- boilerplate$system
    
    
    # -----------------------------------------------------------------------------
    # put the dataset together
    
    dataset <-
      list(
        title = dataset_meta[["title"]],
        alternateIdentifier = dataset_meta[["alternateid"]],
        shortName = dataset_meta[["shortname"]],
        creator = creators,
        associatedParty  = parties,
        metadataProvider = metadata_provider,
        pubDate = as.character(as.Date(dataset_meta[["pubdate"]])),
        intellectualRights = license,
        abstract = abstract,
        keywordSet = kall,
        coverage = coverage,
        contact = contact,
        publisher = publisher,
        distribution = distribution,
        project = project,
        methods = method_xml,
        language = "English",
        dataTable = data_table,
        otherEntity = other_entity
      )
    
    # -------------------------------------------------------------------------------------
    # units. return unit_list NULL if no units
    
    unit <- subset(meta_list[["unit"]], datasetid == dataset_id)
    
    if (dim(unit)[1] > 0) {
      unit_list <- set_unitList(unit)
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
