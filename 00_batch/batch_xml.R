# batch for all the XML generated file

library(EML)
library(rmarkdown)
library(RPostgreSQL)
library(dplyr)
library(data.table)
library(tools)
library(methods)
library(xlsx)

# loading all the packages
source("00_EMLmbon/posgre.r")
source("00_EMLmbon/datatable.r")
source("00_EMLmbon/dataset.r")

source("00_batch/user_info.r")

# input postgreSQL database. change dbname to your DB.
posgre <- posgrefun(
  dbname = "lter_arranged",
  host = host,
  user = user,
  password = password
)

# extract information from result of above function
meta <- posgre$meta
fact <- posgre$fact
unit <- posgre$unit
creator <- posgre$creator
keyword <- posgre$keyword
entities <- posgre$entities
dataset <- posgre$dataset
method <- posgre$method
geo <- posgre$geo
tempo <- posgre$tempo
