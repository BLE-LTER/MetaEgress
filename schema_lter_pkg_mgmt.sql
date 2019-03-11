--
-- PostgreSQL database dump
--

-- Dumped from database version 9.2.24
-- Dumped by pg_dump version 10.1

-- Started on 2018-08-14 15:45:57

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 11 (class 2615 OID 118549)
-- Name: pkg_mgmt; Type: SCHEMA; Schema: -; Owner: likui
--

CREATE SCHEMA pkg_mgmt;


ALTER SCHEMA pkg_mgmt OWNER TO likui;

SET search_path = pkg_mgmt, pg_catalog;

--
-- TOC entry 240 (class 1255 OID 121454)
-- Name: update_modified_column(); Type: FUNCTION; Schema: pkg_mgmt; Owner: likui
--

CREATE FUNCTION update_modified_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.dbupdatetime = now();
    RETURN NEW;	
END;
$$;


ALTER FUNCTION pkg_mgmt.update_modified_column() OWNER TO likui;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 232 (class 1259 OID 123579)
-- Name: pkg_biblio; Type: TABLE; Schema: pkg_mgmt; Owner: likui
--

CREATE TABLE pkg_biblio (
    "DataSetID" integer NOT NULL,
    "Citation" character varying(1000) NOT NULL
);


ALTER TABLE pkg_biblio OWNER TO likui;

--
-- TOC entry 3107 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE pkg_biblio; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON TABLE pkg_biblio IS 'bibliography';


--
-- TOC entry 230 (class 1259 OID 123530)
-- Name: cv_cra; Type: TABLE; Schema: pkg_mgmt; Owner: likui
--

CREATE TABLE cv_cra (
    cra_id character varying(10) NOT NULL,
    cra_name character varying(100) NOT NULL
);


ALTER TABLE cv_cra OWNER TO likui;

--
-- TOC entry 3109 (class 0 OID 0)
-- Dependencies: 230
-- Name: TABLE cv_cra; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON TABLE cv_cra IS 'core study area';


--
-- TOC entry 231 (class 1259 OID 123563)
-- Name: pkg_core_area; Type: TABLE; Schema: pkg_mgmt; Owner: likui
--

CREATE TABLE pkg_core_area (
    "DataSetID" integer NOT NULL,
    "Core_area" character varying(10) NOT NULL
);


ALTER TABLE pkg_core_area OWNER TO likui;

--
-- TOC entry 3111 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE pkg_core_area; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON TABLE pkg_core_area IS 'core study area';


--
-- TOC entry 213 (class 1259 OID 121490)
-- Name: pkg_state; Type: TABLE; Schema: pkg_mgmt; Owner: likui
--

CREATE TABLE pkg_state (
    "DataSetID" integer NOT NULL,
    dataset_archive_id character varying(21),
    rev integer,
    nickname character varying(64),
    data_receipt_date date,
    status character varying(64),
    synth_readiness character varying(15),
    staging_dir character varying(1024),
    eml_draft_path character varying(128),
    notes text,
    pub_notes text,
    who2bug character varying(64),
    dir_internal_final character varying(256),
    dbupdatetime timestamp without time zone,
    update_date_catalog date
);


ALTER TABLE pkg_state OWNER TO likui;

--
-- TOC entry 3113 (class 0 OID 0)
-- Dependencies: 213
-- Name: TABLE pkg_state; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON TABLE pkg_state IS 'aka wordy';


--
-- TOC entry 3114 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN pkg_state.dataset_archive_id; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.dataset_archive_id IS 'ie knb-lter-mcr.1234 or if not assigned a real id yet then what';


--
-- TOC entry 3115 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN pkg_state.rev; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.rev IS 'revision is needed for showDraft. By definition, rev for draft0 is 0. Rev for cataloged make null so latest rev is shown.';


--
-- TOC entry 3116 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN pkg_state.nickname; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.nickname IS 'ie fish_survey or flume or par. This is NOT the eml shortName except perhaps by coincidence.  shortName is stored elsewhere. This is not the staging directory except by coincidence.';


--
-- TOC entry 3117 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN pkg_state.status; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.status IS 'anticipated, draft0, cataloged, backlog or anticipated, draft then back to cataloged';


