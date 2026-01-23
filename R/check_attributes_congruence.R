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
      subset(meta_list[["entities"]],
             datasetid == dataset_id & entity_position == entity)

    # convert whitespace strings to NA for easy checking
    entity_e <- lapply(entity_e, stringr::str_trim)
    entity_e[entity_e == ""] <- NA
    entity_e <- as.data.frame(entity_e)

    factors_e <-
      subset(meta_list[["factors"]],
             datasetid == dataset_id & entity_position == entity)

    attributes <-
      subset(meta_list[["attributes"]],
             datasetid == dataset_id & entity_position == entity)

    missing <-
      subset(meta_list[["missing"]],
             datasetid == dataset_id & entity_position == entity)

    #############################
    # attribute names and order #
    #############################
    output_msgs <- c()

    # Read data file (consistent args no matter how filename is provided)
    path_to_file <- if (filename != "") {
      file.path(file_dir, filename)
    } else {
      file.path(file_dir, entity_e[["filename"]])
    }

    entity_df <- data.table::fread(
      path_to_file,
      na.strings  = c("NA", ""),
      strip.white = TRUE
    )

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
    # missing codes
    #########################

    # check NA missing-code congruence for ALL attributes in metadata
    attrs_to_check <- meta_cols
    attrs_to_check <- attrs_to_check[!is.na(attrs_to_check) & nzchar(attrs_to_check)]
    attrs_to_check <- intersect(attrs_to_check, names(entity_df))

    for (i in attrs_to_check) {

      # codes from missing-code metadata 
      codes <- subset(missing, attributeName == i, select = code, drop = TRUE)
      codes_chr <- trimws(as.character(codes))
      codes_chr <- codes_chr[!is.na(codes_chr)]

      # detect NA in data
      has_na_in_data <- any(is.na(entity_df[[i]]))

      # detect NA in metadata 
      na_in_meta <- any(toupper(codes_chr) == "NA")

      if (has_na_in_data && !na_in_meta) {
        msg <- paste(
          "Value in data not in metadata for DataSetAttributeMissingCodes for attribute", i,
          "for entity", entity_name, ": NA"
        )
        output_msgs <- c(output_msgs, msg)
      }

      if (na_in_meta && !has_na_in_data) {
        msg <- paste(
          "Value in metadata for DataSetAttributeMissingCodes not in data for attribute", i,
          "for entity", entity_name, ": NA"
        )
        output_msgs <- c(output_msgs, msg)
      }
    }

    # enumeration checks
    for (i in unique(factors_e[["attributeName"]])) {

      if (!i %in% names(entity_df)) next

      cats  <- subset(factors_e, attributeName == i, select = code, drop = TRUE)
      codes <- subset(missing,   attributeName == i, select = code, drop = TRUE)

      data_vals <- unique(entity_df[[i]])
      data_vals_chr <- trimws(as.character(data_vals))
      data_vals_chr[is.na(data_vals)] <- "NA"

      cats_chr <- trimws(as.character(cats))
      cats_chr <- cats_chr[!is.na(cats_chr)]

      codes_chr <- trimws(as.character(codes))
      codes_chr <- codes_chr[!is.na(codes_chr)]

      # values present in both enumeration and missing-code metadata
      common_values <- intersect(cats_chr, codes_chr)
      if (length(common_values) > 0) {
        msg <- paste0(
          "For attribute ", i, " in entity ", entity_name,
          " the following values appear in the metadata for both DataSetAttributeEnumeration and DataSetAttributeMissingCodes: ",
          paste(common_values, collapse = ", "),
          ". A term should appear in one metadata table, not both."
        )
        output_msgs <- c(output_msgs, msg)
      }

      # values in data not in enumeration OR missing codes metadata
      missing_metadata_values <- setdiff(data_vals_chr, c(cats_chr, codes_chr))
      if (length(missing_metadata_values) > 0) {
        msg <- paste(
          "Value in data not in metadata for attribute", i,
          "for entity", entity_name, ":",
          paste(missing_metadata_values, collapse = ", ")
        )
        output_msgs <- c(output_msgs, msg)
      }

      # values in enumeration metadata not present in data
      missing_data_values <- setdiff(cats_chr, data_vals_chr)
      if (length(missing_data_values) > 0) {
        msg <- paste(
          "Value in metadata for DataSetAttributeEnumeration not in data for attribute", i,
          "for entity", entity_name, ":",
          paste(missing_data_values, collapse = ", ")
        )
        output_msgs <- c(output_msgs, msg)
      }
    }

    if (length(output_msgs) > 0) {
      return(output_msgs)
    }

    return(paste("Attributes congruence checked and found not wanting for table", entity_name))
  }