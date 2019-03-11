--
-- PostgreSQL database dump
--

-- Dumped from database version 9.2.24
-- Dumped by pg_dump version 10.1

-- Started on 2018-08-09 16:48:07

--
-- TOC entry 9 (class 2615 OID 116395)
--

CREATE SCHEMA mini_metabase;

--
-- TOC entry 3076 (class 0 OID 0)
-- Dependencies: 9
--

COMMENT ON SCHEMA mini_metabase IS 'Schema holds portions of metabase, as needed by SBC MBON.';


SET search_path = mini_metabase, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 200 (class 1259 OID 120985)
-- Name: DataSetAttributes; Type: TABLE; Schema: mini_metabase; Owner: likui
--

CREATE TABLE "DataSetAttributes" (
    "DataSetID" integer NOT NULL,
    "EntitySortOrder" integer NOT NULL,
    "ColumnPosition" smallint NOT NULL,
    "ColumnName" character varying(200) NOT NULL,
    "AttributeLabel" character varying(200) NOT NULL,
    "Description" character varying(2000) DEFAULT 'none'::character varying,
    "StorageType" character varying(30),
    "MeasurementScaleDomainID" character varying(12),
    "FormatString" character varying(40),
    "PrecisionDateTime" character varying(40),
    "TextPatternDefinition" character varying(500),
    "Unit" character varying(100),
    "PrecisionNumeric" double precision,
    "NumberType" character varying(30),
    "MissingValueCode" character varying(30),
    "missingValueCodeExplanation" character varying(200),
    CONSTRAINT "DataSetAttributes_CK_FormatString" CHECK (((("FormatString" IS NULL) AND (("MeasurementScaleDomainID")::text !~~ 'dateTime'::text)) OR (("FormatString" IS NOT NULL) AND (("MeasurementScaleDomainID")::text ~~ 'dateTime'::text)))),
    CONSTRAINT "DataSetAttributes_CK_NumberType" CHECK (((("NumberType" IS NULL) AND (("MeasurementScaleDomainID")::text <> ALL (ARRAY['ratio'::text, 'interval'::text]))) OR (("NumberType" IS NOT NULL) AND (("MeasurementScaleDomainID")::text = ANY (ARRAY['ratio'::text, 'interval'::text]))))),
    CONSTRAINT "DataSetAttributes_CK_PrecisionDateTime" CHECK (((("PrecisionDateTime" IS NULL) AND (("MeasurementScaleDomainID")::text !~~ 'dateTime'::text)) OR (("PrecisionDateTime" IS NOT NULL) AND (("MeasurementScaleDomainID")::text ~~ 'dateTime'::text)))),
    CONSTRAINT "DataSetAttributes_CK_PrecisionNumeric" CHECK (((("PrecisionNumeric" IS NULL) AND (("MeasurementScaleDomainID")::text <> ALL (ARRAY['ratio'::text, 'interval'::text]))) OR (("MeasurementScaleDomainID")::text = ANY (ARRAY['ratio'::text, 'interval'::text])))),
    CONSTRAINT "DataSetAttributes_CK_TextPatternDefinition" CHECK (((("TextPatternDefinition" IS NULL) AND (("MeasurementScaleDomainID")::text !~~ '%Text'::text)) OR (("TextPatternDefinition" IS NOT NULL) AND (("MeasurementScaleDomainID")::text ~~ '%Text'::text)))),
    CONSTRAINT "DataSetAttributes_CK_unit" CHECK (((("Unit" IS NULL) AND (("MeasurementScaleDomainID")::text <> ALL (ARRAY['ratio'::text, 'interval'::text]))) OR (("Unit" IS NOT NULL) AND (("MeasurementScaleDomainID")::text = ANY (ARRAY['ratio'::text, 'interval'::text])))))
);



--
-- TOC entry 174 (class 1259 OID 116409)
--

CREATE TABLE "EMLUnitDictionary" (
    id character varying(100) NOT NULL,
    name character varying(100) NOT NULL,
    custom boolean DEFAULT false NOT NULL,
    "unitType" character varying(50),
    abbreviation character varying(50),
    "multiplierToSI" character varying(50),
    "parentSI" character varying(50),
    "constantToSI" character varying(50),
    description character varying(1000)
);


--
-- TOC entry 196 (class 1259 OID 120427)

--

