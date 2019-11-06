#' @title Create dataset method section.
#'
#' @description Create emld list for a dataset method section.
#'
#' @param meta_list (list) A list of dataframes containing metadata returned by \code{\link{get_meta}}.
#' @param dataset_id (numeric) A dataset ID.
#' @param file_dir (character) Path to directory containing flat files (abstract and method documents). Defaults to current R working directory if "".
#'
#'
#' @return (list) An emld list containing information on methods in LTER-core-metabase for the specified dataset ID.
#'
#' @export

create_method_section <-
  function(meta_list, dataset_id, file_dir = "") {
    steps <- subset(meta_list[["methodstep"]], datasetid == dataset_id, select = methodstep_id, drop = TRUE)

    methodStep <-
      lapply(steps,
        create_method_step,
        meta_list,
        dataset_id = dataset_id,
        file_dir = file_dir
      )

    names(methodStep) <- NULL

    return(methodStep)
  }

# ------------------------------------------------------------------------------

#' @title Create method step.
#'
#' @description Create an emld list for a methodStep.
#'
#' @param step_id (numeric) A methodStep ID. Distinct IDs constitute distinct methodSteps.
#' @param meta_list (list) A list of dataframes containing metadata returned by \code{\link{get_meta}}.
#' @param dataset_id (numeric) A dataset ID.
#' @param file_dir (character) Path to directory containing flat files (abstract and method documents). Defaults to "" or current R working directory.
#'
#' @return (list) An emld list containing a methodStep for the specified dataset ID and methodStep ID.
#'
#' @export

create_method_step <-
  function(step_id,
             meta_list,
             dataset_id,
             file_dir = "") {
    # ---
    # subset

    method_desc <-
      subset(meta_list[["methodstep"]], datasetid == dataset_id &
        methodstep_id == step_id)
    provenance <-
      subset(meta_list[["provenance"]], datasetid == dataset_id &
        methodstep_id == step_id)
    protocols <-
      subset(meta_list[["protocols"]], datasetid == dataset_id &
        methodstep_id == step_id)
    instruments <-
      subset(meta_list[["instruments"]], datasetid == dataset_id &
        methodstep_id == step_id)
    software <-
      subset(meta_list[["software"]], datasetid == dataset_id &
        methodstep_id == step_id)

    # ---
    # method step description
    desc_type <- method_desc[["description_type"]]
    desc_content <- method_desc[["description"]]
    
      if (desc_type == "file") {
        description <- set_TextType(file = file.path(file_dir, desc_content))
      } else if (desc_type == "md") {
        description <- list(markdown = desc_content)
      } else if (desc_type == "docbook") {
        description <- as_emld(xml2::read_xml(as.character(desc_content)))
        description <- description[!names(description) %in% c("@context", "@type")]
      } else if (desc_type == "plaintext") description <- set_TextType(text = desc_content)

    # ---
    # get and expand provenance

    if (nrow(provenance) > 0) {
      ids <-
        provenance[["data_source_packageId"]]

      prov <-
        lapply(
          lapply(ids, EDIutils::api_get_provenance_metadata),
          emld::as_emld
        )

      data_source <- lapply(prov, `[[`, "dataSource")

      # what a roundabout way to do this
      # note: we are selecting the "description" from each data source, unlisting the list, then collapse them together, then set texttype on the collapsed string. mmm convoluted yea?
      prov_desc <-
        set_TextType(text = paste0(unlist(
          lapply(prov, `[[`, "description"),
          use.names = F
        ), collapse = " \n "))

      # ---
      # stitch descriptions together
      description$para <- c(description$para, prov_desc)
    } else {
      data_source <- NULL
    }

    # ---
    # get protocols


    if (nrow(protocols) > 0) {
      protocols_xml <- list()

      for (i in 1:nrow(protocols)) {
        protocols_xml[[i]] <-
          list(
            title = protocols[i, "title"],
            creator = list(
              individualName = list(
                givenName = protocols[i, "givenname"],
                surName = protocols[i, "surname"]
              )
            ),
            distribution = list(online = list(
              url = list(protocols[i, "url"],
                `function` = "download"
              )
            ))
          )
      }
    } else {
      protocols_xml <- NULL
    }

    # ---
    # get instruments

    if (nrow(instruments) > 0) {
      instruments_xml <- list()

      for (i in 1:nrow(instruments)) {
        instruments_xml[[i]] <- instruments[i, "instrument"]
      }
    } else {
      instruments_xml <- NULL
    }


    # ---
    # get software

    if (nrow(software) > 0) {
      software_xml <- list()

      for (i in 1:nrow(software)) {
        software_xml[[i]] <-
          list(
            title = software[i, "title"],
            creator = list(individualName = list(surName = software[i, "surName"])),
            abstract = software[i, "abstract"],
            implementation = list(
              distribution = list(online = list(
                url = list(software[i, "url"],
                  `function` = "information"
                )
              ))
            ),
            version = software[i, "version"]
          )
      }
    } else {
      software_xml <- NULL
    }

    # ---
    # construct and return methodStep

    return(
      list(
        description = description,
        dataSource = data_source,
        protocol = protocols_xml,
        instrumentation = instruments_xml,
        software = software_xml
      )
    )
  }
