#' Assemble the taxonomicCoverage tree in EML
#' @description This function takes the information in metabase and assembles a fully fleshed out taxonomicCoverage EML tree, or more correctly a list of taxonomicClassification nodes. The function will use information from the taxonid, taxonrankvalue, taxonid_provider, and (if you have it) providerurl columns from the vw_eml_taxonomy view queried from metabase. It expects taxonid to contain the correct identifier for the taxon from the listed taxonomic authority/provider, taxonrankvalue to contain the taxon's name, taxonid_provider to provide a correctly spelled name or commonly used ID for the taxonomic provider/authority (e.g. ITIS for the Integrated Taxonomy Information System), and providerurl to contain a working url to the same.
#' @param expand_taxa (logical) TRUE/FALSE on whether to lookup and fully expand a leaf node taxon's full taxonomic classification (kingdom to the lowest rank provided) into nested EML taxonomicCoverage elements (TRUE) or simply make a taxonomic coverage module based on the information provided in metabase (FALSE). This assumes, of course, that the taxa provided are only the leaf nodes. If so, setting this to TRUE and having the full classification may help your dataset be more discover-able, however the lookup process may be more prone to errors. If this is set to TRUE, rows containing taxa from unsupported providers, or from supported providers but whose classification lookups fail, will not be expanded. Defaults to FALSE.
#' @param taxa_df (data.frame) A data.frame with taxonomic information. This is normally queried from a view in LTER-core-metabase, and the function expects certain column names (taxonid, taxonid_provider, provider_url, providerid, taxonrankname, and taxonrankvalue).
#' @return (list) List of taxonomicClassification nodes, in emld list format, one per row of taxa_df
#' @export

