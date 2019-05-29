# MetaEgress
May 17th 2019

### Orientation
`MetaEgress` is a R package to create Ecological Metadata Language (EML) standard metadata documents from an installed and populated LTER-core-metabase. LTER-core-metabase is a metadata database design for management of ecological research metadata, created by the Long Term Ecological Research (LTER) Network and oriented towards production of EML documents at LTER sites. For information on LTER-core-metabase see https://github.com/lter/LTER-core-metabase. The two projects are tightly coupled: make sure to keep both up to date. `MetaEgress` is a play on "Postgres", or "post-Ingres", where Ingres is PostgreSQL's predecessor.

`MetaEgress` contains three main functions to first query metadata LTER-core-metabase, then insert information into appropriate EML slots, then finally ouput a R list structured according to the EML standard. To validate and serialize or write to .xml file, use the functions `eml_validate and `write_eml` available from the `EML` R package on `MetaEgress` output. 

### Features

- Quick and easy workflow to create and update EML documents
- Good for multiple datasets under a project
- Support for multiple missing value codes per attribute

### Installation

Execute this line in R console to install `MetaEgress`. Note that `MetaEgress` depends on the `EML` R package >= 1.99.0 from https://github.com/ropensci/EML or 2.0.0 CRAN, and `RPostgres` >= 1.1.1.

```
devtools::install_github("atn38/MetaEgress")
```

### Usage
See `example/example_workflow.R` for example workflow, from LTER-core-metabase input to EML document (.xml file) final ouput. Note that the example code cannot be run as-is. To try `MetaEgress` functionality without an installed and populated instance of LTER-core-metabase, use one of the database dumps in `db_backups`.

### Useful links
