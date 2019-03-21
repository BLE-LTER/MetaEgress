# example workflow from metabase to EML document
library(EML)
library(RPostgres)

# -----------------------
# connect to metabase and get metadata from specified datasets
entity_meta <- get_meta(dbname = "lter_arranged", host = "localhost", port = 5432, c(99013, 99021))

# set workding directory to path of current script
# as it stands, data files + abstract + methods should probably be in this folder
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# read in boilerplate information and license document
boilerplate <- EML::read_eml("./00_Shared_document/boilerplate.xml")
license <- EML::set_TextType("./00_Shared_document/IntellectualRights.docx")

# -----------------------
# single entity example, datasetid 99013

# create an entity
table_99013 <- create_entity(entity_meta, dataset_id = 99013, entity = 1)
# create EML list object
# outputs write_eml()-ready object
EML_99013 <- create_EML(entity_meta, dataset_id = 99013, boilerplate = boilerplate, license = license, data_table = table_99013)
write_eml(EML_99013, file = "EML_99013.xml")

# ------------------------
# multiple entities example, datasetid 99021

# use lapply() to loop through multiple entity ids
# exclude entities here if wanted
# probably best to loop through data tables and other entities separately
# outputs list of entities
tables_99021 <- lapply(c(1, 2, 3), create_entity, meta_list = entity_meta, dataset_id = 99021)

# create EML list object
EML_99021 <- create_EML(entity_meta, dataset_id = 99021, boilerplate = boilerplate, license = license, data_table = tables_99021)

# validate and serialize (write) EML document
eml_validate(EML_99021)

# which returns
# [1] FALSE
# attr(,"errors")
# [1] "Element 'abstract': This element is not expected. Expected is one of ( references, alternateIdentifier, shortName, title )."

write_eml(EML_99021, file = "EML_99021.xml")
