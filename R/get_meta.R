
# connect to metabase and query for metadata 
# return a list of data frames
# to pass to create_entity() and create_EML()

get_meta <- function(dbname, schema = 'mb2eml_r', host, port, user = NULL, password = NULL, dataset_ids) {
  
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
  
  # get names of all views in schema 
  views_actual <- dbGetQuery(con, paste0("select table_name from information_schema.views where table_schema = '", schema, "'"))
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
  
  views_diff <- setdiff(views_expected, views_actual)
  
  if(length(views_diff) != 0){
    warning(paste0("Views found in schema '", schema, "' not matching expected views. Missing following views: ", views_diff))
  }
  
  view_list <- paste0("mb2eml_r.", views)
  
  # create queries
  # $1 is code for parameterization in postgres
  queries <- paste("SELECT * FROM", view_list, "WHERE datasetid = $1")
  
  # parameterize queries to prevent SQL injection
  param_query <- function(query) {
    result <- RPostgres::dbSendQuery(conn = con, query)
    RPostgres::dbBind(result, list(dataset_ids))
    query_df <- RPostgres::dbFetch(result)
    RPostgres::dbClearResult(result)
    return(query_df)
  }
  
  # apply over list of queries
  query_dfs <- lapply(queries, param_query)
  
  # rename list items according to order of imported views
  names(query_dfs) <- c(
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
    "parties"
  )
  
  return(query_dfs)
}
