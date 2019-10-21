#' Assemble a single EML annotation element
#' 
#' @param annotation_row (data.frame) Data frame with one row containing info for the annotation
#' @return (list) emld list for annotation

assemble_annotation <- function(annotation_row) {
  annotation <- list(
    propertyURI = list(
      annotation_row[["propertyuri"]],
      label = annotation_row[["propertyuri_label"]]
    ),
    valueURI = list(
      annotation_row[["valueuri"]],
      label = annotation_row[["valueuri_label"]]
    )
  )
  return(annotation)
}