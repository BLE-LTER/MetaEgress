# rMetabase2eml
March 28th 2019

### Orientation
This is a R package-in-progress and example workflow to create EML (ecological metadata language) standard metadata documents from an installed and populated LTER-core-metabase. For information on core-metabase see https://github.com/lter/LTER-core-metabase. The predecessor and crucial template to this is work by Li Kui at https://github.com/lkuiucsb/EML_R.

From the metabase, a series of views or "abstraction layer" are extracted into R objects. Wrapper functions included here then take information in these objects and insert into appropriate EML slots. The final product is a ready-to-write R list object with named list items corresponding to EML document tags. Validation and serialization (writing to .xml file) can rely on existing functions eml_validate() and write_eml() respectively from the EML R package. 

### Installation

This depends on the EML R package >= 1.99.0 from https://github.com/ropensci/EML (CRAN has 1.0.3), and RPostgres >= 1.1.1.

NOTE: In-console installation as below does not work as of this document date. Please download R scripts and source them before use. 

```
devtools::install_github("atn38/rMetabase2eml")
```

### Usage
See example/example_workflow.R for example.