--
-- TOC entry 3118 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN pkg_state.synth_readiness; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.synth_readiness IS 'One of metadata_only, download, integration, annotated.  These are levels of readiness for synthesis. Each builds on the lower levels.';


--
-- TOC entry 3119 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN pkg_state.staging_dir; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.staging_dir IS 'The subdirectory where the IMs work on data files after receiving in final_dir and prior to posting in external_dir. Root portion of path is a different constant for MCR than SBC.';


--
-- TOC entry 3120 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN pkg_state.eml_draft_path; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.eml_draft_path IS 'For most pkgs this is merely ''mcr/''. For RAPID datasets this is ''mcr/RAPID/''. For drafts split out into a named dir this might be ''mcr/core/optical/EML/''';


--
-- TOC entry 3121 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN pkg_state.notes; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.notes IS 'what needs doing. what the holdup is. issues.';


--
-- TOC entry 3122 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN pkg_state.pub_notes; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.pub_notes IS 'Reason for being in this state, ie why it is metadata-only currently or Type II.  Such as grad student data or pending publication. May apply to status, network_type, synthesis_readiness.';


--
-- TOC entry 3123 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN pkg_state.who2bug; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.who2bug IS 'often not the creator rather the tech or whoever we need to pester';


--
-- TOC entry 3124 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN pkg_state.dir_internal_final; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.dir_internal_final IS 'directory where submitted so-called final data is staged for inspection.  where to look for new data.';


--
-- TOC entry 3125 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN pkg_state.dbupdatetime; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.dbupdatetime IS 'automatically updates itself.';


--
-- TOC entry 3126 (class 0 OID 0)
-- Dependencies: 213
-- Name: COLUMN pkg_state.update_date_catalog; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.update_date_catalog IS 'Date package last updated in catalog (same as pathquery updatedate)';


--
-- TOC entry 219 (class 1259 OID 123407)
-- Name: pkg_sort; Type: TABLE; Schema: pkg_mgmt; Owner: likui
--

CREATE TABLE pkg_sort (
    "DataSetID" integer NOT NULL,
    network_type character varying(3),
    is_signature boolean,
    is_core boolean,
    temporal_type character varying(22),
    spatial_extent character varying(18),
    spatiotemporal character(4),
    is_thesis boolean,
    is_reference boolean,
    is_exogenous boolean,
    spatial_type character varying(32),
    management_type character varying(64) DEFAULT 'non_templated'::character varying,
    edq character varying DEFAULT 'none'::character varying,
    in_pasta boolean,
    dbupdatetime timestamp without time zone
);


ALTER TABLE pkg_sort OWNER TO likui;

--
-- TOC entry 3128 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE pkg_sort; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON TABLE pkg_sort IS 'pkg_state is wordy and pkg_sort is terse. Instead of one really wide table.  Just easier to edit.';


--
-- TOC entry 3129 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN pkg_sort.network_type; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_sort.network_type IS 'Two values have been defined by the LTER network: Type I and Type II
if neither applies, NULL.';


--
-- TOC entry 3130 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN pkg_sort.is_signature; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_sort.is_signature IS 'defined at discretion of site or PI';


--
-- TOC entry 3131 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN pkg_sort.spatial_type; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_sort.spatial_type IS 'choices: multi-site, one site of one, one place of a site series, non-spatial.';


--
-- TOC entry 3132 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN pkg_sort.management_type; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_sort.management_type IS 'template vs non_templated. The way the metadata is generated.';


--
-- TOC entry 3133 (class 0 OID 0)
-- Dependencies: 219
-- Name: COLUMN pkg_sort.in_pasta; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_sort.in_pasta IS 'This package ID is in production pasta. No implications re access restrictions. Merely passing evaluate does not mean in_pasta is true. column synth_readiness is for that property.';


--
-- TOC entry 206 (class 1259 OID 121300)
-- Name: cv_mgmt_type; Type: TABLE; Schema: pkg_mgmt; Owner: likui
--

CREATE TABLE cv_mgmt_type (
    mgmt_type character varying(32) NOT NULL,
    definition character varying(1024)
);


ALTER TABLE cv_mgmt_type OWNER TO likui;

--
-- TOC entry 207 (class 1259 OID 121308)
-- Name: cv_network_type; Type: TABLE; Schema: pkg_mgmt; Owner: likui
--

