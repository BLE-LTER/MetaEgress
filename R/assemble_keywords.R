#'
#' Assemble keywordSets by thesaurus.
#' 
#' @param keyword_df (data.frame) A data.frame containing keywords. Required columns: "keyword", "keyword_thesaurus", "keywordtype".
#' 
#' @return (list) An emld list structure containing as many keywordSets as there are thesauri in input.
#'
#' @export

assemble_keywordset <- function(keyword_df) {
  kall <-
    lapply(lapply(unique(keyword_df[["keyword_thesaurus"]]), function(x)
      return(keyword_df[keyword_df[["keyword_thesaurus"]] == x, ])), assemble_thesaurus)
  names(kall) <- NULL
  return(kall)
}

#' Assemble a single thesaurus's keywordSet
#' 
#' @param thesaurus (data.frame) A data.frame with keywords in one thesaurus.
#'
#' @return (list) An emld list for one keywordSet corresponding to the thesaurus.
#'

assemble_thesaurus <- function(thesaurus) {
  
  keys <- lapply(lapply(unique(thesaurus[["keyword"]]), function(x)
    return(thesaurus[thesaurus[["keyword"]] == x, ])), assemble_keyword)
  
  set <- list(
    keyword = keys,
    keywordThesaurus = thesaurus[["keyword_thesaurus"]][[1]]
  )
  return(set)
}

#' Assemble a single keyword.
#'
#' @param keyword (data.frame) A data.frame with one row.
#'
#' @return (list) An emld list for a single keyword with keywordType if present.

assemble_keyword <- function(keyword) {
  list(keyword[["keyword"]],
       `keywordType` = null_if_na(keyword, "keywordtype"))
}
