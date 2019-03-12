

posgrefun <- function(dbname,
                      host,
                      port,
                      user,
                      password,
                      dataset_ids) {
  library(RPostgres)
  # loads the PostgreSQL driver
  
  drv <- RPostgres::Postgres()
  # creates a connection to the postgres database
  # note that "con" will be used later in each connection to the database
  
  con <- dbConnect(
    drv,
    dbname = dbname,
    host = host,
    port = 5432,
    user = user,
    password = password
  )
  
  # check for the tables
  
  meta <- dbReadTable(con, c("mb2eml_r", "vw_eml_attributes"))
  fact <-
    dbReadTable(con, c("mb2eml_r", "vw_eml_attributecodedefinition"))
  unit <- dbReadTable(con, c("mb2eml_r", "vw_custom_units"))
  creator <- dbReadTable(con, c("mb2eml_r", "vw_eml_creator"))
  keyword <- dbReadTable(con, c("mb2eml_r", "vw_eml_keyword"))
  entities <- dbReadTable(con, c("mb2eml_r", "vw_eml_entities"))
  dataset <- dbReadTable(con, c("mb2eml_r", "vw_eml_dataset"))
  method <- dbReadTable(con, c("mb2eml_r", "vw_eml_datasetmethod"))
  geo <- dbReadTable(con, c("mb2eml_r", "vw_eml_geographiccoverage"))
  tempo <- dbReadTable(con, c("mb2eml_r", "vw_eml_temporalcoverage"))
  
  dbDisconnect(con)
  
  return (
    list(
      meta = meta,
      fact = fact,
      unit = unit,
      creator = creator,
      keyword = keyword,
      entities = entities,
      dataset = dataset,
      method = method,
      geo = geo,
      tempo = tempo
    )
  )
  
}

postgresfun_2 <- function(dbname, host, port) {
  library(RPostgres)
  driver <- RPostgres::Postgres()
  con <- dbConnect(
    driver,
    dbname = "lter_arranged",
    host = host,
    port = 5432,
    user = rstudioapi::showPrompt(title = "Enter database username", message = "Username"),
    password = rstudioapi::askForPassword(prompt = "Enter database password")
  )
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
  queries <- paste("SELECT * FROM", view_list, "WHERE datasetid = $1")
  
  many_param_query <- function(query){
    query_result <- dbSendQuery(conn = con, query)
    dbBind(query_result, list(dataset_ids))
    query_df <- dbFetch(query_result)
    dbClearResult(query_result)
    return(query_df)
  }
  query_dfs <- lapply(queries, many_param_query)
  
  names(query_dfs) <- c("meta", "factor", "unit", "creator", "keyword", "entities", "dataset", "method", "geo", "temporal")
  return(query_dfs)
}

dfs <- postgresfun_2("lter_arranged", host, port)
