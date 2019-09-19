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

assemble_temporal <- function(tempo_row) {
  
    tempcover <-
      list(rangeOfDates = list(
        beginDate = list(calendarDate = as.character(tempo_row[["begindate"]])),
        endDate = list(calendarDate = as.character(tempo_row[["enddate"]]))
      ))
    return(tempcover)
}

# ------------------------------------------------------------------------------

assemble_geographic <- function(geo_row) {
  geo <-
    list(
      geographicDescription = geo_row[["geographicdescription"]],
      boundingCoordinates = list(
        westBoundingCoordinate = as.character(geo_row[["westboundingcoordinate"]]),
        eastBoundingCoordinate = as.character(geo_row[["eastboundingcoordinate"]]),
        northBoundingCoordinate = as.character(geo_row[["northboundingcoordinate"]]),
        southBoundingCoordinate = as.character(geo_row[["southboundingcoordinate"]]),
        boundingAltitudes = list(
          altitudeMinimum = null_if_na(geo_row, "altitudeminimum"),
          altitudeMaximum = null_if_na(geo_row, "altitudemaximum"),
          altitudeUnits = null_if_na(geo_row, "altitudeunits")
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