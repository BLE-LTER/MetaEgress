# function

create_EML <-
  function(meta_list,
           dataset_id,
           boilerplate,
           license,
           data_table,
           other_entity = NULL) {
    project <- subset(meta_list[["dataset"]], datasetid == dataset_id)
    
    # -----------------------------------------------------------------------------
    # creator
    
    creator_list <-
      subset(meta_list[["creator"]],
             datasetid == dataset_id &
               authorshiprole == "creator")
    
    # function to create a creator object
    create_creator <- function(creator) {
      given_name <-
        trimws(paste(creator[['givenname']],
                     replace(creator[['givenname2']], is.na(creator[['givenname2']]), ""),
                     " "))
      
      p <- list(
        individualName = list(givenName = given_name,
                              surName = creator[['surname']]),
        organizationName = creator[['organization']],
        address = list(
          deliveryPoint = trimws(paste(
            creator[['address1']],
            replace(creator[['address2']], is.na(creator[['address2']]), ""),
            replace(creator[['address3']], is.na(creator[['address3']]), ""),
            " "
          )),
          city = creator[['city']],
          administrativeArea = creator[['state']],
          postalCode = creator[['zipcode']],
          country = creator[['country']]
        ),
        phone = creator[['phone1']],
        electronicaMailAddress = if (is.na(creator[['email']]))
          NULL
        else
          creator[['email']],
        userId = if (!is.na(creator[['orcid']]))
          list(system = paste0("https://orcid.org/", creator[['orcid']]))
        else
          NULL
      )
      return(p)
    }
    
    personnel <- apply(creator_list, 1, create_creator)
    
    # list should be unnamed for write_eml() to work. named list results in invalid schema
    # list names were inherited from row names in meta_list
    names(personnel) <- NULL
    
    # -------------------------------------------------------------------------------
    # methods
    
    method <-
      subset(meta_list[['method']], datasetid == dataset_id)
    methodnum <- unique(method$methodDocument)
    
    for (ii in 1:length(methodnum)) {
      method_s <- subset(method, method$methodDocument == methodnum[ii])
      
      software <-
        if (is.na(method_s$softwareDescription[1])) {
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
                "function" = list("download")
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
                "function" = list("download")
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
                  "function" = list("download")
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
          description = set_TextType(methodnum[ii]),
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
    
    abstract <- set_TextType(project$abstract)
    
    # ------------------------------------------------------------------------------
    # temporal coverage
    
    tempo <- subset(meta_list[["temporal"]], datasetid == dataset_id)
    tempcover <- list(rangeOfDates =
                        list(
                          beginDate =
                            list(calendarDate = as.character(tempo[, "begindate"])),
                          endDate =
                            list(calendarDate = as.character(tempo[, "enddate"]))
                        ))
    # -----------------------------------------------------------------------------
    # spatial coverage
    
    geo <- subset(meta_list[["geo"]], datasetid == dataset_id)
    geo_func <- function(geo_list) {
      geo <- list(
          geographicDescription = geo_list[['geographicdescription']],
          boundingCoordinates = list(
            westBoundingCoordinate = as.character(geo_list[['westboundingcoordinate']]),
            eastBoundingCoordinate = as.character(geo_list[['eastboundingcoordinate']]),
            northBoundingCoordinate = as.character(geo_list[['northboundingcoordinate']]),
            southBoundingCoordinate = as.character(geo_list[['southboundingcoordinate']])
          )
        )
      return(geo)
    }
    
    geoall <- apply(geo, 1, geo_func)
    names(geoall) <- NULL
    
    # -----------------------------------------------------------------------------
    # overall coverage
    coverage <- list(geographicCoverage = geoall,
                     temporalCoverage = tempcover)
    
    # -----------------------------------------------------------------------------
    # keywords
    keywords <- subset(meta_list[['keyword']], datasetid == dataset_id)
    #nkey <- unique(keyword$keyword_thesaurus)
    
    key_func <- function(keyword_list) {
      k <- list(keyword = keyword_list[['keyword']],
                keywordThesaurus = if (keyword_list[['keyword_thesaurus']] == 'none')
                  NULL
                else
                  keyword_list[['keyword_thesaurus']])
      return(k)
    }
    
    kall <- apply(keywords, 1, key_func)
    
    # -----------------------------------------------------------------------------
    # boilerplate information
    
    #boilerplate <- read_eml("../00_Shared_document/boilerplate.xml")
    access <- eml_get(boilerplate, element = "access")
    contact <- eml_get(boilerplate$dataset, element = "contact")
    distribution <- eml_get(boilerplate$dataset, element = "distribution")
    publisher <- eml_get(boilerplate$dataset, element = "publisher")
    project_xml <- eml_get(boilerplate$dataset, element = "project")
    
    #license <- set_TextType("../00_Shared_document/IntellectualRights.docx")
    
    # -----------------------------------------------------------------------------
    # put the dataset together
    
    dataset <- list(
      title = project[['title']],
      alternateIdentifier = project[['alternateid']],
      shortname = project[['shortname']],
      creator = personnel,
      pubDate = as.character(as.Date(project[['pubdate']])),
      intellectualRights = license,
      abstract = abstract,
      keywordSet = kall,
      coverage = coverage,
      contact = contact,
      publisher = publisher,
      distribution = distribution,
      project = project_xml,
      methods = method_xml,
      language = "English",
      dataTable = data_table,
      otherEntity = other_entity
    )
    
    # -------------------------------------------------------------------------------------
    # units
    unit <- subset(meta_list[['unit']], datasetid == dataset_id)
    
    if (dim(unit)[1] > 0) {
      unit_list <- set_unitList(unit)
    } else {
      unit_list <- NULL
    }
    
    # ------------------------------------------------------------------------------------
    # EML EML EML EML
    
    eml <- list(
      packageId = project[['edinum']],
      system = "knb",
      schemaLocation = "eml://ecoinformatics.org/eml-2.1.1 http://nis.lternet.edu/schemas/EML/eml-2.1.1/eml.xsd",
      access = access,
      dataset = dataset,
      additionalMetadata = list(metadata = list(unitList = unit_list))
    )
    
    return(eml)
  }