CREATE TABLE cv_network_type (
    network_type character varying(3) NOT NULL,
    definition character varying(1024)
);


ALTER TABLE cv_network_type OWNER TO likui;

--
-- TOC entry 208 (class 1259 OID 121316)
-- Name: cv_spatial_extent; Type: TABLE; Schema: pkg_mgmt; Owner: likui
--

CREATE TABLE cv_spatial_extent (
    spatial_extent character varying(32) NOT NULL,
    definition character varying(1024)
);


ALTER TABLE cv_spatial_extent OWNER TO likui;

--
-- TOC entry 209 (class 1259 OID 121324)
-- Name: cv_spatial_type; Type: TABLE; Schema: pkg_mgmt; Owner: likui
--

CREATE TABLE cv_spatial_type (
    spatial_type character varying(32) NOT NULL,
    definition character varying(1024)
);


ALTER TABLE cv_spatial_type OWNER TO likui;

--
-- TOC entry 210 (class 1259 OID 121332)
-- Name: cv_spatio_temporal; Type: TABLE; Schema: pkg_mgmt; Owner: likui
--

CREATE TABLE cv_spatio_temporal (
    spatiotemporal character(4) NOT NULL,
    definition character varying(1024)
);


ALTER TABLE cv_spatio_temporal OWNER TO likui;

--
-- TOC entry 211 (class 1259 OID 121340)
-- Name: cv_status; Type: TABLE; Schema: pkg_mgmt; Owner: likui
--

CREATE TABLE cv_status (
    status character varying(20) NOT NULL
);


ALTER TABLE cv_status OWNER TO likui;

--
-- TOC entry 212 (class 1259 OID 121345)
-- Name: cv_temporal_type; Type: TABLE; Schema: pkg_mgmt; Owner: likui
--

CREATE TABLE cv_temporal_type (
    temporal_type character varying(32) NOT NULL,
    definition character varying(1024)
);


ALTER TABLE cv_temporal_type OWNER TO likui;

--
-- TOC entry 221 (class 1259 OID 123472)
-- Name: vw_backlog; Type: VIEW; Schema: pkg_mgmt; Owner: likui
--

CREATE VIEW vw_backlog AS
SELECT s.dataset_archive_id AS dataset_id, CASE WHEN ((s.status)::text = 'draft0'::text) THEN 0 ELSE s.rev END AS rev, s.eml_draft_path, s.nickname, s.data_receipt_date AS "data received", replace((s.status)::text, '_'::text, ' '::text) AS status, o.network_type AS "network type", replace((o.temporal_type)::text, '_'::text, ' '::text) AS "temporal type", t."Title" AS title, CASE WHEN ((o.temporal_type)::text ~~ 'terminated%'::text) THEN ''::character varying ELSE s.who2bug END AS "who to bug", s.update_date_catalog AS "catalog last updated", to_date((s.dbupdatetime)::text, 'YYYY-MM-DD'::text) AS "status updated" FROM ((pkg_state s LEFT JOIN lter_metabase."DataSet" t ON (((s."DataSetID")::text = (t."DataSetID")::text))) LEFT JOIN pkg_sort o ON (((s."DataSetID")::text = (o."DataSetID")::text))) WHERE ((s.data_receipt_date > s.update_date_catalog) OR ((s.status)::text ~~ 'backlog'::text)) ORDER BY s.who2bug, s.dataset_archive_id;


ALTER TABLE vw_backlog OWNER TO likui;

--
-- TOC entry 222 (class 1259 OID 123477)
-- Name: vw_cataloged; Type: VIEW; Schema: pkg_mgmt; Owner: likui
--

CREATE VIEW vw_cataloged AS
SELECT pkg_state.dataset_archive_id AS dataset_id, pkg_state.nickname, pkg_sort.temporal_type, pkg_sort.management_type, pkg_sort.network_type, pkg_state.update_date_catalog, pkg_state.notes FROM (pkg_state JOIN pkg_sort ON (((pkg_state."DataSetID")::text = (pkg_sort."DataSetID")::text))) WHERE ((pkg_state.status)::text = 'cataloged'::text) ORDER BY pkg_sort.temporal_type, pkg_state.nickname;


ALTER TABLE vw_cataloged OWNER TO likui;

