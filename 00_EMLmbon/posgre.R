
posgrefun<- function(dbname,host,port,user,password) {

 library(RPostgreSQL)
 # loads the PostgreSQL driver
  
 drv <- dbDriver("PostgreSQL")
 # creates a connection to the postgres database
 # note that "con" will be used later in each connection to the database

 con <- dbConnect(drv, dbname = dbname,
                 host = host, port = 5432,
                 user = user, password = password)

 # check for the tables
 
 meta<-dbReadTable(con, c("mb2eml_r","vw_eml_attributes")) 
 fact<-dbReadTable(con,c("mb2eml_r","vw_eml_attributecodedefinition"))
 unit<-dbReadTable(con, c("mb2eml_r","vw_custom_units")) 
 creator<-dbReadTable(con, c("mb2eml_r","vw_eml_creator"))
 keyword<-dbReadTable(con, c("mb2eml_r","vw_eml_keyword"))
 entities<-dbReadTable(con, c("mb2eml_r","vw_eml_entities"))
 dataset<-dbReadTable(con, c("mb2eml_r","vw_eml_dataset"))
 method<-dbReadTable(con, c("mb2eml_r","vw_eml_datasetmethod"))
 geo<-dbReadTable(con, c("mb2eml_r","vw_eml_geographiccoverage"))
 tempo<-dbReadTable(con, c("mb2eml_r","vw_eml_temporalcoverage"))
 
 dbDisconnect(con)

 return (list(meta=meta,fact=fact,unit=unit,creator=creator,keyword=keyword,entities=entities,dataset=dataset,method=method,geo=geo,tempo=tempo))

}
