
# example workflow from metabase to EML document

# put project script plus data files and other documents
# eg. abstract, methods in a folder with this script

# ----------------------
# common steps

library(MetaEgress)

# set workding directory to directory of current script
# data files + abstract (as in column DataSet.Abstract) 
# plus methods (as in column DataSetMethodSteps.Description)
# should be in this folder

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# here is where you'd connect to LTER-core-metabase and query for metadata
# you can also use the example metadata list that comes with this package
# this list of dataframes has the same structure as output from the get_meta() function as below

metadata <- example_metadata_list

# connect to metabase and get metadata from specified datasets
# can specify multiple dataset IDs if you plan to reuse this list

# metadata <-
#   get_meta(
#     dbname = "db_name",     # change to your DB name
#     host = "localhost",
#     port = 5432,
#     dataset_ids = c(99013, 99021) # change to vector of datasets wanted
#   )



# ------------------------
# data set specific steps

# create a list of entities

tables_99021 <- create_entity_all(meta_list =  metadata,
                                  file_dir = getwd(),
                                  dataset_id = 99021)

# create EML list object
EML_99021 <-
  create_EML(
    meta_list = metadata,
    entity_list = tables_99021,
    dataset_id = 99021
  )

# validate and serialize (write) EML document
EML::eml_validate(EML_99021)
EML::write_eml(EML_99021, file = "EML_99021.xml")