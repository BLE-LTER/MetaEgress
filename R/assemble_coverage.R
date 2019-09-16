#' @title Assemble dataset coverage elements
#' 
#' @description Assemble geographic, temporal, and taxonomic coverage elements at the dataset level.
#' 
#' @param meta_list (list) A list of dataframes containing metadata returned by \code{\link{get_meta}}.
#' 
#' @return (list) A named list containing geographicCoverage, temporalCoverage, and taxonomicCoverage elements, each NULL if no information is provided.
#' 
#' @export 

assemble_coverage <- function(meta_list) {
  
  geo <- meta_list[["geo"]]
  
  if (nrow(geo) > 0) {
    geoall <- apply(geo, 1, assemble_geographic)
    names(geoall) <- NULL
  } else geoall <- NULL
  
  tempo <- meta_list[["temporal"]]
  
  if (nrow(tempo) > 0) {
    tempall <- apply(tempo, 1, assemble_temporal)
  } else tempall <- NULL
  
  taxa <- meta_list[["taxonomy"]]
  
  if (nrow(taxa) > 0) {
    taxcov <- assemble_taxonomic(taxa)
  } else taxcov <- NULL
  
  coverage <-
    list(
      geographicCoverage = geoall,
      temporalCoverage = tempall,
      taxonomicCoverage = taxcov
    )
  return(coverage)
}

# ------------------------------------------------------------------------------

assemble_temporal <- function(tempo_df) {
  
    tempcover <-
      list(rangeOfDates = list(
        beginDate = list(calendarDate = as.character(tempo[, "begindate"])),
        endDate = list(calendarDate = as.character(tempo[, "enddate"]))
      ))
}

# ------------------------------------------------------------------------------

assemble_geographic <- function(geo_df) {
  geo <-
    list(
      geographicDescription = geo_df[["geographicdescription"]],
      boundingCoordinates = list(
        westBoundingCoordinate = as.character(geo_df[["westboundingcoordinate"]]),
        eastBoundingCoordinate = as.character(geo_df[["eastboundingcoordinate"]]),
        northBoundingCoordinate = as.character(geo_df[["northboundingcoordinate"]]),
        southBoundingCoordinate = as.character(geo_df[["southboundingcoordinate"]]),
        boundingAltitudes = list(
          altitudeMinimum = null_if_na(geo_df, "altitudeminimum"),
          altitudeMaximum = null_if_na(geo_df, "altitudemaximum"),
          altitudeUnits = null_if_na(geo_df, "altitudeunits")
        )
      )
    )
  return(geo)
}

# ------------------------------------------------------------------------------

assemble_taxonomic <- function(taxa) {
  if (nrow(taxa) > 0) {
    taxcov <- set_taxonomicCoverage(taxa[["taxonrankvalue"]], expand = T)
    names(taxcov[[1]]) <- NULL
  } else {
    taxcov <- NULL
  }
  
  return(taxcov)
}