
#' @title Quickly create all EML entity list objects.
#' 
#' @description. Use to quickly create EML entity list objects from all entities listed in dataset. 
#' @param meta_list (character) A list of dataframes containing metadata returned by \code{\link{get_meta}}.
#' @param dataset_id (numeric) A dataset ID.
#' 
#' @return (list) A list containing all data entities from dataset. Use this in the `entity_list` argument for \code{\link{create_EML}}.
#' First level list elements are grouped by entity types present in dataset and named accordingly. 
#' Each first level element is a list of unnamed lists; the number of elements correspond to how many entities of each type are present in dataset. 
#' Second level elements are analogous to output from \code{\link{create_entity}}.
#' 
#' @examples
#' \dontrun{
#' # continued from \code{\link{get_meta}}
#' entities <- create_entity_all(meta_list = metadata, dataset_id = 1)
#' }
#' 
#' @export
#' 


create_entity_all <- function(meta_list, dataset_id) {
  entities <- subset_dataset(meta_list, "entities", dataset_id)
  factors <- subset_dataset(meta_list, "factors", dataset_id)
  attributes <- subset_dataset(meta_list, "attributes", dataset_id)
  missing <- subset_dataset(meta_list, "missing", dataset_id)
  
  e_nos <- entities$entity_position
  names(e_nos) <- entities$entitytype
  all <-
    lapply(e_nos,
           create_entity,
           meta_list = meta_list,
           dataset_id = dataset_id)
  
  all2 <- list(
    data_tables = all[which(names(all) == "dataTable")],
    other_entities = all[which(names(all) == "otherEntity")]
  )
  names(all2[["other_entities"]]) <- NULL
  names(all2[["data_tables"]]) <- NULL
  
  return(all2)
}
