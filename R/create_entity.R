#' @title Create EML entity list object. 
#'
#' @description Use to examine entity list structure or troubleshoot invalid EML, or to put together custom entity lists. Use \code{\link[create_entity_all]} for common EML generation usage, which calls this function under the hood. 
#'
#' @param meta_list (character) A list of dataframes containing metadata returned by \code{\link[get_meta]}.
#' @param dataset_id (numeric) A dataset ID.
#' @param entity (numeric) An entity number.
#' 
#' @return A list object containing one data entity.
#'
#' @examples
#' \dontrun{continued from \code{\link[get_meta]}
#' # A single entity. Useful to examine EML list structure and troubleshoot.
#' entity_1 <- create_entity(meta_list = metadata, dataset_id = 1, entity = 1)
#' 
#' # Many entities. Loop separately for each entity type and name accordingly.
#' data_tables <- c(1:4)
#' other_entities <- c(5:7)
#' entity_list <- list(
#'  dataTable = lapply(data_tables, create_entity, meta_list = metadata, dataset_id = 1),
#'  otherEntity = lapply(other_entities, create_entity, meta_list = metadata, dataset_id = 1)
#' )
#' 
#' }
#' 
#' @export
#' 


create_entity <- function(meta_list, dataset_id, entity) {
  
  # -----------------------------------------------------------------------------------
  
  # subset to specified dataset_id and entity number
  entity_e <-
    subset(meta_list[["entities"]], datasetid == dataset_id &
             entity_position == entity)
  
  # convert whitespace strings to NA for easy checking
  entity_e <- lapply(entity_e, stringr::str_trim)
  entity_e[entity_e == ''] <- NA
  entity_e <- as.data.frame(entity_e)
  
  factors_e <-
    subset(meta_list[["factors"]], datasetid == dataset_id &
             entity_position == entity)
  attributes <-
    subset(meta_list[["attributes"]], datasetid == dataset_id &
             entity_position ==  entity)
  
  # missing <- subset(meta_list[["missing"]], datasetid == dataset_id &
  #                    entity_position ==  entity)
  missing <- subset(meta_list[["missing"]], datasetid == dataset_id &
                      entity_position ==  entity)
  
  # ------------------------------------------------------------------------------------
  # insert placeholder row if queries returned empty
  
  # check for df with no rows, then insert placeholder row. other than datasetid and entity_position, all other columns will be NAs
  check_empty_and_insert <- function(df){
    if (nrow(df) == 0){
      
      df[1, "datasetid"] <- dataset_id
      df[1, "entity_position"] <- entity
    } else {
      df <- df
    }
    
    return(df)
  }
  
  df_list <- list(entity_e, factors_e, attributes)
  df_list <- lapply(df_list, check_empty_and_insert)
  
  # ------------------------------------------------------------------------------------
  # extract information from file
  filename <- as.character(entity_e$filename)
   size0 <- as.character(file.size(filename))
   checksum <- digest::digest(filename, algo = "md5", file = TRUE)
  
  # ------------------------------------------------------------------------------------
  # check for either "dataTable" or "otherEntity"
  
  if (entity_e$entitytype == "dataTable") {
    physical <-
      set_physical(
        objectName = filename,
        size = size0,
        sizeUnit = "byte",
        
        # check for missing urlhead, return NULL if NA
        url = if (!is.na(entity_e$urlpath))
          paste0(entity_e$urlpath, filename)
        else
          NULL,
        numHeaderLines = if (is.na(entity_e$headerlines))
          NULL
        else
          (as.character(entity_e$headerlines))
        ,
        recordDelimiter = if (is.na(entity_e$recorddelimiter))
          NULL
        else
          (entity_e$recorddelimiter)
        ,
        fieldDelimiter = if (is.na(entity_e$fielddlimiter))
          NULL
        else
          (entity_e$fielddlimiter)
        ,
        quoteCharacter = if (is.na(entity_e$quotecharacter))
          NULL
        else
          (entity_e$quotecharacter)
        ,
        attributeOrientation = "column",
        authentication = checksum,
        authMethod = "MD5"
      )
    # getting record count, skipping header rows as specified
    row_count <- length(readr::count_fields(filename, tokenizer = readr::tokenizer_csv(), skip = entity_e[["headerlines"]]))
    
    # coalesce precision and dateTimePrecision
    attributes[["precision"]] <- ifelse(is.na(attributes[["precision"]]), attributes[["dateTimePrecision"]], attributes[["precision"]])
    
    # trimming extra columns due to new column check in rEML 2.0.0
    attributes[["datasetid"]] <- attributes[["entity_position"]] <- attributes[["dateTimePrecision"]] <- NULL
    
    # set attributes
    # check for NULL factors and missing codes dfs first
    
    if (dim(factors_e)[1] > 0 & dim(missing)[1] > 0) {
      attributeList <-
        set_attributes(attributes, factors = factors_e, missingValues = missing)
    } else if (dim(factors_e)[1] == 0) {
      attributeList <- set_attributes(attributes, missingValues = missing)
    }
    else if (dim(missing)[1] == 0) {
      attributeList <- set_attributes(attributes, factors = factors_e)
    }
    else {
      attributeList <- set_attributes(attributes)
    }
    
    # assemble dataTable
    entity <-
      list(
        entityName = entity_e$entityname,
        entityDescription = entity_e$entitydescription,
        physical = physical,
        attributeList = attributeList,
        numberOfRecords = as.character(row_count)
      )
  } 
  
  # all other entity types
  
  else {
    physical <-
      list(
        objectName = filename,
        size = list(size0, unit = "byte"),
        authentication = list(checksum, method = "MD5"),
        dataFormat = list(externallyDefinedFormat = list(formatName = entity_e$formatname)),
        
        # check for missing urlhead, return NULL if NA
        distribution = if (!is.na(entity_e$urlpath))
          list(online = list(url = list(
            paste0(entity_e$urlpath, filename),
            `function` = list("download")
          )))
        else
          NULL
      )
    
    # assemble otherEntity
    entity <-
      list(
        entityName = entity_e$entityname,
        entityDescription = entity_e$entitydescription,
        physical = physical,
        entityType = entity_e$entitytype
      )
  }
  return(entity)
}