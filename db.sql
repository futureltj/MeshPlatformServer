--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.3
-- Dumped by pg_dump version 9.6.3

-- Started on 2017-08-30 11:56:51

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2500 (class 1262 OID 12665)
-- Dependencies: 2499
-- Name: pipeline; Type: COMMENT; Schema: -; Owner: pipeline
--

COMMENT ON DATABASE pipeline IS 'default administrative connection database';


--
-- TOC entry 1 (class 3079 OID 12644)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2503 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 2 (class 3079 OID 16910)
-- Name: http; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS http WITH SCHEMA public;


--
-- TOC entry 2504 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION http; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION http IS 'HTTP client for PostgreSQL, allows web page retrieval inside the database.';


SET search_path = public, pg_catalog;

--
-- TOC entry 219 (class 1255 OID 16428)
-- Name: check_token(); Type: FUNCTION; Schema: public; Owner: pipeline
--

CREATE FUNCTION check_token() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
  if current_setting('request.jwt.claim.email', true) =
     'disgruntled@mycompany.com' then
    raise insufficient_privilege
      using hint = 'Nope, we are on to you';
  end if;
end
$$;


ALTER FUNCTION public.check_token() OWNER TO pipeline;

--
-- TOC entry 234 (class 1255 OID 16461)
-- Name: f_get_rowcnt(text); Type: FUNCTION; Schema: public; Owner: pipeline
--

CREATE FUNCTION f_get_rowcnt(tname text) RETURNS bigint
    LANGUAGE plpgsql
    AS $_$
declare
cnt bigint;
begin
EXECUTE 'select count(*)  from ' || $1 into cnt;
return  cnt;
end
$_$;


ALTER FUNCTION public.f_get_rowcnt(tname text) OWNER TO pipeline;

--
-- TOC entry 220 (class 1255 OID 16719)
-- Name: first_agg(anyelement, anyelement); Type: FUNCTION; Schema: public; Owner: pipeline
--

CREATE FUNCTION first_agg(anyelement, anyelement) RETURNS anyelement
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
        SELECT $1;
$_$;


ALTER FUNCTION public.first_agg(anyelement, anyelement) OWNER TO pipeline;

--
-- TOC entry 221 (class 1255 OID 16721)
-- Name: last_agg(anyelement, anyelement); Type: FUNCTION; Schema: public; Owner: pipeline
--

CREATE FUNCTION last_agg(anyelement, anyelement) RETURNS anyelement
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
        SELECT $2;
$_$;


ALTER FUNCTION public.last_agg(anyelement, anyelement) OWNER TO pipeline;

--
-- TOC entry 883 (class 1255 OID 16720)
-- Name: first(anyelement); Type: AGGREGATE; Schema: public; Owner: pipeline
--

CREATE AGGREGATE first(anyelement) (
    SFUNC = first_agg,
    STYPE = anyelement
);


ALTER AGGREGATE public.first(anyelement) OWNER TO pipeline;

--
-- TOC entry 884 (class 1255 OID 16722)
-- Name: last(anyelement); Type: AGGREGATE; Schema: public; Owner: pipeline
--

CREATE AGGREGATE last(anyelement) (
    SFUNC = last_agg,
    STYPE = anyelement
);


ALTER AGGREGATE public.last(anyelement) OWNER TO pipeline;

--
-- TOC entry 1964 (class 2328 OID 12649)
-- Name: stream_fdw; Type: FOREIGN DATA WRAPPER; Schema: -; Owner: 
--

CREATE FOREIGN DATA WRAPPER stream_fdw HANDLER stream_fdw_handler;


--
-- TOC entry 1965 (class 1417 OID 12650)
-- Name: pipeline_streams; Type: SERVER; Schema: -; Owner: 
--

CREATE SERVER pipeline_streams FOREIGN DATA WRAPPER stream_fdw;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 202 (class 1259 OID 16572)
-- Name: datamodel; Type: TABLE; Schema: public; Owner: pipeline
--

CREATE TABLE datamodel (
    id integer NOT NULL,
    code character varying,
    name character varying,
    topic character varying,
    datatype character varying,
    datastruct character varying,
    processtype character varying,
    process character varying
);


ALTER TABLE datamodel OWNER TO pipeline;

--
-- TOC entry 201 (class 1259 OID 16570)
-- Name: datamodel_id_seq; Type: SEQUENCE; Schema: public; Owner: pipeline
--

