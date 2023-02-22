#' @title Create EML entity list object.
#'
#' @description Use to examine entity list structure or troubleshoot invalid EML, or to put together custom entity lists. Use \code{\link{create_entity_all}} for common EML generation usage, which loops this function over all entities listed in a dataset under the hood.
#'
#' @param meta_list (character) A list of dataframes containing metadata returned by \code{\link{get_meta}}.
#' @param file_dir (character) Path to directory containing flat files (data files). Defaults to current R working directory. Note: if there's information on "entityrecords", "filesize", "filesize_units", and "checksum" columns in the entities table in metabase, there is no need for reading the actual files, so this field can stay NULL. 
#' @param dataset_id (numeric) A dataset ID.
#' @param entity (numeric) An entity number.
#' @param skip_checks (logical) Whether to skip checking for attribute congruence. Defaults to FALSE. 
#'
#' @return (list) A list object containing one data entity.
#' @import EML
#' @importFrom readr count_fields tokenizer_csv
#' @importFrom digest digest
#' @export
#'


create_entity <-
  function(meta_list, file_dir = getwd(), dataset_id, entity, skip_checks = FALSE) {
    # -----------------------------------------------------------------------------------
    
    # subset to specified dataset_id and entity number
    entity_e <-
      subset(meta_list[["entities"]], datasetid == dataset_id &
               entity_position == entity)
    
    # convert whitespace strings to NA for easy checking
    entity_e <- lapply(entity_e, stringr::str_trim)
    entity_e[entity_e == ""] <- NA
    entity_e <- as.data.frame(entity_e)
    
    factors_e <-
      subset(meta_list[["factors"]], datasetid == dataset_id &
               entity_position == entity)
    attributes <-
      subset(meta_list[["attributes"]], datasetid == dataset_id &
               entity_position == entity)
    
    missing <-
      subset(meta_list[["missing"]], datasetid == dataset_id &
               entity_position == entity)
  
    
    if ("annotation" %in% names(meta_list)) {
      annotations <-
        subset(meta_list[["annotation"]], datasetid == dataset_id &
                 entity_position == entity)
    }
    
    # ------------------------------------------------------------------------------------
    # extract physical file information
    filename <- entity_e[["filename"]]
    filepath <- file.path(file_dir, filename)
    
    if (!is.na(entity_e[["filesize"]]))
      size <-
      entity_e[["filesize"]]
    else
      size <- as.character(file.size(filepath))
    
    if (!is.na(entity_e[["filesize_units"]]))
      size_unit <- entity_e[["filesize_units"]]
    else
      size_unit <- "byte"
    
    if (!is.na(entity_e[["checksum"]])) {
      checksum <- entity_e[["checksum"]]
    } else
      checksum <- digest::digest(filepath,
                                 algo = "md5",
                                 file = TRUE)
    # ------------------------------------------------------------------------------------
    ######################
    # assemble dataTable #
    ######################
    
    if (entity_e[["entitytype"]] %in% c("dataTable", "data table")) {
      if (!skip_checks) {
      warning(
        paste0(check_attribute_congruence(
          meta_list = meta_list,
          dataset_id = dataset_id,
          entity = entity,
          file_dir = file_dir
        ), 
        collapse = "\n"
      )
      )
      }
      
      physical <-
        set_physical(
          objectName = filepath,
          size = size,
          sizeUnit = size_unit,
          
          # check for missing urlhead, return NULL if NA
          url = if (!is.na(entity_e[["urlpath"]])) {
            paste0(entity_e[["urlpath"]], filename)
          } else
            NULL,
          numHeaderLines = null_if_na(entity_e, "headerlines"),
          numFooterLines = null_if_na(entity_e, "footerlines"),
          recordDelimiter = null_if_na(entity_e, "recorddelimiter"),
          fieldDelimiter = null_if_na(entity_e, "fielddlimiter"),
          # a typo in the view DDL
          quoteCharacter = null_if_na(entity_e, "quotecharacter"),
          attributeOrientation = "column",
          authentication = checksum,
          authMethod = "MD5"
        )
      
      # getting record count, skipping header rows as specified
      if (is.na(entity_e[["entityrecords"]])) {
      row_count <-
        length(
          count.fields(
            filepath,
            sep = ",",
            skip = entity_e[["headerlines"]]
          )
        )
      } else row_count <- entity_e[["entityrecords"]]
      
      
      # coalesce precision and dateTimePrecision
      attributes[["precision"]] <-
        ifelse(is.na(attributes[["precision"]]), attributes[["dateTimePrecision"]], attributes[["precision"]])
      
      # trimming extra columns due to new column check in rEML 2.0.0
      attributes[["datasetid"]] <-
        attributes[["entity_position"]] <-
        attributes[["dateTimePrecision"]] <- NULL
      
      # set attributes
      # check for NULL factors and missing codes dfs first
      
      if (nrow(factors_e) > 0 & nrow(missing) > 0) {
        attributeList <-
          set_attributes(attributes,
                         factors = factors_e,
                         missingValues = missing)
      } else if (nrow(factors_e) == 0) {
        attributeList <- set_attributes(attributes, missingValues = missing)
      }
      else if (nrow(missing) == 0) {
        attributeList <- set_attributes(attributes, factors = factors_e)
      }
      else attributeList <- set_attributes(attributes)
      
      
      # insert IDs for semantic annotation
      ids <- paste0("d", dataset_id, "-e", entity, "-att", seq(1:nrow(attributes)))
      
      for (i in 1:length(attributeList[["attribute"]])) {
        attributeList[["attribute"]][[i]][["id"]] <- ids[i]
        
        if ("annotation" %in% names(meta_list)) {
          annotation <- subset(annotations, column_position == i)
          if (nrow(annotation) > 0) {
            attributeList[["attribute"]][[i]][["annotation"]] <-
              apply(annotation, 1, assemble_annotation)
            names(attributeList[["attribute"]][[i]][["annotation"]]) <-
              NULL
          }
        }
      }
      
      
      # assemble dataTable
      entity <-
        list(
          entityName = entity_e[["entityname"]],
          entityDescription = null_if_na(entity_e, "entitydescription"),
          physical = physical,
          attributeList = attributeList,
          numberOfRecords = row_count
        )
    }
    
    ########################
    # assemble otherEntity #
    ########################
    
    else {
      if (entity_e[["formattype"]] == "textFormat") {
      data_format <- list(textFormat = )
      } else if (entity_e[["formattype"]] == "externallyDefinedFormat") {
      data_format <- list(externallyDefinedFormat = list(formatName = entity_e[["formatname"]]))
      }
      physical <-
        list(
          objectName = filename,
          size = list(size, unit = size_unit),
          authentication = list(checksum, method = "MD5"),
          dataFormat = list(externallyDefinedFormat = list(formatName = entity_e[["formatname"]])),
          
          # check for missing urlhead, return NULL if NA
          distribution = if (!is.na(entity_e[["urlpath"]])) {
            list(online = list(url = list(
              paste0(entity_e[["urlpath"]], filename),
              `function` = list("download")
            )))
          } else
            NULL
        )
      
      # assemble otherEntity
      entity <-
        list(
          entityName = entity_e[["entityname"]],
          entityDescription = null_if_na(entity_e, "entitydescription"),
          physical = physical,
          entityType = entity_e[["entitytype"]]
        )
    }
    return(entity)
  }