--
-- TOC entry 223 (class 1259 OID 123482)
-- Name: vw_draft_anticipated; Type: VIEW; Schema: pkg_mgmt; Owner: likui
--

CREATE VIEW vw_draft_anticipated AS
SELECT pkg_state.dataset_archive_id AS dataset_id, pkg_state.nickname, pkg_sort.temporal_type, pkg_sort.management_type, pkg_sort.network_type, pkg_state.status, pkg_state.notes FROM (pkg_state JOIN pkg_sort ON (((pkg_state."DataSetID")::text = (pkg_sort."DataSetID")::text))) WHERE (((pkg_state.status)::text = 'draft0'::text) OR ((pkg_state.status)::text = 'anticipated'::text)) ORDER BY pkg_state.status DESC, pkg_sort.temporal_type, pkg_state.nickname;


ALTER TABLE vw_draft_anticipated OWNER TO likui;

--
-- TOC entry 224 (class 1259 OID 123487)
-- Name: vw_drafts_bak; Type: VIEW; Schema: pkg_mgmt; Owner: likui
--

CREATE VIEW vw_drafts_bak AS
SELECT s.dataset_archive_id AS dataset_id, CASE WHEN ((s.status)::text = 'draft0'::text) THEN 0 ELSE s.rev END AS rev, s.eml_draft_path, s.nickname, s.data_receipt_date AS "data received", replace((s.status)::text, '_'::text, ' '::text) AS status, o.network_type AS "network type", replace((o.temporal_type)::text, '_'::text, ' '::text) AS "temporal type", m."Title" AS title, CASE WHEN ((o.temporal_type)::text ~~ 'terminated%'::text) THEN ''::character varying ELSE s.who2bug END AS "who to bug", s.update_date_catalog AS "catalog last updated", to_date((s.dbupdatetime)::text, 'YYYY-MM-DD'::text) AS "status updated" FROM ((pkg_state s LEFT JOIN lter_metabase."DataSet" m ON (((s."DataSetID")::text = (m."DataSetID")::text))) LEFT JOIN pkg_sort o ON (((s."DataSetID")::text = (o."DataSetID")::text))) WHERE (((s.data_receipt_date > s.update_date_catalog) OR ((s.status)::text ~~ 'backlog'::text)) OR ((s.status)::text ~~ 'draft%'::text)) ORDER BY s.eml_draft_path, s.who2bug, s.dataset_archive_id;


ALTER TABLE vw_drafts_bak OWNER TO likui;

--
-- TOC entry 228 (class 1259 OID 123507)
-- Name: vw_dump; Type: VIEW; Schema: pkg_mgmt; Owner: likui
--

CREATE VIEW vw_dump AS
SELECT s.dataset_archive_id AS dataset_id, s.rev, s.nickname, s.data_receipt_date, s.status, s.synth_readiness, s.staging_dir, s.eml_draft_path, s.notes, s.pub_notes, s.who2bug, s.dir_internal_final, s.dbupdatetime, s.update_date_catalog, o."DataSetID" AS dataset_id_, o.network_type, o.is_signature, o.is_core, o.temporal_type, o.spatial_extent, o.spatiotemporal, o.is_thesis, o.is_reference, o.is_exogenous, o.spatial_type, o.dbupdatetime AS dbupdatetime_, o.management_type, o.edq FROM (pkg_state s LEFT JOIN pkg_sort o ON (((s."DataSetID")::text = (o."DataSetID")::text))) ORDER BY (split_part(replace((s.dataset_archive_id)::text, 'X'::text, '9'::text), '.'::text, 2))::integer;


ALTER TABLE vw_dump OWNER TO likui;

--
-- TOC entry 226 (class 1259 OID 123497)
-- Name: vw_im_plan; Type: VIEW; Schema: pkg_mgmt; Owner: likui
--

