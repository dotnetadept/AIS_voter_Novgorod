--
-- PostgreSQL database dump
--

-- Dumped from database version 12.11 (Ubuntu 12.11-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.11 (Ubuntu 12.11-0ubuntu0.20.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _agenda; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._agenda (
    id bigint NOT NULL,
    name text NOT NULL,
    folder text NOT NULL,
    createddate timestamp without time zone NOT NULL,
    lastupdated timestamp without time zone NOT NULL
);


ALTER TABLE public._agenda OWNER TO postgres;

--
-- Name: _agenda_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public._agenda_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public._agenda_id_seq OWNER TO postgres;

--
-- Name: _agenda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public._agenda_id_seq OWNED BY public._agenda.id;


--
-- Name: _aqueduct_version_pgsql; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._aqueduct_version_pgsql (
    versionnumber integer NOT NULL,
    dateofupgrade timestamp without time zone NOT NULL
);


ALTER TABLE public._aqueduct_version_pgsql OWNER TO postgres;

--
-- Name: _file; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._file (
    id bigint NOT NULL,
    path text NOT NULL,
    filename text NOT NULL,
    description text NOT NULL,
    question_id bigint,
    version text
);


ALTER TABLE public._file OWNER TO postgres;

--
-- Name: _file_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public._file_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public._file_id_seq OWNER TO postgres;

--
-- Name: _file_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public._file_id_seq OWNED BY public._file.id;


--
-- Name: _group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._group (
    id bigint NOT NULL,
    name text NOT NULL,
    lawuserscount integer NOT NULL,
    quorumcount integer NOT NULL,
    majoritycount integer NOT NULL,
    onethirdscount integer NOT NULL,
    twothirdscount integer NOT NULL,
    majoritychosencount integer NOT NULL,
    onethirdschosencount integer NOT NULL,
    twothirdschosencount integer NOT NULL,
    roundingroule text NOT NULL,
    workplaces text NOT NULL,
    isactive boolean NOT NULL,
    ismanagerautoauthentication boolean NOT NULL,
    ismanagerautoregistration boolean NOT NULL,
    unblockedmics text NOT NULL
);


ALTER TABLE public._group OWNER TO postgres;

--
-- Name: _group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public._group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public._group_id_seq OWNER TO postgres;

--
-- Name: _group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public._group_id_seq OWNED BY public._group.id;


--
-- Name: _groupuser; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._groupuser (
    id bigint NOT NULL,
    ismanager boolean NOT NULL,
    group_id bigint,
    user_id bigint
);


ALTER TABLE public._groupuser OWNER TO postgres;

--
-- Name: _groupuser_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public._groupuser_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public._groupuser_id_seq OWNER TO postgres;

--
-- Name: _groupuser_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public._groupuser_id_seq OWNED BY public._groupuser.id;


--
-- Name: _meeting; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._meeting (
    id bigint NOT NULL,
    name text NOT NULL,
    status text NOT NULL,
    lastupdated timestamp without time zone NOT NULL,
    agenda_id bigint,
    group_id bigint,
    description text NOT NULL
);


ALTER TABLE public._meeting OWNER TO postgres;

--
-- Name: _meeting_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public._meeting_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public._meeting_id_seq OWNER TO postgres;

--
-- Name: _meeting_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public._meeting_id_seq OWNED BY public._meeting.id;


--
-- Name: _meetingsession; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._meetingsession (
    id bigint NOT NULL,
    meetingid integer NOT NULL,
    startdate timestamp without time zone,
    enddate timestamp without time zone
);


ALTER TABLE public._meetingsession OWNER TO postgres;

--
-- Name: _meetingsession_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public._meetingsession_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public._meetingsession_id_seq OWNER TO postgres;

--
-- Name: _meetingsession_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public._meetingsession_id_seq OWNED BY public._meetingsession.id;


--
-- Name: _question; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._question (
    id bigint NOT NULL,
    name text NOT NULL,
    ordernum integer NOT NULL,
    description text NOT NULL,
    folder text NOT NULL,
    agenda_id bigint
);


ALTER TABLE public._question OWNER TO postgres;

--
-- Name: _question_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public._question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public._question_id_seq OWNER TO postgres;

--
-- Name: _question_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public._question_id_seq OWNED BY public._question.id;


--
-- Name: _questionsession; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._questionsession (
    id bigint NOT NULL,
    meetingsessionid integer NOT NULL,
    questionid integer NOT NULL,
    votingmodeid integer NOT NULL,
    desicion text NOT NULL,
    "interval" integer NOT NULL,
    userscountregistred integer NOT NULL,
    userscountforsuccess integer NOT NULL,
    startdate timestamp without time zone NOT NULL,
    enddate timestamp without time zone,
    userscountvoted integer,
    userscountvotedyes integer,
    userscountvotedno integer,
    userscountvotedindiffirent integer
);


ALTER TABLE public._questionsession OWNER TO postgres;

--
-- Name: _questionsession_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public._questionsession_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public._questionsession_id_seq OWNER TO postgres;

--
-- Name: _questionsession_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public._questionsession_id_seq OWNED BY public._questionsession.id;


--
-- Name: _registration; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._registration (
    id bigint NOT NULL,
    userid integer NOT NULL,
    registrationsession_id bigint NOT NULL
);


ALTER TABLE public._registration OWNER TO postgres;

--
-- Name: _registration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public._registration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public._registration_id_seq OWNER TO postgres;

--
-- Name: _registration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public._registration_id_seq OWNED BY public._registration.id;


--
-- Name: _registrationsession; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._registrationsession (
    id bigint NOT NULL,
    meetingid integer NOT NULL,
    "interval" integer NOT NULL,
    startdate timestamp without time zone,
    enddate timestamp without time zone
);


ALTER TABLE public._registrationsession OWNER TO postgres;

--
-- Name: _registrationsession_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public._registrationsession_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public._registrationsession_id_seq OWNER TO postgres;

--
-- Name: _registrationsession_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public._registrationsession_id_seq OWNED BY public._registrationsession.id;


--
-- Name: _result; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._result (
    id bigint NOT NULL,
    questionsession_id bigint NOT NULL,
    userid integer NOT NULL,
    result text NOT NULL
);


ALTER TABLE public._result OWNER TO postgres;

--
-- Name: _result_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public._result_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public._result_id_seq OWNER TO postgres;

--
-- Name: _result_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public._result_id_seq OWNED BY public._result.id;


--
-- Name: _settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._settings (
    id bigint NOT NULL,
    pallettesettings text,
    operatorschemesettings text,
    managerschemesettings text,
    votingsettings text,
    storeboardsettings text,
    licensesettings text,
    soundsettings text
);


ALTER TABLE public._settings OWNER TO postgres;

--
-- Name: _settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public._settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public._settings_id_seq OWNER TO postgres;

--
-- Name: _settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public._settings_id_seq OWNED BY public._settings.id;


--
-- Name: _storeboardtemplate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._storeboardtemplate (
    id bigint NOT NULL,
    name text NOT NULL,
    items text NOT NULL
);


ALTER TABLE public._storeboardtemplate OWNER TO postgres;

--
-- Name: _storeboardtemplate_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public._storeboardtemplate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public._storeboardtemplate_id_seq OWNER TO postgres;

--
-- Name: _storeboardtemplate_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public._storeboardtemplate_id_seq OWNED BY public._storeboardtemplate.id;


--
-- Name: _user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._user (
    id bigint NOT NULL,
    firstname text NOT NULL,
    secondname text NOT NULL,
    lastname text NOT NULL,
    login text NOT NULL,
    password text NOT NULL,
    lastsession timestamp without time zone,
    isvoter boolean DEFAULT true NOT NULL,
    cardid text NOT NULL
);


ALTER TABLE public._user OWNER TO postgres;

--
-- Name: _user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public._user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public._user_id_seq OWNER TO postgres;

--
-- Name: _user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public._user_id_seq OWNED BY public._user.id;


--
-- Name: _votingmode; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public._votingmode (
    id bigint NOT NULL,
    name text NOT NULL,
    defaultdecision text NOT NULL,
    ordernum integer NOT NULL,
    includeddecisions text NOT NULL
);


ALTER TABLE public._votingmode OWNER TO postgres;

--
-- Name: _votingmode_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public._votingmode_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public._votingmode_id_seq OWNER TO postgres;

--
-- Name: _votingmode_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public._votingmode_id_seq OWNED BY public._votingmode.id;


--
-- Name: _agenda id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._agenda ALTER COLUMN id SET DEFAULT nextval('public._agenda_id_seq'::regclass);


--
-- Name: _file id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._file ALTER COLUMN id SET DEFAULT nextval('public._file_id_seq'::regclass);


--
-- Name: _group id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._group ALTER COLUMN id SET DEFAULT nextval('public._group_id_seq'::regclass);


--
-- Name: _groupuser id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._groupuser ALTER COLUMN id SET DEFAULT nextval('public._groupuser_id_seq'::regclass);


--
-- Name: _meeting id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._meeting ALTER COLUMN id SET DEFAULT nextval('public._meeting_id_seq'::regclass);


--
-- Name: _meetingsession id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._meetingsession ALTER COLUMN id SET DEFAULT nextval('public._meetingsession_id_seq'::regclass);


--
-- Name: _question id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._question ALTER COLUMN id SET DEFAULT nextval('public._question_id_seq'::regclass);


--
-- Name: _questionsession id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._questionsession ALTER COLUMN id SET DEFAULT nextval('public._questionsession_id_seq'::regclass);


--
-- Name: _registration id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._registration ALTER COLUMN id SET DEFAULT nextval('public._registration_id_seq'::regclass);


--
-- Name: _registrationsession id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._registrationsession ALTER COLUMN id SET DEFAULT nextval('public._registrationsession_id_seq'::regclass);


--
-- Name: _result id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._result ALTER COLUMN id SET DEFAULT nextval('public._result_id_seq'::regclass);


--
-- Name: _settings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._settings ALTER COLUMN id SET DEFAULT nextval('public._settings_id_seq'::regclass);


--
-- Name: _storeboardtemplate id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._storeboardtemplate ALTER COLUMN id SET DEFAULT nextval('public._storeboardtemplate_id_seq'::regclass);


--
-- Name: _user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._user ALTER COLUMN id SET DEFAULT nextval('public._user_id_seq'::regclass);


--
-- Name: _votingmode id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._votingmode ALTER COLUMN id SET DEFAULT nextval('public._votingmode_id_seq'::regclass);


--
-- Data for Name: _agenda; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._agenda (id, name, folder, createddate, lastupdated) FROM stdin;
\.


--
-- Data for Name: _aqueduct_version_pgsql; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._aqueduct_version_pgsql (versionnumber, dateofupgrade) FROM stdin;
\.


--
-- Data for Name: _file; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._file (id, path, filename, description, question_id, version) FROM stdin;
\.


--
-- Data for Name: _group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._group (id, name, lawuserscount, quorumcount, majoritycount, onethirdscount, twothirdscount, majoritychosencount, onethirdschosencount, twothirdschosencount, roundingroule, workplaces, isactive, ismanagerautoauthentication, ismanagerautoregistration, unblockedmics) FROM stdin;
2	Законодательное собрание Краснодарского края	70	20	13	10	10	4334	0	0	Отбросить после запятой	{"hasManagement":true,"tribunePlacesCount":3,"hasTribune":true,"managementPlacesCount":6,"rowsCount":10,"rows":[3,7,8,8,8,8,8,8,8,7],"isDisplayEmptyCell":[true,true,true,true,true,true,true,true,true,true],"schemeManagement":[null,null,null,null,null,null],"managementTerminalIds":["012","011","010","005","009","008"],"tribuneTerminalIds":["086","001,002","088"],"tribuneNames":["Левый микрофон","Трибуна","Правый микрофон"],"schemeWorkplaces":[[null,null,null],[null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,40],[null,null,null,null,null,null,5]],"workplacesTerminalIds":[["033","032","031"],["078","069","060","051","042","030","021"],["085","077","068","059","050","041","029","020"],["084","076","067","058","049","040","028","019"],["083","075","066","057","048","039","027","018"],["082","074","065","056","047","038","026","017"],["081","073","064","055","046","037","025","016"],["080","072","063","054","045","036","024","015"],["079","071","062","053","044","035","023","014"],["070","061","052","043","034","022","013"]]}	t	f	f	001,002
16	Законодательное собрание Краснодарского края_копия	70	20	13	10	10	0	0	0	Отбросить после запятой	{"hasManagement":true,"tribunePlacesCount":3,"hasTribune":true,"managementPlacesCount":6,"rowsCount":10,"rows":[3,7,8,8,8,8,8,8,8,7],"isDisplayEmptyCell":[true,true,true,true,true,true,true,true,true,true],"schemeManagement":[null,null,null,null,null,null],"managementTerminalIds":["012","011","010","005","009","008"],"tribuneTerminalIds":["086","001,002","088"],"tribuneNames":["Левый микрофон","Трибуна","Правый микрофон"],"schemeWorkplaces":[[null,null,null],[null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,30],[null,null,null,null,null,null,null,29],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,5]],"workplacesTerminalIds":[["033","032","031"],["078","069","060","051","042","030","021"],["085","077","068","059","050","041","029","020"],["084","076","067","058","049","040","028","019"],["083","075","066","057","048","039","027","018"],["082","074","065","056","047","038","026","017"],["081","073","064","055","046","037","025","016"],["080","072","063","054","045","036","024","015"],["079","071","062","053","044","035","023","014"],["070","061","052","043","034","022","013"]]}	t	f	f	001,002
\.


--
-- Data for Name: _groupuser; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._groupuser (id, ismanager, group_id, user_id) FROM stdin;
2242	t	2	13
2243	f	2	2
2244	f	2	3
2245	f	2	4
2246	f	2	5
2247	f	2	6
2248	f	2	7
2249	f	2	8
2250	f	2	9
2251	f	2	10
2252	f	2	11
2253	f	2	29
2254	f	2	30
2255	f	2	31
2256	f	2	32
2257	f	2	33
2258	f	2	34
2259	f	2	35
2260	f	2	36
2261	f	2	37
2262	f	2	38
2263	f	2	39
2264	f	2	40
2265	f	2	41
2266	f	2	42
2267	f	2	43
2268	f	2	44
2269	f	2	45
2270	f	2	46
2271	f	2	47
2272	f	2	48
2273	f	2	49
2274	f	2	50
2275	f	2	51
2276	f	2	52
2277	f	2	53
2278	f	2	54
2279	f	2	55
2280	f	2	56
2281	f	2	57
2282	f	2	58
2283	f	2	59
2284	f	2	60
2285	f	2	61
2286	f	2	62
2287	f	2	63
2288	f	2	64
2289	f	2	65
2290	f	2	66
2291	f	2	67
2292	f	2	68
2293	f	2	69
2294	f	2	70
2295	f	2	12
2296	f	2	14
2297	f	2	15
2298	f	2	16
2299	f	2	17
2300	f	2	18
2301	f	2	19
2302	f	2	20
2303	f	2	21
2304	f	2	22
2305	f	2	23
2306	f	2	24
2307	f	2	25
2308	f	2	26
2309	f	2	27
2310	f	2	28
1966	t	16	13
1967	f	16	2
1968	f	16	3
1969	f	16	4
1970	f	16	5
1971	f	16	6
1972	f	16	7
1973	f	16	8
1974	f	16	9
1975	f	16	10
1976	f	16	11
1977	f	16	29
1978	f	16	30
1979	f	16	31
1980	f	16	32
1981	f	16	33
1982	f	16	34
1983	f	16	35
1984	f	16	36
1985	f	16	37
1986	f	16	38
1987	f	16	39
1988	f	16	40
1989	f	16	41
1990	f	16	42
1991	f	16	43
1992	f	16	44
1993	f	16	45
1994	f	16	46
1995	f	16	47
1996	f	16	48
1997	f	16	49
1998	f	16	50
1999	f	16	51
2000	f	16	52
2001	f	16	53
2002	f	16	54
2003	f	16	55
2004	f	16	56
2005	f	16	57
2006	f	16	58
2007	f	16	59
2008	f	16	60
2009	f	16	61
2010	f	16	62
2011	f	16	63
2012	f	16	64
2013	f	16	65
2014	f	16	66
2015	f	16	67
2016	f	16	68
2017	f	16	69
2018	f	16	70
2019	f	16	12
2020	f	16	14
2021	f	16	15
2022	f	16	16
2023	f	16	17
2024	f	16	18
2025	f	16	19
2026	f	16	20
2027	f	16	21
2028	f	16	22
2029	f	16	23
2030	f	16	24
2031	f	16	25
2032	f	16	26
2033	f	16	27
2034	f	16	28
\.


--
-- Data for Name: _meeting; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._meeting (id, name, status, lastupdated, agenda_id, group_id, description) FROM stdin;
\.


--
-- Data for Name: _meetingsession; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._meetingsession (id, meetingid, startdate, enddate) FROM stdin;
\.


--
-- Data for Name: _question; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._question (id, name, ordernum, description, folder, agenda_id) FROM stdin;
\.


--
-- Data for Name: _questionsession; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._questionsession (id, meetingsessionid, questionid, votingmodeid, desicion, "interval", userscountregistred, userscountforsuccess, startdate, enddate, userscountvoted, userscountvotedyes, userscountvotedno, userscountvotedindiffirent) FROM stdin;
\.


--
-- Data for Name: _registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._registration (id, userid, registrationsession_id) FROM stdin;
\.


--
-- Data for Name: _registrationsession; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._registrationsession (id, meetingid, "interval", startdate, enddate) FROM stdin;
\.


--
-- Data for Name: _result; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._result (id, questionsession_id, userid, result) FROM stdin;
\.


--
-- Data for Name: _settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._settings (id, pallettesettings, operatorschemesettings, managerschemesettings, votingsettings, storeboardsettings, licensesettings, soundsettings) FROM stdin;
1	{"backgroundColor":4288585374,"schemeBackgroundColor":1040187391,"cellColor":520093696,"alternateCellColor":503316480,"alternateRowNumbers":"1","alternateRowPadding":10,"paddingRowNumbers":"0,4,5,6","cellTextColor":4278716424,"cellBorderColor":2315255808,"unRegistredColor":4294967295,"registredColor":4283953953,"voteYesColor":4284084398,"voteNoColor":4294937216,"voteIndifferentColor":4294703424,"askWordColor":4282085887,"onSpeechColor":4289961435,"buttonTextColor":4294967295,"iconOnlineColor":4283215696,"iconOfflineColor":4294198070,"iconDocumentsDownloadedColor":4283215696,"iconDocumentsNotDownloadedColor":4294198070}	{"inverseScheme":true,"controlSound":false,"cellWidth":120,"cellBorder":1,"cellInnerPadding":4,"cellOuterPaddingVertical":5,"cellOuterPaddingHorisontal":4,"isShortNamesUsed":true,"cellTextSize":14,"overflowOption":"Обрезать текст","textMaxLines":1,"showOverflow":true,"iconSize":20}	{"inverseScheme":false,"controlSound":false,"cellWidth":120,"cellBorder":1,"cellInnerPadding":1,"cellOuterPaddingVertical":20,"cellOuterPaddingHorisontal":2,"isShortNamesUsed":true,"cellTextSize":16,"overflowOption":"Обрезать текст","textMaxLines":1,"showOverflow":true,"iconSize":32,"deputyFontSize":21,"deputyNumberFontSize":22,"deputyCaptionFontSize":20,"deputyFilesListHeight":310}	{"isVotingFixed":false,"defaultRegistrationInterval":45,"defaultVotingInterval":70,"defaultShowResultInterval":2,"defaultNewQuestionName":"Вопрос","defaultFirstQuestionName":"Регламентные вопросы","defaultFirstQuestionVotingName":"регламентным вопросам","defaultQuestionNumberPrefix":"","isFirstQuestionUseNumber":false,"defaultVotingModeId":1,"reportsFolderPath":"/home/user/Рабочий стол/Протоколы"}	{"backgroundColor":4278255718,"textColor":4294967295,"height":255,"width":450,"padding":10,"meetingDescriptionTemplate":"Очередное \\nпленарное заседание\\nЗаконодательного Собрания\\nКраснодарского края\\nшестого созыва","speakerInterval":0,"breakInterval":1800,"meetingDescriptionFontSize":16,"meetingFontSize":14,"groupFontSize":14,"customCaptionFontSize":18,"customTextFontSize":16,"resultItemsFontSize":18,"resultTotalFontSize":24,"timersFontSize":24,"questionNameFontSize":14,"questionDescriptionFontSize":14,"justifyQuestionDescription":true,"clockFontSize":14,"clockFontBold":false,"detailsAnimationDuration":3,"detailsRowsCount":5,"detailsFontSize":18}	{"licenseKey":"00001-00001-00080-00001-00002"}	{"registrationStart":"/home/vladimir/Downloads/ding.mp3","registrationEnd":"","votingStart":"/home/user/Музыка/ding.mp3","votingEnd":"","hymnStart":"/home/user/Музыка/ГИМН_СЕССИЯ.mp3","hymnEnd":"/home/user/Музыка/гимн_без_слов.mp3","defaultStreamUrl":"Process.run('pkill', <String>['-f', 'firefox']);"}
\.


--
-- Data for Name: _storeboardtemplate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._storeboardtemplate (id, name, items) FROM stdin;
1	1	[{"order":0,"text":"432","fontSize":143,"weight":"Жирный","align":"По правому краю"},{"order":1,"text":"2222222","fontSize":14,"weight":"Жирный","align":"По левому краю"},{"order":2,"text":"4444","fontSize":8,"weight":"Жирный","align":"По центру"}]
2	2	[{"order":0,"text":"111111111111111111111111","fontSize":14,"weight":"Обычный","align":"По центру"},{"order":1,"text":"22222222222222222222","fontSize":89,"weight":"Обычный","align":"По правому краю"}]
3	аротанребуг еинелпутсыв	[{"order":0,"text":" иицаратсинимdfdA fdfkU","fontSize":20,"weight":"Обычный","align":"По центру"},{"order":1,"text":"ЧИВЕЬТАРДНОК","fontSize":30,"weight":"Жирный","align":"По центру"}]
4	В	[{"order":0,"text":"","fontSize":14,"weight":"Обычный","align":"По центру"},{"order":1,"text":"","fontSize":14,"weight":"Обычный","align":"По левому краю"},{"order":2,"text":"","fontSize":14,"weight":"Жирный","align":"По правому краю"}]
1	1	[{"order":0,"text":"432","fontSize":143,"weight":"Жирный","align":"По правому краю"},{"order":1,"text":"2222222","fontSize":14,"weight":"Жирный","align":"По левому краю"},{"order":2,"text":"4444","fontSize":8,"weight":"Жирный","align":"По центру"}]
2	2	[{"order":0,"text":"111111111111111111111111","fontSize":14,"weight":"Обычный","align":"По центру"},{"order":1,"text":"22222222222222222222","fontSize":89,"weight":"Обычный","align":"По правому краю"}]
3	аротанребуг еинелпутсыв	[{"order":0,"text":" иицаратсинимdfdA fdfkU","fontSize":20,"weight":"Обычный","align":"По центру"},{"order":1,"text":"ЧИВЕЬТАРДНОК","fontSize":30,"weight":"Жирный","align":"По центру"}]
4	В	[{"order":0,"text":"","fontSize":14,"weight":"Обычный","align":"По центру"},{"order":1,"text":"","fontSize":14,"weight":"Обычный","align":"По левому краю"},{"order":2,"text":"","fontSize":14,"weight":"Жирный","align":"По правому краю"}]
1	1	[{"order":0,"text":"432","fontSize":143,"weight":"Жирный","align":"По правому краю"},{"order":1,"text":"2222222","fontSize":14,"weight":"Жирный","align":"По левому краю"},{"order":2,"text":"4444","fontSize":8,"weight":"Жирный","align":"По центру"}]
2	2	[{"order":0,"text":"111111111111111111111111","fontSize":14,"weight":"Обычный","align":"По центру"},{"order":1,"text":"22222222222222222222","fontSize":89,"weight":"Обычный","align":"По правому краю"}]
3	аротанребуг еинелпутсыв	[{"order":0,"text":" иицаратсинимdfdA fdfkU","fontSize":20,"weight":"Обычный","align":"По центру"},{"order":1,"text":"ЧИВЕЬТАРДНОК","fontSize":30,"weight":"Жирный","align":"По центру"}]
4	В	[{"order":0,"text":"","fontSize":14,"weight":"Обычный","align":"По центру"},{"order":1,"text":"","fontSize":14,"weight":"Обычный","align":"По левому краю"},{"order":2,"text":"","fontSize":14,"weight":"Жирный","align":"По правому краю"}]
\.


--
-- Data for Name: _user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._user (id, firstname, secondname, lastname, login, password, lastsession, isvoter, cardid) FROM stdin;
2	Владимир	Агафонов	Александрович	1	1	\N	t	1
3	Александр	Агеев	Александрович	2	2	\N	t	2
4	Юлия	Алешкевич	Сергеевна	3	3	\N	t	3
5	Сергей	Алтухов	Викторович	4	4	\N	t	4
6	Иван	Артеменко	Петрович	5	5	\N	t	5
7	Александра	Бакина	Андреевна	6	6	\N	t	6
8	Иван	Безуглый	Васильевич	7	7	\N	t	7
9	Сергей	Белан	Алексеевич	8	8	\N	t	8
10	Жанна	Беловол	Викторовна	9	9	\N	t	9
11	Олег	Бойченко	Игоревич	10	10	\N	t	10
29	Андрей	Куемжиев	Александрович	28	28	\N	t	28
30	Эдуард	Кузнецов	Анатольевич	29	29	\N	t	29
31	Дмитрий	Лебедев	Геннадьевич	30	30	\N	t	30
32	Борис	Левитский	Евгеньевич	31	31	\N	t	31
33	Дмитрий	Лоцманов	Николаевич	32	32	\N	t	32
34	Владимир	Лыбанев	Викторович	33	33	\N	t	33
35	Сергей	Орленко	Юрьевич	34	34	\N	t	34
36	Сергей	Орлов	Иванович	35	35	\N	t	35
37	Батырбий	Панеш	Мугдинович	36	36	\N	t	36
38	Роберт	Паранянц	Васильевич	37	37	\N	t	37
39	Юлия	Пархоменко	Викторовна	38	38	\N	t	38
40	Николай	Петропавловский	Николаевич	39	39	\N	t	39
41	Александр	Поголов	Викторович	40	40	\N	t	40
42	Владимир	Порханов	Алексеевич	41	41	\N	t	41
43	Татьяна	Рой	Геннадьевна	42	42	\N	t	42
44	Алексей	Руднев	Валентинович	43	43	\N	t	43
45	Петр	Савельев	Александрович	44	44	\N	t	44
46	Алексей	Сафронов	Иванович	45	45	\N	t	45
47	Вячеслав	Сбитнев	Леонидович	46	46	\N	t	46
48	Андрей	Сигидин	Сергеевич	47	47	\N	t	47
49	Алексей	Сидюков	Алексеевич	48	48	\N	t	48
50	Павел	Соколенко	Васильевич	49	49	\N	t	49
51	Виктор	Тепляков	Нодариевич	50	50	\N	t	50
52	Алексей	Титов	Николаевич	51	51	\N	t	51
53	Александр	Трубилин	Иванович	52	52	\N	t	52
54	Батырбий	Тутаришев	Зульевич	53	53	\N	t	53
55	Иван	Тутушкин	Геннадьевич	54	54	\N	t	54
57	Александр	Хараман	Юрьевич	56	56	\N	t	56
58	Владимир	Харламов	Иванович	57	57	\N	t	57
59	Денис	Хмелевской	Леонидович	58	58	\N	t	58
60	Сергей	Чабанец	Григорьевич	59	59	\N	t	59
61	Сергей	Чвикалов	Викторович	60	60	\N	t	60
62	Владимир	Чепель	Вячеславович	61	61	\N	t	61
63	Виктор	Чернявский	Васильевич	62	62	\N	t	62
64	Геннадий	Шабунин	Дмитриевич	63	63	\N	t	63
65	Сергей	Шатохин	Викторович	64	64	\N	t	64
66	Евгений	Шендрик	Демьянович	65	65	\N	t	65
67	Евгения	Шумейко	Владимировна	66	66	\N	t	66
68	Борис	Юнанов	Геннадьевич	67	67	\N	t	67
69	Сергей	Ярышев	Николаевич	68	68	\N	t	68
70	Владимир	Ященко	Иванович	69	69	\N	t	69
12	Андрей	Булдин	Владимирович	11	11	\N	t	11
13	Юрий	Бурлачко	Александрович	12	12	\N	t	12
14	Александр	Галенко	Петрович	13	13	\N	t	13
15	Андрей	Горбань	Евгеньевич	14	14	\N	t	14
16	Николай	Гриценко	Павлович	15	15	\N	t	15
17	Александр	Джеус	Васильевич	16	16	\N	t	16
18	Константин	Димитриев	Триондофилович	17	17	\N	t	17
19	Андрей	Дорошенко	Николаевич	18	18	\N	t	18
20	Сергей	Жиленко	Викторович	19	19	\N	t	19
21	Иван	Жилищиков	Андреевич	20	20	\N	t	20
22	Александр	Звягин	Анатольевич	21	21	\N	t	21
23	Владимир	Зюзин	Александрович	22	22	\N	t	22
24	Ирина	Караваева	Владимировна	23	23	\N	t	23
25	Сергей	Кизинёк	Владимирович	24	24	\N	t	24
26	Ирина	Конограева	Дмитриевна	25	25	\N	t	25
27	Николай	Кравченко	Петрович	26	26	\N	t	26
28	Борис	Красавцев	Евгеньевич	27	27	\N	t	27
56	Сергей	Усенко	Павлович	551	55	\N	t	55
71	d	d	d	d	d	\N	t	70
72	2	2	2	2	2	\N	t	2
73	3	3	3	3	3	\N	t	3
\.


--
-- Data for Name: _votingmode; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._votingmode (id, name, defaultdecision, ordernum, includeddecisions) FROM stdin;
1	Принять	Большинство от установленного числа	0	Большинство от установленного числа;2/3 от установленного числа;1/3 от установленного числа;Большинство от выбранных членов;2/3 от выбранных членов;1/3 от выбранных членов;Большинство от зарегистрированных членов;2/3 от зарегистрированных членов;1/3 от зарегистрированных членов;
2	Отклонить	Большинство от установленного числа	1	Большинство от установленного числа;2/3 от установленного числа;1/3 от установленного числа;Большинство от выбранных членов;2/3 от выбранных членов;1/3 от выбранных членов;Большинство от зарегистрированных членов;2/3 от зарегистрированных членов;1/3 от зарегистрированных членов;
\.


--
-- Name: _agenda_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._agenda_id_seq', 75, true);


--
-- Name: _file_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._file_id_seq', 6839, true);


--
-- Name: _group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._group_id_seq', 16, true);


--
-- Name: _groupuser_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._groupuser_id_seq', 2310, true);


--
-- Name: _meeting_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._meeting_id_seq', 122, true);


--
-- Name: _meetingsession_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._meetingsession_id_seq', 299, true);


--
-- Name: _question_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._question_id_seq', 2061, true);


--
-- Name: _questionsession_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._questionsession_id_seq', 2394, true);


--
-- Name: _registration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._registration_id_seq', 4287, true);


--
-- Name: _registrationsession_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._registrationsession_id_seq', 704, true);


--
-- Name: _result_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._result_id_seq', 27636, true);


--
-- Name: _settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._settings_id_seq', 5, true);


--
-- Name: _storeboardtemplate_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._storeboardtemplate_id_seq', 4, true);


--
-- Name: _user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._user_id_seq', 73, true);


--
-- Name: _votingmode_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._votingmode_id_seq', 4, true);


--
-- Name: _agenda _agenda_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._agenda
    ADD CONSTRAINT _agenda_pkey PRIMARY KEY (id);


--
-- Name: _aqueduct_version_pgsql _aqueduct_version_pgsql_versionnumber_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._aqueduct_version_pgsql
    ADD CONSTRAINT _aqueduct_version_pgsql_versionnumber_key UNIQUE (versionnumber);


--
-- Name: _file _file_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._file
    ADD CONSTRAINT _file_pkey PRIMARY KEY (id);


--
-- Name: _group _group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._group
    ADD CONSTRAINT _group_pkey PRIMARY KEY (id);


--
-- Name: _groupuser _groupuser_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._groupuser
    ADD CONSTRAINT _groupuser_pkey PRIMARY KEY (id);


--
-- Name: _meeting _meeting_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._meeting
    ADD CONSTRAINT _meeting_pkey PRIMARY KEY (id);


--
-- Name: _meetingsession _meetingsession_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._meetingsession
    ADD CONSTRAINT _meetingsession_pkey PRIMARY KEY (id);


--
-- Name: _question _question_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._question
    ADD CONSTRAINT _question_pkey PRIMARY KEY (id);


--
-- Name: _questionsession _questionsession_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._questionsession
    ADD CONSTRAINT _questionsession_pkey PRIMARY KEY (id);


--
-- Name: _registration _registration_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._registration
    ADD CONSTRAINT _registration_pkey PRIMARY KEY (id);


--
-- Name: _registrationsession _registrationsession_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._registrationsession
    ADD CONSTRAINT _registrationsession_pkey PRIMARY KEY (id);


--
-- Name: _result _result_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._result
    ADD CONSTRAINT _result_pkey PRIMARY KEY (id);


--
-- Name: _settings _settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._settings
    ADD CONSTRAINT _settings_pkey PRIMARY KEY (id);


--
-- Name: _user _user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._user
    ADD CONSTRAINT _user_pkey PRIMARY KEY (id);


--
-- Name: _votingmode _votingmode_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._votingmode
    ADD CONSTRAINT _votingmode_pkey PRIMARY KEY (id);


--
-- Name: _file_question_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX _file_question_id_idx ON public._file USING btree (question_id);


--
-- Name: _groupuser_group_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX _groupuser_group_id_idx ON public._groupuser USING btree (group_id);


--
-- Name: _groupuser_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX _groupuser_user_id_idx ON public._groupuser USING btree (user_id);


--
-- Name: _meeting_agenda_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX _meeting_agenda_id_idx ON public._meeting USING btree (agenda_id);


--
-- Name: _meeting_group_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX _meeting_group_id_idx ON public._meeting USING btree (group_id);


--
-- Name: _question_agenda_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX _question_agenda_id_idx ON public._question USING btree (agenda_id);


--
-- Name: _registration_registrationsession_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX _registration_registrationsession_id_idx ON public._registration USING btree (registrationsession_id);


--
-- Name: _result_questionsession_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX _result_questionsession_id_idx ON public._result USING btree (questionsession_id);


--
-- Name: _file _file_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._file
    ADD CONSTRAINT _file_question_id_fkey FOREIGN KEY (question_id) REFERENCES public._question(id) ON DELETE CASCADE;


--
-- Name: _groupuser _groupuser_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._groupuser
    ADD CONSTRAINT _groupuser_group_id_fkey FOREIGN KEY (group_id) REFERENCES public._group(id) ON DELETE CASCADE;


--
-- Name: _groupuser _groupuser_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._groupuser
    ADD CONSTRAINT _groupuser_user_id_fkey FOREIGN KEY (user_id) REFERENCES public._user(id) ON DELETE CASCADE;


--
-- Name: _meeting _meeting_agenda_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._meeting
    ADD CONSTRAINT _meeting_agenda_id_fkey FOREIGN KEY (agenda_id) REFERENCES public._agenda(id) ON DELETE SET NULL;


--
-- Name: _meeting _meeting_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._meeting
    ADD CONSTRAINT _meeting_group_id_fkey FOREIGN KEY (group_id) REFERENCES public._group(id) ON DELETE SET NULL;


--
-- Name: _question _question_agenda_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._question
    ADD CONSTRAINT _question_agenda_id_fkey FOREIGN KEY (agenda_id) REFERENCES public._agenda(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

