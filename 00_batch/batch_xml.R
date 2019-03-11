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

# input postgreSQL table
posgre <- posgrefun(
  dbname = "li_tim_dump",
  host = host,
  user = user,
  password = password
)

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
