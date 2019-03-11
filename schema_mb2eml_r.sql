--
-- PostgreSQL database dump
--

-- Dumped from database version 9.2.24
-- Dumped by pg_dump version 10.1

-- Started on 2018-08-10 13:19:49

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 8 (class 2615 OID 116479)
-- Name: mb2eml_r; Type: SCHEMA; Schema: -; Owner: mob
--

CREATE SCHEMA mb2eml_r;

--
-- TOC entry 2940 (class 0 OID 0)
-- Dependencies: 8
-- Name: SCHEMA mb2eml_r; Type: COMMENT; Schema: -; Owner: mob
--

COMMENT ON SCHEMA mb2eml_r IS 'Schema holds views for converting metabase content to EML via R';


SET search_path = mb2eml_r, pg_catalog;

--
-- TOC entry 201 (class 1259 OID 121036)
-- Name: vw_custom_units; Type: VIEW; Schema: mb2eml_r; Owner: likui
--

CREATE VIEW vw_custom_units AS
SELECT v."DataSetID" AS datasetid, v."Unit" AS id, u."unitType", u.abbreviation, u."multiplierToSI", u."parentSI", u."constantToSI", u.description FROM (mini_metabase."DataSetAttributes" v JOIN mini_metabase."EMLUnitDictionary" u ON (((v."Unit")::text = (u.name)::text))) GROUP BY v."DataSetID", v."Unit", u."unitType", u.abbreviation, u."multiplierToSI", u."parentSI", u."constantToSI", u.description ORDER BY v."DataSetID";

--
-- TOC entry 197 (class 1259 OID 120440)
-- Name: vw_eml_attributecodedefinition; Type: VIEW; Schema: mb2eml_r; Owner: likui
--

CREATE VIEW vw_eml_attributecodedefinition AS
SELECT d."DataSetID" AS datasetid, d."EntitySortOrder" AS entity_position, d."ColumnName" AS "attributeName", d.code, d.definition FROM mini_metabase."EMLAttributeCodeDefinition" d ORDER BY d."DataSetID", d."EntitySortOrder";

--
-- TOC entry 211 (class 1259 OID 122012)
-- Name: vw_eml_attributes; Type: VIEW; Schema: mb2eml_r; Owner: likui
--

CREATE VIEW vw_eml_attributes AS
SELECT d."DataSetID" AS datasetid, d."EntitySortOrder" AS entity_position, d."ColumnName" AS "attributeName", d."AttributeLabel" AS "attributeLabel", d."Description" AS "attributeDefinition", CASE WHEN ((d."MeasurementScaleDomainID")::text ~~ 'nominal%'::text) THEN 'nominal'::character varying WHEN ((d."MeasurementScaleDomainID")::text ~~ 'ordinal%'::text) THEN 'ordinal'::character varying ELSE d."MeasurementScaleDomainID" END AS "measurementScale", CASE WHEN ((d."MeasurementScaleDomainID")::text ~~ '%Enum'::text) THEN 'enumeratedDomain'::text WHEN ((d."MeasurementScaleDomainID")::text ~~ '%Text'::text) THEN 'textDomain'::text WHEN ((d."MeasurementScaleDomainID")::text = ANY (ARRAY['ratio'::text, 'interval'::text])) THEN 'numericDomain'::text WHEN ((d."MeasurementScaleDomainID")::text = 'dateTime'::text) THEN 'dateTimeDomain'::text ELSE NULL::text END AS domain, d."StorageType" AS "storageType", d."FormatString" AS "formatString", d."PrecisionDateTime" AS "dateTimePrecision", d."TextPatternDefinition" AS definition, d."Unit" AS unit, d."PrecisionNumeric" AS "precision", d."NumberType" AS "numberType", d."MissingValueCode" AS "missingValueCode", d."missingValueCodeExplanation" FROM mini_metabase."DataSetAttributes" d ORDER BY d."DataSetID", d."EntitySortOrder", d."ColumnPosition";

--
-- TOC entry 190 (class 1259 OID 117682)
-- Name: vw_eml_creator; Type: VIEW; Schema: mb2eml_r; Owner: likui
--

CREATE VIEW vw_eml_creator AS
SELECT d."DataSetID" AS datasetid, d."AuthorshipOrder" AS authorshiporder, d."AuthorshipRole" AS authorshiprole, d."NameID" AS nameid, (p."GivenName")::text AS givenname, p."MiddleName" AS givenname2, p."SurName" AS surname, p."Organization" AS organization, p."Address1" AS address1, p."Address2" AS address2, p."Address3" AS address3, p."City" AS city, p."State" AS state, p."Country" AS country, p."ZipCode" AS zipcode, p."Phone1" AS phone1, p."Phone2" AS phone2, p."FAX" AS fax, p."Email" AS email, i."Identificationlink" AS orcid FROM ((mini_metabase."DataSetPersonnel" d LEFT JOIN mini_metabase."People" p ON (((d."NameID")::text = (p."NameID")::text))) LEFT JOIN mini_metabase."Peopleidentification" i ON (((d."NameID")::text = (i."NameID")::text))) WHERE (((d."AuthorshipRole")::text = 'creator'::text) OR ((d."AuthorshipRole")::text = 'organization'::text)) ORDER BY d."DataSetID", d."AuthorshipOrder";

--
-- TOC entry 208 (class 1259 OID 121989)
-- Name: vw_eml_dataset; Type: VIEW; Schema: mb2eml_r; Owner: likui
--

