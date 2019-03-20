library(EML)

contacts <- list(individualName = list(givenName = "Jeanette", surName = "Clark"))

geo_list <- data.frame("description" = c("one", "two"),
                       "west" = c(1, 2),
                       "east" = c(1, 2),
                       "north" = c(1, 2),
                       "south" = c(1, 2))

geo_func <- function(geo_list){
  geo <- list(
    geographicDescription = geo_list[['description']],
    boundingCoordinates = list(
      westBoundingCoordinate = as.character(geo_list[['west']]),
      eastBoundingCoordinate = as.character(geo_list[['east']]),
      northBoundingCoordinate = as.character(geo_list[['north']]),
      southBoundingCoordinate = as.character(geo_list[['south']])
    )
  )
  return(geo)
}

covs <- apply(geo_list, 1, geo_func)


my_eml <- list(packageId = "id", system = "system",
               dataset = list(
                 title = "A Mimimal Valid EML Dataset",
                 abstract = "abstract",
                 creator = contacts,
                 contact = contacts,
                 coverage = list(geographicCoverage = covs))
)

eml_validate(my_eml)
