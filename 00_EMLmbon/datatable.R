## function to create either a dataTable or an otherEntity custom class object to use in the custom function dataset() 

datatablefun <- function(datasetid, entity) {
  entities_s <- entities[entities$datasetid == datasetid & entities$entity_position == entity, ]

  filename <- entities_s$filename

  size0 <- as.character(file.size(filename))

  checksum <- digest::digest(filename, algo = "md5", file = TRUE)

  if (entities_s$entitytype == "dataTable") {
    ## set_physical() is a method from `eml` package
    physical <- set_physical(
      objectName = filename,
      size = size0,
      sizeUnit = "byte",
      url = paste0(entities_s$urlpath, filename),
      numHeaderLines = if (is.na(entities_s$headerlines)) (NULL) else (as.character(entities_s$headerlines)),
      recordDelimiter = if (is.na(entities_s$recorddelimiter)) (NULL) else (entities_s$recorddelimiter),
      fieldDelimiter = if (is.na(entities_s$fielddlimiter)) (NULL) else (entities_s$fielddlimiter),
      quoteCharacter = if (is.na(entities_s$quotecharacter)) (NULL) else (entities_s$quotecharacter),
      attributeOrientation = "column",
      authentication = checksum,
      authMethod = "MD5"
    )

    row <- nrow(fread(filename, data.table = F, showProgress = F))

    meta1 <- meta[meta$datasetid == datasetid & meta$entity_position == entity, ]

    fact1 <- fact[fact$datasetid == datasetid & fact$entity_position == entity, c("attributeName", "code", "definition")]

    if (dim(fact1)[1] > 0) {
      attributeList <- set_attributes(meta1, factors = fact1)
    } else {
      attributeList <- set_attributes(meta1)
    }

    dataTable <- new("dataTable",
      entityName = entities_s$entityname,
      entityDescription = entities_s$entitydescription,
      physical = physical,
      attributeList = attributeList,
      numberOfRecords = as.character(row)
    )
  } else {
    physical <- new("physical",
      objectName = filename,
      size = new("size", size0, unit = "byte"),
      authentication = new("authentication", checksum, method = "MD5"),
      dataFormat = new("dataFormat",
        externallyDefinedFormat = new("externallyDefinedFormat",
          formatName = entities_s$formatname
        )
      ),
      distribution = new("distribution", online = new("online", url = new("url",
        paste0(entities_s$urlpath, filename),
        "function" = new("xml_attribute", "download")
      )))
    )
    dataTable <- new("otherEntity",
      entityName = entities_s$entityname,
      entityDescription = entities_s$entitydescription,
      physical = physical,
      entityType = entities_s$entitytype
    )
  }
  return(dataTable)
}
