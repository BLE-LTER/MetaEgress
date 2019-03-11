# create a function to check for installed packages and install them if they are not installed
install <- function(packages) {
  new.packages <-
    packages[!(packages %in% installed.packages()[, "Package"])]
  if (length(new.packages)) {
    install.packages(new.packages, dependencies = TRUE)
  }
  sapply(packages, require, character.only = TRUE)
}

# usage
required.packages <- c(
  "EML",
  "rmarkdown",
  "RPostgreSQL",
  "dplyr",
  "data.table",
  "tools",
  "methods",
  "xlsx",
  "styler"
)
install(required.packages)