CREATE SEQUENCE datamodel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE datamodel_id_seq OWNER TO pipeline;

--
-- TOC entry 2505 (class 0 OID 0)
-- Dependencies: 201
-- Name: datamodel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pipeline
--

ALTER SEQUENCE datamodel_id_seq OWNED BY datamodel.id;


--
-- TOC entry 192 (class 1259 OID 16506)
-- Name: department; Type: TABLE; Schema: public; Owner: pipeline
--

CREATE TABLE department (
    id integer NOT NULL,
    code character varying,
    name character varying,
    parentid integer
);


ALTER TABLE department OWNER TO pipeline;

--
-- TOC entry 191 (class 1259 OID 16504)
-- Name: department_id_seq; Type: SEQUENCE; Schema: public; Owner: pipeline
--

CREATE SEQUENCE department_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE department_id_seq OWNER TO pipeline;

--
-- TOC entry 2506 (class 0 OID 0)
-- Dependencies: 191
-- Name: department_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pipeline
--

ALTER SEQUENCE department_id_seq OWNED BY department.id;


--
-- TOC entry 214 (class 1259 OID 16644)
-- Name: department_v; Type: VIEW; Schema: public; Owner: pipeline
--

CREATE VIEW department_v AS
 SELECT t.id,
    t.code,
    t.name,
    t.parentid,
    ( SELECT count(*) AS count
           FROM department
          WHERE (department.parentid = t.id)) AS cnt
   FROM department t;


ALTER TABLE department_v OWNER TO pipeline;

--
-- TOC entry 208 (class 1259 OID 16605)
-- Name: device; Type: TABLE; Schema: public; Owner: pipeline
--

CREATE TABLE device (
    id integer NOT NULL,
    code character varying,
    name character varying,
    typeid integer,
    nodeid integer,
    attrs jsonb
);


ALTER TABLE device OWNER TO pipeline;

--
-- TOC entry 207 (class 1259 OID 16603)
-- Name: device_id_seq; Type: SEQUENCE; Schema: public; Owner: pipeline
--

CREATE SEQUENCE device_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE device_id_seq OWNER TO pipeline;

--
-- TOC entry 2507 (class 0 OID 0)
-- Dependencies: 207
-- Name: device_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pipeline
--

ALTER SEQUENCE device_id_seq OWNED BY device.id;


--
-- TOC entry 206 (class 1259 OID 16594)
-- Name: devicetype; Type: TABLE; Schema: public; Owner: pipeline
--

CREATE TABLE devicetype (
    id integer NOT NULL,
    code character varying,
    name character varying
);


ALTER TABLE devicetype OWNER TO pipeline;

--
-- TOC entry 205 (class 1259 OID 16592)
-- Name: devicetype_id_seq; Type: SEQUENCE; Schema: public; Owner: pipeline
--

CREATE SEQUENCE devicetype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE devicetype_id_seq OWNER TO pipeline;

--
-- TOC entry 2508 (class 0 OID 0)
-- Dependencies: 205
-- Name: devicetype_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pipeline
--

ALTER SEQUENCE devicetype_id_seq OWNED BY devicetype.id;


--
-- TOC entry 200 (class 1259 OID 16561)
-- Name: gateway; Type: TABLE; Schema: public; Owner: pipeline
--

CREATE TABLE gateway (
    id integer NOT NULL,
    code character varying,
    configid integer,
    mqttuser character varying,
    mqttpwd character varying,
    status character varying
);


ALTER TABLE gateway OWNER TO pipeline;

--
-- TOC entry 199 (class 1259 OID 16559)
-- Name: gateway_id_seq; Type: SEQUENCE; Schema: public; Owner: pipeline
--

CREATE SEQUENCE gateway_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gateway_id_seq OWNER TO pipeline;

--
-- TOC entry 2509 (class 0 OID 0)
-- Dependencies: 199
-- Name: gateway_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pipeline
--

ALTER SEQUENCE gateway_id_seq OWNED BY gateway.id;


--
-- TOC entry 198 (class 1259 OID 16550)
-- Name: gwconfig; Type: TABLE; Schema: public; Owner: pipeline
--

CREATE TABLE gwconfig (
    id integer NOT NULL,
    code character varying,
    name character varying,
    fileurl jsonb
);


ALTER TABLE gwconfig OWNER TO pipeline;

--
-- TOC entry 197 (class 1259 OID 16548)
-- Name: gwconfig_id_seq; Type: SEQUENCE; Schema: public; Owner: pipeline
--

