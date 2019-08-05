#'
#'
#'
#'
#'
#'

create_method_section <-
  function(meta_list, dataset_id, file_dir) {
    method_desc <-
      subset(meta_list[["methodstep"]], datasetid == dataset_id)
    provenance <-
      subset(meta_list[["provenance"]], datasetid == dataset_id)
    # protocols <- 
    #  subset(meta_list[["protocols"]], datasetid == dataset_id)
    
    
    methodStep <-
      lapply(
        method_desc[["methodstep_id"]],
        create_method_step,
        meta_list,
        method_desc = method_desc,
        provenance = provenance,
        file_dir = NULL
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
           method_desc,
           provenance,
           file_dir = NULL) {
    # ---
    # get method step description
    description <-
      if (is.null(file_dir))
        set_TextType(subset(method_desc, methodstep_id == step_id, description)[[1]])
    else
      set_TextType(file.path(file_dir, subset(method_desc, methodstep_id == step_id, description)[[1]]))
    
    # ---
    # get and expand provenance
    
    if (nrow(provenance) > 0) {
    ids <-
      subset(provenance, methodstep_id == step_id, data_source_packageId)[[1]]
    
    prov <-
      lapply(lapply(ids, EDIutils::api_get_provenance_metadata),
             emld::as_emld)
    
    data_source <- lapply(prov, `[[`, "dataSource")
    
    # what a roundabout way to do this
    prov_desc <- set_TextType(text = paste0(unlist(lapply(prov, `[[`, "description"), use.names = F), collapse = " \n "))
    
    # ---
    # stitch descriptions together
    description$para <- c(description$para, prov_desc)
    
    } else {
      data_source <- NULL
    }
    
    
    return(list(description = description,
      dataSource = data_source))
    
    # ---
    # get protocols
    
    
    
    
    # ---
    # get instruments
    
    
    # ---
    # get software
    
    # ---
    # construct methodStep
    
    
    # ---
    # return methodStep
    
    
  }