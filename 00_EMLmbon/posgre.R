# connect to metabase and query for metadata

get_meta <- function(dbname, host, port) {
  
  # set DB driver
  library(RPostgres)
  driver <- RPostgres::Postgres()
  
  # connect to specified DB
  con <- dbConnect(
    driver,
    dbname = "lter_arranged",
    host = host,
    port = 5432,
    user = rstudioapi::showPrompt(title = "Enter database username", message = "Username"),
    password = rstudioapi::askForPassword(prompt = "Enter database password")
  )
  
  # views to query from
  view_list <- list(
    "mb2eml_r.vw_eml_attributes",
    "mb2eml_r.vw_eml_attributecodedefinition",
    "mb2eml_r.vw_custom_units",
    "mb2eml_r.vw_eml_creator",
    "mb2eml_r.vw_eml_keyword",
    "mb2eml_r.vw_eml_entities",
    "mb2eml_r.vw_eml_dataset",
    "mb2eml_r.vw_eml_datasetmethod",
    "mb2eml_r.vw_eml_geographiccoverage",
    "mb2eml_r.vw_eml_temporalcoverage"
  )
  
  # create queries
  queries <- paste("SELECT * FROM", view_list, "WHERE datasetid = $1")
  
  # parameterize queries to prevent SQL injection
  param_query <- function(query){
    result <- dbSendQuery(conn = con, query)
    dbBind(result, list(dataset_ids))
    query_df <- dbFetch(result)
    dbClearResult(result)
    return(query_df)
  }
  
  # apply over list of queries and name list items
  query_dfs <- lapply(queries, param_query)
  
  names(query_dfs) <- c("meta", "factors", "unit", "creator", "keyword", "entities", "dataset", "method", "geo", "temporal")
  
  return(query_dfs)
}