CREATE TABLE "EMLAttributeCodeDefinition" (
    "DataSetID" integer NOT NULL,
    "EntitySortOrder" integer NOT NULL,
    "ColumnName" character varying(200) NOT NULL,
    code character varying(200) NOT NULL,
    definition character varying(200) NOT NULL
);



--
-- TOC entry 187 (class 1259 OID 117568)
--

CREATE TABLE "DataSetPersonnel" (
    "DataSetID" integer NOT NULL,
    "NameID" character varying(20) NOT NULL,
    "AuthorshipOrder" smallint NOT NULL,
    "AuthorshipRole" character varying(100)
);



--
-- TOC entry 185 (class 1259 OID 117450)
--

CREATE TABLE "People" (
    "NameID" character varying(20) NOT NULL,
    "Honorific" character varying(10),
    "GivenName" character varying(30) NOT NULL,
    "MiddleName" character varying(30),
    "SurName" character varying(50) NOT NULL,
    "Suffix" character varying(10),
    "FriendlyName" character varying(50),
    "Organization" character varying(50),
    "Address1" character varying(100),
    "Address2" character varying(100),
    "Address3" character varying(100),
    "City" character varying(30),
    "State" character varying(20),
    "Country" character varying(30),
    "ZipCode" character varying(20),
    "Email" character varying(50),
    "WebPage" character varying(100),
    "Phone1" character varying(50),
    "Phone2" character varying(50),
    "FAX" character varying(50),
    "ServerLogin" character varying(50),
    "GenderCode" character(1),
    "EthnicityCode" character varying(20),
    "RaceCode" character varying(20),
    "CitizenCode" character varying(20),
    "DisabilityCode" character varying(20) DEFAULT 'None'::character varying,
    primary_site character(3),
    dbupdatetime timestamp without time zone
);


--
-- TOC entry 3082 (class 0 OID 0)
-- Dependencies: 185

--

COMMENT ON COLUMN "People"."GenderCode" IS 'Not used';


--
-- TOC entry 3083 (class 0 OID 0)
-- Dependencies: 185

--

COMMENT ON COLUMN "People"."EthnicityCode" IS 'Not used';


--
-- TOC entry 3084 (class 0 OID 0)
-- Dependencies: 185

--

COMMENT ON COLUMN "People"."RaceCode" IS 'Not used';


--
-- TOC entry 3085 (class 0 OID 0)
-- Dependencies: 185

--

COMMENT ON COLUMN "People"."CitizenCode" IS 'Not used';


--
-- TOC entry 3086 (class 0 OID 0)
-- Dependencies: 185

--

COMMENT ON COLUMN "People"."DisabilityCode" IS 'Not used';


--
-- TOC entry 3087 (class 0 OID 0)
-- Dependencies: 185
--

COMMENT ON COLUMN "People".primary_site IS 'Not used';


--
-- TOC entry 189 (class 1259 OID 117665)
--

CREATE TABLE "Peopleidentification" (
    "NameID" character varying(20) NOT NULL,
    "IdentificationID" smallint NOT NULL,
    "Identificationtype" character varying(30),
    "Identificationlink" character varying(200)
);



--
-- TOC entry 186 (class 1259 OID 117548)
--

CREATE TABLE "DataSet" (
    "DataSetID" integer NOT NULL,
    "Title" character varying(300) NOT NULL,
    "Investigator" character varying(20) NOT NULL,
    "SubmitDate" timestamp without time zone DEFAULT now(),
    "Abstract" character varying(5000) NOT NULL
);



--
-- TOC entry 198 (class 1259 OID 120474)
--

CREATE TABLE "DataSetMethods" (
    "DataSetID" integer NOT NULL,
    "effectiveRange" character varying(20) NOT NULL,
    "EntitySortOrder" integer,
    "methodDocument" character varying(100) NOT NULL,
    "samplingStudyExtent" character varying(200),
    "samplingUnits" character varying(200),
    "samplingDescription" character varying(1000),
    "protocolTitle" character varying(200),
    "protocolOwner" character varying(20),
    "protocolDescription" character varying(1000),
    "instrumentTitle" character varying(200),
    "instrumentOwner" character varying(20),
    "instrumentDescription" character varying(1000),
    "softwareTitle" character varying(200),
    "softwareDescription" character varying(1000),
    "softwareVersion" character varying(10),
    "softwareOwner" character varying(20)
);


--
-- TOC entry 188 (class 1259 OID 117633)
--