CREATE SEQUENCE gwconfig_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE gwconfig_id_seq OWNER TO pipeline;

--
-- TOC entry 2510 (class 0 OID 0)
-- Dependencies: 197
-- Name: gwconfig_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pipeline
--

ALTER SEQUENCE gwconfig_id_seq OWNED BY gwconfig.id;


--
-- TOC entry 190 (class 1259 OID 16465)
-- Name: idseq; Type: SEQUENCE; Schema: public; Owner: pipeline
--

CREATE SEQUENCE idseq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE idseq OWNER TO pipeline;

--
-- TOC entry 211 (class 1259 OID 16629)
-- Name: lookup_id_seq; Type: SEQUENCE; Schema: public; Owner: pipeline
--

CREATE SEQUENCE lookup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE lookup_id_seq OWNER TO pipeline;

--
-- TOC entry 212 (class 1259 OID 16631)
-- Name: lookup; Type: TABLE; Schema: public; Owner: pipeline
--

CREATE TABLE lookup (
    id integer DEFAULT nextval('lookup_id_seq'::regclass) NOT NULL,
    code character varying,
    name character varying,
    parentid integer
);


ALTER TABLE lookup OWNER TO pipeline;

--
-- TOC entry 213 (class 1259 OID 16640)
-- Name: lookup_v; Type: VIEW; Schema: public; Owner: pipeline
--

CREATE VIEW lookup_v AS
 SELECT l.id,
    l.code,
    l.name,
    l.parentid,
    p.code AS parentcode
   FROM lookup l,
    lookup p
  WHERE (l.parentid = p.id);


ALTER TABLE lookup_v OWNER TO pipeline;

--
-- TOC entry 194 (class 1259 OID 16517)
-- Name: menu; Type: TABLE; Schema: public; Owner: pipeline
--

CREATE TABLE menu (
    id integer NOT NULL,
    code character varying,
    name character varying,
    icon character varying,
    mpid integer,
    route character varying,
    bpid integer
);


ALTER TABLE menu OWNER TO pipeline;

--
-- TOC entry 193 (class 1259 OID 16515)
-- Name: menu_id_seq; Type: SEQUENCE; Schema: public; Owner: pipeline
--

CREATE SEQUENCE menu_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE menu_id_seq OWNER TO pipeline;

--
-- TOC entry 2511 (class 0 OID 0)
-- Dependencies: 193
-- Name: menu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pipeline
--

ALTER SEQUENCE menu_id_seq OWNED BY menu.id;


--
-- TOC entry 204 (class 1259 OID 16583)
-- Name: node; Type: TABLE; Schema: public; Owner: pipeline
--

CREATE TABLE node (
    id integer NOT NULL,
    code character varying,
    modelid integer,
    gwid integer
);


ALTER TABLE node OWNER TO pipeline;

--
-- TOC entry 203 (class 1259 OID 16581)
-- Name: node_id_seq; Type: SEQUENCE; Schema: public; Owner: pipeline
--

CREATE SEQUENCE node_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE node_id_seq OWNER TO pipeline;

--
-- TOC entry 2512 (class 0 OID 0)
-- Dependencies: 203
-- Name: node_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pipeline
--

ALTER SEQUENCE node_id_seq OWNED BY node.id;


--
-- TOC entry 210 (class 1259 OID 16617)
-- Name: person; Type: TABLE; Schema: public; Owner: pipeline
--

CREATE TABLE person (
    id integer NOT NULL,
    usercode character varying,
    username character varying,
    password character varying,
    depid integer,
    roleid integer,
    menus character varying[],
    attrs jsonb
);


ALTER TABLE person OWNER TO pipeline;

--
-- TOC entry 209 (class 1259 OID 16615)
-- Name: person_id_seq; Type: SEQUENCE; Schema: public; Owner: pipeline
--

CREATE SEQUENCE person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE person_id_seq OWNER TO pipeline;

--
-- TOC entry 2513 (class 0 OID 0)
-- Dependencies: 209
-- Name: person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pipeline
--

ALTER SEQUENCE person_id_seq OWNED BY person.id;


--
-- TOC entry 196 (class 1259 OID 16528)
-- Name: role; Type: TABLE; Schema: public; Owner: pipeline
--

CREATE TABLE role (
    id integer NOT NULL,
    code character varying,
    name character varying
);


ALTER TABLE role OWNER TO pipeline;

