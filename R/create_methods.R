#'
#'
#'
#'
#'
#'

create_method_section <-
  function(meta_list, dataset_id, file_dir = NULL) {
    
    steps <- meta_list[["methodstep"]][["methodstep_id"]]
    
    methodStep <-
      lapply(
        steps,
        create_method_step,
        meta_list,
        dataset_id = dataset_id,
        file_dir = file_dir
      )
    
    names(methodStep) <- NULL
    
    return(methodStep)
  }

#'
#'
#'
#'
#'
#'

create_method_step <-
  function(step_id,
           meta_list,
           dataset_id,
           file_dir = NULL) {
    # ---
    # subset
    
    method_desc <-
      subset(meta_list[["methodstep"]], datasetid == dataset_id & methodstep_id == step_id)
    provenance <-
      subset(meta_list[["provenance"]], datasetid == dataset_id & methodstep_id == step_id)
    protocols <-
      subset(meta_list[["protocols"]], datasetid == dataset_id & methodstep_id == step_id)
    

    # ---
    # get method step description
    description <-
      if (is.null(file_dir))
        set_TextType(file = method_desc[["description"]])
    else
      set_TextType(file.path(file_dir, method_desc[["description"]]))
    
    # ---
    # get and expand provenance
    
    
    
    if (nrow(provenance) > 0) {
      ids <-
        provenance[["data_source_packageId"]]
      
      prov <-
        lapply(lapply(ids, EDIutils::api_get_provenance_metadata),
               emld::as_emld)
      
      data_source <- lapply(prov, `[[`, "dataSource")
      
      # what a roundabout way to do this
      prov_desc <-
        set_TextType(text = paste0(unlist(
          lapply(prov, `[[`, "description"), use.names = F
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
        protocols_xml <- c(protocols_xml,
                           list(
                             title = protocols[i,][["title"]],
                             creator = list(
                               individualName = list(
                                 givenName = protocols[i,][["givenname"]],
                                 middleName = if (!is.na(protocols[i,][["givenname"]]))
                                   protocols[i,][["givenname"]]
                                 else
                                   NULL,
                                 surName = protocols[i,][["surname"]]
                               )
                             ),
                             distribution = list(online = list(
                               url = list(protocols[i,][["url"]],
                                          `function` = "download")
                             ))
                           ))
      }
    }
    
    return(list(description = description,
                dataSource = data_source,
                protocol = protocols_xml))
    # ---
    # get instruments
    
    
    # ---
    # get software
    
    # ---
    # construct methodStep
    
    
    # ---
    # return methodStep
    
    
  }