CREATE VIEW vw_im_plan AS
SELECT replace((o.temporal_type)::text, '_'::text, ' '::text) AS "Temporal type", ((split_part((s.dataset_archive_id)::text, '.'::text, 1) || '.'::text) || split_part((s.dataset_archive_id)::text, '.'::text, 2)) AS "Dataset ID", s.nickname AS "Short Name", o.network_type AS "Network type", o.management_type AS "Management type", to_char((s.update_date_catalog)::timestamp with time zone, 'YYYY-MM-DD'::text) AS "Catalog update date", s.notes AS "Notes", replace(replace((s.status)::text, '_'::text, ' '::text), 'draft'::text, 'revision pending'::text) AS status FROM ((pkg_state s LEFT JOIN lter_metabase."DataSet" m ON (((s."DataSetID")::text = (m."DataSetID")::text))) LEFT JOIN pkg_sort o ON (((s."DataSetID")::text = (o."DataSetID")::text))) WHERE ((s.status)::text = ANY (ARRAY[('cataloged'::character varying)::text, ('backlog'::character varying)::text, ('redesign_anticipated'::character varying)::text, ('draft'::character varying)::text])) ORDER BY o.temporal_type, s.nickname, s.dataset_archive_id;


ALTER TABLE vw_im_plan OWNER TO likui;

--
-- TOC entry 225 (class 1259 OID 123492)
-- Name: vw_pub; Type: VIEW; Schema: pkg_mgmt; Owner: likui
--

CREATE VIEW vw_pub AS
SELECT s.dataset_archive_id AS dataset_id, o.network_type AS "network type", replace((o.temporal_type)::text, '_'::text, ' '::text) AS "temporal type", o.is_signature AS "is signature", o.is_core AS "is core", o.is_thesis AS "is thesis", o.is_reference AS "is reference", o.is_exogenous AS "is exogenous", m."Title" AS title, to_char((s.data_receipt_date)::timestamp with time zone, 'YYYY-MM-DD'::text) AS "data last received", to_char((s.update_date_catalog)::timestamp with time zone, 'YYYY-MM-DD'::text) AS "catalog updated", replace(replace((s.status)::text, '_'::text, ' '::text), 'draft'::text, 'revision pending'::text) AS status, s.nickname FROM ((pkg_state s LEFT JOIN lter_metabase."DataSet" m ON (((s."DataSetID")::text = (m."DataSetID")::text))) LEFT JOIN pkg_sort o ON (((s."DataSetID")::text = (o."DataSetID")::text))) WHERE ((s.status)::text = ANY (ARRAY[('cataloged'::character varying)::text, ('backlog'::character varying)::text, ('redesign_anticipated'::character varying)::text, ('draft'::character varying)::text])) ORDER BY o.is_signature DESC, o.is_core DESC, o.temporal_type, o.is_thesis, o.is_reference, o.is_exogenous, s.dataset_archive_id;


ALTER TABLE vw_pub OWNER TO likui;

--
-- TOC entry 227 (class 1259 OID 123502)
-- Name: vw_self; Type: VIEW; Schema: pkg_mgmt; Owner: likui
--

CREATE VIEW vw_self AS
SELECT s.dataset_archive_id AS dataset_id, CASE WHEN ((s.status)::text = 'draft0'::text) THEN 0 ELSE s.rev END AS rev, s.eml_draft_path, s.nickname, s.data_receipt_date AS "data received", replace((s.status)::text, '_'::text, ' '::text) AS status, o.network_type AS "network type", replace((o.temporal_type)::text, '_'::text, ' '::text) AS "temporal type", m."Title" AS title, CASE WHEN ((o.temporal_type)::text ~~ 'terminated%'::text) THEN ''::character varying ELSE s.who2bug END AS "who to bug", s.update_date_catalog AS "catalog last updated", to_date((s.dbupdatetime)::text, 'YYYY-MM-DD'::text) AS "status updated" FROM ((pkg_state s LEFT JOIN lter_metabase."DataSet" m ON (((s."DataSetID")::text = (m."DataSetID")::text))) LEFT JOIN pkg_sort o ON (((s."DataSetID")::text = (o."DataSetID")::text))) ORDER BY s.status, s.who2bug, split_part((s.dataset_archive_id)::text, '.'::text, 2);


ALTER TABLE vw_self OWNER TO likui;

--
-- TOC entry 220 (class 1259 OID 123467)
-- Name: vw_temporal; Type: VIEW; Schema: pkg_mgmt; Owner: likui
--

