# create either a dataTable or an otherEntity custom class object
# for use in the custom function dataset()

create_entity <- function(meta_list, dataset_id, entity) {
  # subset tables that are entity-specific
  #specific <- meta_list[c("meta", "factors", "entities")]
  #info <- lapply(specific, subset,datasetid == dataset_id & entity_position == entity)
  
  ent <- subset(meta_list[["entities"]], datasetid == dataset_id & entity_position == entity)
  fact1 <- subset(meta_list[["factor"]], datasetid == dataset_id & entity_position == entity)
  meta1 <- subset(meta_list[["meta"]], datasetid == dataset_id & entity_position == entity)
  
  filename <- ent$filename
  size0 <- as.character(file.size(filename))
  checksum <- digest::digest(filename, algo = "md5", file = TRUE)
  
  if (ent$entitytype == "dataTable") {
    ## set_physical() is a method from `eml` package
    physical <- set_physical(
      objectName = filename,
      size = size0,
      sizeUnit = "byte",
      url = paste0(ent$urlpath, filename),
      numHeaderLines = if (is.na(ent$headerlines))
        (NULL)
      else
        (as.character(ent$headerlines))
      ,
      recordDelimiter = if (is.na(ent$recorddelimiter))
        (NULL)
      else
        (ent$recorddelimiter)
      ,
      fieldDelimiter = if (is.na(ent$fielddlimiter))
        (NULL)
      else
        (ent$fielddlimiter)
      ,
      quoteCharacter = if (is.na(ent$quotecharacter))
        (NULL)
      else
        (ent$quotecharacter)
      ,
      attributeOrientation = "column",
      authentication = checksum,
      authMethod = "MD5"
    )
    
    row <- nrow(fread(filename, data.table = F, showProgress = F))
    
    if (dim(fact1)[1] > 0) {
      attributeList <- set_attributes(meta1, factors = fact1)
    } else {
      attributeList <- set_attributes(meta1)
    }
    
    # assemble dataTable
    
    dataTable <- list(
      entityName = ent$entityname,
      entityDescription = ent$entitydescription,
      physical = physical,
      attributeList = attributeList,
      numberOfRecords = as.character(row)
    )
  } else {
    physical <- list(
      objectName = filename,
      size = list(size0, unit = "byte"),
      authentication = list(checksum, method = "MD5"),
      dataFormat = list(externallyDefinedFormat = list(formatName = ent$formatname)),
      distribution = list(online = list(url = list(paste0(ent$urlpath, filename),
                             "function" = list("download"))
      ))
    )
    dataTable <- list(
      entityName = ent$entityname,
      entityDescription = ent$entitydescription,
      physical = physical,
      entityType = ent$entitytype
    )
  }
  return(dataTable)
}