--
-- TOC entry 215 (class 1259 OID 16648)
-- Name: person_v; Type: VIEW; Schema: public; Owner: pipeline
--

CREATE VIEW person_v AS
 SELECT t.id,
    t.usercode,
    t.username,
    t.password,
    t.depid,
    t.roleid,
    t.menus,
    t.attrs,
    ( SELECT department.name
           FROM department
          WHERE (department.id = t.depid)) AS depname,
    ( SELECT role.name
           FROM role
          WHERE (role.id = t.roleid)) AS rolename
   FROM person t;


ALTER TABLE person_v OWNER TO pipeline;

--
-- TOC entry 195 (class 1259 OID 16526)
-- Name: role_id_seq; Type: SEQUENCE; Schema: public; Owner: pipeline
--

CREATE SEQUENCE role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE role_id_seq OWNER TO pipeline;

--
-- TOC entry 2514 (class 0 OID 0)
-- Dependencies: 195
-- Name: role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pipeline
--

ALTER SEQUENCE role_id_seq OWNED BY role.id;


--
-- TOC entry 2323 (class 2604 OID 16575)
-- Name: datamodel id; Type: DEFAULT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY datamodel ALTER COLUMN id SET DEFAULT nextval('datamodel_id_seq'::regclass);


--
-- TOC entry 2318 (class 2604 OID 16509)
-- Name: department id; Type: DEFAULT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY department ALTER COLUMN id SET DEFAULT nextval('department_id_seq'::regclass);


--
-- TOC entry 2326 (class 2604 OID 16608)
-- Name: device id; Type: DEFAULT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY device ALTER COLUMN id SET DEFAULT nextval('device_id_seq'::regclass);


--
-- TOC entry 2325 (class 2604 OID 16597)
-- Name: devicetype id; Type: DEFAULT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY devicetype ALTER COLUMN id SET DEFAULT nextval('devicetype_id_seq'::regclass);


--
-- TOC entry 2322 (class 2604 OID 16564)
-- Name: gateway id; Type: DEFAULT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY gateway ALTER COLUMN id SET DEFAULT nextval('gateway_id_seq'::regclass);


--
-- TOC entry 2321 (class 2604 OID 16553)
-- Name: gwconfig id; Type: DEFAULT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY gwconfig ALTER COLUMN id SET DEFAULT nextval('gwconfig_id_seq'::regclass);


--
-- TOC entry 2319 (class 2604 OID 16520)
-- Name: menu id; Type: DEFAULT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY menu ALTER COLUMN id SET DEFAULT nextval('menu_id_seq'::regclass);


--
-- TOC entry 2324 (class 2604 OID 16586)
-- Name: node id; Type: DEFAULT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY node ALTER COLUMN id SET DEFAULT nextval('node_id_seq'::regclass);


--
-- TOC entry 2327 (class 2604 OID 16620)
-- Name: person id; Type: DEFAULT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY person ALTER COLUMN id SET DEFAULT nextval('person_id_seq'::regclass);


--
-- TOC entry 2320 (class 2604 OID 16531)
-- Name: role id; Type: DEFAULT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY role ALTER COLUMN id SET DEFAULT nextval('role_id_seq'::regclass);


--
-- TOC entry 2484 (class 0 OID 16572)
-- Dependencies: 202
-- Data for Name: datamodel; Type: TABLE DATA; Schema: public; Owner: pipeline
--

COPY datamodel (id, code, name, topic, datatype, datastruct, processtype, process) FROM stdin;
1	test	name1	\N	\N	\N	\N	\N
2	test2	name2	\N	\N	\N	\N	\N
\.


--
-- TOC entry 2515 (class 0 OID 0)
-- Dependencies: 201
-- Name: datamodel_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pipeline
--

SELECT pg_catalog.setval('datamodel_id_seq', 2, true);


--
-- TOC entry 2474 (class 0 OID 16506)
-- Dependencies: 192
-- Data for Name: department; Type: TABLE DATA; Schema: public; Owner: pipeline
--

COPY department (id, code, name, parentid) FROM stdin;
2	code11	DEPARTMENT_11	1
3	code12	DEPARTMENT_12	1
4	code13	DEPARTMENT_133	1
1	code1	DEPARTMENT_1e	0
5	dd	cccdd	1
\.


--
-- TOC entry 2516 (class 0 OID 0)
-- Dependencies: 191
-- Name: department_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pipeline
--

