
# connect to metabase and query for metadata 
# return a list of data frames
# to pass to create_entity() and create_EML()

get_meta <- function(dbname, schema = 'mb2eml_r', dataset_ids, host = 'localhost', port = 5432, user = NULL, password = NULL) {
  
  # -----------------------------------------------------------------------------------
  # set DB driver
  driver <- RPostgres::Postgres()
  
  # connect to specified DBs
  con <- dbConnect(
      drv = driver,
      dbname = dbname,
      host = host,
      port = port,
      user = if (is.null(user)) rstudioapi::showPrompt(title = "Enter database username", message = "Username to use in connecting to metabase") else user,
      password = if (is.null(password)) rstudioapi::askForPassword(prompt = "Enter database password") else password
    )
  
  # -------------------------------------------------------------------------------------
  # get names of all views in schema 
  views_actual <- dbGetQuery(con, paste0("SELECT table_name from information_schema.views WHERE table_schema = '", schema, "'"))
  views_actual <- as.vector(views_actual[[1]])
  
  # expected views
  views_expected <- c(
    "vw_eml_attributes",
    "vw_eml_attributecodedefinition",
    "vw_custom_units",
    "vw_eml_creator",
    "vw_eml_keyword",
    "vw_eml_entities",
    "vw_eml_dataset",
    "vw_eml_datasetmethod",
    "vw_eml_geographiccoverage",
    "vw_eml_temporalcoverage",
    "vw_eml_associatedparty",
    "vw_eml_missingcodes"
  )
  
  # difference between expected and actual views
  views_diff <- setdiff(views_expected, views_actual)
  if(length(views_diff) != 0){
    warning(paste0("Views found in schema '", schema, "' not matching expected views. Missing following view(s): ", views_diff, "."))
  }
  
  views_to_query <- paste0(schema, ".", views_actual)
  names(views_to_query) <- views_actual

  # ---------------------------------------------------------------------------------
  # function to parameterize queries to prevent SQL injection
  param_query <- function(view) {
    
    # create queries
    # $1 is code for parameterization in postgres
    query <- paste("SELECT * FROM", view, "WHERE datasetid = $1")
    
    result <- RPostgres::dbSendQuery(conn = con, query)
    RPostgres::dbBind(result, list(dataset_ids))
    query_df <- RPostgres::dbFetch(result)
    RPostgres::dbClearResult(result)
    return(query_df)
  }
  
  # apply over list of views to query
  query_dfs <- lapply(views_to_query, param_query)
  
  # ----------------------------------------------------------------------------------
  # rename list items
  
  # short names order has to match order of expected views
  names_short <- c(
    "attributes",
    "factors",
    "unit",
    "creator",
    "keyword",
    "entities",
    "dataset",
    "method",
    "geo",
    "temporal",
    "parties",
    "missing"
  )
  
  # match expected views with names of data frames in list 
  existing <- match(views_expected, names(query_dfs))
  
  # rename according to matched indices
  names(query_dfs)[na.omit(existing)] <- names_short[which(!is.na(existing))]
   
  return(query_dfs)
}
