## function to

datasetfun <-
  function(datasetid,
           dataTable = NULL,
           otherentity = NULL) {
    # dataset table
    project1 <- dataset[dataset$datasetid == datasetid, ]
    
    # ------------------------------------------------------
    # creator
    
    creator_s <-
      creator[creator$datasetid == datasetid &
                creator$authorshiprole == "creator", ]
    
    for (i in 1:nrow(creator_s)) {
      if (i == 1
          #& creator_s[i, "surname"] == ""
          ) {
          p <- new(
            "creator",
            organizationName = creator_s$organization[i],
            address = new(
              "address",
              deliveryPoint = if (!is.na(creator_s$address2[i])) {
                paste0(creator_s$address1[i], ",", creator_s$address2[i])
              } else {
                creator_s$address1[i]
              },
              city = creator_s$city[i],
              administrativeArea = creator_s$state[i],
              postalCode = creator_s$zipcode[i],
              country = creator_s$country[i]
            ),
            electronicMailAddress = creator_s$email[i]
          )
          pall <- list(p)
    }
    else {
      givenname <-
        ifelse(
          !is.na(creator_s$givenname2[i]),
          paste0(creator_s$givenname[i], " ", creator_s$givenname2[i]),
          creator_s$givenname[i]
        )
      
      p <- new(
        "creator",
        individualName = new(
          "individualName",
          givenName = givenname,
          surName = creator_s$surname[i]
        ),
        electronicMailAddress = if (is.na(creator_s$email[i]))
          (NULL)
        else
          (creator_s$email[i])
        ,
        userId = if (!is.na(creator_s$orcid[i])) {
          new("userId",
              paste0("https://orcid.org/", creator_s$orcid[i]),
              directory = "http://orcid.org/")
        } else {
          NULL
        }
      )
      
      pall <- c(pall, list(p))
    }
  }

#---------------------------------------------
# methods

method1 <- method[method$datasetid == datasetid, ]

methodnum <- unique(method1$methodDocument)

for (ii in 1:length(methodnum)) {
  method_s <- subset(method1, method1$methodDocument == methodnum[ii])
  
  software <- if (is.na(method_s$softwareDescription[1])) {
    NULL
  } else {
    new(
      "software",
      title = if (is.na(method_s$softwareTitle)[1]) {
        NULL
      } else {
        method_s$softwareTitle[1]
      },
      creator = if (is.na(method_s$softwareOwner[1])) {
        NULL
      } else {
        new(
          "creator",
          individualName = new("individualName",
                               surName = method_s$softwareOwner[1])
        )
      },
      implementation = new(
        "implementation",
        distribution = new("distribution",
                           online = new(
                             "online",
                             url = new(
                               "url",
                               method_s$softwareDescription[1],
                               "function" = new("xml_attribute", "download")
                             )
                           ))
      ),
      version = method_s$softwareVersion[1]
    )
  }
  
  instrument <- if (is.na(method_s$instrumentDescription[1])) {
    NULL
  } else {
    new(
      "instrument",
      title = if (is.na(method_s$instrumentTitle[1])) {
        NULL
      } else {
        method_s$instrumentTitle[1]
      },
      creator = if (is.na(method_s$instrumentOwner[1])) {
        NULL
      } else {
        new(
          "creator",
          individualName = new("individualName",
                               surName = method_s$instrumentOwner[1])
        )
      },
      distribution = new("distribution",
                         online = new(
                           "online",
                           url = new(
                             "url",
                             method_s$instrumentDescription[1],
                             "function" = new("xml_attribute", "download")
                           )
                         ))
    )
  }
  if (!is.na(method_s$protocolDescription)) {
    for (kk in 1:nrow(method_s)) {
      protocol <- if (is.na(method_s$protocolDescription[kk])) {
        NULL
      } else {
        new(
          "protocol",
          title = if (is.na(method_s$protocolTitle[kk])) {
            NULL
          } else {
            method_s$protocolTitle[kk]
          },
          creator = if (is.na(method_s$protocolOwner[kk])) {
            NULL
          } else {
            new(
              "creator",
              individualName = new("individualName",
                                   surName = method_s$protocolOwner[kk])
            )
          },
          distribution = new("distribution",
                             online = new(
                               "online",
                               url = new(
                                 "url",
                                 method_s$protocolDescription[kk],
                                 "function" = new("xml_attribute", "download")
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
  
  methodstep <- new(
    "methodStep",
    description = as(set_TextType(methodnum[ii]), "description"),
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


method_xml <- new("methods",
                  methodStep = methodall)

# -----------------------------------------------------
# abstract

abstract <- as(set_TextType(project1$abstract), "abstract")
#abstract <- as(set_TextType("equation.docx"), "abstract")

# ------------------------------------------------------
# date info

tempcover <- new("temporalCoverage",
                 rangeOfDates =
                   new(
                     "rangeOfDates",
                     beginDate =
                       new("beginDate",
                           calendarDate = as.character(tempo[tempo$datasetid == datasetid, "begindate"])),
                     endDate =
                       new("endDate",
                           calendarDate = as.character(tempo[tempo$datasetid == datasetid, "enddate"]))
                   ))

#------------------------------------------------------------
# spatial extend


geo_s <- geo[geo$datasetid == datasetid, ]

for (i in 1:nrow(geo_s)) {
  geocover <- new(
    "geographicCoverage",
    geographicDescription = geo_s$"geographicdescription"[i],
    boundingCoordinates = new(
      "boundingCoordinates",
      westBoundingCoordinate = as.character(geo_s$"westboundingcoordinate"[i]),
      eastBoundingCoordinate = as.character(geo_s$"eastboundingcoordinate"[i]),
      northBoundingCoordinate = as.character(geo_s$"northboundingcoordinate"[i]),
      southBoundingCoordinate = as.character(geo_s$"southboundingcoordinate"[i])
    )
  )
  
  if (i == 1) {
    geoall <- list(geocover)
  }
  else {
    geoall <- c(geoall, list(geocover))
  }
}

coverage1 <- new("Coverage",
                 geographicCoverage = geoall,
                 temporalCoverage = tempcover)

# ----------------------------------------------------------
# keyword

keyword1 <- droplevels(keyword[keyword$datasetid == datasetid, ])

nkey <- unique(keyword1$keyword_thesaurus)

for (i in 1:length(nkey)) {
  if (nkey[i] == "none") {
    k <-
      new("keywordSet", keyword = as.vector(keyword1[keyword1$keyword_thesaurus == nkey[i], "keyword"]))
  } else {
    k <-
      new("keywordSet",
          keyword = as.vector(keyword1[keyword1$keyword_thesaurus == nkey[i], "keyword"]),
          keywordThesaurus = nkey[i])
  }
  
  if (i == 1) {
    kall <- list(k)
  } else {
    kall <- c(kall, list(k))
  }
}


# --------------------------------------------------------------
# the boilerplate information

sharefile <- "../00_Shared_document/"

xml_in <- read_eml(paste0(sharefile, "boilerplate.xml"), sep = "")

access1 <- eml_get(xml_in@access)
contact1 <- eml_get(xml_in@dataset, element = "contact")
distribution1 <- eml_get(xml_in@dataset, element = "distribution")
publisher1 <- eml_get(xml_in@dataset, element = "publisher")
project_xml <- eml_get(xml_in@dataset, element = "project")

intellectualrights1 <-
  as(set_TextType(paste0(sharefile, "IntellectualRights.docx")), "intellectualRights")

#---------------------------------------------------------------
# put the dataset together
dataset1 <- new(
  "dataset",
  title = project1$title,
  alternateIdentifier = project1$alternatedid,
  shortName = project1$shortname,
  creator = pall,
  pubDate = as.character(as.Date(project1$pubdate)),
  intellectualRights = intellectualrights1,
  abstract = abstract,
  keywordSet = kall,
  coverage = coverage1,
  contact = contact1,
  publisher = publisher1,
  distribution = distribution1,
  project = project_xml,
  methods = method_xml,
  language = "English",
  dataTable = dataTable,
  otherEntity = otherentity
)



# ------------------------------------------------------------------
# unit list
unit1 <- unit[unit$datasetid == datasetid, ]

# -----------------------------------------------------------------
# create EML custom class object for use in writing EML later

if (dim(unit1)[1] > 0) {
  eml <- new(
    "eml",
    packageId = project1$edinum,
    system = "knb",
    schemaLocation = "eml://ecoinformatics.org/eml-2.1.1 http://nis.lternet.edu/schemas/EML/eml-2.1.1/eml.xsd",
    access = access1,
    dataset = dataset1,
    additionalMetadata = as(set_unitList(unit1), "additionalMetadata")
  )
} else {
  eml <- new(
    "eml",
    packageId = project1$edinum,
    system = "knb",
    schemaLocation = "eml://ecoinformatics.org/eml-2.1.1 http://nis.lternet.edu/schemas/EML/eml-2.1.1/eml.xsd",
    access = access1,
    dataset = dataset1
  )
}

return(eml)
}
