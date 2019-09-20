#'
#' @title Assemble EML list structure for multiple personnel.
#' @description Assemble emld list structure for multiple EML ResponsibleParty type.
#'
#' @param personnel_df (data.frame) A data frame containing information on personnel
#' @return (list) emld list with unnamed child items, each with information on personnel
#' @export

assemble_personnel <- function(personnel_df) {
  
  if (nrow(personnel_df) > 0) {
    
    people <- list()
    nameids <- unique(personnel_df[["nameid"]])
    
    # loop over unique personnel ids (not single rows, to account for multiple user IDs)
    
    for (i in 1:length(nameids)) {
      people[[i]] <- assemble_person(personnel_df[personnel_df[["nameid"]] == nameids[[i]], ])
    }

    # for EML elements with possible multiple sub-elements
    # list items must be unnamed for valid EML.
    # here, list item names were inherited from row names in meta_list

    names(people) <- NULL
    return(people)
  } else return(NULL)
}

# ------------------------------------------------------------------------------

#' @title Assemble EML list structure for singular personnel.
#' @description Assemble emld list structure for an EML ResponsibleParty type.
#'
#' @param nameid (data.frame) A data.frame containing information on a single ResponsibleParty corresponding to a metabase name ID. Most often single row but can contain multiple rows if there are multiple user IDs listed.
#' @return (list) emld list structure.
#' 
#' @export

assemble_person <- function(nameid) {
  
  # account for multiple rows aka multiple user IDs
  if (nrow(nameid) > 1) {
    person <- nameid[1, ]
  } else person <- nameid

  if (!is.na(person[["givenname"]]) ||
    !is.na(person[["surname"]])) {
    if (!is.na(person[["givenname"]]) || !is.na(person[["givenname2"]])) {
      given_name <-
        paste(
          null_if_na(person, "givenname"),
          null_if_na(person, "givenname2")
        )
    } else given_name <- NULL

    individual_name <- list(
      givenName = given_name,
      surName = null_if_na(person, "surname")
    )
  } else individual_name <- NULL


  # check for empty address

  if (is.na(person[["address1"]]) &
    is.na(person[["address2"]]) & is.na(person[["address3"]])) {
    delivery_point <- NULL
  } else {
    delivery_point <-
      paste(
        null_if_na(person, "address1"),
        null_if_na(person, "address2"),
        null_if_na(person, "address3")
      )
  }

  address <- list(
    deliveryPoint = delivery_point,
    city = null_if_na(person, "city"),
    administrativeArea = null_if_na(person, "state"),
    postalCode = null_if_na(person, "zipcode"),
    country = null_if_na(person, "country")
  )

  user_id <- apply(nameid, 1, assemble_userid)
  names(user_id) <- NULL

  # ---
  # assemble person list structure

  p <- list(
    individualName = individual_name,
    positionName = null_if_na(person, "position"),
    organizationName = null_if_na(person, "organization"),
    address = address,
    phone = null_if_na(person, "phone1"),
    electronicMailAddress = null_if_na(person, "email"),
    userId = user_id,
    role = if ("authorshiprole" %in% colnames(person)) if (!person[["authorshiprole"]] %in% c("creator", "contact")) null_if_na(person, "authorshiprole") else NULL 
    else NULL,
    onlineUrl = null_if_na(person, "online_url")
  )
  
  return(p)
}

# -----

assemble_userid <- function(person) {
  
  if (!is.na(person[["userid"]])) {
    list(person[["userid"]],
         `directory` = null_if_na(person, "userid_type")
    )
  }
  else NULL
}