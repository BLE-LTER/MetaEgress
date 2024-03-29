#' @title Assemble boilerplate items.
#' 
#' @param bp_df (data.frame) Data frame containing boilerplate XML trees on access, dataset-level distribution, and project.
#' @param bp_people (data.frame) Data frame containing expanded info on contact, metadata provider, publisher. 
#' @param bp_setting (character) The boilerplate setting ("default" or otherwise).
#'
#' @return (list) Named list containing boilerplate items: scope, system, access, project, distribution, contact, metadata provider, publisher, license.
#' @export

assemble_boilerplate <- function(bp_df, bp_people, bp_setting) {
  
  bp_df <- bp_df[bp_df[["bp_setting"]] == bp_setting, ]
  bp_people <- bp_people[bp_people[["bp_setting"]] == bp_setting, ]
  
  contact <- bp_people[bp_people[["bp_role"]] == "contact", ]
  contact <- tryCatch(assemble_person(contact), error = function(cond) return(NULL))
  
  publisher <- bp_people[bp_people[["bp_role"]] == "publisher", ]
  publisher <- tryCatch(assemble_person(publisher), error = function(cond) return(NULL))
  
  metadata_provider <- bp_people[bp_people[["bp_role"]] == "metadata_provider", ]
  metadata_provider <- tryCatch(assemble_person(metadata_provider), error = function(cond) return(NULL))
  
  if (!is.na(bp_df[["access"]])) {
  access <- as_emld(xml2::read_xml(as.character(bp_df[["access"]])))
  access <- access[!names(access) %in% c("@context", "@type")]
  } else access <- NULL
  
  if (!is.na(bp_df[["distribution"]])) {
  distribution <- as_emld(xml2::read_xml(as.character(bp_df[["distribution"]])))
  distribution <- distribution[!names(distribution) %in% c("@context", "@type")]
  } else distribution <- NULL
  
  if (!is.na(bp_df[["project"]])) {
  project = as_emld(xml2::read_xml(as.character(bp_df[["project"]])))
  project <- project[!names(project) %in% c("@context", "@type")]
  } else project <- NULL
  
  if (!is.na(bp_df[["intellectual_rights"]])) {
    rights = as_emld(xml2::read_xml(as.character(bp_df[["intellectual_rights"]])))
    rights <- rights[!names(rights) %in% c("@context", "@type")]
  } else rights <- NULL
  
  if (!is.na(bp_df[["licensed"]])) {
    licensed = as_emld(xml2::read_xml(as.character(bp_df[["licensed"]])))
    licensed <- licensed[!names(licensed) %in% c("@context", "@type")]
  } else licensed <- NULL
  
  bp <- list(
    scope = bp_df[["scope"]],
    system = bp_df[["system"]],
    access = access,
    project = project,
    distribution = distribution,
    contact = contact,
    metadata_provider = metadata_provider, 
    publisher = publisher,
    rights = rights,
    licensed = licensed
  )
  return(bp)
  
}