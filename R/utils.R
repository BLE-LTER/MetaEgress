
# utilities for MetaEgress
# not exported

null_if_na <- function(parent, thing) {
  if (thing %in% names(parent)) {
    if (!all(is.na(parent[[thing]]))) {
      return(parent[[thing]])
    } else return(NULL)
  } else {
    return(NULL)
  }
}

na_if_empty <- function(thing) {
  thing <- trimws(thing)
  thing[thing == ""] <- NA
  return(thing)
}


# ---------------------------
# check for empty queries and insert placeholder row with dataset_id in question and optional entity number too
# all other columns in placeholder row are NAs

hold_place <- function(df) {
  if (nrow(df) == 0) {
    df[1, "datasetid"] <- dataset_id
    if ("entity_position" %in% colnames(df)) {
      df[1, "entity_position"] <- entity
    }
  }
  return(df)
}

# -----------------------------
# subset by datasetid

subset_dataset <- function(meta_list, list_item, dataset_id) {
  if (list_item %in% names(meta_list)) {
    subset(meta_list[[list_item]], datasetid == dataset_id)
  } else {
    return(NULL)
  }
}

subset_entity <- function(df) {
  if (exists(df)) {
    subset(df, entity_position == entity_position)
  } else {
    return(NULL)
  }
}
