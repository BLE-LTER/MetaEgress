#rm(list = ls())

#------------------------------------
# read the batch file and load all the libraries

setwd("C:/Users/atn893/Downloads/mini_metabase_three_schema")

source("00_batch/batch_xml.R")

# _----------------------------------
# generate EML
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

datasetid <- 1001

datatable1 <- datatablefun(
  datasetid = datasetid,
  entity = 1
)
otherentity1 <- datatablefun(
  datasetid = datasetid,
  entity = 2
)

#----------------------------------------------
# generate EML
eml <- datasetfun(
  datasetid = datasetid,
  dataTable = datatable1
)

sblueml_validate(eml)


write_eml(eml, "XML_1001.xml")
