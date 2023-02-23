#' @title Assemble dataset coverage elements
#'
#' @description Assemble geographic, temporal, and taxonomic coverage elements at the dataset level.
#'
#' @param meta_list (list) A list of dataframes containing metadata returned by \code{\link{get_meta}}.
#' @param expand_taxa (logical) Whether to use just the taxa names stored in taxonrankvalue and expand into full taxonomic trees (TRUE), or just make a taxonomic coverage module strictly based on the information provided (FALSE). Defaults to TRUE.
#' @param skip_taxa (logical) Whether to skip the call to \code{assemble_taxonomic}. Provided in case it doesn't work -- taxonomies are tricky; one option is to insert a snippet of EML generated elsewhere manually in a text editor. 
#'
#' @return (list) A named list containing geographicCoverage, temporalCoverage, and taxonomicCoverage elements, each NULL if no information is provided.
#'
#' @export

assemble_coverage <- function(meta_list, 
                              expand_taxa = TRUE,
                              skip_taxa = FALSE
                              ) {
  geo <- meta_list[["geo"]]
  # geo uses a for loop instead of apply() because apply() converts the df into a matrix and therefore our hard work using format() to pad to 6 decimal points is lost
  if (nrow(geo) > 0) {
    geocov <- list()
    for (i in 1:nrow(geo)) {
      geocov[[i]] <- assemble_geographic(geo[i,])
    }
  } else
    geocov <- NULL
  
  tempo <- meta_list[["temporal"]]
  
  if (nrow(tempo) > 0) {
    tempcov <- apply(tempo, 1, assemble_temporal)
  } else
    tempcov <- NULL

  taxa <- meta_list[["taxonomy"]]
  
  if (nrow(taxa) > 0 & !skip_taxa) {
    taxcov <- assemble_taxonomic(taxa, expand_taxa)
  } else
    taxcov <- NULL
  
  coverage <-
    list(
      geographicCoverage = geocov,
      temporalCoverage = tempcov,
      taxonomicCoverage = taxcov
    )
  return(coverage)
}

# ------------------------------------------------------------------------------

assemble_temporal <- function(tempo_row) {
  tempcov <-
    list(rangeOfDates = list(
      beginDate = list(calendarDate = as.character(tempo_row[["begindate"]])),
      endDate = list(calendarDate = as.character(tempo_row[["enddate"]]))
    ))
  return(tempcov)
}

# ------------------------------------------------------------------------------

assemble_geographic <- function(geo_row) {
  geocov <-
    list(
      geographicDescription = geo_row[["geographicdescription"]],
      boundingCoordinates = list(
        westBoundingCoordinate = format(geo_row[["westboundingcoordinate"]], nsmall = 6),
        # format to pad trailing zeroes till at least 6 decimal points
        eastBoundingCoordinate = format(geo_row[["eastboundingcoordinate"]], nsmall = 6),
        northBoundingCoordinate = format(geo_row[["northboundingcoordinate"]], nsmall = 6),
        southBoundingCoordinate = format(geo_row[["southboundingcoordinate"]], nsmall = 6),
        boundingAltitudes = list(
          altitudeMinimum = null_if_na(geo_row, "altitudeminimum"),
          altitudeMaximum = null_if_na(geo_row, "altitudemaximum"),
          altitudeUnits = null_if_na(geo_row, "altitudeunits")
        )
      )
    )
  return(geocov)
}
