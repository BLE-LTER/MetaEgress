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
    # loop over all personnel
    
    for (i in 1:nrow(personnel_df)) {
      people[[i]] <- assemble_person(personnel_df[i, ])
    }

    # for EML elements with possible multiple sub-elements
    # list items must be unnamed for valid EML.
    # here, list item names were inherited from row names in meta_list

    names(people) <- NULL
    return(people)
  } else {
    return(NULL)
  }
}

# ------------------------------------------------------------------------------

#' @title Assemble EML list structure for singular personnel.
#' @description Assemble emld list structure for an EML ResponsibleParty type.
#'
#' @param row (data.frame) A single-row data.frame containing information on a single ResponsibleParty.
#' @return (list) emld list structure.
#' 
#' @export
#'

assemble_person <- function(row) {
  # check for organization

  if (!is.na(row[["givenname"]]) ||
    !is.na(row[["surname"]])) {
    if (!is.na(row[["givenname"]]) || !is.na(row[["givenname2"]])) {
      given_name <-
        paste(
          null_if_na(row, "givenname"),
          null_if_na(row, "givenname2")
        )
    } else {
      given_name <- NULL
    }

    individual_name <- list(
      givenName = given_name,
      surName = null_if_na(row, "surname")
    )
  } else {
    individual_name <- NULL
  }


  # check for empty address

  if (is.na(row[["address1"]]) &
    is.na(row[["address2"]]) & is.na(row[["address3"]])) {
    delivery_point <- NULL
  } else {
    delivery_point <-
      paste(
        null_if_na(row, "address1"),
        null_if_na(row, "address2"),
        null_if_na(row, "address3")
      )
  }

  address <- list(
    deliveryPoint = delivery_point,
    city = null_if_na(row, "city"),
    administrativeArea = null_if_na(row, "state"),
    postalCode = null_if_na(row, "zipcode"),
    country = null_if_na(row, "country")
  )

  user_id <-
    if ("userid" %in% colnames(row) & !is.na(row[["userid"]])) {
      list(row[["userid"]],
        `directory` = null_if_na(row, "userid_type")
      )
    }
    else {
      NULL
    }

  # ---
  # assemble person list structure

  p <- list(
    individualName = individual_name,
    organizationName = null_if_na(row, "organization"),
    address = address,
    phone = null_if_na(row, "phone1"),
    electronicMailAddress = null_if_na(row, "email"),
    userId = user_id,
    role = if ("authorshiprole" %in% colnames(row) & !row[["authorshiprole"]] %in% c("creator", "contact")) {
      null_if_na(row, "authorshiprole")
    } else {
      NULL
    }
  )
  return(p)
}
