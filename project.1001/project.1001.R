#rm(list = ls())

#------------------------------------
# read the batch file, which in turn load all the libraries, read in all functions

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

source("00_batch/batch_xml.R")

# --------------------------------------
# generate custom class objects for EML

# set to EXACT datasetid as in DB
datasetid <- 99013

# repeat for all datatables
datatable1 <- datatablefun(
  datasetid = datasetid,
  entity = 1
)

# repeat for all entities of other file types
otherentity1 <- datatablefun(
  datasetid = datasetid,
  entity = 2
)

# ----------------------------------------------
# generate EML
eml <- datasetfun(
  datasetid = datasetid,
  dataTable = datatable1
)

#sblueml_validate(eml)
eml_validate(eml)

write_eml(eml, "XML_99013.xml")
