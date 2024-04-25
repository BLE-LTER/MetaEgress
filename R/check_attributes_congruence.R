#' @title Check metadata-data congruence for attributes.
#'
#' @description Check for congruence between metadata and data in attribute names, enumeration, and missing value codes. \code{\link{create_entity}} uses this function to check for congruence and issues warnings. Note that the checks are written in order, and if one fails other checks down the line will not be performed, since for example, it's difficult to check for enumeration congruence if attribute names do not match up in data and metadata. Note that some checks are not yet implemented: (1) check whether a missing code present in data is not present in metadata -- this one is challenging because naturally many data values will not be listed in a missing codes list. The function might throw a warning if you use a numeric code for a character column, since R will read the entire data column as character and 9999 != "9999.00".
#'
#' @param meta_list (character) A list of dataframes containing metadata returned by \code{\link{get_meta}}.
#' @param dataset_id (numeric) A dataset ID.
#' @param entity (numeric) An entity number.
#' @param file_dir (character) Path to directory containing flat files (data files). Defaults to current R working directory.
#' @param filename (character) Filename. Defaults to "", in which case the entity metadata will be read to find filename.
#' @return (character) Character vector of warnings to be used in a stop() or warning() call.
#' @export
#'
check_attribute_congruence <-
  function(meta_list,
            dataset_id,
            entity,
            file_dir = getwd(),
            filename = "") {

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

    #############################
    # attribute names and order #
    #############################
    output_msgs <- c()
    if (filename != "") {
    entity_df <- data.table::fread(file.path(file_dir, filename))
    } else entity_df <- data.table::fread(file.path(file_dir, entity_e[["filename"]]), na.strings = NULL)
    entity_name <- entity_e[["entityname"]]
    data_cols <- colnames(entity_df)
    meta_cols <- attributes[["attributeName"]]
    if (length(meta_cols) - length(data_cols) != 0) {
      msg <-
        paste(
          "Number of attributes in metadata not matching that of columns in data for entity",
          entity_name,
          ". There are",
          length(data_cols),
          "in data: \n",
          paste0(data_cols, collapse = "\n"),
          "\n and",
          length(meta_cols),
          "in metadata: \n",
          paste0(meta_cols, collapse = "\n")
        )
      output_msgs <- c(output_msgs, msg)
      return(output_msgs)
    }
    if (!all(data_cols == meta_cols)) {
     if (!all(data_cols[order(data_cols)] == meta_cols[order(meta_cols)])) {
       msg <- paste(
         "Spelling of attribute names in metadata not matching that of column names in data for entity",
         entity_name
       )
       output_msgs <- c(output_msgs, msg)
       return(output_msgs)
     } else {
       msg <- paste(
         "Order of attributes in metadata not matching that of columns in data for entity",
         entity_name
       )
       output_msgs <- c(output_msgs, msg)
       return(output_msgs)
     }
    }


    #########################
    # attribute enumeration #
    #########################


    for (i in unique(factors_e[["attributeName"]])) {
      cats <- subset(factors_e, attributeName == i, select = code, drop = TRUE)
      codes <- subset(missing, attributeName == i, select = code, drop = TRUE)
      
      # Check for matching lengths
      if (length(unique(entity_df[[i]])) != length(cats) + length(codes)) {
        # Report mismatched codes along with entity and attribute names
        mismatched_codes <- setdiff(unique(entity_df[[i]]), c(cats, codes))
        msg <- paste0(
          "Mismatched codes in attribute " , i,
          " for entity ", entity_name,".",
          " Has duplicate values in metadata for both enumeration and missing code for value: ", codes,
          paste(mismatched_codes, collapse = ", ")
        )
        output_msgs <- c(output_msgs, msg)
      }
      else if (!all(unique(entity_df[[i]]) %in% c(cats, codes) | c(cats, codes) %in% unique(entity_df[[i]]))) {
        # Report enumeration mismatch
        msg <- paste(
          "Enumeration in attribute", i,
          "in metadata not matching that in data for entity", entity_name
        )
        output_msgs <- c(output_msgs, msg)
      }
    }
    if (length(output_msgs) > 0){
      return(output_msgs)
    }


    #######################
    # missing value codes #
    #######################

    for (i in unique(missing[["attributeName"]])) {
      codes <- subset(missing, attributeName == i, select = code, drop = TRUE)
      if (!all(codes %in% unique(entity_df[[i]]))) {
        msg <- paste(
          "Missing code in attribute",
          i,
          "in metadata not matching that in data for entity",
          entity_name
        )
        output_msgs <- c(output_msgs, msg)

      }
    }
    if (length(output_msgs) > 0){
      return(output_msgs)
    } else return("Attributes congruence checked and found not wanting. Congratulations!")
  }