assemble_taxonomic <- function(taxa_df,
                               expand_taxa = FALSE) {
  # init the result list
  taxcov <- list()

  if (nrow(taxa_df) > 0) {
    # ---------------------- EXPANDING TAXA -----------------------------------#
    if (expand_taxa) {
      # providers supported by taxadb and by extension the EML package
      # taken from https://docs.ropensci.org/taxadb/articles/data-sources.html
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
      # providers supported by taxize::classification (i.e. expandable)
      # taken from function documentation
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

      # resolve provided provider ids to the abbreviations used by the
      # in case there are unwanted uppercase or whitespace characters
      taxa_df$taxonid_provider <-
        apply(taxa_df,
              1,
              match_provider,
              type = 'id',
              simplify = T)

      # send different sets of taxa to different processing methods
      # first we separate the input by whether unsupported/supported and by which package
      unsupported <-
        taxa_df[!taxa_df$taxonid_provider %in% union(taxadb_provs, expandprovs),]
      taxadb_supported <-
        taxa_df[taxa_df$taxonid_provider %in% taxadb_provs,]
      # only send to taxize what taxadb didn't already cover
      taxize_supported <-
        taxa_df[taxa_df$taxonid_provider %in% setdiff(expandprovs, taxadb_provs),]

      # loop through each supported provider by taxadb
      for (i in seq_along(unique(taxadb_supported$taxonid_provider))) {
        df <-
          taxadb_supported[taxadb_supported$taxonid_provider == unique(taxadb_supported$taxonid_provider)[[i]],]
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

      # loop through each supported provider by taxize::classification
      # that are not already covered by taxadb
      for (i in seq_along(unique(taxize_supported$taxonid_provider))) {
        # subset
        df <-
          taxize_supported[taxize_supported$taxonid_provider == unique(taxize_supported$taxonid_provider)[[i]], ]
        # if taxonids arent available, then use names
        sci_ids <-
          ifelse(is.null(null_if_na(df, "taxonid")), df$taxonrankvalue, df$taxonid)
        classifications <-
          suppressMessages(unname(
            mapply(
              taxize::classification,
              sci_id = sci_ids,
              id = df$taxonid,
              db = df$taxonid_provider
            )
          ))
        # append rows where classification failed back into unsupported
        narows <- is.na(classifications)
        unsupported <- rbind(unsupported,
                             df[narows,])
        # remove fails from classifications
        classifications <- classifications[!narows]
        cov <-
          lapply(classifications,
                 assemble_taxon_nested,
                 providerurl = match_provider(df[1, ], type = 'url'))
        taxcov <- c(taxcov, cov)
      }

      # loop through and assemble as-is for unsupported providers
      if (nrow(unsupported) > 1) {
        unsupported_cov <- list()
        for (i in 1:nrow(unsupported)) {
          unsupported_cov[[i]] <- assemble_taxon(unsupported[i,])
        }
        # append unsupported taxa to taxcov
        taxcov <- c(taxcov, unsupported_cov)
      }

      names(taxcov) <- NULL
      taxcov <- list(taxonomicClassification = taxcov)
    } # end of expand_taxa = TRUE

    # ------------------------- expand_taxa = FALSE -----------------------------#
    else if (!expand_taxa) {
      for (i in 1:nrow(taxa_df)) {
        taxcov[[i]] <- assemble_taxon(taxa_df[i,])
      }
      names(taxcov) <- NULL
      taxcov <- list(taxonomicClassification = taxcov)
    }
  }
  else if (nrow(taxa_df) == 0) {
    taxcov <- NULL
  }
  return(taxcov)
}


#' Assemble a single recursive nested taxonomicClassification node
#' @description Recursive or nested means this function does use the full taxonomic tree and nest the leaf taxon within.
#' @param provider (character) URL of the taxonomic authority/provider
#' @param classification (data.frame) One data.frame containing one full taxonomic classification tree for one leaf taxon.
#'
#' @return
assemble_taxon_nested <- function(classification, providerurl) {
  pop <- function(taxa) {
    if (nrow(taxa) > 1) {
      list(
        taxonRankName = taxa[1, 'rank', drop = TRUE],
        taxonRankValue = taxa[1, 'name', drop = TRUE],
        taxonId = list(taxa[1, 'id', drop = TRUE],
                       `provider` = providerurl),
        taxonomicClassification = pop(taxa[-1, ])
      )
    }
    else {
      list(
        taxonRankName = taxa[1, 'rank', drop = TRUE],
        taxonRankValue = taxa[1, 'name', drop = TRUE],
        taxonId = list(taxa[1, 'id', drop = TRUE],
                       `provider` = providerurl)
      )
    }
  }
  taxa <- pop(classification)
  return(taxa)
}

#' Assemble a single non-recursive, non-nested taxonomicClassification node
#' @description Non-recursive or non-nested means this function does not lookup the full taxonomic tree and nest the leaf taxon within.
#' @param taxa_row (data.frame) One row of a data.frame containing information on a single taxon.
#' @return (list) An emld formatted unnamed list describing a single taxon
assemble_taxon <- function(taxa_row) {
  taxclass <-
    list(
      taxonRankName = null_if_na(taxa_row, "taxonrankname"),
      taxonRankValue = null_if_na(taxa_row, "taxonrankvalue"),
      commonName = null_if_na(taxa_row, "commonname"),
      taxonId = list(taxa_row[["taxonid"]],
                     `provider` = match_provider(taxa_row = taxa_row))
    )
  return(taxclass)
}

#' Resolve provider ID or URL based on the information provided in metabase
#' @param type (character) "url" or "id". Type of information to return. id returns an abbreviation that can be used to plug in many taxonomic functions. Defaults to url.
#' @param taxa_row (data.frame) One row of a data.frame containing information on a single taxon.
#' @return (character) URL of the taxonomic provider as can be best guessed by the function. "unknown" if no provider url or name provided (nothing to go on), or if the provider name is not known.

match_provider <- function(taxa_row, type = "url") {
  stopifnot(type == 'url' | type == 'id')
  out <- NULL
  # reference table
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
      'kew\'s plants of the world',
      'the plant list',
      'tpl',
      'open tree of life',
      'open tree of life taxonomy',
      'ott',
      'otlt',
      'otl',
      'fishbase',
      'fish base',
      'fb',
      'sealifebase',
      'sea life base',
      'slb',
      'iucn red list',
      'iucn'
    ),
    machine.readable.id = c(
      'col',
      'col',
      'itis',
      'itis',
      'worms',
      'worms',
      'gbif',
      'gbif',
      'tropicos',
      'tropicos',
      'ncbi',
      'ncbi',
      'eol',
      'eol',
      'nbn',
      'nbn',
      'natserv',
      'natserv',
      'bold',
      'bold',
      'bold',
      'wiki',
      'wiki',
      'pow',
      'kew',
      'kew',
      'tpl',
      'tpl',
      'ott',
      'ott',
      'ott',
      'ott',
      'ott',
      'fb',
      'fb',
      'fb',
      'slb',
      'slb',
      'slb',
      'iucn',
      'iucn'
    ),
    machine.readable.url = c(
      'https://www.catalogueoflife.org/',
      'https://www.catalogueoflife.org/',
      'https://itis.gov',
      'https://itis.gov',
      'https://marinespecies.org',
      'https://marinespecies.org',
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
      'https://explorer.natureserve.org/index.htm',
      'https://explorer.natureserve.org/index.htm',
      'https://v3.boldsystems.org/',
      'https://v3.boldsystems.org/',
      'https://v3.boldsystems.org/',
      'https://species.wikimedia.org/wiki/Main_Page',
      'https://species.wikimedia.org/wiki/Main_Page',
      'https://www.plantsoftheworldonline.org/',
      'https://www.plantsoftheworldonline.org/',
      'https://www.plantsoftheworldonline.org/',
      'https://www.theplantlist.org/',
      'https://www.theplantlist.org/',
      'https://tree.opentreeoflife.org/about/taxonomy-version/ott3.1',
      'https://tree.opentreeoflife.org/about/taxonomy-version/ott3.1',
      'https://tree.opentreeoflife.org/about/taxonomy-version/ott3.1',
      'https://tree.opentreeoflife.org/about/taxonomy-version/ott3.1',
      'https://tree.opentreeoflife.org/about/taxonomy-version/ott3.1',
      'https://fishbase.org',
      'https://fishbase.org',
      'https://fishbase.org',
      'https://www.sealifebase.ca/',
      'https://www.sealifebase.ca/',
      'https://www.sealifebase.ca/',
      'https://www.iucnredlist.org',
      'https://www.iucnredlist.org'
    ),
    stringsAsFactors = F
  )

  # ---------------------- URL ------------------------------------------
  if (type == "url") {
    # first we see if provider URL is already provided
    if ("providerurl" %in% names(taxa_row) &&
        !is.na(taxa_row[["providerurl"]])) {
      out <- taxa_row[["providerurl"]]
    }
    else if (is.null(null_if_na(taxa_row, "providerurl"))) {
      # we try matching IDs next
      if ("providerid" %in% names(taxa_row) &&
          !is.na(taxa_row[["providerid"]])) {
        # to all lowercase and whitespace trimmed
        id <- tolower(trimws(taxa_row[["providerid"]]))
        out <-
          cw$machine.readable.url[match(id[id %in% cw$human.readable], cw$human.readable)]
        if (length(out) == 0)
          out <- id
      }
      # then provider names
      else if ("taxonid_provider" %in% names(taxa_row) &&
               !is.na(taxa_row[["taxonid_provider"]])) {
        name <- tolower(trimws(taxa_row[["providerid"]]))
        out <-
          cw$machine.readable.url[match(name[name %in% cw$human.readable], cw$human.readable)]
        if (length(out) == 0)
          out <- name
      }
    }
    if (is.null(out) | is.na(out) | length(out) == 0)
      out <- "unknown"
    return(out)
  }

  if (type == "id") {
    # we try matching IDs next
    if ("providerid" %in% names(taxa_row) &&
        !is.na(taxa_row[["providerid"]])) {
      # all lowercase and whitespace trimmed
      id <- tolower(trimws(taxa_row[["providerid"]]))
      out <-
        cw$machine.readable.id[match(id[id %in% cw$human.readable], cw$human.readable)]
      if (length(out) == 0)
        out <- id
    }
    # then provider names
    else if ("taxonid_provider" %in% names(taxa_row) &&
             !is.na(taxa_row[["taxonid_provider"]])) {
      name <- tolower(trimws(taxa_row[["providerid"]]))
      url <-
        cw$machine.readable.id[match(name[name %in% cw$human.readable], cw$human.readable)]
      if (length(out) == 0)
        url <- id
    }
    if (is.null(out) | is.na(out) | length(out) == 0)
      out <- "unknown"
    return(out)
  }
}
