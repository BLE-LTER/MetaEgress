How to use `MetaEgress` to generate EML document from LTER-core-metabase
========================================================================

Last updated: 05 June, 2019

This is an example workflow from metabase to EML document. This guide
assumes you have an installed and populated instance of
LTER-core-metabase, plus log-in credentials for an user with at least
read or SELECT access to this database. See the [LTER-core-metabase
Github repository](https://github.com/lter/LTER-core-metabase) for
information on installation and population. If you would like to test
drive `MetaEgress`, use the database dump specifically made for this
purpose; see [this document](use_dump.md).

Outline
-------

-   [Preparation](#preparation)
-   [Set up in R](#set-up-in-r)
-   [Connect and query from
    LTER-core-metabase](#connect-and-query-from-lter-core-metabase)
-   [Create entities](#create-entities)
-   [Create EML](#create-eml)
-   [Validate and write to file](#validate-and-write-to-file)
-   [Troubleshoot invalid EML](#troubleshoot-invalid-eml)

Preparation
-----------

### Necessary components

(aside from well populated metabase)

-   An abstract document in pandoc-compatible format. The file name
    should be exactly as specified in metabase `DataSet.Abstract`.
-   A method document in pandoc-compatible format. The file name should
    be exactly as specified in metabase `DataSetMethods.methodDocument`.
-   A boilerplate XML file (see [Filling out a boilerplate for your
    project](#filling-out-a-boilerplate-for-your-project)).
-   A license document in pandoc-compatible format.
-   Data files for all listed entities. File names should be exactly as
    listed in metabase `DataSetEntities.FileName`.

**Note on document formats**

`MetaEgress` uses the function `set_TextType` from the EML R package to
wrap documents in XML tags. See `set_TextType` documentation to learn
more about compatible formats: `?EML::set_TextType`.

### Filling out a boilerplate for your project

There are certain EML elements that you might wish to include in an EML
document and that are not represented in LTER-core-metabase. This might
change in the future. However, these are generally general information
about the research project that do not normally change between datasets.
For normal usage at LTER sites, these are trees at the following XPaths:

-   eml/access
-   eml/dataset/distribution
-   eml/dataset/publisher
-   eml/dataset/contact
-   eml/dataset/project

Fill out these trees as applicable to your LTER site or project. Refer
to the [EML best practices
v3](https://environmentaldatainitiative.files.wordpress.com/2017/11/emlbestpractices-v3.pdf)
document. Save the XML file in your project folder (see below).

**NOTE:** `MetaEgress` will not read in other XML tags not contained in
the above trees.

### Set up a local project folder

Put data files and other documents (e.g. abstract, methods, boilerplate,
license) in a folder.

Recommended approach for local files: Create a R script in this folder
and run `MetaEgress` from this script.

For remotely hosted data: TODO

### Remotely hosted data

TODO

Set up in R
-----------

In the project R script:

    # Load MetaEgress into R environment
    library(MetaEgress)

    # Set working directory to current script's directory
    setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

    # Set paths to boilerplate XML file and license document
    boilerplate_path <- normalizePath("./00_Shared_document/boilerplate.xml")
    license_path <- normalizePath("./00_Shared_document/IntellectualRights.docx")

Connect and query from LTER-core-metabase
-----------------------------------------

    # View documentation
    ?get_meta

    # Use function
    metadata <-
      get_meta(
        dbname = "metabase",       # change to your DB name
        schema = "mb2eml_r",       # change to schema containing views
        dataset_ids = 1,           # change to ID or numeric vector of IDs wanted
        host = "localhost",        # change to IP address if remote host
        port = 5432,
        user = NULL,               # change to username and password to save time or if not using RStudio
        password = NULL            # if NULL, RStudio will create pop-up windows asking for username and password
      )

Create entities
---------------

    # View documentation
    ?create_entity_all

    # Use the function
    entities <- create_entity_all(
      meta_list = metadata,   # list returned by `get_meta`
      dataset_id = 1          # a singular dataset ID
    )

**Note** that even if the function runs successfully, many warnings will
likely be generated. Use `warnings()` to see them. Most of the time the
warnings will be about custom units and can safely be ignored.

Create EML
----------

    # View documentation
    ?create_EML

    # Use the function
    EML <-
      create_EML(
        meta_list = metadata,                 # list returned by `get_meta`
        entity_list = entities,               # list returned by `create_entity_all`
        dataset_id = 1,                       # a singular dataset ID
        boilerplate_path = boilerplate_path,  # path to boilerplate XML file
        license_path = license_path           # path to license document
    )

Validate and write to file
--------------------------

First validate EML document using the function `eml_validate` from EML R
package. The input could be an EML list object or output from
`create_entity`, or a XML file.

    EML::eml_validate(EML)

Desired outcome is TRUE:

    [1] TRUE
    attr(,"errors")
    character(0)

Should `eml_validate` return FALSE, examine the list object returned by
`create_EML`. Error messages by `eml_validate` could be quite cryptic
and might not point to the real problem.

Then serialize or write to XML file using the function `write_eml` from
the EML R package.

    EML::write_eml(EML, file = "EML.xml")

Troubleshoot invalid EML
------------------------

TODO
