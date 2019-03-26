# create either a dataTable or an otherEntity class object
# for use in create_EML()

create_entity <- function(meta_list, dataset_id, entity) {
  
  # check arguments
  
  if(missing(meta_list)){
    stop('metadata list missing. use get_meta() to extract from metase')
  }
  if(missing(dataset_id)){
    stop('please supply dataset id(s)')
  }
  if(!is.numeric(dataset_id)){
    stop('please supply numeric dataset id(s)')
  }
  
  # subset to specified dataset_id and entity number
  ent <-
    subset(meta_list[["entities"]], datasetid == dataset_id &
             entity_position == entity)
  
  # convert whitespace strings to NA for easy checking
  ent <- lapply(ent, stringr::str_trim)
  ent[ent == ''] <- NA
  
  fact1 <-
    subset(meta_list[["factors"]], datasetid == dataset_id &
             entity_position == entity)
  attributes <-
    subset(meta_list[["attributes"]], datasetid == dataset_id &
             entity_position ==  entity)
  
  # extract information from file
  filename <- ent$filename
  size0 <- as.character(file.size(filename))
  checksum <- digest::digest(filename, algo = "md5", file = TRUE)
  
  # check for either "dataTable" or "otherEntity"
  # need support for other entity types
  if (ent$entitytype == "dataTable") {
    physical <-
      set_physical(
        objectName = filename,
        size = size0,
        sizeUnit = "byte",
        
        # check for missing urlhead, return NULL if NA
        url = if (!is.na(ent$urlpath))
          paste0(ent$urlpath, filename)
        else
          NULL,
        numHeaderLines = if (is.na(ent$headerlines))
          NULL
        else
          (as.character(ent$headerlines))
        ,
        recordDelimiter = if (is.na(ent$recorddelimiter))
          NULL
        else
          (ent$recorddelimiter)
        ,
        fieldDelimiter = if (is.na(ent$fielddlimiter))
          NULL
        else
          (ent$fielddlimiter)
        ,
        quoteCharacter = if (is.na(ent$quotecharacter))
          NULL
        else
          (ent$quotecharacter)
        ,
        attributeOrientation = "column",
        authentication = checksum,
        authMethod = "MD5"
      )
    
    row <-
      nrow(data.table::fread(filename, data.table = F, showProgress = F))
    
    if (dim(fact1)[1] > 0) {
      attributeList <- set_attributes(attributes, factors = fact1)
    } else {
      attributeList <- set_attributes(attributes)
    }
    
    # assemble dataTable
    entity <-
      list(
        entityName = ent$entityname,
        entityDescription = ent$entitydescription,
        physical = physical,
        attributeList = attributeList,
        numberOfRecords = as.character(row)
      )
  } else {
    physical <-
      list(
        objectName = filename,
        size = list(size0, unit = "byte"),
        authentication = list(checksum, method = "MD5"),
        dataFormat = list(externallyDefinedFormat = list(formatName = ent$formatname)),
        
        # check for missing urlhead, return NULL if NA
        distribution = if (!is.na(ent$urlpath))
          list(online = list(url = list(
            paste0(ent$urlpath, filename),
            `function` = list("download")
          )))
        else
          NULL
      )
    
    # assemble otherEntity
    entity <-
      list(
        entityName = ent$entityname,
        entityDescription = ent$entitydescription,
        physical = physical,
        entityType = ent$entitytype
      )
  }
  return(entity)
}