CREATE TABLE "DataSetEntities" (
    "DataSetID" integer NOT NULL,
    "EntityName" character varying(100) NOT NULL,
    "EntityType" character varying(50) NOT NULL,
    "EntityDescription" character varying(1000) NOT NULL,
    "EntityRecords" integer,
    "SortOrder" integer,
    "Filetype" character varying(10),
    "Subpath" character varying(1024),
    "Urlhead" character varying(1024),
    "FileName" character varying(100)
);


--
-- TOC entry 204 (class 1259 OID 121933)
--

CREATE TABLE "FileTypeList" (
    "FileType" character varying(10) NOT NULL,
    "TypeName" character varying(50) NOT NULL,
    "FileFormat" character varying(80) NOT NULL,
    "Extension" character varying(10) NOT NULL,
    "Description" character varying(255) NOT NULL,
    "Delimiters" character varying(50) NOT NULL,
    "Header" character varying(300) NOT NULL,
    "EML_FormatType" character varying(50),
    "RecordDelimiter" character varying(10),
    "NumHeaderLines" smallint,
    "NumFooterLines" smallint,
    "AttributeOrientation" character varying(20) DEFAULT 'column'::character varying,
    "QuoteCharacter" character(1),
    "FieldDelimiter" character varying(10),
    "CharacterEncoding" character varying(20),
    "CollapseDelimiters" character varying(3),
    "LiteralCharacter" character varying(4),
    "externallyDefinedFormat_formatName" character varying(200),
    "externallyDefinedFormat_formatVersion" character varying(200),
    CONSTRAINT "CK_FileTypeList_CollapseDelimiters" CHECK (((("CollapseDelimiters")::text = ANY (ARRAY[('yes'::character varying)::text, ('no'::character varying)::text])) OR ("CollapseDelimiters" IS NULL)))
);


--
-- TOC entry 207 (class 1259 OID 121968)
--

CREATE TABLE "DataSetSites" (
    "DataSetID" integer NOT NULL,
    "EntitySortOrder" integer NOT NULL,
    "GeoCoverageSortOrder" integer DEFAULT 1 NOT NULL,
    "SiteLocation" character varying(100) DEFAULT 'California, USA'::character varying NOT NULL,
    "SiteDesc" character varying(1000),
    "ShapeType" character varying(20),
    "WBoundLon" character varying(100),
    "EBoundLon" character varying(100),
    "SBoundLat" character varying(100),
    "NBoundLat" character varying(100),
    "AltitudeMin" character varying(100),
    "AltitudeMax" character varying(100),
    unit character varying(10),
    CONSTRAINT "CK_DataSetSites_ShapeType" CHECK ((("ShapeType")::text = ANY (ARRAY[('point'::character varying)::text, ('rectangle'::character varying)::text, ('polygon'::character varying)::text, ('polyline'::character varying)::text, ('vector'::character varying)::text])))
);


--
-- TOC entry 194 (class 1259 OID 119178)
--

CREATE TABLE "DataSetKeywords" (
    "DataSetID" integer NOT NULL,
    "Keyword" character varying(100) NOT NULL,
    "ThesaurusID" character varying(1024) DEFAULT 'foo'::character varying NOT NULL
);


--
-- TOC entry 192 (class 1259 OID 119118)
--

CREATE TABLE "KeywordThesaurus" (
    "ThesaurusID" character varying(50) NOT NULL,
    "ThesaurusLabel" character varying(250),
    "ThesaurusUrl" character varying(250),
    "UseInMetadata" boolean DEFAULT true NOT NULL,
    "ThesaurusSortOrder" integer
);



--
-- TOC entry 193 (class 1259 OID 119162)
--

CREATE TABLE "Keywords" (
    "Keyword" character varying(50) NOT NULL,
    "ThesaurusID" character varying(50) NOT NULL,
    "KeywordType" character varying(20) DEFAULT 'theme'::character varying NOT NULL
);


--
-- TOC entry 206 (class 1259 OID 121958)
--

CREATE TABLE "DataSetTemporal" (
    "DataSetID" integer NOT NULL,
    "EntitySortOrder" integer NOT NULL,
    "BeginDate" date NOT NULL,
    "EndDate" date NOT NULL,
    "UseOnlyYear" boolean
);


--
-- TOC entry 173 (class 1259 OID 116396)
--

