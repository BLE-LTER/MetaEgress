# metabase-to-eml-R
March 20th 2019

### Orientation
This is a R package-in-progress and example workflow to create EML (ecological metadata language) standard metadata from an installed and populated LTER-core-metabase. For instructions and scripts on core-metabase see https://github.com/lter/LTER-core-metabase. 

This depends on EML R package >1.99.0 from https://github.com/ropensci/EML (CRAN), and RPostgres >1.1.1 to import from metabase.

### Installation

```
devtools::install_github("atn38/metabase2eml")
```

### Usage
See example/project_99013.R for example.