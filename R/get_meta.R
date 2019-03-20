# connect to metabase and query for metadata return a list of data frames
# to pass to create_entity() and create_EML()

get_meta <- function(dbname, host, port, dataset_ids) {
  
  # set DB driver
  #library(RPostgres)
  driver <- RPostgres::Postgres()
  
  # connect to specified DB
  con <- dbConnect(
      drv = driver,
      dbname = dbname,
      host = host,
      port = port,
      user = rstudioapi::showPrompt(title = "Enter database username", message = "Username to use in connecting to metabase"),
      password = rstudioapi::askForPassword(prompt = "Enter database password")
    )
  
  # views to query from
  views <- list(
    "vw_eml_attributes",
    "vw_eml_attributecodedefinition",
    "vw_custom_units",
    "vw_eml_creator",
    "vw_eml_keyword",
    "vw_eml_entities",
    "vw_eml_dataset",
    "vw_eml_datasetmethod",
    "vw_eml_geographiccoverage",
    "vw_eml_temporalcoverage"
  )
  view_list <- paste0("mb2eml_r.", views)
  
  # create queries
  queries <- paste("SELECT * FROM", view_list, "WHERE datasetid = $1")
  
  # parameterize queries to prevent SQL injection
  param_query <- function(query) {
    result <- RPostgres::dbSendQuery(conn = con, query)
    RPostgres::dbBind(result, list(dataset_ids))
    query_df <- RPostgres::dbFetch(result)
    RPostgres::dbClearResult(result)
    return(query_df)
  }
  
  # apply over list of queries and name list items
  query_dfs <- lapply(queries, param_query)
  
  # rename list items according to order of views above
  names(query_dfs) < c(
    "meta",
    "factors",
    "unit",
    "creator",
    "keyword",
    "entities",
    "dataset",
    "method",
    "geo",
    "temporal"
  )
  
  return(query_dfs)
}
