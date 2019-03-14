# function to check installed packages against required packages and install any missing

install <- function(packages) {
  new.packages <-
    packages[!(packages %in% installed.packages()[, "Package"])]
  if (length(new.packages)) {
    install.packages(new.packages, dependencies = TRUE)
  }
  sapply(packages, require, character.only = TRUE)
}

# list of required packages
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

# install missing packages
install(required.packages)

