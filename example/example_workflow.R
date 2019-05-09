
# example workflow from metabase to EML document
# put project script plus data files and other documents
# eg. abstract, methods, boilerplate, license
# in a folder level with the folder containing R scripts (if not installed as package)

# ----------------------
# common steps
# load in libraries, no need if installed as package

library(EML)
library(RPostgres)


# source functions, no need if installed as package

source('../R/get_meta.R')
source('../R/create_entity.R')
source('../R/create_EML.R')


# connect to metabase and get metadata from specified datasets
# once done, can reuse list

metadata <-
  get_meta(
    dbname = "lter_arranged",     # change to your DB name
    host = "localhost",
    port = 5432,
    dataset_ids = c(99013, 99021) # change to vector of datasets wanted
  )

# set workding directory to directory of current script
# data files + abstract (as in column DataSet.Abstract) 
# plus methods (as in column DataSetMethods.methodDocument)
# should be in this folder

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


# specify paths to boilerplate XML and license document
# edit those two as needed beforehand
# note that .docx format only works with 'rmarkdown' package (see set_TextType help for more info)

boilerplate_path <- EML::read_eml("./00_Shared_document/boilerplate.xml")
license_path <- normalizePath("./00_Shared_document/IntellectualRights.docx")

# -----------------------
# single entity example, datasetid 99013

# create an entity
# this step would generate warnings, mostly of the unit sort
# unit warnings are fine because custom units are defined later

table_99013 <-
  create_entity(meta_list = metadata,
                dataset_id = 99013,
                entity = 1)

# create EML list object
EML_99013 <-
  create_EML(
    meta_list = metadata,
    dataset_id = 99013,
    boilerplate_path =  boilerplate_path,
    license_path = license_path,
    data_table = table_99013
  )

# validate
EML::eml_validate(EML_99013)
s
# serialize (write)
EML::write_eml(EML_99013, file = "EML_99013.xml")


# ------------------------
# multiple entities example, datasetid 99021

# use lapply() to loop through multiple entity ids
# exclude entities here if wanted
# loop through data tables and other entities separately
# outputs list of entities

tables_99021 <- lapply(c(1:3), create_entity, meta_list = entity_meta, dataset_id = 99021)

# create EML list object
EML_99021 <-
  create_EML(
    meta_list = metadata,
    dataset_id = 99021,
    boilerplate = boilerplate,
    license = license,
    data_table = tables_99021
  )

# validate and serialize (write) EML document
eml_validate(EML_99021)
write_eml(EML_99021, file = "EML_99021.xml")


# ------------------------
# multiple entities example, datasetid 99021
# WITH TEST MODIFICATIONS IN METABASE, DO NOT RUN

# connect to metabase
meta_mod <-
  get_meta(
    dbname = "lter_tests",
    host = "localhost",
    port = 5432,
    dataset_ids = c(99013, 99021)
  )

# create entities
tables_99021_mod <- lapply(c(1:3), create_entity, meta_list = meta_mod, dataset_id = 99021)

# create EML list object
EML_99021_mod <-
  create_EML(
    meta_list = meta_mod,
    dataset_id = 99021,
    boilerplate = boilerplate,
    license = license,
    data_table = tables_99021_mod
  )

# validate and serialize (write) EML document
eml_validate(EML_99021_mod)
write_eml(EML_99021_mod, file = "EML_99021_mod.xml")
