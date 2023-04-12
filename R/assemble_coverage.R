#' @title Assemble dataset coverage elements
#' @description Assemble geographic, temporal, and taxonomic coverage elements at the dataset level.
#' @param meta_list (list) A list of dataframes containing metadata returned by \code{\link{get_meta}}.
#' @param expand_taxa (logical) TRUE/FALSE on whether assemble_taxonomic will lookup and fully expand a leaf node taxon's full taxonomic classification (kingdom to the lowest rank provided) into nested EML taxonomicCoverage elements (TRUE) or simply make a taxonomic coverage module based on the information provided in metabase (FALSE). This assumes, of course, that the taxa provided are only the leaf nodes. If so, setting this to TRUE and having the full classification may help your dataset be more discover-able, however the lookup process may be more prone to errors. If this is set to TRUE, rows containing taxa from unsupported providers, or from supported providers but whose classification lookups fail, will not be expanded. The function will use information from the taxonid, taxonrankvalue, taxonid_provider, and (if you have it) providerurl columns from the vw_eml_taxonomy view queried from metabase. It expects taxonid to contain the correct identifier for the taxon from the listed taxonomic authority/provider, taxonrankvalue to contain the taxon's name, taxonid_provider to provide a correctly spelled name or commonly used ID for the taxonomic provider/authority (e.g. ITIS for the Integrated Taxonomy Information System), and providerurl to contain a working url to the same.  Defaults to FALSE
#' @param skip_taxa (logical) Whether to skip the call to \code{assemble_taxonomic}. Provided in case assemble_taxonomic fails in some way -- taxonomies are tricky; one option is to manually insert in a text editor a snippet of EML generated elsewhere, into the complete EML output from MetaEgress. Defaults to FALSE.
#' @return (list) A named list containing geographicCoverage, temporalCoverage, and taxonomicCoverage elements, each NULL if no information is provided.
#' @export

assemble_coverage <- function(meta_list,
                              expand_taxa = FALSE,
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
