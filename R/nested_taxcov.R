nested_taxcov <- function(sci_names, db = "itis") {
  classified <- classification(sci_names, db)
  taxa_df <- class2tree(classified)[["classification"]]
  taxa_df <- taxa_df[, ncol(taxa_df):1]
  taxa_df[] <- lapply(taxa_df, as.character)
  return(taxa_df)
  return(structurize(taxa_df = taxa_df))
}

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
  } else return(NULL)
}