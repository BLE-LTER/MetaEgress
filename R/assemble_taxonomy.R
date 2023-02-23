
#' Title
#'
#' @param expand_taxa
#' @param taxa_df
#'
#' @return
#' @export
#'
#' @examples

assemble_taxonomic <- function(taxa_df, expand_taxa) {
  if (nrow(taxa_df) > 0) {
    if (expand_taxa) {
      provs <- tolower(unique(taxa_df[["taxonomicprovider"]]))
      n <- length(provs)
      # list of taxonomic providers supported by taxadb and by extension EML
      # taken from https://docs.ropensci.org/taxadb/articles/data-sources.html
      dbprovs <- c("itis",
                   "ncbi",
                   "col",
                   "tpl",
                   "gbif",
                   "fb",
                   "slb",
                   "wd",
                   "ott",
                   "iucn")
      # list of taxonomic providers supported by taxize
      # taken from https://docs.ropensci.org/taxize/articles/datasources.html
      izeprovs <- c(
        "eol",
        "itis",
        "gnr",
        "gni",
        "iucn",
        "tropicos",
        "tpl",
        "ncbi",
        "vascan",
        "ipni",
        "bold",
        "nbn",
        "fg",
        "eubon",
        "ion",
        "tol",
        "worms",
        "natserv",
        "wiki",
        "pow",
        "gbif"
      )
      # list of taxonomic providers supported by taxize::clasification
      # taken from the above function documentation
      # others providers in izeprovs but not in this list will not be expanded
      expandprovs <- c(
        "ncbi",
        "itis",
        "eol",
        "tropicos",
        "gbif",
        "nbn",
        "worms",
        "natserv",
        "bold",
        "wiki",
        "pow"
      )
      
      # check whether the providers listed are supported by taxadb
      alldb <-
        provs %in% dbprovs
      # check whether the providers listed are supported by taxize
      allize <-
        provs %in% izeprovs
      # check whether there are providers supported 
      expandize <- provs %in% expandprovs
      # check whether there are providers supported by taxadb but not expandable taxize
      dbnotize <-
        provs %in% setdiff(dbprovs, izeprovs)
      # check whether there are providers not supported at all
      atall <- provs %in% union(dbprovs, izeprovs)
      
      # ------------------------------------------------------------------
      # start checking for cases
      # ------------------------------------------------------------------
      
      # case 1: one provider
      if (n == 1) {
        
        # case 1.2: one provider supported by taxadb
        
        
        # 
        
        if (all(expandize)) {
          
        }
        
        else if (all(alldb)) {
          taxcov <-
          EML::set_taxonomicCoverage(taxa[["taxonrankvalue"]], expand = T, db = provs)
        names(taxcov[[1]]) <- NULL
        }
      } 
      
      
      
      else if (n > 1 &
                 all(alldb)) {
        # case 2: multiple providers supported by taxadb
        taxcov <-
          lapply(
            provs,
            EML::set_taxonomicCoverage,
            sci_names = taxa[["taxonrankvalue"]],
            expand = T
          )
        names(taxcov) <- NULL
      } else if (all(allize)) {
        # case 3: there are provider(s) not supported by taxadb
        
      }
    } else if (any(atall)) {
      #TODO: assemble as is without expanding into full trees
    }
  } else {
    taxcov <- NULL
  }
  return(taxcov)
}


assemble_taxize <- function(sci_names, provider) {
  
}



#' 
#' #' Title
#' #'
#' #' @param sci_names
#' #' @param db
#' #'
#' #' @return
#' #' @export
#' #'
#' #' @examples
#' nested_taxcov <- function(sci_names, db = "itis") {
#'   classified <- taxize::classification(sci_names, db)
#'   taxa_df <- taxize::class2tree(classified)[["classification"]]
#'   taxa_df <- taxa_df[, ncol(taxa_df):1]
#'   taxa_df[] <- lapply(taxa_df, as.character)
#'   return(taxa_df)
#'   return(structurize(taxa_df = taxa_df))
#' }
#' 
#' #' Create the taxonomicCoverage EML node
#' #'
#' #' @param sci_names
#' #'     (list) Object returned by \code{MetaEgress::get_classification()}.
#' #'
#' #' @return
#' #' \item{list}{If \code{write.file = FALSE} an emld list object is returned
#' #' for use with the EML R Package.}
#' #' \item{.xml file}{If \code{write.file = TRUE} a .xml file is written to
#' #' \code{path}}.
#' #'
#' set_taxonomic_coverage <- function(sci_names) {
#'   pop <- function(taxa) {
#'     if (length(taxa) > 1) {
#'       list(
#'         taxonRankName = taxa[[1]]$taxonRankName,
#'         taxonRankValue = taxa[[1]]$taxonRankValue,
#'         taxonId = taxa[[1]]$taxonId,
#'         commonName = taxa[[1]]$commonName,
#'         taxonomicClassification = pop(taxa[-1])
#'       )
#'     } else {
#'       list(
#'         taxonRankName = taxa[[1]]$taxonRankName,
#'         taxonRankValue = taxa[[1]]$taxonRankValue,
#'         taxonId = taxa[[1]]$taxonId,
#'         commonName = taxa[[1]]$commonName
#'       )
#'     }
#'   }
#'   
#'   taxa <- lapply(sci_names,
#'                  function(sci_name) {
#'                    pop(sci_name)
#'                  })
#'   
#'   return(list(taxonomicClassification = taxa))
#'   
#' }
#' 
#' #' Title
#' #'
#' #' @param taxa_df
#' #'
#' #' @return
#' #' @export
#' #'
#' #' @examples
#' structurize <- function(taxa_df) {
#'   if (ncol(taxa_df) > 0 && nrow(taxa_df) > 0) {
#'     taxonomicClassification = list()
#'     
#'     while (all(is.na(unique(taxa_df[[1]])))) {
#'       taxa_df <- taxa_df[, -1, drop = FALSE]
#'     }
#'     
#'     for (i in seq_along(unique(taxa_df[[1]]))) {
#'       current_rank_value <- unique(taxa_df[[1]])[[i]]
#'       
#'       # subset out the rows that will go into recursion
#'       next_rank_taxa_df <-
#'         taxa_df[taxa_df[[1]] == current_rank_value, -1, drop = FALSE]
#'       
#'       taxonomicClassification[[i]] <- list(
#'         taxonRankName = colnames(taxa_df)[[1]],
#'         taxonRankValue = current_rank_value,
#'         taxonomicClassification =
#'           structurize(next_rank_taxa_df)
#'       )
#'     }
#'     return(taxonomicClassification)
#'   } else
#'     return(NULL)
#' }
