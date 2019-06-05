Use sample database dump to test drive `MetaEgress`
===================================================

Last updated: 05 June, 2019

About this sample database
--------------------------

This sample instance of LTER-core-metabase is a copy of the production
database at [BLE-LTER](https://ble.lternet.edu). The backup is made
without any access or GRANT statements, and does not specify ownership
to any user/group role. As a test database, security is not a priority.
The user you use to create the new database will effectively become the
owner; use these credentials for `MetaEgress` later on.

Download database backup script
-------------------------------

[Download here.](sample_metabase_dump.sql)

The backup is in plain text .sql format. You might wish to inspect it in
a text editor.

Create new database and restore schema + data
---------------------------------------------

This sample code is meant to be run in psql, a Postgres command-line
interface on Windows. You can adapt it to run in a SQL client (right
word?) of your choice. Make sure to note the user you use to log in
initially and to create the new database. As the backup does not assume
any ownership or access statements, the user you use for these tasks
will effectively become the owner to the database. You will also need
credentials for this user later on to use `MetaEgress` to connect to the
database and query metadata from it.

    psql CREATE DATABASE metabase;      -- create new empty database called "metabase"

    psql \c metabase;                   -- switch to the new database

    psql \i <path to plain-text backup> -- execute backup script on new database
