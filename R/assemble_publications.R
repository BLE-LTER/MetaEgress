#' @title Assemble EML list structure for multiple publications
#' @description Assemble emld list structure for multiple citationType.
#'
#' @param publication_df (data.frame) A data frame containing information on publications
#' @return (list) emld list with unnamed child items, each with information on publications
#'
#'


assemble_publications <- function(publication_df) {
  pubs <- list(
    lit_cited = list(citation = list()),
    usage_citation = list(),
    ref_pub = list(bibtex = NULL)
  )
  for (i in 1:nrow(publication_df)) {
    row <- publication_df[i,]
    if (row[["relationship"]] == "literatureCited") {
      pubs[["lit_cited"]][["citation"]][[i]] <- list(bibtex = row[["bibtex"]])
    } else if (row[["relationship"]] == "usageCitation") {
      pubs[["usage_citation"]][[i]] <- list(bibtex = row[["bibtex"]])
    } else if (row[["relationship"]] == "referencePublication") {
      pubs[["ref_pub"]][["bibtex"]] <-
        paste(pubs[["ref_pub"]][["bibtex"]], row[["bibtex"]], sep = "\n")
    }
  }
  return(pubs)
}