SELECT pg_catalog.setval('department_id_seq', 9, true);


--
-- TOC entry 2490 (class 0 OID 16605)
-- Dependencies: 208
-- Data for Name: device; Type: TABLE DATA; Schema: public; Owner: pipeline
--

COPY device (id, code, name, typeid, nodeid, attrs) FROM stdin;
\.


--
-- TOC entry 2517 (class 0 OID 0)
-- Dependencies: 207
-- Name: device_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pipeline
--

SELECT pg_catalog.setval('device_id_seq', 1, false);


--
-- TOC entry 2488 (class 0 OID 16594)
-- Dependencies: 206
-- Data for Name: devicetype; Type: TABLE DATA; Schema: public; Owner: pipeline
--

COPY devicetype (id, code, name) FROM stdin;
2	LocationGateway	定位网关
\.


--
-- TOC entry 2518 (class 0 OID 0)
-- Dependencies: 205
-- Name: devicetype_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pipeline
--

SELECT pg_catalog.setval('devicetype_id_seq', 2, true);


--
-- TOC entry 2482 (class 0 OID 16561)
-- Dependencies: 200
-- Data for Name: gateway; Type: TABLE DATA; Schema: public; Owner: pipeline
--

COPY gateway (id, code, configid, mqttuser, mqttpwd, status) FROM stdin;
\.


--
-- TOC entry 2519 (class 0 OID 0)
-- Dependencies: 199
-- Name: gateway_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pipeline
--

SELECT pg_catalog.setval('gateway_id_seq', 1, false);


--
-- TOC entry 2480 (class 0 OID 16550)
-- Dependencies: 198
-- Data for Name: gwconfig; Type: TABLE DATA; Schema: public; Owner: pipeline
--

COPY gwconfig (id, code, name, fileurl) FROM stdin;
4	dd	xx	{"file": {"uid": "rc-upload-1503203908709-7", "name": "avatar-3449c9e5e332f1dbb81505cd739fbf3f.zip", "size": 36630, "type": "application/x-zip-compressed", "status": "done", "percent": 100, "response": {"msg": "avatar-3449c9e5e332f1dbb81505cd739fbf3f.zip", "success": true}, "lastModified": 1503197439705, "originFileObj": {"uid": "rc-upload-1503203908709-7"}, "lastModifiedDate": "2017-08-20T02:50:39.705Z"}, "fileList": [{"uid": "rc-upload-1503203908709-7", "name": "avatar-3449c9e5e332f1dbb81505cd739fbf3f.zip", "size": 36630, "type": "application/x-zip-compressed", "status": "done", "percent": 100, "response": {"msg": "avatar-3449c9e5e332f1dbb81505cd739fbf3f.zip", "success": true}, "lastModified": 1503197439705, "originFileObj": {"uid": "rc-upload-1503203908709-7"}, "lastModifiedDate": "2017-08-20T02:50:39.705Z"}]}
\.


--
-- TOC entry 2520 (class 0 OID 0)
-- Dependencies: 197
-- Name: gwconfig_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pipeline
--

SELECT pg_catalog.setval('gwconfig_id_seq', 4, true);


--
-- TOC entry 2521 (class 0 OID 0)
-- Dependencies: 190
-- Name: idseq; Type: SEQUENCE SET; Schema: public; Owner: pipeline
--

SELECT pg_catalog.setval('idseq', 1, false);


--
-- TOC entry 2494 (class 0 OID 16631)
-- Dependencies: 212
-- Data for Name: lookup; Type: TABLE DATA; Schema: public; Owner: pipeline
--

COPY lookup (id, code, name, parentid) FROM stdin;
2	deptype_system	系统设定	1
1	deptype	部门类别	0
3	deptype_user	用户设定	1
\.


--
-- TOC entry 2522 (class 0 OID 0)
-- Dependencies: 211
-- Name: lookup_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pipeline
--

SELECT pg_catalog.setval('lookup_id_seq', 1, false);


--
-- TOC entry 2476 (class 0 OID 16517)
-- Dependencies: 194
-- Data for Name: menu; Type: TABLE DATA; Schema: public; Owner: pipeline
--

COPY menu (id, code, name, icon, mpid, route, bpid) FROM stdin;
\.


--
-- TOC entry 2523 (class 0 OID 0)
-- Dependencies: 193
-- Name: menu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pipeline
--

SELECT pg_catalog.setval('menu_id_seq', 1, false);


