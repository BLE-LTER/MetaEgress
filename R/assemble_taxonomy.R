



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
  # init taxcov list
  taxcov <- list()

  if (nrow(taxa_df) > 0) {
    # ---------------------- EXPANDING TAXA -----------------------------------#
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
      # TODO: check for one or multiple taxonomic providers
      # TODO: check for taxonomic providers not covered by taxadb

      provs <- unique(taxa_df[["taxonid_provider"]])
      n <- length(provs)

      # TODO: need to match providers to these acronyms

      # list of dbs supported by taxadb and by extension EML
      taxadb_provs <-
        c("itis",
          "ncbi",
          "col",
          "tpl",
          "gbif",
          "fb",
          "slb",
          "wd",
          "ott",
          "iucn")

      # list of dbs supported by taxize
      taxize_provs <- c(
        "eol",
        "itis",
        "gnr",
        "gni",
        "iucn",
        "tropicos",
        "tp",
        "tpl",
        "ncbi",
        "vascan",
        "ipni",
        "bold",
        "worms",
        "bold",
        "pesi",
        "myco",
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
        "natserv"
      )

      # send different sets of taxa to different processing methods
      unsupported <-
        taxa_df[!taxa_df$taxonid_provider %in% union(taxadb_provs, taxize_provs),]
      taxadb_supported <- taxa_df[taxa_df$taxonid_provider %in% taxadb_provs, ]
      taxize_supported <- taxa_df[taxa]

      for (i in 1:nrow(unsupported)) {
        taxcov[[i]] <- assemble_taxon(unsupported[i, ])
      }
      n <- length(taxcov)


      for (i in seq_along(unique(taxadb_supported$taxonid_provider))) {
        df <-
          taxadb_supported[taxadb_supported$taxonid_provider == unique(taxadb_supported$taxonid_provider)[[i]]]
        taxcov <-
          c(
            taxcov,
            EML::set_taxonomicCoverage(
              sci_names = df$taxonrankvalue,
              expand = TRUE,
              db = unique(taxadb_supported$taxonid_provider)[[i]]
            )
          )
      }


    # ------------------------- NO EXPANDING TAXA -----------------------------#
    else if (!expand_taxa) {
      #TODO: assemble as is without expanding into full trees
      for (i in 1:nrow(taxa_df)) {
        taxcov[[i]] <- assemble_taxon(taxa_df[i, ])
      }
      names(taxcov) <- NULL
      taxcov <- list(taxonomicClassification = taxcov)
    }
  }

  else {
    taxcov <- NULL
  }
  return(taxcov)
}


assemble_taxize <- function(sci_names, provider) {
  
#' Assemble a single non-recursive taxonomicClassification node
#'
#' @param taxa_row (data.frame) One row of a data.frame containing information on a single taxon.
#'
#' @return
#'
#' @examples
assemble_taxon <- function(taxa_row) {
  taxclass <-
    list(
      taxonRankName = null_if_na(taxa_row, "taxonrankname"),
      taxonRankValue = null_if_na(taxa_row, "taxonrankvalue"),
      commonname = null_if_na(taxa_row, "commonname"),
      taxonId = list(taxa_row[["taxonid"]],
                     `provider` = match_provider_url(taxa_row))
    )

  return(taxclass)
}

#' Resolve provider url based on the information provided in metabase
#'
#' @param taxa_row (data.frame) One row of a data.frame containing information on a single taxon.
#'
#' @return (character) URL of the taxonomic provider as can be best guessed by the function. "unknown" if no provider url or name provided (nothing to go on), or if the provider name is not known.
#'
#'
match_provider_url <- function(taxa_row) {
  url <- NULL

  # first we see if provider URL is already provided
  if ("providerurl" %in% names(taxa_row) &&
      !is.na(taxa_row[["providerurl"]])) {
    url <- taxa_row[["providerurl"]]
  } else if (is.null(null_if_na(taxa_row, "providerurl"))) {
    cw <- data.frame(
      human.readable = c(
        'col',
        'catalogue of life',
        'integrated taxonomic information system',
        'itis',
        'world register of marine species',
        'worms',
        'gbif backbone taxonomy',
        'gbif',
        'tropicos - missouri botanical garden',
        'tropicos',
        'ncbi',
        'national center for biotechnology information',
        'eol',
        'encyclopedia of life',
        'nbn',
        'national biodiversity network',
        'natserv',
        'natureserv',
        'bold',
        'bolds',
        'barcode of life data system',
        'wiki',
        'wikispecies',
        'pow',
        'kew',
        'kew\'s plants of the world'
      ),
      machine.readable = c(
        'https://www.catalogueoflife.org/',
        'https://www.catalogueoflife.org/',
        'https://itis.gov',
        'https://itis.gov',
        'http://marinespecies.org',
        'http://marinespecies.org',
        'https://gbif.org',
        'https://gbif.org',
        'https://www.tropicos.org/',
        'https://www.tropicos.org/',
        'https://www.ncbi.nlm.nih.gov/taxonomy',
        'https://www.ncbi.nlm.nih.gov/taxonomy',
        'https://eol.org/',
        'https://eol.org/',
        'https://nbn.org.uk/',
        'https://nbn.org.uk/',
        'http://explorer.natureserve.org/index.htm',
        'http://explorer.natureserve.org/index.htm',
        'http://v3.boldsystems.org/',
        'http://v3.boldsystems.org/',
        'http://v3.boldsystems.org/',
        'https://species.wikimedia.org/wiki/Main_Page',
        'https://species.wikimedia.org/wiki/Main_Page',
        'http://www.plantsoftheworldonline.org/',
        'http://www.plantsoftheworldonline.org/',
        'http://www.plantsoftheworldonline.org/'
      ),
      stringsAsFactors = F
    )

    # we try matching IDs next
    if ("providerid" %in% names(taxa_row) &&
        !is.na(taxa_row[["providerid"]])) {
      # all lowercase and whitespace trimmed
      id <- tolower(trimws(taxa_row[["providerid"]]))
      url <-
        cw$machine.readable[match(id[id %in% cw$human.readable], cw$human.readable)]
      if (length(url) == 0)
        url <- id
    }

    # then provider names
    else if ("taxonid_provider" %in% names(taxa_row) &&
             !is.na(taxa_row[["taxonid_provider"]])) {
      name <- tolower(trimws(taxa_row[["providerid"]]))
      url <-
        cw$machine.readable[match(name[name %in% cw$human.readable], cw$human.readable)]
      if (length(url) == 0)
        url <- id
    }
  }

  if (is.null(url) | is.na(url) | length(url) == 0)
    url <- "unknown"
  return(url)
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