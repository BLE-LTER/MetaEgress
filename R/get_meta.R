#' @title Connect to metabase and query metadata.
#'
#' @description Connect to instance of LTER-core-metabase and query for metadata.
#'
#' @param dbname (character) name of database.
#' @param schema (character) name of schema containing views. Defaults to 'mb2eml_r'.
#' @param dataset_ids (numeric) Number or numeric vector of dataset IDs to query.
#' @param host (character) host name or IP address. Defaults to 'localhost'.
#' @param port (numeric) port number. Defaults to 5432.
#' @param user (character) (optional) username to use in connecting to database. Use to save time. If not supplied, the R console will prompt you to enter a username.
#' @param password (character) (optional) password to user. Use to save time. If not supplied, the R console will prompt you to enter a password.
#'
#' @return (list) A list of data frames corresponding to views from specified schema in metabase
#' to pass to \code{\link{create_entity}}, \code{\link{create_entity_all}} and \code{\link{create_EML}}
#'
#' @examples
#' \dontrun{
#' # Can query multiple datasets at once
#' metadata <- get_meta(dbname = "ble_metabase", dataset_ids = c(1, 2))
#' }
#'
#' @import RPostgres
#' @export



get_meta <-
  function(dbname,
             schema = "mb2eml_r",
             dataset_ids,
             host = "localhost",
             port = 5432,
             user = NULL,
             password = NULL) {
    # -----------------------------------------------------------------------------------
    # set DB driver
    driver <- RPostgres::Postgres()

    # connect to specified DB
    con <- dbConnect(
      drv = driver,
      dbname = dbname,
      host = host,
      port = port,
      user = if (is.null(user))
        readline(prompt = "Enter database username: ")
       else user,
      password = if (is.null(password))
        readline(prompt = "Enter database password: ")
      else password
    )

    # -------------------------------------------------------------------------------------
    # get names of all views in schema
    views_actual <-
      dbGetQuery(
        con,
        paste0(
          "SELECT table_name from information_schema.views WHERE table_schema = '",
          schema,
          "'"
        )
      )
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
      "vw_eml_methodstep_description",
      "vw_eml_geographiccoverage",
      "vw_eml_temporalcoverage",
      "vw_eml_associatedparty",
      "vw_eml_missingcodes",
      "vw_eml_taxonomy",
      "vw_eml_changehistory",
      "vw_eml_provenance",
      "vw_eml_protocols",
      "vw_eml_instruments",
      "vw_eml_software",
      "vw_eml_boilerplate",
      "vw_eml_bp_people"
    )
    
    # missing views: difference between expected and actual views
    views_missing <- setdiff(views_expected, views_actual)
    if (length(views_missing) != 0) {
      warning(
        paste0(
          "Views found in schema '",
          schema,
          "' not matching expected views. Missing following view(s): ",
          paste(views_missing, collapse = ", "),
          ". Please check your installation of LTER-core-metabase."
        )
      )
    }

    # unexpected views: difference between actual and expected views
    views_unexpected <- setdiff(views_actual, views_expected)
    if (length(views_unexpected) != 0) {
      warning(
        paste0(
          "Views found in schema '",
          schema,
          "' not matching expected views. Unexpected view(s): ",
          paste(views_unexpected, collapse = ", "),
          ". Please read in and process these view(s) manually."
        )
      )
    }
    
    # remove boilerplate views
    views_expected <- views_expected[!views_expected %in% c("vw_eml_boilerplate", "vw_eml_bp_people")]
    
    views_to_query <-
      paste0(schema, ".", intersect(views_actual, views_expected))
    names(views_to_query) <- intersect(views_actual, views_expected)
    # ---------------------------------------------------------------------------------
    # function to parameterize queries to prevent SQL injection
    param_query <- function(view) {
      # create queries. $1 is code for parameterization in postgres
      query <- paste("SELECT * FROM", view, "WHERE datasetid = $1")

      result <- RPostgres::dbSendQuery(conn = con, query)
      RPostgres::dbBind(result, list(dataset_ids))
      query_df <- RPostgres::dbFetch(result)
      RPostgres::dbClearResult(result)
      return(query_df)
    }

    # apply over list of views to query
    query_dfs <- lapply(views_to_query, param_query)

    
    # ---------------------------------------------------------------------------------
    # read in boilerplate views separately since these do not have datasetid column
    
    query_dfs[["boilerplate"]] <- dbGetQuery(con, paste0('SELECT * FROM ', schema, '.vw_eml_boilerplate'))
    query_dfs[["bp_people"]] <- dbGetQuery(con, paste0('SELECT * FROM ', schema, '.vw_eml_bp_people'))
    
    
    # disconnect
    dbDisconnect(con)

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
      "methodstep",
      "geo",
      "temporal",
      "parties",
      "missing",
      "taxonomy",
      "changehistory",
      "provenance",
      "protocols",
      "instruments",
      "software",
      "boilerplate",
      "bp_people"
    )

    # match expected views with names of data frames in list
    existing <- match(views_expected, names(query_dfs))

    # rename according to matched indices
    names(query_dfs)[na.omit(existing)] <-
      names_short[which(!is.na(existing))]
    message("You might want to erase command history, since user password to your database was given.")
    return(query_dfs)
  }