CREATE TABLE "EMLAttributeDictionary" (
    "AttributeID" character varying(100) NOT NULL,
    "AttributeName" character varying(200) NOT NULL,
    "AttributeLabel" character varying(200) NOT NULL,
    "Description" character varying(2000) DEFAULT 'none'::character varying,
    "StorageType" character varying(30),
    "MeasurementScaleDomainID" character varying(12),
    "FormatString" character varying(40),
    "PrecisionDateTime" character varying(40),
    "TextPatternDefinition" character varying(500),
    "Unit" character varying(100),
    "PrecisionNumeric" double precision,
    "NumberType" character varying(30),
    CONSTRAINT "EMLAttributeDictionary_CK_FormatString" CHECK (((("FormatString" IS NULL) AND (("MeasurementScaleDomainID")::text !~~ 'dateTime'::text)) OR (("FormatString" IS NOT NULL) AND (("MeasurementScaleDomainID")::text ~~ 'dateTime'::text)))),
    CONSTRAINT "EMLAttributeDictionary_CK_NumberType" CHECK (((("NumberType" IS NULL) AND (("MeasurementScaleDomainID")::text <> ALL (ARRAY['ratio'::text, 'interval'::text]))) OR (("NumberType" IS NOT NULL) AND (("MeasurementScaleDomainID")::text = ANY (ARRAY['ratio'::text, 'interval'::text]))))),
    CONSTRAINT "EMLAttributeDictionary_CK_PrecisionDateTime" CHECK (((("PrecisionDateTime" IS NULL) AND (("MeasurementScaleDomainID")::text !~~ 'dateTime'::text)) OR (("PrecisionDateTime" IS NOT NULL) AND (("MeasurementScaleDomainID")::text ~~ 'dateTime'::text)))),
    CONSTRAINT "EMLAttributeDictionary_CK_PrecisionNumeric" CHECK (((("PrecisionNumeric" IS NULL) AND (("MeasurementScaleDomainID")::text <> ALL (ARRAY['ratio'::text, 'interval'::text]))) OR (("MeasurementScaleDomainID")::text = ANY (ARRAY['ratio'::text, 'interval'::text])))),
    CONSTRAINT "EMLAttributeDictionary_CK_TextPatternDefinition" CHECK (((("TextPatternDefinition" IS NULL) AND (("MeasurementScaleDomainID")::text !~~ '%Text'::text)) OR (("TextPatternDefinition" IS NOT NULL) AND (("MeasurementScaleDomainID")::text ~~ '%Text'::text)))),
    CONSTRAINT "EMLAttributeDictionary_CK_unit" CHECK (((("Unit" IS NULL) AND (("MeasurementScaleDomainID")::text <> ALL (ARRAY['ratio'::text, 'interval'::text]))) OR (("Unit" IS NOT NULL) AND (("MeasurementScaleDomainID")::text = ANY (ARRAY['ratio'::text, 'interval'::text])))))
);


--
-- TOC entry 3096 (class 0 OID 0)
-- Dependencies: 173
--

COMMENT ON CONSTRAINT "EMLAttributeDictionary_CK_FormatString" ON "EMLAttributeDictionary" IS 'null if MeasurementScaleDomainID not dateTime otherwise not null';


--
-- TOC entry 191 (class 1259 OID 118973)
--

CREATE TABLE "EMLKeywordTypeList" (
    "KeywordType" character varying(20) NOT NULL,
    "TypeDefinition" character varying(500)
);


--
-- TOC entry 175 (class 1259 OID 116416)

--

CREATE TABLE "EMLMeasurementScaleList" (
    "measurementScale" character varying(20) NOT NULL
);



--
-- TOC entry 176 (class 1259 OID 116419)

--

CREATE TABLE "EMLNumberTypeList" (
    "NumberType" character varying(30) NOT NULL
);


-- TOC entry 177 (class 1259 OID 116422)

--

CREATE TABLE "EMLStorageTypeList" (
    "StorageType" character varying(30) NOT NULL,
    "typeSystem" character varying(200)
);


--
-- TOC entry 3101 (class 0 OID 0)
-- Dependencies: 177

--

COMMENT ON COLUMN "EMLStorageTypeList"."typeSystem" IS 'include the entire url if it is a url';


--
-- TOC entry 178 (class 1259 OID 116425)

--

