#'
#' Assemble dataset level maintenance tree
#' 
#' @param dataset_df (data.frame) A data frame containing information on the dataset.
#' @param changehistory_df (data.frame) A data frame containing information on the dataset's change history. 
#'
#' @return (list) An emld list structure containting the EML maintenance tree: description, update frequency, change history
#' 
#' @export

assemble_maintenance <- function(dataset_df, changehistory_df) {
  
  maint_desc <-
    if (!is.na(dataset_df[["maintenance_description"]])) {
      dataset_df[["maintenance_description"]]
    } else "No maintenance description provided."
  
  update_freq <-
    if (!is.na(dataset_df[["maintenanceupdatefrequency"]])) {
      dataset_df[["maintenanceupdatefrequency"]]
    } else NULL
  
  if (nrow(changehistory_df) > 0) {
    change_history <- apply(changehistory_df, 1, make_history)
    names(change_history) <- NULL
  } else  change_history <- NULL
  
  maintenance <- list(
    description = maint_desc,
    maintenanceUpdateFrequency = update_freq,
    changeHistory = change_history
  )
  
  return(maintenance)
  
}


#' Create a single entry in dataset change history.
#'
#' @param changehistory (data.frame) A data.frame with a single row.
#' 
#' @return (list) An emld list for one change history entry.

make_history <- function(changehistory) {
  one_change <- list(
    changeScope = null_if_na(changehistory, "change_scope"),
    oldValue = if (changehistory[["revision_number"]] == 1) {
      "No previous revision"
    } else {
      paste("See previous revision", as.numeric(changehistory[["revision_number"]]) - 1)
    },
    changeDate = changehistory[["change_date"]],
    comment = if (!is.na(changehistory[["revision_notes"]])) {
      paste(changehistory[["givenname"]], changehistory[["surname"]], ":", changehistory[["revision_notes"]])
    } else {
      NULL
    }
  )
  
  return(one_change)
}

