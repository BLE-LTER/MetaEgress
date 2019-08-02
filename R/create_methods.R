#'
#'
#'
#'
#'
#'

create_method_section <-
  function(meta_list, dataset_id, file_dir) {
    
    method_desc <- subset(meta_list[["methodstep"]], datasetid == dataset_id)
    provenance <- subset(meta_list[["provenance"]], datasetid == dataset_id)
    
    methodStep <- lapply(method_desc["methodstep_id"], create_method_step, meta_list, method_desc = method_desc, provenance = provenance, file_dir = NULL)
    
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
  function(meta_list, method_desc, provenance, file_dir = NULL, step_id){
    # ---
    # get method step description
    #description <-
    #  if (is.null(file_dir))
    #    set_TextType(method_desc["methodstep_id" == step_id, "description"])
    #else
    #  set_TextType(file.path(file_dir, method_desc[["description"]]))
    
    # ---
    # get and expand provenance
    provenance <- subset(provenance, "methodstep_id" == step_id, "data_source_packageId")
    
    data_source <- list()
    for (i in 1:length(provenance)) {
      prov_xml <- EDIutils::api_get_provenance_metadata(provenance[[i]])
      prov_xml <- emld::as_emld(prov_xml)
      data_source <- list(data_source, dataSource = prov_xml[["dataSource"]])
    }
    
    return(list(
      description = description,
      dataSource = data_source
    ))
    
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