CREATE TABLE "EMLUnitTypes" (
    id character varying(50) NOT NULL,
    name character varying(50) NOT NULL,
    dimension_name character varying(50) NOT NULL,
    dimension_power integer
);

--
-- TOC entry 179 (class 1259 OID 116428)

--

CREATE TABLE "MeasurementScaleDomains" (
    "EMLDomainType" character varying(17) NOT NULL,
    "MeasurementScale" character varying(8) NOT NULL,
    "NonNumericDomain" character varying(17),
    "MeasurementScaleDomainID" character varying(12) NOT NULL
);


--
-- TOC entry 3077 (class 0 OID 0)
-- Dependencies: 9
--

REVOKE ALL ON SCHEMA mini_metabase FROM PUBLIC;


--
-- TOC entry 3078 (class 0 OID 0)
-- Dependencies: 200
-- Name: DataSetAttributes; Type: ACL; Schema: mini_metabase; Owner: likui
--

REVOKE ALL ON TABLE "DataSetAttributes" FROM PUBLIC;


--
-- TOC entry 3079 (class 0 OID 0)
-- Dependencies: 174



--
-- TOC entry 3080 (class 0 OID 0)
-- Dependencies: 196
-- Name: EMLAttributeCodeDefinition; Type: ACL; Schema: mini_metabase; Owner: likui
--

REVOKE ALL ON TABLE "EMLAttributeCodeDefinition" FROM PUBLIC;



--
-- TOC entry 3081 (class 0 OID 0)
-- Dependencies: 187

--

REVOKE ALL ON TABLE "DataSetPersonnel" FROM PUBLIC;



--
-- TOC entry 3088 (class 0 OID 0)
-- Dependencies: 185

--

REVOKE ALL ON TABLE "People" FROM PUBLIC;



--
-- TOC entry 3089 (class 0 OID 0)
-- Dependencies: 189

--

REVOKE ALL ON TABLE "Peopleidentification" FROM PUBLIC;


--
-- TOC entry 3090 (class 0 OID 0)
-- Dependencies: 186

--

REVOKE ALL ON TABLE "DataSet" FROM PUBLIC;


--
-- TOC entry 3091 (class 0 OID 0)
-- Dependencies: 198

--

REVOKE ALL ON TABLE "DataSetMethods" FROM PUBLIC;



--
-- TOC entry 3092 (class 0 OID 0)
-- Dependencies: 188

--

REVOKE ALL ON TABLE "DataSetEntities" FROM PUBLIC;


--
-- TOC entry 3093 (class 0 OID 0)
-- Dependencies: 194

--

REVOKE ALL ON TABLE "DataSetKeywords" FROM PUBLIC;



--
-- TOC entry 3094 (class 0 OID 0)
-- Dependencies: 192

--

REVOKE ALL ON TABLE "KeywordThesaurus" FROM PUBLIC;



--
-- TOC entry 3095 (class 0 OID 0)
-- Dependencies: 193

--

REVOKE ALL ON TABLE "Keywords" FROM PUBLIC;


--
-- TOC entry 3097 (class 0 OID 0)
-- Dependencies: 173
--

REVOKE ALL ON TABLE "EMLAttributeDictionary" FROM PUBLIC;


--
-- TOC entry 3098 (class 0 OID 0)
-- Dependencies: 191
--

REVOKE ALL ON TABLE "EMLKeywordTypeList" FROM PUBLIC;


--
-- TOC entry 3099 (class 0 OID 0)
-- Dependencies: 175
--

REVOKE ALL ON TABLE "EMLMeasurementScaleList" FROM PUBLIC;

--
-- TOC entry 3100 (class 0 OID 0)
-- Dependencies: 176

--

REVOKE ALL ON TABLE "EMLNumberTypeList" FROM PUBLIC;


--
-- TOC entry 3102 (class 0 OID 0)
-- Dependencies: 177

--

REVOKE ALL ON TABLE "EMLStorageTypeList" FROM PUBLIC;



--
-- TOC entry 3103 (class 0 OID 0)
-- Dependencies: 178

--

REVOKE ALL ON TABLE "EMLUnitTypes" FROM PUBLIC;



--
-- TOC entry 3104 (class 0 OID 0)
-- Dependencies: 179

--

REVOKE ALL ON TABLE "MeasurementScaleDomains" FROM PUBLIC;

-- Completed on 2018-08-09 16:48:08

--
-- PostgreSQL database dump complete
--

