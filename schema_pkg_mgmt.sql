--
-- PostgreSQL database dump
--

-- Dumped from database version 9.2.24
-- Dumped by pg_dump version 10.1

-- Started on 2018-08-10 13:21:05

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 10 (class 2615 OID 116370)
-- Name: pkg_mgmt; Type: SCHEMA; Schema: -; Owner: likui
--

CREATE SCHEMA pkg_mgmt;

--
-- TOC entry 2962 (class 0 OID 0)
-- Dependencies: 10
-- Name: SCHEMA pkg_mgmt; Type: COMMENT; Schema: -; Owner: likui
--

COMMENT ON SCHEMA pkg_mgmt IS 'schema copied from sbc_metabase.pkg_mgmt';


SET search_path = pkg_mgmt, pg_catalog;

--
-- TOC entry 212 (class 1255 OID 121616)
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

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 202 (class 1259 OID 121556)
-- Name: pkg_state; Type: TABLE; Schema: pkg_mgmt; Owner: likui
--

CREATE TABLE pkg_state (
    "DataSetID" integer NOT NULL,
    dataset_archive_id character varying(21) NOT NULL,
    rev integer,
    nickname character varying(64),
    data_receipt_date date,
    status character varying(64),
    staging_dir character varying(1024),
    notes text,
    pub_notes text,
    dbupdatetime timestamp without time zone,
    update_date_catalog date
);

--
-- TOC entry 2964 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN pkg_state.dataset_archive_id; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.dataset_archive_id IS 'ie knb-lter-mcr.1234 or if not assigned a real id yet then what';


--
-- TOC entry 2965 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN pkg_state.rev; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.rev IS 'revision is needed for showDraft. By definition, rev for draft0 is 0. Rev for cataloged make null so latest rev is shown.';


--
-- TOC entry 2966 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN pkg_state.nickname; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.nickname IS 'ie fish_survey or flume or par. This is the eml shortName. This is not the staging directory except by coincidence.';


--
-- TOC entry 2967 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN pkg_state.status; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.status IS 'anticipated, draft0, cataloged, backlog or anticipated, draft then back to cataloged';


--
-- TOC entry 2968 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN pkg_state.staging_dir; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.staging_dir IS 'The subdirectory where the IMs work on data files after receiving in final_dir and prior to posting in external_dir. Root portion of path is a different constant for MCR than SBC.';


--
-- TOC entry 2969 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN pkg_state.notes; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.notes IS 'what needs doing. what the holdup is. issues.';


--
-- TOC entry 2970 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN pkg_state.pub_notes; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.pub_notes IS 'Reason for being in this state, ie why it is metadata-only currently or Type II.  Such as grad student data or pending publication. May apply to status, network_type, synthesis_readiness.';


--
-- TOC entry 2971 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN pkg_state.dbupdatetime; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.dbupdatetime IS 'automatically updates itself.';


--
-- TOC entry 2972 (class 0 OID 0)
-- Dependencies: 202
-- Name: COLUMN pkg_state.update_date_catalog; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_state.update_date_catalog IS 'Date package last updated in catalog (same as pubdate)';


--
-- TOC entry 183 (class 1259 OID 117231)
-- Name: cv_metadata_amt; Type: TABLE; Schema: pkg_mgmt; Owner: likui
--

CREATE TABLE cv_metadata_amt (
    metadata_amt character varying(20) NOT NULL,
    definition character varying(1024)
);

--
-- TOC entry 2974 (class 0 OID 0)
-- Dependencies: 183
-- Name: TABLE cv_metadata_amt; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON TABLE cv_metadata_amt IS 'based on the dmp, amount will be A=entity level, (a, b); B=entity + prov; C: cited';


--
-- TOC entry 180 (class 1259 OID 116528)
-- Name: cv_status; Type: TABLE; Schema: pkg_mgmt; Owner: likui
--

CREATE TABLE cv_status (
    status character varying(20) NOT NULL
);

--
-- TOC entry 2976 (class 0 OID 0)
-- Dependencies: 180
-- Name: TABLE cv_status; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON TABLE cv_status IS 'in this order: 1. anticipated 2. draft0 3. cataloged then 4 or 5 backlog or ancipated_redesign then 6. draft then back to cataloged.';


--
-- TOC entry 181 (class 1259 OID 116531)
-- Name: cv_temporal_type; Type: TABLE; Schema: pkg_mgmt; Owner: likui
--

CREATE TABLE cv_temporal_type (
    temporal_type character varying(32) NOT NULL,
    definition character varying(1024)
);

--
-- TOC entry 184 (class 1259 OID 117286)
-- Name: cv_trophic_level; Type: TABLE; Schema: pkg_mgmt; Owner: likui
--

CREATE TABLE cv_trophic_level (
    trophic_level character varying(20) NOT NULL,
    definition character varying(1024)
);

--
-- TOC entry 2979 (class 0 OID 0)
-- Dependencies: 184
-- Name: TABLE cv_trophic_level; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON TABLE cv_trophic_level IS 'primary data = first observation. secondary = integrated from primary';


--
-- TOC entry 203 (class 1259 OID 121588)
-- Name: pkg_sort; Type: TABLE; Schema: pkg_mgmt; Owner: likui
--

CREATE TABLE pkg_sort (
    "DataSetID" integer NOT NULL,
    temporal_type character varying(22),
    spatial_extent character varying(18),
    spatiotemporal character(4),
    trophic_level character varying(20),
    metadata_amt character varying(20),
    is_exogenous boolean,
    spatial_type character varying(32),
    dbupdatetime timestamp without time zone,
    in_pasta boolean
);

--
-- TOC entry 2981 (class 0 OID 0)
-- Dependencies: 203
-- Name: TABLE pkg_sort; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON TABLE pkg_sort IS 'pkg_state is wordy and pkg_sort is terse. Instead of one really wide table.  Just easier to edit.';


--
-- TOC entry 2982 (class 0 OID 0)
-- Dependencies: 203
-- Name: COLUMN pkg_sort.in_pasta; Type: COMMENT; Schema: pkg_mgmt; Owner: likui
--

COMMENT ON COLUMN pkg_sort.in_pasta IS 'This package ID is in production pasta. No implications re access restrictions. Merely passing evaluate does not mean in_pasta is true. ';