--
-- TOC entry 2486 (class 0 OID 16583)
-- Dependencies: 204
-- Data for Name: node; Type: TABLE DATA; Schema: public; Owner: pipeline
--

COPY node (id, code, modelid, gwid) FROM stdin;
\.


--
-- TOC entry 2524 (class 0 OID 0)
-- Dependencies: 203
-- Name: node_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pipeline
--

SELECT pg_catalog.setval('node_id_seq', 1, false);


--
-- TOC entry 2492 (class 0 OID 16617)
-- Dependencies: 210
-- Data for Name: person; Type: TABLE DATA; Schema: public; Owner: pipeline
--

COPY person (id, usercode, username, password, depid, roleid, menus, attrs) FROM stdin;
1	test	测试用户23	111111	3	1	\N	{"phone": 138111111, "address": "北京1"}
3	aa	dd	\N	3	2	\N	{}
2	user1	测试	dddd	4	2	\N	{"phone": "13533333333", "address": "爱爱爱"}
5	dd	ffdd	ddd	3	2	\N	{}
7	a	b	fff	1	2	\N	{}
\.


--
-- TOC entry 2525 (class 0 OID 0)
-- Dependencies: 209
-- Name: person_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pipeline
--

SELECT pg_catalog.setval('person_id_seq', 8, true);


--
-- TOC entry 2478 (class 0 OID 16528)
-- Dependencies: 196
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: pipeline
--

COPY role (id, code, name) FROM stdin;
1	admin	管理员
2	viewer	查看员
\.


--
-- TOC entry 2526 (class 0 OID 0)
-- Dependencies: 195
-- Name: role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pipeline
--

SELECT pg_catalog.setval('role_id_seq', 2, true);


--
-- TOC entry 2340 (class 2606 OID 16580)
-- Name: datamodel datamodel_pkey; Type: CONSTRAINT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY datamodel
    ADD CONSTRAINT datamodel_pkey PRIMARY KEY (id);


--
-- TOC entry 2330 (class 2606 OID 16514)
-- Name: department department_pkey; Type: CONSTRAINT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY department
    ADD CONSTRAINT department_pkey PRIMARY KEY (id);


--
-- TOC entry 2346 (class 2606 OID 16613)
-- Name: device device_pkey; Type: CONSTRAINT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY device
    ADD CONSTRAINT device_pkey PRIMARY KEY (id);


--
-- TOC entry 2344 (class 2606 OID 16602)
-- Name: devicetype devicetype_pkey; Type: CONSTRAINT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY devicetype
    ADD CONSTRAINT devicetype_pkey PRIMARY KEY (id);


--
-- TOC entry 2338 (class 2606 OID 16569)
-- Name: gateway gateway_pkey; Type: CONSTRAINT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY gateway
    ADD CONSTRAINT gateway_pkey PRIMARY KEY (id);


--
-- TOC entry 2336 (class 2606 OID 16558)
-- Name: gwconfig gwconfig_pkey; Type: CONSTRAINT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY gwconfig
    ADD CONSTRAINT gwconfig_pkey PRIMARY KEY (id);


--
-- TOC entry 2350 (class 2606 OID 16639)
-- Name: lookup lookup_pkey; Type: CONSTRAINT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY lookup
    ADD CONSTRAINT lookup_pkey PRIMARY KEY (id);


--
-- TOC entry 2332 (class 2606 OID 16525)
-- Name: menu menu_pkey; Type: CONSTRAINT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY menu
    ADD CONSTRAINT menu_pkey PRIMARY KEY (id);


--
-- TOC entry 2342 (class 2606 OID 16591)
-- Name: node node_pkey; Type: CONSTRAINT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY node
    ADD CONSTRAINT node_pkey PRIMARY KEY (id);


--
-- TOC entry 2348 (class 2606 OID 16625)
-- Name: person person_pkey; Type: CONSTRAINT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY person
    ADD CONSTRAINT person_pkey PRIMARY KEY (id);


--
-- TOC entry 2334 (class 2606 OID 16536)
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: pipeline
--

ALTER TABLE ONLY role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- TOC entry 2502 (class 0 OID 0)
-- Dependencies: 7
-- Name: public; Type: ACL; Schema: -; Owner: pipeline
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM pipeline;
GRANT ALL ON SCHEMA public TO pipeline;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2017-08-30 11:57:05

--
-- PostgreSQL database dump complete
--