CREATE VIEW vw_temporal AS
SELECT s.dataset_archive_id AS dataset_id, CASE WHEN ((s.status)::text = 'draft0'::text) THEN 0 ELSE s.rev END AS rev, s.eml_draft_path, s.nickname, to_char((s.data_receipt_date)::timestamp with time zone, 'YYYY-MM-DD'::text) AS "data received", to_char((s.update_date_catalog)::timestamp with time zone, 'YYYY-MM-DD'::text) AS "catalog updated", to_char((s.dbupdatetime)::timestamp with time zone, 'YYYY-MM-DD'::text) AS db_updated, replace((s.status)::text, '_'::text, ' '::text) AS status, o.network_type AS "network type", replace((o.temporal_type)::text, '_'::text, ' '::text) AS "temporal type", m."Title" AS title, CASE WHEN ((o.temporal_type)::text ~~ 'terminated%'::text) THEN ''::character varying ELSE s.who2bug END AS "who to bug" FROM ((pkg_state s LEFT JOIN lter_metabase."DataSet" m ON (((s."DataSetID")::text = (m."DataSetID")::text))) LEFT JOIN pkg_sort o ON (((s."DataSetID")::text = (o."DataSetID")::text))) ORDER BY s.who2bug, s.dataset_archive_id;


ALTER TABLE vw_temporal OWNER TO likui;

--
-- TOC entry 3106 (class 0 OID 0)
-- Dependencies: 11
-- Name: pkg_mgmt; Type: ACL; Schema: -; Owner: likui
--

REVOKE ALL ON SCHEMA pkg_mgmt FROM PUBLIC;
REVOKE ALL ON SCHEMA pkg_mgmt FROM likui;
GRANT ALL ON SCHEMA pkg_mgmt TO likui;
GRANT USAGE ON SCHEMA pkg_mgmt TO mcr_web_browser;


--
-- TOC entry 3108 (class 0 OID 0)
-- Dependencies: 232
-- Name: pkg_biblio; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE pkg_biblio FROM PUBLIC;
REVOKE ALL ON TABLE pkg_biblio FROM likui;
GRANT ALL ON TABLE pkg_biblio TO likui;
GRANT ALL ON TABLE pkg_biblio TO mob;
GRANT SELECT ON TABLE pkg_biblio TO read_only_user;


--
-- TOC entry 3110 (class 0 OID 0)
-- Dependencies: 230
-- Name: cv_cra; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE cv_cra FROM PUBLIC;
REVOKE ALL ON TABLE cv_cra FROM likui;
GRANT ALL ON TABLE cv_cra TO likui;
GRANT ALL ON TABLE cv_cra TO mob;
GRANT SELECT ON TABLE cv_cra TO read_only_user;


--
-- TOC entry 3112 (class 0 OID 0)
-- Dependencies: 231
-- Name: pkg_core_area; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE pkg_core_area FROM PUBLIC;
REVOKE ALL ON TABLE pkg_core_area FROM likui;
GRANT ALL ON TABLE pkg_core_area TO likui;
GRANT ALL ON TABLE pkg_core_area TO mob;
GRANT SELECT ON TABLE pkg_core_area TO read_only_user;


--
-- TOC entry 3127 (class 0 OID 0)
-- Dependencies: 213
-- Name: pkg_state; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE pkg_state FROM PUBLIC;
REVOKE ALL ON TABLE pkg_state FROM likui;
GRANT ALL ON TABLE pkg_state TO likui;
GRANT ALL ON TABLE pkg_state TO mob;
GRANT SELECT ON TABLE pkg_state TO mcr_web_browser;
GRANT SELECT ON TABLE pkg_state TO read_only_user;


--
-- TOC entry 3134 (class 0 OID 0)
-- Dependencies: 219
-- Name: pkg_sort; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE pkg_sort FROM PUBLIC;
REVOKE ALL ON TABLE pkg_sort FROM likui;
GRANT ALL ON TABLE pkg_sort TO likui;
GRANT ALL ON TABLE pkg_sort TO mob;
GRANT SELECT ON TABLE pkg_sort TO read_only_user;


--
-- TOC entry 3135 (class 0 OID 0)
-- Dependencies: 206
-- Name: cv_mgmt_type; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE cv_mgmt_type FROM PUBLIC;
REVOKE ALL ON TABLE cv_mgmt_type FROM likui;
GRANT ALL ON TABLE cv_mgmt_type TO likui;
GRANT ALL ON TABLE cv_mgmt_type TO mob;
GRANT SELECT ON TABLE cv_mgmt_type TO read_only_user;


