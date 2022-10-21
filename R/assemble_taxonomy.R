


#' Title
#'
#' @param expand_taxa
#' @param taxa_df
#'
#' @return
#' @export
#'
#' @examples

assemble_taxonomy <- function(taxa_df, expand_taxa) {
  if (nrow(taxa_df) > 0) {
    if (expand_taxa) {
      # TODO: check for one or multiple taxonomic providers
      # TODO: check for taxonomic providers not covered by taxadb

      provs <- unique(taxa_df[["taxonomicprovider"]])
      n <- length(provs)
      db <-
        provs %in% c("itis",
                     "ncbi",
                     "col",
                     "tpl",
                     "gbif",
                     "fb",
                     "slb",
                     "wd",
                     "ott",
                     "iucn") # list of dbs supported by taxadb and by extension EML

      # case 1: one provider and supported by taxadb
      if (n == 1 & db) {
        taxcov <-
          EML::set_taxonomicCoverage(taxa[["taxonrankvalue"]], expand = T, db = provs)
        names(taxcov[[1]]) <- NULL
      } else if (n > 1 & db) { # case 2: multiple providers supported by taxadb
        taxcov <-
          lapply(provs, EML::set_taxonomicCoverage, sci_names = taxa[["taxonrankvalue"]], expand = T)
        names(taxcov) <- NULL
      } else { # case 3: provider(s) not supported by taxadb

      }
    } else {
      #TODO: assemble as is without expanding into full trees
    }
  } else {
    taxcov <- NULL
  }
  return(taxcov)
}

#' Title
#'
#' @param sci_names
#' @param db
#'
#' @return
#' @export
#'
#' @examples
nested_taxcov <- function(sci_names, db = "itis") {
  classified <- taxize::classification(sci_names, db)
  taxa_df <- taxize::class2tree(classified)[["classification"]]
  taxa_df <- taxa_df[, ncol(taxa_df):1]
  taxa_df[] <- lapply(taxa_df, as.character)
  return(taxa_df)
  return(structurize(taxa_df = taxa_df))
}

#' Title
#'
#' @param taxa_df
#'
#' @return
#' @export
#'
#' @examples
structurize <- function(taxa_df) {
  if (ncol(taxa_df) > 0 && nrow(taxa_df) > 0) {
    taxonomicClassification = list()

    while (all(is.na(unique(taxa_df[[1]])))) {
      taxa_df <- taxa_df[, -1, drop = FALSE]
    }

    for (i in seq_along(unique(taxa_df[[1]]))) {
      current_rank_value <- unique(taxa_df[[1]])[[i]]

      # subset out the rows that will go into recursion
      next_rank_taxa_df <-
        taxa_df[taxa_df[[1]] == current_rank_value, -1, drop = FALSE]

      taxonomicClassification[[i]] <- list(
        taxonRankName = colnames(taxa_df)[[1]],
        taxonRankValue = current_rank_value,
        taxonomicClassification =
          structurize(next_rank_taxa_df)
      )
    }
    return(taxonomicClassification)
  } else
    return(NULL)
}