CREATE VIEW vw_eml_dataset AS
SELECT d."DataSetID" AS datasetid, k.dataset_archive_id AS alternatedid, pg_catalog.concat(k.dataset_archive_id, '.', k.rev) AS edinum, d."Title" AS title, d."Abstract" AS abstract, k.data_receipt_date AS projdate, k.update_date_catalog AS pubdate, k.nickname AS shortname FROM (mini_metabase."DataSet" d LEFT JOIN pkg_mgmt.pkg_state k ON ((d."DataSetID" = k."DataSetID"))) ORDER BY d."DataSetID";

--
-- TOC entry 199 (class 1259 OID 120505)
-- Name: vw_eml_datasetmethod; Type: VIEW; Schema: mb2eml_r; Owner: likui
--

CREATE VIEW vw_eml_datasetmethod AS
SELECT d."DataSetID" AS datasetid, d."effectiveRange", d."EntitySortOrder" AS entity_position, d."methodDocument", d."samplingStudyExtent", d."samplingUnits", d."samplingDescription", d."protocolTitle", d."protocolOwner", d."protocolDescription", d."instrumentTitle", d."instrumentOwner", d."instrumentDescription", d."softwareTitle", d."softwareDescription", d."softwareVersion", d."softwareOwner" FROM mini_metabase."DataSetMethods" d ORDER BY d."DataSetID";

--
-- TOC entry 205 (class 1259 OID 121948)
-- Name: vw_eml_entities; Type: VIEW; Schema: mb2eml_r; Owner: likui
--

CREATE VIEW vw_eml_entities AS
SELECT e."DataSetID" AS datasetid, e."SortOrder" AS entity_position, e."EntityType" AS entitytype, e."EntityName" AS entityname, e."EntityDescription" AS entitydescription, pg_catalog.concat(e."Urlhead", e."Subpath") AS urlpath, (e."FileName")::text AS filename, k."FileFormat" AS fileformat, k."EML_FormatType" AS formattype, k."RecordDelimiter" AS recorddelimiter, k."NumHeaderLines" AS headerlines, k."NumFooterLines" AS footerlines, k."FieldDelimiter" AS fielddlimiter, k."externallyDefinedFormat_formatName" AS formatname, k."QuoteCharacter" AS quotecharacter FROM ((mini_metabase."DataSetEntities" e LEFT JOIN mini_metabase."FileTypeList" k ON (((e."Filetype")::text = (k."FileType")::text))) LEFT JOIN pkg_mgmt.pkg_state p ON (((e."DataSetID")::text = (p."DataSetID")::text))) ORDER BY e."DataSetID", e."SortOrder";

--
-- TOC entry 210 (class 1259 OID 122008)
-- Name: vw_eml_geographiccoverage; Type: VIEW; Schema: mb2eml_r; Owner: likui
--

CREATE VIEW vw_eml_geographiccoverage AS
SELECT d."DataSetID" AS datasetid, d."EntitySortOrder" AS entity_position, d."GeoCoverageSortOrder" AS geocoverage_sort_order, d."SiteDesc" AS geographicdescription, d."NBoundLat" AS northboundingcoordinate, d."SBoundLat" AS southboundingcoordinate, d."EBoundLon" AS eastboundingcoordinate, d."WBoundLon" AS westboundingcoordinate, d."AltitudeMin" AS altitudeminimum, d."AltitudeMax" AS altitudemaximum, d.unit AS altitudeunits FROM mini_metabase."DataSetSites" d ORDER BY d."DataSetID", d."EntitySortOrder", d."GeoCoverageSortOrder";

--
-- TOC entry 195 (class 1259 OID 119212)
-- Name: vw_eml_keyword; Type: VIEW; Schema: mb2eml_r; Owner: likui
--

CREATE VIEW vw_eml_keyword AS
SELECT d."DataSetID" AS datasetid, t."ThesaurusSortOrder" AS thesaurus_sort_order, d."Keyword" AS keyword, COALESCE(t."ThesaurusLabel", 'none'::character varying) AS keyword_thesaurus, k."KeywordType" AS keywordtype FROM ((mini_metabase."DataSetKeywords" d LEFT JOIN mini_metabase."Keywords" k ON (((d."Keyword")::text = (k."Keyword")::text))) JOIN mini_metabase."KeywordThesaurus" t ON (((k."ThesaurusID")::text = (t."ThesaurusID")::text))) GROUP BY d."DataSetID", t."ThesaurusSortOrder", d."Keyword", t."ThesaurusLabel", k."KeywordType" ORDER BY d."DataSetID", t."ThesaurusSortOrder", d."Keyword";

--
-- TOC entry 209 (class 1259 OID 121998)
-- Name: vw_eml_temporalcoverage; Type: VIEW; Schema: mb2eml_r; Owner: likui
--

CREATE VIEW vw_eml_temporalcoverage AS
SELECT "DataSetTemporal"."DataSetID" AS datasetid, "DataSetTemporal"."EntitySortOrder" AS entity_position, CASE "DataSetTemporal"."UseOnlyYear" WHEN true THEN to_char(("DataSetTemporal"."BeginDate")::timestamp with time zone, 'YYYY'::text) ELSE to_char(("DataSetTemporal"."BeginDate")::timestamp with time zone, 'YYYY-MM-DD'::text) END AS begindate, CASE "DataSetTemporal"."UseOnlyYear" WHEN true THEN to_char(("DataSetTemporal"."EndDate")::timestamp with time zone, 'YYYY'::text) ELSE to_char(("DataSetTemporal"."EndDate")::timestamp with time zone, 'YYYY-MM-DD'::text) END AS enddate FROM mini_metabase."DataSetTemporal" ORDER BY "DataSetTemporal"."DataSetID", "DataSetTemporal"."EntitySortOrder";