--
-- TOC entry 3136 (class 0 OID 0)
-- Dependencies: 207
-- Name: cv_network_type; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE cv_network_type FROM PUBLIC;
REVOKE ALL ON TABLE cv_network_type FROM likui;
GRANT ALL ON TABLE cv_network_type TO likui;
GRANT ALL ON TABLE cv_network_type TO mob;
GRANT SELECT ON TABLE cv_network_type TO read_only_user;


--
-- TOC entry 3137 (class 0 OID 0)
-- Dependencies: 208
-- Name: cv_spatial_extent; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE cv_spatial_extent FROM PUBLIC;
REVOKE ALL ON TABLE cv_spatial_extent FROM likui;
GRANT ALL ON TABLE cv_spatial_extent TO likui;
GRANT ALL ON TABLE cv_spatial_extent TO mob;
GRANT SELECT ON TABLE cv_spatial_extent TO read_only_user;


--
-- TOC entry 3138 (class 0 OID 0)
-- Dependencies: 209
-- Name: cv_spatial_type; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE cv_spatial_type FROM PUBLIC;
REVOKE ALL ON TABLE cv_spatial_type FROM likui;
GRANT ALL ON TABLE cv_spatial_type TO likui;
GRANT ALL ON TABLE cv_spatial_type TO mob;
GRANT SELECT ON TABLE cv_spatial_type TO read_only_user;


--
-- TOC entry 3139 (class 0 OID 0)
-- Dependencies: 210
-- Name: cv_spatio_temporal; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE cv_spatio_temporal FROM PUBLIC;
REVOKE ALL ON TABLE cv_spatio_temporal FROM likui;
GRANT ALL ON TABLE cv_spatio_temporal TO likui;
GRANT ALL ON TABLE cv_spatio_temporal TO mob;
GRANT SELECT ON TABLE cv_spatio_temporal TO read_only_user;


--
-- TOC entry 3140 (class 0 OID 0)
-- Dependencies: 211
-- Name: cv_status; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE cv_status FROM PUBLIC;
REVOKE ALL ON TABLE cv_status FROM likui;
GRANT ALL ON TABLE cv_status TO likui;
GRANT ALL ON TABLE cv_status TO mob;
GRANT SELECT ON TABLE cv_status TO read_only_user;


--
-- TOC entry 3141 (class 0 OID 0)
-- Dependencies: 212
-- Name: cv_temporal_type; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE cv_temporal_type FROM PUBLIC;
REVOKE ALL ON TABLE cv_temporal_type FROM likui;
GRANT ALL ON TABLE cv_temporal_type TO likui;
GRANT ALL ON TABLE cv_temporal_type TO mob;
GRANT SELECT ON TABLE cv_temporal_type TO read_only_user;


--
-- TOC entry 3142 (class 0 OID 0)
-- Dependencies: 221
-- Name: vw_backlog; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE vw_backlog FROM PUBLIC;
REVOKE ALL ON TABLE vw_backlog FROM likui;
GRANT ALL ON TABLE vw_backlog TO likui;
GRANT SELECT ON TABLE vw_backlog TO mcr_web_browser;
GRANT SELECT ON TABLE vw_backlog TO im_assist;
GRANT ALL ON TABLE vw_backlog TO mob;
GRANT SELECT ON TABLE vw_backlog TO read_only_user;


--
-- TOC entry 3143 (class 0 OID 0)
-- Dependencies: 222
-- Name: vw_cataloged; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE vw_cataloged FROM PUBLIC;
REVOKE ALL ON TABLE vw_cataloged FROM likui;
GRANT ALL ON TABLE vw_cataloged TO likui;
GRANT SELECT ON TABLE vw_cataloged TO mcr_web_browser;
GRANT ALL ON TABLE vw_cataloged TO mob;
GRANT SELECT ON TABLE vw_cataloged TO read_only_user;
GRANT SELECT ON TABLE vw_cataloged TO im_assist;


--
-- TOC entry 3144 (class 0 OID 0)
-- Dependencies: 223
-- Name: vw_draft_anticipated; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE vw_draft_anticipated FROM PUBLIC;
REVOKE ALL ON TABLE vw_draft_anticipated FROM likui;
GRANT ALL ON TABLE vw_draft_anticipated TO likui;
GRANT SELECT ON TABLE vw_draft_anticipated TO mcr_web_browser;
GRANT ALL ON TABLE vw_draft_anticipated TO mob;
GRANT SELECT ON TABLE vw_draft_anticipated TO read_only_user;
GRANT SELECT ON TABLE vw_draft_anticipated TO im_assist;


--
-- TOC entry 3145 (class 0 OID 0)
-- Dependencies: 224
-- Name: vw_drafts_bak; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE vw_drafts_bak FROM PUBLIC;
REVOKE ALL ON TABLE vw_drafts_bak FROM likui;
GRANT ALL ON TABLE vw_drafts_bak TO likui;
GRANT SELECT ON TABLE vw_drafts_bak TO mcr_web_browser;
GRANT SELECT ON TABLE vw_drafts_bak TO im_assist;
GRANT ALL ON TABLE vw_drafts_bak TO mob;
GRANT SELECT ON TABLE vw_drafts_bak TO read_only_user;


--
-- TOC entry 3146 (class 0 OID 0)
-- Dependencies: 228
-- Name: vw_dump; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE vw_dump FROM PUBLIC;
REVOKE ALL ON TABLE vw_dump FROM likui;
GRANT ALL ON TABLE vw_dump TO likui;
GRANT SELECT ON TABLE vw_dump TO mcr_web_browser;
GRANT ALL ON TABLE vw_dump TO mob;
GRANT SELECT ON TABLE vw_dump TO read_only_user;


--
-- TOC entry 3147 (class 0 OID 0)
-- Dependencies: 226
-- Name: vw_im_plan; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE vw_im_plan FROM PUBLIC;
REVOKE ALL ON TABLE vw_im_plan FROM likui;
GRANT ALL ON TABLE vw_im_plan TO likui;
GRANT SELECT ON TABLE vw_im_plan TO mcr_web_browser;
GRANT SELECT ON TABLE vw_im_plan TO sbc;
GRANT ALL ON TABLE vw_im_plan TO mob;
GRANT SELECT ON TABLE vw_im_plan TO read_only_user;
GRANT SELECT ON TABLE vw_im_plan TO im_assist;


--
-- TOC entry 3148 (class 0 OID 0)
-- Dependencies: 225
-- Name: vw_pub; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE vw_pub FROM PUBLIC;
REVOKE ALL ON TABLE vw_pub FROM likui;
GRANT ALL ON TABLE vw_pub TO likui;
GRANT SELECT ON TABLE vw_pub TO mcr_web_browser;
GRANT SELECT ON TABLE vw_pub TO sbc;
GRANT ALL ON TABLE vw_pub TO mob;
GRANT SELECT ON TABLE vw_pub TO read_only_user;
GRANT SELECT ON TABLE vw_pub TO im_assist;


--
-- TOC entry 3149 (class 0 OID 0)
-- Dependencies: 227
-- Name: vw_self; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE vw_self FROM PUBLIC;
REVOKE ALL ON TABLE vw_self FROM likui;
GRANT ALL ON TABLE vw_self TO likui;
GRANT SELECT ON TABLE vw_self TO mcr_web_browser;
GRANT SELECT ON TABLE vw_self TO im_assist;
GRANT ALL ON TABLE vw_self TO mob;
GRANT SELECT ON TABLE vw_self TO read_only_user;


--
-- TOC entry 3150 (class 0 OID 0)
-- Dependencies: 220
-- Name: vw_temporal; Type: ACL; Schema: pkg_mgmt; Owner: likui
--

REVOKE ALL ON TABLE vw_temporal FROM PUBLIC;
REVOKE ALL ON TABLE vw_temporal FROM likui;
GRANT ALL ON TABLE vw_temporal TO likui;
GRANT SELECT ON TABLE vw_temporal TO mcr_web_browser;
GRANT SELECT ON TABLE vw_temporal TO im_assist;
GRANT SELECT ON TABLE vw_temporal TO sbc;
GRANT ALL ON TABLE vw_temporal TO mob;
GRANT SELECT ON TABLE vw_temporal TO read_only_user;


-- Completed on 2018-08-14 15:45:58

--
-- PostgreSQL database dump complete
--

