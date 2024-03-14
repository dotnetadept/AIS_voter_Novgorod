--
-- PostgreSQL database dump
--

-- Dumped from database version 12.8 (Ubuntu 12.8-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.8 (Ubuntu 12.8-0ubuntu0.20.04.1)

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
    authenticationmode text NOT NULL,
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
38	test123434	test123434_15.10.2021	2021-10-15 06:48:25.558567	2021-10-15 06:48:25.558567
37	test	test_24.09.2021	2021-09-24 06:54:02.563751	2021-10-21 06:32:08.512702
\.


--
-- Data for Name: _aqueduct_version_pgsql; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._aqueduct_version_pgsql (versionnumber, dateofupgrade) FROM stdin;
1	2021-01-15 06:31:12.55797
\.


--
-- Data for Name: _file; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._file (id, path, filename, description, question_id, version) FROM stdin;
2583	test_24.09.2021/d67c861b-25ac-473c-b2c5-5db4202f5266	Основная повестка[00].pdf	Об избрании счетной комиссии	883	80db2c83-e606-4f8a-9421-73d7c86e465a
2584	test_24.09.2021/d67c861b-25ac-473c-b2c5-5db4202f5266	Основная повестка[01].pdf	Об избрании секретариата	883	10a55b0e-d997-44f3-8738-7fab65c2a0c1
2585	test_24.09.2021/d67c861b-25ac-473c-b2c5-5db4202f5266	Основная повестка[02].pdf	Об избрании редакционной комиссии	883	9de1031a-28f3-4416-b859-4a6c501fe558
2586	test_24.09.2021/d67c861b-25ac-473c-b2c5-5db4202f5266	Основная повестка[03].pdf	Регламент	883	8b0082d9-79f8-41c6-bf71-996a5291119e
2587	test_24.09.2021/5c7854bd-59bb-45fd-ad8c-cabc33c62e44	Вопрос01_файл01.pdf	Проект закона Краснодарского края и документы к нему	884	b3a2fbce-3f36-43da-9cb3-a30558e6f6cb
2588	test_24.09.2021/5c7854bd-59bb-45fd-ad8c-cabc33c62e44	Вопрос01_файл02.pdf	Пояснительная записка	884	20a03969-33c2-4f24-a021-370f05414411
2589	test_24.09.2021/5c7854bd-59bb-45fd-ad8c-cabc33c62e44	Вопрос01_файл03.pdf	Финансово-экономическое обоснование	884	f1e2a601-830d-4e47-a013-44500b381b2e
2590	test_24.09.2021/5c7854bd-59bb-45fd-ad8c-cabc33c62e44	Вопрос01_файл04.pdf	Перечень	884	e9ca6333-ac4d-4f39-8c7f-ea6bf40404b5
2591	test_24.09.2021/5c7854bd-59bb-45fd-ad8c-cabc33c62e44	Вопрос01_файл05.pdf	Проект постановления Законодательного Собрания	884	3f2cb0fa-f524-4a52-8d62-3e3d2bde0aa2
2592	test_24.09.2021/d9d957d8-8422-47b9-a124-5c4636a0b137	Вопрос02_файл01.pdf	Проект закона Краснодарского края и документы к нему	885	44a30408-7dc4-4728-996d-440588e058d8
2593	test_24.09.2021/d9d957d8-8422-47b9-a124-5c4636a0b137	Вопрос02_файл02.pdf	Пояснительная записка	885	141feafd-60a7-4853-b8f9-b54c05552327
2594	test_24.09.2021/d9d957d8-8422-47b9-a124-5c4636a0b137	Вопрос02_файл03.pdf	Финансово-экономическое обоснование	885	a05f5b5f-5529-4694-80aa-08c8ba19d93b
2595	test_24.09.2021/d9d957d8-8422-47b9-a124-5c4636a0b137	Вопрос02_файл04.pdf	Перечень	885	e992162b-0397-4d3b-b5e5-8d4026c82447
2596	test_24.09.2021/d9d957d8-8422-47b9-a124-5c4636a0b137	Вопрос02_файл05.pdf	Проект постановления Законодательного Собрания	885	fb691ac9-966b-46af-86a4-d82a92145cee
2597	test_24.09.2021/e6423286-8817-49e4-88c8-236748cf16dc	Вопрос03_файл01.pdf	Проект закона Краснодарского края и документы к нему	886	ba68bbe4-b523-4e7c-ac52-da6007fb1205
2598	test_24.09.2021/e6423286-8817-49e4-88c8-236748cf16dc	Вопрос03_файл02.pdf	Пояснительная записка	886	7419eb2e-265a-417c-a129-547665ddb26e
2599	test_24.09.2021/e6423286-8817-49e4-88c8-236748cf16dc	Вопрос03_файл03.pdf	Финансово-экономическое обоснование	886	2667d255-2ecc-4d00-8213-17a68d1c4b68
2600	test_24.09.2021/e6423286-8817-49e4-88c8-236748cf16dc	Вопрос03_файл04.pdf	Перечень	886	cad6e26a-86d4-492c-9974-6ca3ff5cdc42
2601	test_24.09.2021/e6423286-8817-49e4-88c8-236748cf16dc	Вопрос03_файл05.pdf	Проект постановления Законодательного Собрания	886	126ecb90-3298-4a10-9303-1a8b2784e5a5
2602	test_24.09.2021/01812392-00f6-4369-8035-357dbbe01e3b	Вопрос04_файл01.pdf	Проект закона Краснодарского края и документы к нему	887	2504331e-c116-4f12-9930-dc7479e6e870
2603	test_24.09.2021/01812392-00f6-4369-8035-357dbbe01e3b	Вопрос04_файл02.pdf	Пояснительная записка	887	00d60f6e-70bc-4b12-ab90-2388fade60fe
2604	test_24.09.2021/01812392-00f6-4369-8035-357dbbe01e3b	Вопрос04_файл03.pdf	Финансово-экономическое обоснование	887	4a2a4c70-c883-4f37-a111-cf5425fc1c88
2605	test_24.09.2021/01812392-00f6-4369-8035-357dbbe01e3b	Вопрос04_файл04.pdf	Перечень	887	d5a12a8e-58a1-4e43-b8ac-c913e81688f6
2606	test_24.09.2021/01812392-00f6-4369-8035-357dbbe01e3b	Вопрос04_файл05.pdf	Проект постановления Законодательного Собрания	887	3035db21-078f-4ab8-bd87-e473ec1e052b
2607	test_24.09.2021/beb0f009-55e5-4320-943d-7a844ec78009	Вопрос05_файл01.pdf	Проект постановления Законодательного Собрания	888	4a43c569-fd5e-407f-a259-2222d042be48
2608	test_24.09.2021/9fb0d9ab-761d-43ad-afb0-a79f2dbd5d4e	Вопрос06_файл01.pdf	Проект закона Краснодарского края и документы к нему	889	eafab531-7d6a-458e-9a58-5d8fae06074a
2609	test_24.09.2021/9fb0d9ab-761d-43ad-afb0-a79f2dbd5d4e	Вопрос06_файл02.pdf	Пояснительная записка	889	2c061738-cbd9-482c-a495-ea320a518fd4
2610	test_24.09.2021/9fb0d9ab-761d-43ad-afb0-a79f2dbd5d4e	Вопрос06_файл03.pdf	Финансово-экономическое обоснование	889	8edcf161-c1b2-400e-8577-eca5db2d05ae
2611	test_24.09.2021/9fb0d9ab-761d-43ad-afb0-a79f2dbd5d4e	Вопрос06_файл04.pdf	Перечень	889	00eb4935-5036-417b-b249-8d7e19f70bb3
2612	test_24.09.2021/9fb0d9ab-761d-43ad-afb0-a79f2dbd5d4e	Вопрос06_файл05.pdf	Проект постановления Законодательного Собрания	889	b894f4ee-1d6b-4e86-9673-7cc995641417
2613	test_24.09.2021/de1f8e47-5e36-4a4d-93c4-5bf5c3efce5b	Вопрос07_файл01.pdf	Проект постановления Законодательного Собрания	890	7e0c32ac-e65a-42f8-b689-042712d4c66e
2614	test_24.09.2021/af44ffb0-5591-41e0-bf12-c91b824db3e9	Вопрос08_файл01.pdf	Проект закона Краснодарского края	891	f8b7e7e2-d8ba-4965-9dab-53475bcca5be
2615	test_24.09.2021/af44ffb0-5591-41e0-bf12-c91b824db3e9	Вопрос08_файл02.pdf	Таблица поправок	891	ccfce7b7-173c-4bb3-99fd-cd5a25e382b0
2616	test_24.09.2021/af44ffb0-5591-41e0-bf12-c91b824db3e9	Вопрос08_файл03.pdf	Проект постановления Законодательного Собрания	891	90633473-1303-47a3-ba93-fd0b7f423d51
2617	test_24.09.2021/4148669b-366c-4da6-abe8-d81aedc141b1	Вопрос09_файл01.pdf	Проект закона Краснодарского края	892	3a8eb1e8-956b-4741-a23a-e4355ecb3fb0
2618	test_24.09.2021/4148669b-366c-4da6-abe8-d81aedc141b1	Вопрос09_файл02.pdf	Пояснительная записка	892	2d21d8e3-c44f-4950-a183-4e9867f48268
2619	test_24.09.2021/4148669b-366c-4da6-abe8-d81aedc141b1	Вопрос09_файл03.pdf	Финансово-экономическое обоснование	892	00be6d97-86a8-4129-b138-f1429bee999f
2620	test_24.09.2021/4148669b-366c-4da6-abe8-d81aedc141b1	Вопрос09_файл04.pdf	Перечень	892	32740e3b-c11e-4ba5-8b62-c20db7d79c4b
2621	test_24.09.2021/4148669b-366c-4da6-abe8-d81aedc141b1	Вопрос09_файл05.pdf	Проект постановления Законодательного Собрания	892	a0ad8e69-0e90-4253-8ca0-340956c5d81a
2622	test_24.09.2021/b3647928-4087-4700-95ef-bac9bc627c04	Вопрос10_файл01.pdf	Проект закона Краснодарского края	893	6881a889-41f0-400b-b8e9-fd8bd8e783f4
2623	test_24.09.2021/b3647928-4087-4700-95ef-bac9bc627c04	Вопрос10_файл02.pdf	Пояснительная записка	893	dbc83a86-c234-4b63-8a89-12a8a54620dc
2624	test_24.09.2021/b3647928-4087-4700-95ef-bac9bc627c04	Вопрос10_файл03.pdf	Финансово-экономическое обоснование	893	a36a5824-234f-445e-98a9-bf71a7d1e5e7
2625	test_24.09.2021/b3647928-4087-4700-95ef-bac9bc627c04	Вопрос10_файл04.pdf	Перечень	893	48eecaf0-de6f-4a3e-b2f7-624f506536e1
2626	test_24.09.2021/b3647928-4087-4700-95ef-bac9bc627c04	Вопрос10_файл05.pdf	Проект постановления Законодательного Собрания	893	114ad9b2-dd8d-4a37-afb2-483cd095e3b3
2627	test_24.09.2021/1023591d-7b97-4413-a2ab-ab606208e46e	Вопрос11_файл01.pdf	Проект закона Краснодарского края	894	39dc53b6-dab7-4a8d-b54e-6949d4163c5b
2628	test_24.09.2021/1023591d-7b97-4413-a2ab-ab606208e46e	Вопрос11_файл02.pdf	Пояснительная записка	894	3dc90cd4-661d-48bd-9fb5-afa089ebc17a
2629	test_24.09.2021/1023591d-7b97-4413-a2ab-ab606208e46e	Вопрос11_файл03.pdf	Финансово-экономическое обоснование	894	6867e201-422c-4af2-9d5e-23c4e433b67e
2630	test_24.09.2021/1023591d-7b97-4413-a2ab-ab606208e46e	Вопрос11_файл04.pdf	Перечень	894	5ad34e83-d522-4c24-972c-d12e9fd79a6b
2631	test_24.09.2021/1023591d-7b97-4413-a2ab-ab606208e46e	Вопрос11_файл05.pdf	Проект постановления Законодательного Собрания	894	3e136fdd-0ebf-4d54-a8b7-37af8bf6e34c
2632	test_24.09.2021/c90a8cb6-5f5f-4acb-8e54-9b797cd2c7e3	Вопрос12_файл01.pdf	Проект закона Краснодарского края	895	35c53d86-0508-45c6-b046-d0d237867b12
2633	test_24.09.2021/c90a8cb6-5f5f-4acb-8e54-9b797cd2c7e3	Вопрос12_файл02.pdf	Таблица поправок	895	dbc79a40-49ef-4312-bb46-ca74f78ab52e
2634	test_24.09.2021/c90a8cb6-5f5f-4acb-8e54-9b797cd2c7e3	Вопрос12_файл03.pdf	Проект постановления Законодательного Собрания	895	fcb8b2c7-91ab-48b4-901b-bef691fe398a
2635	test_24.09.2021/5cc9898d-7f46-4e99-ad90-014d8afd56e5	Вопрос13_файл01.pdf	Проект закона Краснодарского края	896	32d5f8ae-6db8-4cbc-bb2d-54a76e91c13e
2636	test_24.09.2021/5cc9898d-7f46-4e99-ad90-014d8afd56e5	Вопрос13_файл02.pdf	Пояснительная записка	896	89bf5939-118c-421c-a9c6-269cc9d79912
2637	test_24.09.2021/5cc9898d-7f46-4e99-ad90-014d8afd56e5	Вопрос13_файл03.pdf	Финансово-экономическое обоснование	896	02a1ac95-3bbb-489c-9b2d-2eecc8a2d64f
2638	test_24.09.2021/5cc9898d-7f46-4e99-ad90-014d8afd56e5	Вопрос13_файл04.pdf	Перечень	896	61dd8c7e-0caf-4546-9c1c-3c6c86737439
2639	test_24.09.2021/5cc9898d-7f46-4e99-ad90-014d8afd56e5	Вопрос13_файл05.pdf	Проект постановления Законодательного Собрания	896	70dbb36c-a5d3-405f-8f50-f1f7275b9178
2640	test_24.09.2021/e55c4138-5dc3-4ef7-a6ff-647b39ac7c0c	Вопрос14_файл01.pdf	Проект закона Краснодарского края	897	16e1a4dd-9697-4afb-9b3b-ffd8a1262206
2641	test_24.09.2021/e55c4138-5dc3-4ef7-a6ff-647b39ac7c0c	Вопрос14_файл02.pdf	Пояснительная записка	897	adb902b0-3764-45b3-8217-01ca30fbe6ff
2642	test_24.09.2021/e55c4138-5dc3-4ef7-a6ff-647b39ac7c0c	Вопрос14_файл03.pdf	Финансово-экономическое обоснование	897	40799ed6-b87a-4ce3-acea-21d11e82ff1e
2643	test_24.09.2021/e55c4138-5dc3-4ef7-a6ff-647b39ac7c0c	Вопрос14_файл04.pdf	Перечень	897	52efc826-e8da-4a8d-a83a-64cdf2bcb966
2644	test_24.09.2021/e55c4138-5dc3-4ef7-a6ff-647b39ac7c0c	Вопрос14_файл05.pdf	Проект постановления Законодательного Собрания	897	1dbd51cf-90de-49e4-93c3-2aa62508335f
2645	test_24.09.2021/e55c4138-5dc3-4ef7-a6ff-647b39ac7c0c	Вопрос14_файл06.pdf	Таблица поправок ко 2-му чтению	897	a56a5dd4-11c0-4657-904c-bc0b2d2dc4a8
2646	test_24.09.2021/96e9e01b-acc6-4ee9-82ef-f0ec5f541dca	Вопрос15_файл01.pdf	Проект закона Краснодарского края	898	1142a009-ed3a-4c0f-8889-5649b75f1338
2647	test_24.09.2021/96e9e01b-acc6-4ee9-82ef-f0ec5f541dca	Вопрос15_файл02.pdf	Пояснительная записка	898	321712cf-a8dd-4951-b1e1-89dc89445ad2
2648	test_24.09.2021/96e9e01b-acc6-4ee9-82ef-f0ec5f541dca	Вопрос15_файл03.pdf	Финансово-экономическое обоснование	898	8143062a-1fd2-432f-8bb0-5ed8728f2ecb
2649	test_24.09.2021/96e9e01b-acc6-4ee9-82ef-f0ec5f541dca	Вопрос15_файл04.pdf	Перечень	898	34b86ab4-d2a9-4497-9497-a0fa33c0cef6
2650	test_24.09.2021/96e9e01b-acc6-4ee9-82ef-f0ec5f541dca	Вопрос15_файл05.pdf	Проект постановления Законодательного Собрания	898	605672ac-4c67-49b3-bfb0-3e238c357253
2651	test_24.09.2021/a1640e9b-8f0f-4735-91a7-8c576e9030c2	Вопрос16_файл01.pdf	Проект закона Краснодарского края	899	3bd9cb1f-b1a7-4d8e-b1e9-7603de136546
2652	test_24.09.2021/a1640e9b-8f0f-4735-91a7-8c576e9030c2	Вопрос16_файл02.pdf	Пояснительная записка	899	f66c4aa4-dfbd-478b-822b-0849b4436206
2653	test_24.09.2021/a1640e9b-8f0f-4735-91a7-8c576e9030c2	Вопрос16_файл03.pdf	Финансово-экономическое обоснование	899	27cddf2d-07be-43eb-83c6-95023e6247e9
2654	test_24.09.2021/a1640e9b-8f0f-4735-91a7-8c576e9030c2	Вопрос16_файл04.pdf	Перечень	899	6f4deb54-3995-4768-8357-ecbfd4f5ae09
2655	test_24.09.2021/a1640e9b-8f0f-4735-91a7-8c576e9030c2	Вопрос16_файл05.pdf	Проект постановления Законодательного Собрания	899	fcb5a0d9-a388-4175-8c20-b62d7cd6a0e1
2656	test_24.09.2021/70417cff-07c8-4a26-9b55-be9e5ca121b7	Вопрос17_файл01.pdf	Проект закона Краснодарского края	900	195f71b0-24e4-454d-bd48-0ad147bd75fa
2657	test_24.09.2021/70417cff-07c8-4a26-9b55-be9e5ca121b7	Вопрос17_файл02.pdf	Пояснительная записка	900	b1893793-f207-4f19-a8be-4700e5563ad1
2658	test_24.09.2021/70417cff-07c8-4a26-9b55-be9e5ca121b7	Вопрос17_файл03.pdf	Финансово-экономическое обоснование	900	82ecd095-e590-42e1-a345-cadedcd50369
2659	test_24.09.2021/70417cff-07c8-4a26-9b55-be9e5ca121b7	Вопрос17_файл04.pdf	Перечень	900	d53adb9c-e733-403b-8dd3-2eb23f912bd1
2660	test_24.09.2021/70417cff-07c8-4a26-9b55-be9e5ca121b7	Вопрос17_файл05.pdf	Проект постановления Законодательного Собрания	900	5f2c1923-7cf7-4dbf-858f-6067ae97d711
2661	test_24.09.2021/1b42e09f-5794-4081-921f-f37cfcf1d110	Вопрос18_файл01.pdf	Проект закона Краснодарского края	901	2c7f4edf-e0c3-4427-8627-7513ef97f83c
2662	test_24.09.2021/1b42e09f-5794-4081-921f-f37cfcf1d110	Вопрос18_файл02.pdf	Таблица поправок	901	528ff511-bc0a-45b7-846a-c3f6c222f32d
2663	test_24.09.2021/1b42e09f-5794-4081-921f-f37cfcf1d110	Вопрос18_файл03.pdf	Проект постановления Законодательного Собрания	901	778f3882-1f93-4816-8130-7dfaf510d6d7
2664	test_24.09.2021/7098cb59-dd68-4682-a11c-00e6dd838af7	Вопрос19_файл01.pdf	Проект закона Краснодарского края	902	ce84e59f-c369-40f0-95ea-138e68fd0ca8
2665	test_24.09.2021/7098cb59-dd68-4682-a11c-00e6dd838af7	Вопрос19_файл02.pdf	Проект постановления Законодательного Собрания	902	4d4ffee7-52ac-48ab-8eef-b109dc8aa185
2666	test_24.09.2021/7098cb59-dd68-4682-a11c-00e6dd838af7	Вопрос19_файл03.pdf	Проект постановления Законодательного Собрания	902	12f6c084-a507-4e9a-92c5-59f5d8dbf8f2
2667	test_24.09.2021/80d2b960-e1ee-4add-8b29-4cec28d1dd64	Вопрос20_файл01.pdf	Решение комитета ЗСК	903	3544f42c-3170-4c3a-8765-6b4723eb33ed
2668	test_24.09.2021/80d2b960-e1ee-4add-8b29-4cec28d1dd64	Вопрос20_файл02.pdf	Информация об образовании и трудовой деятельности	903	27e22f1a-8267-4adb-8850-47aea0fd746a
2669	test_24.09.2021/80d2b960-e1ee-4add-8b29-4cec28d1dd64	Вопрос20_файл03.pdf	Правительственная телеграмма	903	b7fc1b77-4e06-449b-bb78-1d3f60aa9360
2670	test_24.09.2021/f7561cc5-54cc-4510-96ad-c6155d9fa8c3	Вопрос21_файл01.pdf	Проект постановления Законодательного Собрания	904	885f2d5a-51ae-489d-9400-b046771cac80
2671	test_24.09.2021/34fe49ba-e54b-42a5-a4fc-ee0c1d52b9c0	Вопрос22_файл01.pdf	Проект постановления Законодательного Собрания	905	083f1581-ae30-43f7-b7d5-0ef336fbc1e5
2672	test_24.09.2021/fbf6d8b8-1cc6-4487-afc8-997c5879b257	Вопрос23_файл01.pdf	Проект постановления Законодательного Собрания	906	04ab518e-eeaa-4e6c-a47c-54f0d0d3c543
2673	test_24.09.2021/7d6a7f87-ede2-477e-b730-6e4b3bcab1ee	Вопрос24_файл01.pdf	Проект постановления Законодательного Собрания	907	09c1d6ff-004e-4890-b34e-5a55644b788d
2674	test_24.09.2021/b46e2204-c43e-4c95-9266-db65e25d2b4c	Вопрос25_файл01.pdf	Проект постановления Законодательного Собрания	908	2bda3f8b-e5f4-4799-a8dc-6ec754598a39
2675	test_24.09.2021/3b9bd93e-a3b2-4f46-8331-a38325fb687e	Вопрос26_файл01.pdf	Проект постановления Законодательного Собрания	909	ad0deb1d-758e-4cd1-93b5-76f402123565
2676	test_24.09.2021/b38aaf1f-0c36-4169-b7fb-6e06bfcd7c76	Вопрос27_файл01.pdf	Проект постановления Законодательного Собрания	910	725df3a9-a828-4183-a3d0-ef8927f6bd4d
2677	test_24.09.2021/b38aaf1f-0c36-4169-b7fb-6e06bfcd7c76	Вопрос27_файл02.pdf	Проект постановления Законодательного Собрания	910	1a6d3c28-2437-4a68-8d37-36c04d05aebd
2678	test_24.09.2021/f4b8117b-48b2-4c19-b5d2-3fecdf9feab0	Вопрос28_файл01.pdf	Проект постановления Законодательного Собрания	911	a7e15a24-b524-413d-b4e0-4a62159e8bef
2679	test_24.09.2021/6405ebf3-c752-4b69-a1ad-46a9ab38e31f	Вопрос29_файл01.pdf	Проект постановления Законодательного Собрания	912	616a146c-58cd-4f47-a91c-a0f017caeb90
2680	test_24.09.2021/7c9a035f-699e-4e11-b5b1-eb19c9845ce5	Вопрос30_файл01.pdf	Проект постановления Законодательного Собрания	913	9cbe7a5c-e8fd-45b7-b675-da3ea9865d09
2681	test_24.09.2021/aadf641d-86e8-4e92-aaba-ffdbe7d58b44	Вопрос31_файл01.pdf	Проект постановления Законодательного Собрания	914	78cfa7b5-56f5-4796-b7f8-dcdecb2f0e5c
2682	test_24.09.2021/e2979117-ece7-4dc0-9d5c-9033e3853602	Вопрос32_файл01.pdf	Проект постановления Законодательного Собрания	915	c469302c-6df1-4eab-badf-e34e3cd62197
2683	test_24.09.2021/a63c906a-d82e-4ec2-b8b6-51181c538006	Вопрос33_файл01.pdf	Проект постановления Законодательного Собрания	916	d3d2309e-e7d3-41c9-be4a-291149e0d9bd
2684	test_24.09.2021/f4f1ff47-1fcf-4e1f-81b9-4f2ed41c156a	Вопрос34_файл01.pdf	Проект постановления Законодательного Собрания	917	16bc0cf4-4d9d-4ebb-b015-65a8b5217c91
2685	test123434_15.10.2021/39af5c6e-6799-42c3-bc38-6a7b640f5263	Основная повестка[00].pdf	Об избрании счетной комиссии	918	0eba7ba1-e367-470f-b834-99b124b057ec
2686	test123434_15.10.2021/39af5c6e-6799-42c3-bc38-6a7b640f5263	Основная повестка[01].pdf	Об избрании секретариата	918	ce4c44ea-c6e3-4566-aa47-caab84f1234b
2687	test123434_15.10.2021/39af5c6e-6799-42c3-bc38-6a7b640f5263	Основная повестка[02].pdf	Об избрании редакционной комиссии	918	f5ff9919-bdbf-4912-81d1-b82f07207369
2688	test123434_15.10.2021/39af5c6e-6799-42c3-bc38-6a7b640f5263	Основная повестка[03].pdf	Регламент	918	b0bb3ccf-7433-48ee-a186-ca0c2d8de763
2689	test123434_15.10.2021/d9485b40-456d-4514-b9a7-057fb2cad270	Вопрос01_файл01.pdf	Проект закона Краснодарского края и документы к нему	919	ddf824aa-d227-47a3-b683-7e1b1a5a1de3
2690	test123434_15.10.2021/d9485b40-456d-4514-b9a7-057fb2cad270	Вопрос01_файл02.pdf	Пояснительная записка	919	52178d3e-0acb-4553-916c-bfd30a6c1e22
2691	test123434_15.10.2021/d9485b40-456d-4514-b9a7-057fb2cad270	Вопрос01_файл03.pdf	Финансово-экономическое обоснование	919	418ab34f-0ae4-46ba-9fe4-da73768db9f7
2692	test123434_15.10.2021/d9485b40-456d-4514-b9a7-057fb2cad270	Вопрос01_файл04.pdf	Перечень	919	7847d02d-c4bb-4083-9808-91b3b07a1414
2693	test123434_15.10.2021/d9485b40-456d-4514-b9a7-057fb2cad270	Вопрос01_файл05.pdf	Проект постановления Законодательного Собрания	919	0dc6ba52-89c2-4a1c-8be2-cf9968d763ce
2694	test123434_15.10.2021/5a160be6-1078-4e9b-bce1-f7313c5c144c	Вопрос02_файл01.pdf	Проект закона Краснодарского края и документы к нему	920	aed2a67b-1e9d-46c2-97a9-ffd863c6d7dd
2695	test123434_15.10.2021/5a160be6-1078-4e9b-bce1-f7313c5c144c	Вопрос02_файл02.pdf	Пояснительная записка	920	f4f50401-4554-4322-92ef-992120eed91d
2696	test123434_15.10.2021/5a160be6-1078-4e9b-bce1-f7313c5c144c	Вопрос02_файл03.pdf	Финансово-экономическое обоснование	920	0161f539-0286-4a85-bea5-d3225464b303
2697	test123434_15.10.2021/5a160be6-1078-4e9b-bce1-f7313c5c144c	Вопрос02_файл04.pdf	Перечень	920	ab113728-6298-4b30-9086-42e9c3c45dfb
2698	test123434_15.10.2021/5a160be6-1078-4e9b-bce1-f7313c5c144c	Вопрос02_файл05.pdf	Проект постановления Законодательного Собрания	920	741fc29c-16cc-4e81-9b73-57b4c0ff1a4f
2699	test123434_15.10.2021/6a1c8ca1-9f01-46d1-8c3d-28b7a4dcd492	Вопрос03_файл01.pdf	Проект закона Краснодарского края и документы к нему	921	94c344c2-240d-48a1-af68-fe72a88e8db6
2700	test123434_15.10.2021/6a1c8ca1-9f01-46d1-8c3d-28b7a4dcd492	Вопрос03_файл02.pdf	Пояснительная записка	921	fa92c205-92f9-4338-9433-44fecd2269da
2701	test123434_15.10.2021/6a1c8ca1-9f01-46d1-8c3d-28b7a4dcd492	Вопрос03_файл03.pdf	Финансово-экономическое обоснование	921	18b2c1f7-f978-496a-a4ab-d2ee26998ee5
2702	test123434_15.10.2021/6a1c8ca1-9f01-46d1-8c3d-28b7a4dcd492	Вопрос03_файл04.pdf	Перечень	921	009695da-43bd-4b20-bf46-9893f9d8c9a0
2703	test123434_15.10.2021/6a1c8ca1-9f01-46d1-8c3d-28b7a4dcd492	Вопрос03_файл05.pdf	Проект постановления Законодательного Собрания	921	a963600e-9e94-4346-8a55-1dccd0ab0b0d
2704	test123434_15.10.2021/f356bb23-dc0b-4be1-900c-6744ec7985ea	Вопрос04_файл01.pdf	Проект закона Краснодарского края и документы к нему	922	8a9897f3-b4b2-4856-8bf1-741fedec8e19
2705	test123434_15.10.2021/f356bb23-dc0b-4be1-900c-6744ec7985ea	Вопрос04_файл02.pdf	Пояснительная записка	922	4a6a962f-0451-4d9d-8f2a-710057d314a1
2706	test123434_15.10.2021/f356bb23-dc0b-4be1-900c-6744ec7985ea	Вопрос04_файл03.pdf	Финансово-экономическое обоснование	922	97d05e6b-707c-4185-82f9-6f0fa63bbec4
2707	test123434_15.10.2021/f356bb23-dc0b-4be1-900c-6744ec7985ea	Вопрос04_файл04.pdf	Перечень	922	e5ebb675-6efe-403d-a0d0-4ca688d3966c
2708	test123434_15.10.2021/f356bb23-dc0b-4be1-900c-6744ec7985ea	Вопрос04_файл05.pdf	Проект постановления Законодательного Собрания	922	4174364e-1341-4e74-aa63-05fcc75d882a
2709	test123434_15.10.2021/aac4236d-2341-4419-8268-e19978b2c0ec	Вопрос05_файл01.pdf	Проект постановления Законодательного Собрания	923	4c365063-17ee-4478-bb7a-bdcc5e9928c9
2710	test123434_15.10.2021/ec399e41-1065-4307-a85d-086b07c8bf84	Вопрос06_файл01.pdf	Проект закона Краснодарского края и документы к нему	924	cccc8405-6454-4dea-a5bb-a10510cb89f9
2711	test123434_15.10.2021/ec399e41-1065-4307-a85d-086b07c8bf84	Вопрос06_файл02.pdf	Пояснительная записка	924	881f7cc6-3fbf-4a83-8f89-6c28c51a1801
2712	test123434_15.10.2021/ec399e41-1065-4307-a85d-086b07c8bf84	Вопрос06_файл03.pdf	Финансово-экономическое обоснование	924	3d6737e4-a20f-49c8-968f-84391d2ce839
2713	test123434_15.10.2021/ec399e41-1065-4307-a85d-086b07c8bf84	Вопрос06_файл04.pdf	Перечень	924	e11f797d-19a6-4987-b668-5dc777639064
2714	test123434_15.10.2021/ec399e41-1065-4307-a85d-086b07c8bf84	Вопрос06_файл05.pdf	Проект постановления Законодательного Собрания	924	ef558b90-8895-4500-a9c4-e0405ef8a332
2715	test123434_15.10.2021/6d84986c-37e2-4bd5-8fe2-cc5de42095d9	Вопрос07_файл01.pdf	Проект постановления Законодательного Собрания	925	264227ca-8ec6-4aee-a1d6-435b03f7ea6d
2716	test123434_15.10.2021/11ab72c5-9d5f-4d9c-af99-593456b1ef16	Вопрос08_файл01.pdf	Проект закона Краснодарского края	926	eedb2378-2d34-43e6-abba-433d57b50e1b
2717	test123434_15.10.2021/11ab72c5-9d5f-4d9c-af99-593456b1ef16	Вопрос08_файл02.pdf	Таблица поправок	926	5475387a-7039-4b83-ae9d-3c2f2ec92f3e
2718	test123434_15.10.2021/11ab72c5-9d5f-4d9c-af99-593456b1ef16	Вопрос08_файл03.pdf	Проект постановления Законодательного Собрания	926	2613fd9d-d37a-4a4a-82d8-fcbad452feae
2719	test123434_15.10.2021/ad1a4573-dd65-43e9-8015-52d7046a851a	Вопрос09_файл01.pdf	Проект закона Краснодарского края	927	ccc20060-5182-4aee-92a0-0b33078e9b76
2720	test123434_15.10.2021/ad1a4573-dd65-43e9-8015-52d7046a851a	Вопрос09_файл02.pdf	Пояснительная записка	927	3d119730-4258-4268-9149-a2e360ea7260
2721	test123434_15.10.2021/ad1a4573-dd65-43e9-8015-52d7046a851a	Вопрос09_файл03.pdf	Финансово-экономическое обоснование	927	059f970d-bdb3-4a7c-9b2d-0c8174b01439
2722	test123434_15.10.2021/ad1a4573-dd65-43e9-8015-52d7046a851a	Вопрос09_файл04.pdf	Перечень	927	cfb24de3-557c-4e82-b3f0-94e6c2d15f65
2723	test123434_15.10.2021/ad1a4573-dd65-43e9-8015-52d7046a851a	Вопрос09_файл05.pdf	Проект постановления Законодательного Собрания	927	5fb0c43d-ec2a-419b-8e6e-5ae06912437e
2724	test123434_15.10.2021/a3c43481-9fc7-48d8-8e6c-bf235406ab10	Вопрос10_файл01.pdf	Проект закона Краснодарского края	928	f1aa92f8-f089-4dfa-8ba1-07abb48b3376
2725	test123434_15.10.2021/a3c43481-9fc7-48d8-8e6c-bf235406ab10	Вопрос10_файл02.pdf	Пояснительная записка	928	5e68638f-6791-4f51-a038-f46b14032633
2726	test123434_15.10.2021/a3c43481-9fc7-48d8-8e6c-bf235406ab10	Вопрос10_файл03.pdf	Финансово-экономическое обоснование	928	c3236b7c-65b7-46df-88b5-bd150fe2ab5b
2727	test123434_15.10.2021/a3c43481-9fc7-48d8-8e6c-bf235406ab10	Вопрос10_файл04.pdf	Перечень	928	187810f9-40b8-42a6-9cdf-99d49204d643
2728	test123434_15.10.2021/a3c43481-9fc7-48d8-8e6c-bf235406ab10	Вопрос10_файл05.pdf	Проект постановления Законодательного Собрания	928	2c618658-81f6-437c-a4d8-5875434c4a20
2729	test123434_15.10.2021/80a7290e-86a8-407a-95b3-38d84c644df8	Вопрос11_файл01.pdf	Проект закона Краснодарского края	929	030f7775-cf21-495b-a300-570a903733a4
2730	test123434_15.10.2021/80a7290e-86a8-407a-95b3-38d84c644df8	Вопрос11_файл02.pdf	Пояснительная записка	929	2ef7f025-ce37-4783-b284-ca513cf0a371
2731	test123434_15.10.2021/80a7290e-86a8-407a-95b3-38d84c644df8	Вопрос11_файл03.pdf	Финансово-экономическое обоснование	929	160f43b9-cdc7-4543-97c4-5a18791cb20a
2732	test123434_15.10.2021/80a7290e-86a8-407a-95b3-38d84c644df8	Вопрос11_файл04.pdf	Перечень	929	b19ffa0b-2f94-4839-adc0-f90c26dc81cc
2733	test123434_15.10.2021/80a7290e-86a8-407a-95b3-38d84c644df8	Вопрос11_файл05.pdf	Проект постановления Законодательного Собрания	929	f6c21d07-f8ff-4b6c-9cdf-eba694c352a6
2734	test123434_15.10.2021/8aff3e2d-d095-4692-9ece-ea3716fabd7b	Вопрос12_файл01.pdf	Проект закона Краснодарского края	930	776cfa90-7cde-4a9d-b02b-e6ad98d5ef73
2735	test123434_15.10.2021/8aff3e2d-d095-4692-9ece-ea3716fabd7b	Вопрос12_файл02.pdf	Таблица поправок	930	355f506f-4ad8-4ba7-88c6-e24638c48bc8
2736	test123434_15.10.2021/8aff3e2d-d095-4692-9ece-ea3716fabd7b	Вопрос12_файл03.pdf	Проект постановления Законодательного Собрания	930	8688e8b1-422e-4040-b9cd-64d484c73894
2737	test123434_15.10.2021/61019586-da71-49fc-a45b-47199f180362	Вопрос13_файл01.pdf	Проект закона Краснодарского края	931	e72c4f98-420f-44e6-a38d-0c5e47fe72ea
2738	test123434_15.10.2021/61019586-da71-49fc-a45b-47199f180362	Вопрос13_файл02.pdf	Пояснительная записка	931	527e7ea3-4d46-4d22-9483-5c57fbc3b46e
2739	test123434_15.10.2021/61019586-da71-49fc-a45b-47199f180362	Вопрос13_файл03.pdf	Финансово-экономическое обоснование	931	6beb0b15-e18f-4913-898f-ae01c5f7c593
2740	test123434_15.10.2021/61019586-da71-49fc-a45b-47199f180362	Вопрос13_файл04.pdf	Перечень	931	59d30ab0-47e2-4f1d-bed3-2cc0b190acd9
2741	test123434_15.10.2021/61019586-da71-49fc-a45b-47199f180362	Вопрос13_файл05.pdf	Проект постановления Законодательного Собрания	931	074e9df7-09fa-4c25-8c6e-be00a84d7717
2742	test123434_15.10.2021/4be79243-8a17-4896-8f69-6d23f76e4059	Вопрос14_файл01.pdf	Проект закона Краснодарского края	932	4b0a3842-061d-4dfc-9de2-ffb7a422de31
2743	test123434_15.10.2021/4be79243-8a17-4896-8f69-6d23f76e4059	Вопрос14_файл02.pdf	Пояснительная записка	932	9ba193b2-5ef3-4cfe-a531-bfb146aca976
2744	test123434_15.10.2021/4be79243-8a17-4896-8f69-6d23f76e4059	Вопрос14_файл03.pdf	Финансово-экономическое обоснование	932	79ea10d0-8ae0-4d9b-83d8-33a3c51c3514
2745	test123434_15.10.2021/4be79243-8a17-4896-8f69-6d23f76e4059	Вопрос14_файл04.pdf	Перечень	932	e28036da-84f8-47b9-acc4-7dded2bca45d
2746	test123434_15.10.2021/4be79243-8a17-4896-8f69-6d23f76e4059	Вопрос14_файл05.pdf	Проект постановления Законодательного Собрания	932	42f5c25f-d908-494b-8d45-f403018736a7
2747	test123434_15.10.2021/4be79243-8a17-4896-8f69-6d23f76e4059	Вопрос14_файл06.pdf	Таблица поправок ко 2-му чтению	932	9c15587d-6af1-4683-bc53-f888452e8706
2748	test123434_15.10.2021/c6d610a9-edf4-4159-a90b-773f329d80dc	Вопрос15_файл01.pdf	Проект закона Краснодарского края	933	4fd2aa35-25d9-47e9-9f62-b912e27c4ae2
2749	test123434_15.10.2021/c6d610a9-edf4-4159-a90b-773f329d80dc	Вопрос15_файл02.pdf	Пояснительная записка	933	3dd6c446-f014-4c1f-aba8-68d2194dc8a1
2750	test123434_15.10.2021/c6d610a9-edf4-4159-a90b-773f329d80dc	Вопрос15_файл03.pdf	Финансово-экономическое обоснование	933	4c412265-434c-4deb-961f-08ee2414b3d4
2751	test123434_15.10.2021/c6d610a9-edf4-4159-a90b-773f329d80dc	Вопрос15_файл04.pdf	Перечень	933	c6f214dc-ff3f-4ec8-bb0c-d1678bb84e41
2752	test123434_15.10.2021/c6d610a9-edf4-4159-a90b-773f329d80dc	Вопрос15_файл05.pdf	Проект постановления Законодательного Собрания	933	beffffca-3b24-49c1-865b-3de3061d2578
2753	test123434_15.10.2021/aa585533-44cf-4bbb-8296-7674f442cc10	Вопрос16_файл01.pdf	Проект закона Краснодарского края	934	ab64988b-e359-4b3e-8420-93aac48478fe
2754	test123434_15.10.2021/aa585533-44cf-4bbb-8296-7674f442cc10	Вопрос16_файл02.pdf	Пояснительная записка	934	7c0af23f-1bf1-432f-af37-92e2ee0b3c9c
2755	test123434_15.10.2021/aa585533-44cf-4bbb-8296-7674f442cc10	Вопрос16_файл03.pdf	Финансово-экономическое обоснование	934	43d43fe2-a72a-472a-a750-be6005983340
2756	test123434_15.10.2021/aa585533-44cf-4bbb-8296-7674f442cc10	Вопрос16_файл04.pdf	Перечень	934	02934c12-6251-4f1e-8850-1356e9cd8f57
2757	test123434_15.10.2021/aa585533-44cf-4bbb-8296-7674f442cc10	Вопрос16_файл05.pdf	Проект постановления Законодательного Собрания	934	9039d63f-9cab-460d-a5cc-10ef6e263ec7
2758	test123434_15.10.2021/d986fb43-f227-46da-8d93-8bd06aa7f2ce	Вопрос17_файл01.pdf	Проект закона Краснодарского края	935	f2930e90-3fa4-4fa2-9005-b805d875e3ec
2759	test123434_15.10.2021/d986fb43-f227-46da-8d93-8bd06aa7f2ce	Вопрос17_файл02.pdf	Пояснительная записка	935	30f4d567-6e32-4cc2-82f4-01ec0ecad80d
2760	test123434_15.10.2021/d986fb43-f227-46da-8d93-8bd06aa7f2ce	Вопрос17_файл03.pdf	Финансово-экономическое обоснование	935	9eb4ce1b-caed-4de8-a6d3-35c756d16981
2761	test123434_15.10.2021/d986fb43-f227-46da-8d93-8bd06aa7f2ce	Вопрос17_файл04.pdf	Перечень	935	726777ba-c7fd-46fc-88dc-f4678d39ba88
2762	test123434_15.10.2021/d986fb43-f227-46da-8d93-8bd06aa7f2ce	Вопрос17_файл05.pdf	Проект постановления Законодательного Собрания	935	05262f54-d2b2-4952-a64d-525320894f6d
2763	test123434_15.10.2021/8746c6c5-127e-4ded-97b8-1be416413968	Вопрос18_файл01.pdf	Проект закона Краснодарского края	936	88b202da-8def-47be-bacc-9ab8dd7b9a3c
2764	test123434_15.10.2021/8746c6c5-127e-4ded-97b8-1be416413968	Вопрос18_файл02.pdf	Таблица поправок	936	2287bd68-8ea6-4fd1-ab80-deba1cf19f9f
2765	test123434_15.10.2021/8746c6c5-127e-4ded-97b8-1be416413968	Вопрос18_файл03.pdf	Проект постановления Законодательного Собрания	936	f0593091-c381-454a-ba5a-1e434b828a5a
2766	test123434_15.10.2021/9a906aa5-b7b6-476e-9ce8-4eaf234c1935	Вопрос19_файл01.pdf	Проект закона Краснодарского края	937	e6208590-ba71-4032-a040-b1823364559b
2767	test123434_15.10.2021/9a906aa5-b7b6-476e-9ce8-4eaf234c1935	Вопрос19_файл02.pdf	Проект постановления Законодательного Собрания	937	f0b0e6fe-d86d-4b03-bef8-949cf473f1f0
2768	test123434_15.10.2021/9a906aa5-b7b6-476e-9ce8-4eaf234c1935	Вопрос19_файл03.pdf	Проект постановления Законодательного Собрания	937	40a0ca79-fa8e-45ea-b71a-c1a0bc100c30
2769	test123434_15.10.2021/c0f7a380-ba4a-4d88-8138-1d69b7147afc	Вопрос20_файл01.pdf	Решение комитета ЗСК	938	aa0d8034-2f7b-4765-b60d-5d6ac6fa75fb
2770	test123434_15.10.2021/c0f7a380-ba4a-4d88-8138-1d69b7147afc	Вопрос20_файл02.pdf	Информация об образовании и трудовой деятельности	938	7158e87d-bf32-4830-95ed-b616a769ffb7
2771	test123434_15.10.2021/c0f7a380-ba4a-4d88-8138-1d69b7147afc	Вопрос20_файл03.pdf	Правительственная телеграмма	938	74e7a87c-d2ce-4de2-9d58-01bf160c1a37
2772	test123434_15.10.2021/69f1872c-3787-432d-820f-62dba68997d7	Вопрос21_файл01.pdf	Проект постановления Законодательного Собрания	939	68771404-c24c-4787-bc74-04b98f63dfa0
2773	test123434_15.10.2021/31fef26a-9b4d-4f5a-b8d6-24fbd7e353d9	Вопрос22_файл01.pdf	Проект постановления Законодательного Собрания	940	01649722-d09f-4c72-9cbe-c5d00b39fdad
2774	test123434_15.10.2021/dca6cdf2-92bd-46f8-9dc8-651b57b8057a	Вопрос23_файл01.pdf	Проект постановления Законодательного Собрания	941	5599e75d-1ff6-4080-b35c-aaece57abe6e
2775	test123434_15.10.2021/9370b949-2556-45cd-8cc8-6f95b58ac1c6	Вопрос24_файл01.pdf	Проект постановления Законодательного Собрания	942	7236a143-1053-4eaa-b187-7e64733149e9
2776	test123434_15.10.2021/e70f2f5f-0835-440a-a12b-cd9fa961daf4	Вопрос25_файл01.pdf	Проект постановления Законодательного Собрания	943	04647189-552f-4565-bb32-753caea83020
2777	test123434_15.10.2021/5b5403e0-0c33-40c1-919d-1b45ddf15708	Вопрос26_файл01.pdf	Проект постановления Законодательного Собрания	944	cd92e416-75b7-4984-843a-7bace9f7e379
2778	test123434_15.10.2021/6f405f09-8ed0-49dc-af4a-d9ee187e012b	Вопрос27_файл01.pdf	Проект постановления Законодательного Собрания	945	60219038-5e1a-49d1-8fdf-70a6f70a7247
2779	test123434_15.10.2021/6f405f09-8ed0-49dc-af4a-d9ee187e012b	Вопрос27_файл02.pdf	Проект постановления Законодательного Собрания	945	81185188-3c62-46d9-aefd-4285ac669756
2780	test123434_15.10.2021/d57c9845-a40e-4270-bd8b-fcb48418d042	Вопрос28_файл01.pdf	Проект постановления Законодательного Собрания	946	64179c66-dd84-470f-92c0-fadd870e3016
2781	test123434_15.10.2021/92f18ad0-031f-4ea1-ad40-0fb9350cb1b7	Вопрос29_файл01.pdf	Проект постановления Законодательного Собрания	947	54ac1469-b196-433c-9cc6-3b4f5e705a85
2782	test123434_15.10.2021/8cf36f2e-1321-4858-8826-f42a857f6b23	Вопрос30_файл01.pdf	Проект постановления Законодательного Собрания	948	92d901a6-a171-4a7a-a1d9-5acee874e8a2
2783	test123434_15.10.2021/c7723ec0-1fd4-40af-a797-264a11667d34	Вопрос31_файл01.pdf	Проект постановления Законодательного Собрания	949	8469c66e-b909-499c-ba0b-b788110165d5
2784	test123434_15.10.2021/eda76dd4-20bd-4da9-8d75-0cf7a961d9bb	Вопрос32_файл01.pdf	Проект постановления Законодательного Собрания	950	a02435ef-dda7-4726-9841-3f40d6c9080f
2785	test123434_15.10.2021/354c39da-bb47-4e9b-9c32-8f49efc5e49a	Вопрос33_файл01.pdf	Проект постановления Законодательного Собрания	951	11745c9b-4696-44d3-b45c-a919d73fadac
2786	test123434_15.10.2021/d755f39e-6e64-4cbf-b58a-6700df859658	Вопрос34_файл01.pdf	Проект постановления Законодательного Собрания	952	a28d6017-9300-4d00-9283-ad311484282b
\.


--
-- Data for Name: _group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._group (id, name, lawuserscount, quorumcount, majoritycount, onethirdscount, twothirdscount, majoritychosencount, onethirdschosencount, twothirdschosencount, roundingroule, workplaces, isactive, ismanagerautoauthentication, ismanagerautoregistration, authenticationmode, unblockedmics) FROM stdin;
12	111	11	0	0	0	0	0	0	0	Отбросить после запятой	{"hasManagement":true,"managementPlacesCount":1,"hasTribune":false,"tribuneNames":[],"tribunePlacesCount":0, "tribuneTerminalIds":[],"rowsCount":0,"rows":[],"isDisplayEmptyCell":[],"schemeManagement":[null],"managementTerminalIds":[null],"schemeWorkplaces":[],"workplacesTerminalIds":[]}	f	f	t	Смарт картой	
7	Большая группа краснодар	1	1	0	0	0	0	0	0	Отбросить после запятой	{"hasManagement":true,"tribunePlacesCount":0,"hasTribune":false,"managementPlacesCount":6,"rowsCount":10,"rows":[8,8,8,8,8,8,8,8,8,8],"isDisplayEmptyCell":[false,true,true,true,true,true,true,true,true,true],"schemeManagement":[1,null,null,null,null,null],"managementTerminalIds":["2",null,null,null,null,null],"tribuneTerminalIds":[],"tribuneNames":[],"schemeWorkplaces":[[null,null,null,null,null,10,9,8],[4,null,15,null,14,null,11,null],[null,17,16,null,13,12,null,null],[2,3,5,7,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null]],"workplacesTerminalIds":[["111",null,null,null,null,null,null,"3"],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null]]}	t	t	t	Логин и пароль	001,002
13	Законодательное Собрание Краснодарского края	10	1	1	1	1	1	1	1	Отбросить после запятой	{"hasManagement":true,"tribunePlacesCount":4,"hasTribune":true,"managementPlacesCount":6,"rowsCount":10,"rows":[8,8,8,8,8,8,8,8,8,8],"isDisplayEmptyCell":[false,true,true,true,true,true,true,true,true,true],"schemeManagement":[1,null,null,null,null,null],"managementTerminalIds":["002",null,null,null,null,null],"tribuneTerminalIds":["006,007","004","008,044,066,077","007,009"],"tribuneNames":["Трибуна1","Трибуна3","Трибуна 2","Трииибуна 6545465465"],"schemeWorkplaces":[[null,null,null,null,null,10,9,8],[4,null,15,null,14,null,11,null],[6,17,16,null,13,12,null,null],[2,3,5,7,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null]],"workplacesTerminalIds":[["111",null,null,null,null,null,null,"003"],[null,null,null,null,null,null,null,"012"],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null],[null,null,null,null,null,null,null,null]]}	t	t	t	Логин и пароль	
\.


--
-- Data for Name: _groupuser; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._groupuser (id, ismanager, group_id, user_id) FROM stdin;
893	f	13	5
894	f	13	6
895	f	13	7
896	f	13	9
897	f	13	10
898	f	13	11
899	f	13	12
900	f	13	13
901	f	13	14
902	f	13	15
903	f	13	16
904	f	13	17
905	t	13	1
906	f	13	2
907	f	13	4
908	f	13	3
909	f	13	8
380	f	12	2
381	f	12	3
382	f	12	4
383	f	12	5
384	f	12	6
385	f	12	7
386	f	12	8
387	f	12	9
388	f	12	10
389	f	12	11
390	f	12	12
391	f	12	13
392	f	12	14
393	f	12	15
394	f	12	16
395	f	12	17
396	f	12	1
397	f	12	18
398	f	12	47
399	f	12	48
400	f	12	49
877	f	7	5
878	f	7	7
879	f	7	9
880	f	7	10
881	f	7	11
882	f	7	12
883	f	7	13
884	f	7	14
885	f	7	15
886	f	7	16
887	f	7	17
888	t	7	1
889	f	7	2
890	f	7	4
891	f	7	3
892	f	7	8
\.


--
-- Data for Name: _meeting; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._meeting (id, name, status, lastupdated, agenda_id, group_id, description) FROM stdin;
82	324243432	Ожидание	2021-10-21 06:57:37.399641	38	13	Очередное \nпленарное заседание\nЗаконодательного собрания\nКраснодарского Края\nшестого созыва
80	1	Ожидание	2021-10-21 06:56:46.468556	37	13	Очередное \nпленарное заседание\nЗаконодательного собрания\nКраснодарского Края\nшестого созыва
83	21	Ожидание	2021-10-21 07:07:07.648143	37	13	Очередное \nпленарное заседание\nЗаконодательного собрания\nКраснодарского Края\nшестого созыва
81	1	Завершено	2021-10-15 06:44:31.43511	37	13	Очередное \nпленарное заседание\nЗаконодательного собрания\nКраснодарского Края\nшестого созыва
\.


--
-- Data for Name: _meetingsession; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._meetingsession (id, meetingid, startdate, enddate) FROM stdin;
192	82	2021-10-21 06:33:22.70832	2021-10-21 06:33:50.419099
193	80	2021-10-21 06:35:17.034677	2021-10-21 06:35:19.533777
194	82	2021-10-21 06:48:19.552894	2021-10-21 06:48:24.00505
195	82	2021-10-21 06:50:14.038747	2021-10-21 06:50:16.932914
166	80	2021-09-25 13:08:28.563028	2021-09-26 16:01:09.761576
167	80	2021-09-26 16:04:07.828901	2021-09-26 16:01:35.048628
168	80	2021-09-26 16:04:07.828901	2021-09-26 16:03:49.912049
169	80	2021-09-26 16:04:07.828901	2021-09-27 17:05:52.896946
170	80	2021-09-27 17:09:50.316891	2021-09-28 23:54:54.391243
171	80	2021-09-29 06:14:55.231964	2021-09-29 06:14:59.33991
172	80	2021-10-01 00:52:25.054563	2021-10-11 18:38:06.929483
165	80	2021-09-24 08:20:31.756371	2021-09-24 09:29:55.596776
196	80	2021-10-21 06:55:06.368661	2021-10-21 06:55:35.819759
173	80	2021-10-13 06:08:22.45852	2021-10-13 06:08:25.373665
174	81	2021-10-13 12:28:59.515712	2021-10-15 05:56:44.821207
197	80	2021-10-21 06:56:34.215349	2021-10-21 06:56:46.468556
176	80	2021-10-15 06:03:52.944864	2021-10-15 06:04:47.965357
177	80	2021-10-15 06:07:08.153126	2021-10-15 06:09:01.266222
178	81	2021-10-15 06:13:05.293468	2021-10-15 06:15:44.288996
198	82	2021-10-21 06:57:07.091043	2021-10-21 06:57:37.399641
179	81	2021-10-15 06:17:43.54842	2021-10-15 06:20:15.002572
181	80	2021-10-15 06:23:22.352102	2021-10-15 06:25:32.764759
182	80	2021-10-15 06:29:13.338433	2021-10-15 06:29:57.85864
183	81	2021-10-15 06:31:04.572888	2021-10-15 06:31:57.931849
184	81	2021-10-15 06:44:07.864858	2021-10-15 06:44:31.43511
185	82	2021-10-15 09:25:47.007826	2021-10-17 22:12:48.046042
186	82	2021-10-18 02:11:46.755947	2021-10-21 06:19:13.439282
187	80	2021-10-21 06:25:06.215222	2021-10-21 06:25:46.753409
188	80	2021-10-21 06:28:15.515427	2021-10-21 06:29:21.568009
189	82	2021-10-21 06:30:23.557504	2021-10-21 06:30:38.103738
190	80	2021-10-21 06:32:21.253058	2021-10-21 06:32:23.821281
\.


--
-- Data for Name: _question; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._question (id, name, ordernum, description, folder, agenda_id) FROM stdin;
883	Регламентные вопросы	0	'[]'	d67c861b-25ac-473c-b2c5-5db4202f5266	37
885	Вопрос	2	'[{"caption":"","text":"Закон \\"О внесении изменений в Закон Краснодарского края \\"О бюджете Территориального фонда обязательного медицинского страхования Краснодарского края на 2020 год и на плановый период 2021 и 2022 годов\\". Внесен главой администрации (губернатором) Краснодарского края. Первое чтение. (Докладчик Морозова Л.Ю.)."}]'	d9d957d8-8422-47b9-a124-5c4636a0b137	37
886	Вопрос	3	'[{"caption":"","text":"Закон \\"Об исполнении бюджета Территориального фонда обязательного медицинского страхования Краснодарского края за 2019 год\\". Внесен главой администрации (губернатором) Краснодарского края. Первое чтение. (Докладчик Морозова Л.Ю.)"}]'	e6423286-8817-49e4-88c8-236748cf16dc	37
887	Вопрос	4	'[{"caption":"","text":"Закон \\"О внесении изменений в Закон Краснодарского края \\"О Территориальной программе государственных гарантий бесплатного оказания гражданам медицинской помощи в Краснодарском крае на 2020 год и на плановый период 2021 и 2022 годов\\". Внесен главой администрации (губернатором) Краснодарского края. Первое чтение. (Докладчик Филиппов Е.Ф.)\\r"}]'	01812392-00f6-4369-8035-357dbbe01e3b	37
888	Вопрос	5	'[{"caption":"","text":"Постановление \\"О согласовании предложений о внесении изменений в государственную программу Краснодарского края \\"Развитие здравоохранения\\". (Докладчик Филиппов Е.Ф.)"}]'	beb0f009-55e5-4320-943d-7a844ec78009	37
889	Вопрос	6	'[{"caption":"","text":"Закон \\"О внесении изменений в Закон Краснодарского края \\"О комиссиях по делам несовершеннолетних и защите их прав в Краснодарском крае\\". Внесен главой администрации (губернатором) Краснодарского края. Первое чтение. (Докладчик Гаркуша С.П.)"}]'	9fb0d9ab-761d-43ad-afb0-a79f2dbd5d4e	37
891	Вопрос	8	'[{"caption":"","text":"Закон \\"О внесении изменений в статью 12.2 Закона Краснодарского края \\"О промышленной политике в Краснодарском крае\\". Второе чтение. (Докладчик Алтухов С.В.)"}]'	af44ffb0-5591-41e0-bf12-c91b824db3e9	37
892	Вопрос	9	'[{"caption":"","text":"Закон \\"О внесении изменений в Закон Краснодарского края \\"О разграничении имущества, находящегося в собственности муниципального образования Тимашевский район, между вновь образованными городским, сельскими поселениями и муниципальным образованием Тимашевский район, в состав которого они входят\\". Первое чтение. (Докладчик Усенко С.П.)"}]'	4148669b-366c-4da6-abe8-d81aedc141b1	37
893	Вопрос	10	'[{"caption":"","text":"Закон \\"О приостановлении действия Закона Краснодарского края \\"О наделении органов местного самоуправления отдельными государственными полномочиями Краснодарского края по предоставлению земельных участков, находящихся в государственной собственности Краснодарского края\\". Первое чтение. (Докладчик Усенко С.П.)"}]'	b3647928-4087-4700-95ef-bac9bc627c04	37
894	Вопрос	11	'[{"caption":"","text":"Закон \\"О внесении изменения в Закон Краснодарского края \\"О Контрольно-счетной палате Краснодарского края\\". Первое чтение. (Докладчик Кравченко Н.П.)"}]'	1023591d-7b97-4413-a2ab-ab606208e46e	37
895	Вопрос	12	'[{"caption":"","text":"Закон \\"О внесении изменений в статью 2 Закона Краснодарского края \\"О налоге на имущество организаций\\". Второе чтение. (Докладчик Кравченко Н.П.)"}]'	c90a8cb6-5f5f-4acb-8e54-9b797cd2c7e3	37
896	Вопрос	13	'[{"caption":"","text":"Закон \\"О внесении изменения в статью 27 Закона Краснодарского края \\"О статусе депутата Законодательного Собрания Краснодарского края\\". Первое чтение. (Докладчик Горбань А.Е.)"}]'	5cc9898d-7f46-4e99-ad90-014d8afd56e5	37
898	Вопрос	15	'[{"caption":"","text":"Закон \\"О внесении изменений в Закон Краснодарского края \\"О мерах по профилактике безнадзорности и правонарушений несовершеннолетних в Краснодарском крае\\". Первое чтение. (Докладчик Чернявский В.В.) "}]'	96e9e01b-acc6-4ee9-82ef-f0ec5f541dca	37
899	Вопрос	16	'[{"caption":"","text":"Закон \\"О внесении изменений в статьи 27 и 28 Закона Краснодарского края \\"О местном самоуправлении в Краснодарском крае\\". Первое чтение. (Докладчик Жиленко С.В.)"}]'	a1640e9b-8f0f-4735-91a7-8c576e9030c2	37
900	Вопрос	17	'[{"caption":"","text":"Закон \\"О внесении изменения в статью 8 Закона Краснодарского края \\"Об организации транспортного обслуживания населения легковыми такси в Краснодарском крае\\". Первое чтение. (Докладчик Чепель В.В.)"}]'	70417cff-07c8-4a26-9b55-be9e5ca121b7	37
901	Вопрос	18	'[{"caption":"","text":"Закон \\"О внесении изменений в Закон Краснодарского края \\"Об административных правонарушениях\\". Второе чтение. (Докладчик Джеус А.В.)"}]'	1b42e09f-5794-4081-921f-f37cfcf1d110	37
903	Вопрос	20	'[{"caption":"","text":"Постановление \\"О назначении на должность Уполномоченного по правам ребенка в Краснодарском крае\\". (Докладчик Чернявский В.В.)"}]'	80d2b960-e1ee-4add-8b29-4cec28d1dd64	37
904	Вопрос	21	'[{"caption":"","text":"Постановление \\"О назначении на должности мировых судей Краснодарского края\\". (Докладчик Горбань А.Е.)"}]'	f7561cc5-54cc-4510-96ad-c6155d9fa8c3	37
905	Вопрос	22	'[{"caption":"","text":"Постановление \\"О согласовании предложений о внесении изменений в государственную программу Краснодарского края \\"Социально-экономическое и инновационное развитие Краснодарского края\\". (Докладчик Руппель А.А.)"}]'	34fe49ba-e54b-42a5-a4fc-ee0c1d52b9c0	37
906	Вопрос	23	'[{"caption":"","text":"Постановление \\"О согласовании предложений о внесении изменений в государственную программу Краснодарского края \\"Развитие топливно-энергетического комплекса\\". (Докладчик Ляшко А.В.)"}]'	fbf6d8b8-1cc6-4487-afc8-997c5879b257	37
907	Вопрос	24	'[{"caption":"","text":"Постановление \\"О согласовании предложений о внесении изменений в государственную программу Краснодарского края \\"Развитие сети автомобильных дорог Краснодарского края\\". (Докладчик Писаренко А.В.)"}]'	7d6a7f87-ede2-477e-b730-6e4b3bcab1ee	37
908	Вопрос	25	'[{"caption":"","text":"Постановление \\"О согласовании предложений о внесении изменений в государственную программу Краснодарского края \\"Казачество Кубани\\". (Докладчик Конофьев Д.С.)"}]'	b46e2204-c43e-4c95-9266-db65e25d2b4c	37
909	Вопрос	26	'[{"caption":"","text":"Постановление \\"О выполнении государственной программы Краснодарского края \\"Казачество Кубани\\" в 2019 году\\". (Докладчик Конофьев Д.С.)"}]'	3b9bd93e-a3b2-4f46-8331-a38325fb687e	37
910	Вопрос	27	'[{"caption":"","text":"Постановление \\"О ходе реализации Закона Краснодарского края \\"Об аквакультуре (рыбоводстве) на территории Краснодарского края\\". (Докладчик Дерека Ф.И.)"}]'	b38aaf1f-0c36-4169-b7fb-6e06bfcd7c76	37
911	Вопрос	28	'[{"caption":"","text":"Постановление \\"О награждении Памятным знаком Законодательного Собрания Краснодарского края \\"За активное участие в территориальном общественном самоуправлении\\". (Докладчик Жиленко С.В.)"}]'	f4b8117b-48b2-4c19-b5d2-3fecdf9feab0	37
912	Вопрос	29	'[{"caption":"","text":"Постановление \\"О прекращении полномочий члена экспертно-консультативного совета при комитете Законодательного Собрания Краснодарского края по военным вопросам, общественной безопасности, воспитанию допризывной молодежи и делам казачества\\". (Докладчик Шендрик Е.Д.)"}]'	6405ebf3-c752-4b69-a1ad-46a9ab38e31f	37
913	Вопрос	30	'[{"caption":"","text":"Постановление \\"О положительных отзывах на проекты федеральных законов\\". (Докладчик Горбань А.Е.)"}]'	7c9a035f-699e-4e11-b5b1-eb19c9845ce5	37
914	Вопрос	31	'[{"caption":"","text":"Постановление \\"Об отрицательных отзывах на проекты федеральных законов\\". (Докладчик Горбань А.Е.)"}]'	aadf641d-86e8-4e92-aaba-ffdbe7d58b44	37
918	Регламентные вопросы	0	'[]'	39af5c6e-6799-42c3-bc38-6a7b640f5263	38
919	Вопрос	1	'[{"caption":"","text":"Закон \\"О внесении изменений в Закон Краснодарского края \\"О бюджетном процессе в Краснодарском крае\\". Внесен главой администрации (губернатором) Краснодарского края. Первое чтение. (Докладчик Максименко С.В.)"}]'	d9485b40-456d-4514-b9a7-057fb2cad270	38
920	Вопрос	2	'[{"caption":"","text":"Закон \\"О внесении изменений в Закон Краснодарского края \\"О бюджете Территориального фонда обязательного медицинского страхования Краснодарского края на 2020 год и на плановый период 2021 и 2022 годов\\". Внесен главой администрации (губернатором) Краснодарского края. Первое чтение. (Докладчик Морозова Л.Ю.)."}]'	5a160be6-1078-4e9b-bce1-f7313c5c144c	38
921	Вопрос	3	'[{"caption":"","text":"Закон \\"Об исполнении бюджета Территориального фонда обязательного медицинского страхования Краснодарского края за 2019 год\\". Внесен главой администрации (губернатором) Краснодарского края. Первое чтение. (Докладчик Морозова Л.Ю.)"}]'	6a1c8ca1-9f01-46d1-8c3d-28b7a4dcd492	38
922	Вопрос	4	'[{"caption":"","text":"Закон \\"О внесении изменений в Закон Краснодарского края \\"О Территориальной программе государственных гарантий бесплатного оказания гражданам медицинской помощи в Краснодарском крае на 2020 год и на плановый период 2021 и 2022 годов\\". Внесен главой администрации (губернатором) Краснодарского края. Первое чтение. (Докладчик Филиппов Е.Ф.)\\r"}]'	f356bb23-dc0b-4be1-900c-6744ec7985ea	38
923	Вопрос	5	'[{"caption":"","text":"Постановление \\"О согласовании предложений о внесении изменений в государственную программу Краснодарского края \\"Развитие здравоохранения\\". (Докладчик Филиппов Е.Ф.)"}]'	aac4236d-2341-4419-8268-e19978b2c0ec	38
924	Вопрос	6	'[{"caption":"","text":"Закон \\"О внесении изменений в Закон Краснодарского края \\"О комиссиях по делам несовершеннолетних и защите их прав в Краснодарском крае\\". Внесен главой администрации (губернатором) Краснодарского края. Первое чтение. (Докладчик Гаркуша С.П.)"}]'	ec399e41-1065-4307-a85d-086b07c8bf84	38
925	Вопрос	7	'[{"caption":"","text":"Постановление \\"О мерах, принимаемых органами местного самоуправления в Славянском районе по социально-экономическому развитию территорий в рамках реализации Указа Президента Российской Федерации \\"О национальных целях и стратегических задачах развития Российской Федерации на период до 2024 года\\", Послания Президента Российской Федерации Федеральному Собранию Российской Федерации от 15 января 2020 года и приоритетных региональных проектов\\". (Докладчик Синяговский Р.И.)"}]'	6d84986c-37e2-4bd5-8fe2-cc5de42095d9	38
926	Вопрос	8	'[{"caption":"","text":"Закон \\"О внесении изменений в статью 12.2 Закона Краснодарского края \\"О промышленной политике в Краснодарском крае\\". Второе чтение. (Докладчик Алтухов С.В.)"}]'	11ab72c5-9d5f-4d9c-af99-593456b1ef16	38
927	Вопрос	9	'[{"caption":"","text":"Закон \\"О внесении изменений в Закон Краснодарского края \\"О разграничении имущества, находящегося в собственности муниципального образования Тимашевский район, между вновь образованными городским, сельскими поселениями и муниципальным образованием Тимашевский район, в состав которого они входят\\". Первое чтение. (Докладчик Усенко С.П.)"}]'	ad1a4573-dd65-43e9-8015-52d7046a851a	38
928	Вопрос	10	'[{"caption":"","text":"Закон \\"О приостановлении действия Закона Краснодарского края \\"О наделении органов местного самоуправления отдельными государственными полномочиями Краснодарского края по предоставлению земельных участков, находящихся в государственной собственности Краснодарского края\\". Первое чтение. (Докладчик Усенко С.П.)"}]'	a3c43481-9fc7-48d8-8e6c-bf235406ab10	38
916	Вопрос	33	'[{"caption":"","text":"Постановление \\"О перерыве между пленарными заседаниями Законодательного Собрания Краснодарского края в 2020 году\\". (Докладчик Горбань А.Е.)"}]'	a63c906a-d82e-4ec2-b8b6-51181c538006	37
917	Вопрос	34	'[{"caption":"","text":"Постановление \\"О награждении Почетной грамотой Законодательного Собрания Краснодарского края и Благодарственным письмом Законодательного Собрания Краснодарского края\\". (Докладчик Горбань А.Е.)"}]'	f4f1ff47-1fcf-4e1f-81b9-4f2ed41c156a	37
929	Вопрос	11	'[{"caption":"","text":"Закон \\"О внесении изменения в Закон Краснодарского края \\"О Контрольно-счетной палате Краснодарского края\\". Первое чтение. (Докладчик Кравченко Н.П.)"}]'	80a7290e-86a8-407a-95b3-38d84c644df8	38
930	Вопрос	12	'[{"caption":"","text":"Закон \\"О внесении изменений в статью 2 Закона Краснодарского края \\"О налоге на имущество организаций\\". Второе чтение. (Докладчик Кравченко Н.П.)"}]'	8aff3e2d-d095-4692-9ece-ea3716fabd7b	38
931	Вопрос	13	'[{"caption":"","text":"Закон \\"О внесении изменения в статью 27 Закона Краснодарского края \\"О статусе депутата Законодательного Собрания Краснодарского края\\". Первое чтение. (Докладчик Горбань А.Е.)"}]'	61019586-da71-49fc-a45b-47199f180362	38
932	Вопрос	14	'[{"caption":"","text":"Закон \\"О внесении изменений в Закон Краснодарского края \\"Об Уполномоченном по правам человека в Краснодарском крае\\". Первое чтение. (Докладчик Горбань А.Е.)"}]'	4be79243-8a17-4896-8f69-6d23f76e4059	38
933	Вопрос	15	'[{"caption":"","text":"Закон \\"О внесении изменений в Закон Краснодарского края \\"О мерах по профилактике безнадзорности и правонарушений несовершеннолетних в Краснодарском крае\\". Первое чтение. (Докладчик Чернявский В.В.) "}]'	c6d610a9-edf4-4159-a90b-773f329d80dc	38
934	Вопрос	16	'[{"caption":"","text":"Закон \\"О внесении изменений в статьи 27 и 28 Закона Краснодарского края \\"О местном самоуправлении в Краснодарском крае\\". Первое чтение. (Докладчик Жиленко С.В.)"}]'	aa585533-44cf-4bbb-8296-7674f442cc10	38
935	Вопрос	17	'[{"caption":"","text":"Закон \\"О внесении изменения в статью 8 Закона Краснодарского края \\"Об организации транспортного обслуживания населения легковыми такси в Краснодарском крае\\". Первое чтение. (Докладчик Чепель В.В.)"}]'	d986fb43-f227-46da-8d93-8bd06aa7f2ce	38
936	Вопрос	18	'[{"caption":"","text":"Закон \\"О внесении изменений в Закон Краснодарского края \\"Об административных правонарушениях\\". Второе чтение. (Докладчик Джеус А.В.)"}]'	8746c6c5-127e-4ded-97b8-1be416413968	38
937	Вопрос	19	'[{"caption":"","text":"Закон \\"О внесении изменений в статьи 20 и 26 Закона Краснодарского края \\"Об организации проведения капитального ремонта общего имущества собственников помещений в многоквартирных домах, расположенных на территории Краснодарского края\\". Второе чтение. (Докладчик Лыбанев В.В.)"}]'	9a906aa5-b7b6-476e-9ce8-4eaf234c1935	38
938	Вопрос	20	'[{"caption":"","text":"Постановление \\"О назначении на должность Уполномоченного по правам ребенка в Краснодарском крае\\". (Докладчик Чернявский В.В.)"}]'	c0f7a380-ba4a-4d88-8138-1d69b7147afc	38
939	Вопрос	21	'[{"caption":"","text":"Постановление \\"О назначении на должности мировых судей Краснодарского края\\". (Докладчик Горбань А.Е.)"}]'	69f1872c-3787-432d-820f-62dba68997d7	38
940	Вопрос	22	'[{"caption":"","text":"Постановление \\"О согласовании предложений о внесении изменений в государственную программу Краснодарского края \\"Социально-экономическое и инновационное развитие Краснодарского края\\". (Докладчик Руппель А.А.)"}]'	31fef26a-9b4d-4f5a-b8d6-24fbd7e353d9	38
941	Вопрос	23	'[{"caption":"","text":"Постановление \\"О согласовании предложений о внесении изменений в государственную программу Краснодарского края \\"Развитие топливно-энергетического комплекса\\". (Докладчик Ляшко А.В.)"}]'	dca6cdf2-92bd-46f8-9dc8-651b57b8057a	38
942	Вопрос	24	'[{"caption":"","text":"Постановление \\"О согласовании предложений о внесении изменений в государственную программу Краснодарского края \\"Развитие сети автомобильных дорог Краснодарского края\\". (Докладчик Писаренко А.В.)"}]'	9370b949-2556-45cd-8cc8-6f95b58ac1c6	38
943	Вопрос	25	'[{"caption":"","text":"Постановление \\"О согласовании предложений о внесении изменений в государственную программу Краснодарского края \\"Казачество Кубани\\". (Докладчик Конофьев Д.С.)"}]'	e70f2f5f-0835-440a-a12b-cd9fa961daf4	38
944	Вопрос	26	'[{"caption":"","text":"Постановление \\"О выполнении государственной программы Краснодарского края \\"Казачество Кубани\\" в 2019 году\\". (Докладчик Конофьев Д.С.)"}]'	5b5403e0-0c33-40c1-919d-1b45ddf15708	38
945	Вопрос	27	'[{"caption":"","text":"Постановление \\"О ходе реализации Закона Краснодарского края \\"Об аквакультуре (рыбоводстве) на территории Краснодарского края\\". (Докладчик Дерека Ф.И.)"}]'	6f405f09-8ed0-49dc-af4a-d9ee187e012b	38
946	Вопрос	28	'[{"caption":"","text":"Постановление \\"О награждении Памятным знаком Законодательного Собрания Краснодарского края \\"За активное участие в территориальном общественном самоуправлении\\". (Докладчик Жиленко С.В.)"}]'	d57c9845-a40e-4270-bd8b-fcb48418d042	38
947	Вопрос	29	'[{"caption":"","text":"Постановление \\"О прекращении полномочий члена экспертно-консультативного совета при комитете Законодательного Собрания Краснодарского края по военным вопросам, общественной безопасности, воспитанию допризывной молодежи и делам казачества\\". (Докладчик Шендрик Е.Д.)"}]'	92f18ad0-031f-4ea1-ad40-0fb9350cb1b7	38
948	Вопрос	30	'[{"caption":"","text":"Постановление \\"О положительных отзывах на проекты федеральных законов\\". (Докладчик Горбань А.Е.)"}]'	8cf36f2e-1321-4858-8826-f42a857f6b23	38
949	Вопрос	31	'[{"caption":"","text":"Постановление \\"Об отрицательных отзывах на проекты федеральных законов\\". (Докладчик Горбань А.Е.)"}]'	c7723ec0-1fd4-40af-a797-264a11667d34	38
950	Вопрос	32	'[{"caption":"","text":"Постановление \\"О докладе Законодательного Собрания Краснодарского края \\"О состоянии законодательства Краснодарского края в 2019 году\\". (Докладчик Горбань А.Е.)"}]'	eda76dd4-20bd-4da9-8d75-0cf7a961d9bb	38
951	Вопрос	33	'[{"caption":"","text":"Постановление \\"О перерыве между пленарными заседаниями Законодательного Собрания Краснодарского края в 2020 году\\". (Докладчик Горбань А.Е.)"}]'	354c39da-bb47-4e9b-9c32-8f49efc5e49a	38
952	Вопрос	34	'[{"caption":"","text":"Постановление \\"О награждении Почетной грамотой Законодательного Собрания Краснодарского края и Благодарственным письмом Законодательного Собрания Краснодарского края\\". (Докладчик Горбань А.Е.)"}]'	d755f39e-6e64-4cbf-b58a-6700df859658	38
884	Вопрос	1	'[{"caption":"","text":"Закон \\"О внесении изменений в Закон Краснодарского края \\"О бюджетном процессе в Краснодарском крае\\". Внесен главой администрации (губернатором) Краснодарского края. Первое чтение. (Докладчик Максименко С.В.1111111111111111111111)"},{"caption":"","text":""}]'	5c7854bd-59bb-45fd-ad8c-cabc33c62e44	37
890	Вопрос	7	'[{"caption":"","text":"Постановление \\"О мерах, принимаемых органами местного самоуправления в Славянском районе по социально-экономическому развитию территорий в рамках реализации Указа Президента Российской Федерации \\"О национальных целях и стратегических задачах развития Российской Федерации на период до 2024 года\\", Послания Президента Российской Федерации Федеральному Собранию Российской Федерации от 15 января 2020 года и приоритетных региональных проектов\\". (Докладчик Синяговский Р.И.)"}]'	de1f8e47-5e36-4a4d-93c4-5bf5c3efce5b	37
897	Вопрос	14	'[{"caption":"","text":"Закон \\"О внесении изменений в Закон Краснодарского края \\"Об Уполномоченном по правам человека в Краснодарском крае\\". Первое чтение. (Докладчик Горбань А.Е.)"}]'	e55c4138-5dc3-4ef7-a6ff-647b39ac7c0c	37
902	Вопрос	19	'[{"caption":"","text":"Закон \\"О внесении изменений в статьи 20 и 26 Закона Краснодарского края \\"Об организации проведения капитального ремонта общего имущества собственников помещений в многоквартирных домах, расположенных на территории Краснодарского края\\". Второе чтение. (Докладчик Лыбанев В.В.)"}]'	7098cb59-dd68-4682-a11c-00e6dd838af7	37
915	Вопрос	32	'[{"caption":"","text":"Постановление \\"О докладе Законодательного Собрания Краснодарского края \\"О состоянии законодательства Краснодарского края в 2019 году\\". (Докладчик Горбань А.Е.)"}]'	e2979117-ece7-4dc0-9d5c-9033e3853602	37
\.


--
-- Data for Name: _questionsession; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._questionsession (id, meetingsessionid, questionid, votingmodeid, desicion, "interval", userscountregistred, userscountforsuccess, startdate, enddate, userscountvoted, userscountvotedyes, userscountvotedno, userscountvotedindiffirent) FROM stdin;
439	165	885	2	Большинство от зарегистрированных членов	17	0	0	2021-09-24 09:02:49.899318	2021-09-24 09:02:51.197147	0	0	\N	\N
440	165	885	2	Большинство от зарегистрированных членов	17	0	0	2021-09-24 09:02:53.092362	2021-09-24 09:02:54.47569	0	0	\N	\N
441	166	916	2	Большинство от зарегистрированных членов	17	0	0	2021-09-25 13:09:48.858438	2021-09-25 13:09:50.503708	0	0	\N	\N
442	166	883	2	Большинство от зарегистрированных членов	17	0	0	2021-09-25 13:11:09.118716	2021-09-25 13:11:10.642396	0	0	\N	\N
443	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:16:07.923086	2021-09-26 14:16:09.933144	0	0	\N	\N
444	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:17:13.250068	2021-09-26 14:17:14.496767	0	0	\N	\N
445	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:17:15.168576	2021-09-26 14:17:16.097429	0	0	\N	\N
446	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:17:16.974212	2021-09-26 14:17:17.975319	0	0	\N	\N
447	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:17:18.630685	2021-09-26 14:17:19.334529	0	0	\N	\N
448	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:17:20.073063	2021-09-26 14:17:20.976526	0	0	\N	\N
449	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:17:21.431178	2021-09-26 14:17:22.102627	0	0	\N	\N
450	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:17:22.787047	2021-09-26 14:17:23.302775	0	0	\N	\N
451	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:33:30.067516	2021-09-26 14:33:31.470854	0	0	\N	\N
460	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:38:44.833623	2021-09-26 14:38:46.127544	0	0	\N	\N
452	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:33:33.045277	2021-09-26 14:34:16.727008	0	0	\N	\N
453	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:34:19.668222	2021-09-26 14:34:38.045539	0	0	\N	\N
455	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:35:06.459614	2021-09-26 14:35:09.663604	0	0	\N	\N
456	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:35:14.9927	2021-09-26 14:35:44.938091	0	0	\N	\N
461	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:38:47.019981	2021-09-26 14:38:48.011986	0	0	\N	\N
457	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:35:46.105501	2021-09-26 14:36:07.058469	0	0	\N	\N
458	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:36:14.546989	2021-09-26 14:38:39.773927	0	0	\N	\N
459	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:38:41.976232	2021-09-26 14:38:43.712123	0	0	\N	\N
471	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:58:53.00718	2021-09-26 14:59:06.031012	0	0	\N	\N
462	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:44:35.628449	2021-09-26 14:52:03.983891	0	0	\N	\N
463	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:52:10.335616	2021-09-26 14:52:14.095127	0	0	\N	\N
464	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:53:24.414894	2021-09-26 14:53:27.085002	0	0	\N	\N
465	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:57:22.2609	2021-09-26 14:57:23.722087	0	0	\N	\N
466	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:57:24.556855	2021-09-26 14:57:25.587216	0	0	\N	\N
467	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:57:26.279733	2021-09-26 14:57:27.082116	0	0	\N	\N
468	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:57:27.636348	2021-09-26 14:57:28.090315	0	0	\N	\N
469	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:57:28.278499	2021-09-26 14:57:28.590423	0	0	\N	\N
470	166	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 14:57:28.756758	2021-09-26 14:57:28.921491	0	0	\N	\N
473	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 14:59:31.283154	2021-09-26 14:59:33.216794	0	0	\N	\N
477	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:37:03.091227	2021-09-26 15:37:20.900599	0	0	\N	\N
474	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 14:59:37.904004	2021-09-26 14:59:58.712824	0	0	\N	\N
472	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 14:59:07.245574	2021-09-26 15:30:54.485339	0	0	\N	\N
475	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:36:33.252318	2021-09-26 15:36:34.514015	0	0	\N	\N
476	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:36:35.722143	2021-09-26 15:36:53.900579	0	0	\N	\N
478	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:37:27.669619	2021-09-26 15:37:28.899352	0	0	\N	\N
479	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:37:29.54779	2021-09-26 15:37:30.597417	0	0	\N	\N
480	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:37:31.153694	2021-09-26 15:37:33.452437	0	0	\N	\N
481	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:37:42.302915	2021-09-26 15:37:48.788372	0	0	\N	\N
482	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:40:23.793298	2021-09-26 15:40:41.900573	0	0	\N	\N
483	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:40:44.029464	2021-09-26 15:41:01.900522	0	0	\N	\N
484	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:41:34.989713	2021-09-26 15:41:37.607514	0	0	\N	\N
454	166	883	2	Большинство от зарегистрированных членов	883	1	0	2021-09-26 14:34:50.185979	2021-09-26 14:40:36.447616	0	0	\N	\N
485	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:41:39.553997	2021-09-26 15:42:25.493149	0	0	\N	\N
508	169	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 16:21:54.194961	2021-09-26 16:22:11.852563	0	0	\N	\N
486	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:42:26.650568	2021-09-26 15:45:01.315279	0	0	\N	\N
487	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:45:02.418715	2021-09-26 15:45:04.256714	0	0	\N	\N
488	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:45:04.923406	2021-09-26 15:45:06.026526	0	0	\N	\N
489	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:46:48.160874	2021-09-26 15:46:49.440523	0	0	\N	\N
490	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:48:32.673545	2021-09-26 15:48:44.097982	0	0	\N	\N
491	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:53:01.764446	2021-09-26 15:53:02.972794	0	0	\N	\N
492	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:53:04.56552	2021-09-26 15:53:05.643069	0	0	\N	\N
493	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:53:06.364922	2021-09-26 15:53:07.309534	0	0	\N	\N
494	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:53:07.941512	2021-09-26 15:53:08.633503	0	0	\N	\N
495	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:53:09.060534	2021-09-26 15:53:09.547901	0	0	\N	\N
496	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:53:10.052453	2021-09-26 15:53:10.286306	0	0	\N	\N
497	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:53:10.544473	2021-09-26 15:53:10.740671	0	0	\N	\N
498	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:53:11.021274	2021-09-26 15:53:11.252634	0	0	\N	\N
499	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:53:11.465683	2021-09-26 15:53:11.6447	0	0	\N	\N
500	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:53:11.833033	2021-09-26 15:53:12.931702	0	0	\N	\N
501	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:56:29.469614	2021-09-26 15:56:40.418436	0	0	\N	\N
502	166	883	2	Большинство от зарегистрированных членов	17	2	1	2021-09-26 15:58:46.312952	2021-09-26 15:58:47.786843	0	0	\N	\N
503	167	883	2	Большинство от зарегистрированных членов	17	0	0	2021-09-26 16:10:30.642802	2021-09-26 16:10:44.021674	0	0	\N	\N
504	169	883	2	Большинство от зарегистрированных членов	17	0	0	2021-09-26 16:20:53.543483	2021-09-26 16:20:56.841355	0	0	\N	\N
505	169	883	2	Большинство от зарегистрированных членов	17	0	0	2021-09-26 16:21:20.251751	2021-09-26 16:21:27.144654	0	0	\N	\N
506	169	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 16:21:30.611508	2021-09-26 16:21:34.326238	0	0	\N	\N
507	169	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 16:21:48.009575	2021-09-26 16:21:51.711266	0	0	\N	\N
509	169	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 16:23:22.269371	2021-09-26 16:23:23.710307	0	0	\N	\N
510	169	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 16:24:32.97629	2021-09-26 16:24:38.020883	0	0	\N	\N
511	169	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 16:24:41.064463	2021-09-26 16:24:58.778592	0	0	\N	\N
512	169	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 16:25:03.870397	2021-09-26 16:25:21.778547	0	0	\N	\N
513	169	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 16:25:41.699763	2021-09-26 16:25:44.409084	0	0	\N	\N
514	169	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 16:26:02.484891	2021-09-26 16:26:03.772561	0	0	\N	\N
515	169	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 16:26:17.557623	2021-09-26 16:26:35.77856	0	0	\N	\N
516	169	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 16:38:27.801716	2021-09-26 16:38:45.778559	0	0	\N	\N
517	169	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-26 16:38:49.842869	2021-09-26 16:39:03.205406	0	0	\N	\N
518	170	883	2	Большинство от зарегистрированных членов	17	0	0	2021-09-27 17:12:34.850474	2021-09-27 17:12:36.507271	0	0	\N	\N
519	170	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-28 13:07:24.599182	2021-09-28 13:07:34.868296	1	0	\N	\N
520	170	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-28 13:25:38.337665	2021-09-28 13:25:39.203838	0	0	\N	\N
521	170	883	2	Большинство от зарегистрированных членов	17	1	0	2021-09-28 13:25:54.594806	2021-09-28 13:26:02.157818	0	0	\N	\N
522	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-01 00:53:53.302484	2021-10-01 00:53:54.663965	0	0	0	0
523	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-01 00:56:18.317539	2021-10-01 00:56:21.188583	0	0	0	0
524	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-05 02:16:07.973152	2021-10-05 02:16:09.933783	0	0	0	0
525	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-05 02:16:11.320842	2021-10-05 02:16:14.884577	0	0	0	0
526	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-05 02:16:18.12095	2021-10-05 02:16:24.840885	0	0	0	0
527	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-05 02:16:26.936783	2021-10-05 02:16:28.305097	0	0	0	0
528	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-05 02:16:31.922766	2021-10-05 02:16:33.217265	0	0	0	0
529	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-05 02:16:34.621088	2021-10-05 02:16:52.996172	0	0	0	0
530	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-05 02:16:54.780114	2021-10-05 02:16:56.722342	0	0	0	0
531	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-05 02:17:18.835748	2021-10-05 02:17:19.922923	0	0	0	0
532	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-05 02:17:21.131498	2021-10-05 02:17:22.199389	0	0	0	0
533	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-05 02:17:24.115243	2021-10-05 02:17:24.835031	0	0	0	0
534	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-05 02:17:26.163468	2021-10-05 02:17:27.341301	0	0	0	0
535	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-05 02:22:49.556162	2021-10-05 02:23:00.857314	0	0	0	0
536	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-05 02:23:02.939303	2021-10-05 02:23:04.264892	0	0	0	0
537	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-05 02:23:05.784253	2021-10-05 02:23:07.656304	0	0	0	0
538	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-05 02:23:11.70444	2021-10-05 02:23:13.936408	0	0	0	0
539	172	883	2	Большинство от зарегистрированных членов	17	1	0	2021-10-05 02:23:22.126934	2021-10-05 02:23:24.198651	0	0	0	0
540	172	883	2	Большинство от зарегистрированных членов	17	1	0	2021-10-05 02:23:49.937712	2021-10-05 02:23:51.721304	0	0	0	0
541	172	883	2	Большинство от зарегистрированных членов	17	1	0	2021-10-05 02:26:11.52298	2021-10-05 02:26:14.162386	0	0	0	0
542	172	883	2	Большинство от зарегистрированных членов	17	1	0	2021-10-05 02:26:18.300673	2021-10-05 02:26:20.783206	0	0	0	0
543	172	883	2	Большинство от зарегистрированных членов	17	1	0	2021-10-05 02:26:46.147774	2021-10-05 02:26:47.309076	0	0	0	0
544	172	883	2	Большинство от зарегистрированных членов	17	1	0	2021-10-05 02:26:48.730204	2021-10-05 02:26:50.134633	0	0	0	0
545	172	883	2	Большинство от зарегистрированных членов	17	1	0	2021-10-05 02:26:57.736557	2021-10-05 02:26:59.232577	0	0	0	0
546	172	883	2	Большинство от зарегистрированных членов	17	1	0	2021-10-05 02:27:02.400015	2021-10-05 02:27:12.833184	0	0	0	0
547	172	883	2	Большинство от зарегистрированных членов	17	1	0	2021-10-05 02:27:16.832884	2021-10-05 02:27:18.673185	0	0	0	0
548	172	883	2	Большинство от зарегистрированных членов	17	1	0	2021-10-05 02:31:47.78865	2021-10-05 02:31:49.235825	0	0	0	0
549	172	883	2	Большинство от зарегистрированных членов	17	1	0	2021-10-05 02:31:51.322763	2021-10-05 02:32:08.996157	0	0	0	0
550	172	883	2	Большинство от зарегистрированных членов	17	1	0	2021-10-05 11:34:13.526225	2021-10-05 11:34:31.193533	1	0	1	0
551	172	883	2	Большинство от зарегистрированных членов	17	1	0	2021-10-05 11:35:03.981881	2021-10-05 11:35:10.787726	1	1	0	0
552	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 06:43:27.458529	2021-10-08 06:43:28.875786	0	0	0	0
553	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 06:43:31.453241	2021-10-08 06:43:32.358888	0	0	0	0
554	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 06:43:44.538518	2021-10-08 06:43:46.089653	0	0	0	0
555	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 06:43:47.714119	2021-10-08 06:43:48.50578	0	0	0	0
556	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 06:43:54.853303	2021-10-08 06:43:56.131762	0	0	0	0
557	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 06:47:27.219529	2021-10-08 06:47:29.542046	0	0	0	0
558	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 06:48:16.918281	2021-10-08 06:48:18.645841	0	0	0	0
559	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 06:48:27.431893	2021-10-08 06:48:30.192963	0	0	0	0
560	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 06:49:24.459503	2021-10-08 06:49:26.590931	0	0	0	0
561	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 06:49:58.613964	2021-10-08 06:50:00.352075	0	0	0	0
562	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 07:04:40.521753	2021-10-08 07:04:41.714537	0	0	0	0
563	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 07:04:43.241149	2021-10-08 07:04:45.516835	0	0	0	0
564	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 07:19:05.744845	2021-10-08 07:19:07.145687	0	0	0	0
565	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 07:19:08.832649	2021-10-08 07:19:09.893293	0	0	0	0
566	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 07:23:42.82463	2021-10-08 07:23:44.849043	0	0	0	0
567	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 07:24:21.638082	2021-10-08 07:24:23.398202	0	0	0	0
568	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 07:24:28.508681	2021-10-08 07:24:30.098107	0	0	0	0
569	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 07:24:35.020292	2021-10-08 07:24:36.201245	0	0	0	0
570	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 07:24:41.040555	2021-10-08 07:24:42.086405	0	0	0	0
571	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 07:24:49.103532	2021-10-08 07:24:50.10507	0	0	0	0
572	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 07:34:03.229627	2021-10-08 07:34:04.890511	0	0	0	0
573	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 07:34:06.476242	2021-10-08 07:34:07.492641	0	0	0	0
574	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 07:34:17.005869	2021-10-08 07:34:18.128207	0	0	0	0
575	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 07:34:23.028011	2021-10-08 07:34:24.203753	0	0	0	0
576	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 07:34:31.621604	2021-10-08 07:34:32.583577	0	0	0	0
577	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 07:34:37.056414	2021-10-08 07:34:38.700612	0	0	0	0
578	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 07:34:48.807677	2021-10-08 07:34:49.897652	0	0	0	0
579	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 07:36:07.391428	2021-10-08 07:36:08.352148	0	0	0	0
580	172	883	2	Большинство от зарегистрированных членов	17	1	0	2021-10-08 07:37:12.342535	2021-10-08 07:37:13.013982	0	0	0	0
581	172	883	2	Большинство от зарегистрированных членов	17	1	0	2021-10-08 07:37:14.555591	2021-10-08 07:37:15.550231	0	0	0	0
582	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 10:15:28.652916	2021-10-08 10:15:29.927454	0	0	0	0
583	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 10:15:50.793408	2021-10-08 10:15:51.601095	0	0	0	0
584	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 10:15:53.576472	2021-10-08 10:15:54.357005	0	0	0	0
585	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 10:15:55.98792	2021-10-08 10:15:57.821426	0	0	0	0
586	172	883	2	Большинство от зарегистрированных членов	17	0	0	2021-10-08 10:16:02.383451	2021-10-08 10:16:03.673855	0	0	0	0
587	174	883	2	Большинство от зарегистрированных членов	17	1	0	2021-10-14 07:20:01.960415	2021-10-14 07:20:07.749682	1	1	0	0
588	174	883	2	Большинство от зарегистрированных членов	17	1	0	2021-10-14 07:21:49.31547	2021-10-14 07:21:55.452313	1	0	1	0
589	185	918	2	Большинство от зарегистрированных членов	17	1	0	2021-10-16 09:56:35.44989	2021-10-16 09:56:36.97005	0	0	0	0
590	185	918	2	Большинство от зарегистрированных членов	17	1	0	2021-10-17 07:44:34.790557	2021-10-17 07:44:43.079701	1	1	0	0
591	185	918	2	Большинство от зарегистрированных членов	17	1	0	2021-10-17 07:52:07.999866	2021-10-17 07:52:18.140266	1	1	0	0
592	185	918	2	Большинство от зарегистрированных членов	17	1	0	2021-10-17 07:56:20.475785	2021-10-17 07:56:28.614435	1	1	0	0
593	185	918	2	Большинство от зарегистрированных членов	17	1	0	2021-10-17 07:56:56.201361	2021-10-17 07:57:14.684937	1	0	1	0
594	185	918	2	Большинство от зарегистрированных членов	17	1	0	2021-10-17 07:57:27.339379	2021-10-17 07:57:29.08043	0	0	0	0
595	185	918	2	Большинство от зарегистрированных членов	17	1	0	2021-10-17 07:57:41.9572	2021-10-17 07:57:48.858677	1	0	0	1
596	185	918	2	Большинство от зарегистрированных членов	17	1	0	2021-10-17 19:01:25.259663	2021-10-17 19:01:33.08547	1	0	0	1
597	185	918	2	Большинство от зарегистрированных членов	17	1	0	2021-10-17 20:05:23.398406	2021-10-17 20:05:41.65667	1	0	0	1
598	185	918	2	Большинство от зарегистрированных членов	17	1	0	2021-10-17 21:58:07.214576	2021-10-17 21:58:08.539806	0	0	0	0
599	186	918	2	Большинство от зарегистрированных членов	17	2	1	2021-10-18 02:36:52.910875	2021-10-18 02:37:00.039831	1	1	0	0
600	187	883	2	Большинство от зарегистрированных членов	17	1	0	2021-10-21 06:25:39.907067	2021-10-21 06:25:43.781408	0	0	0	0
\.


--
-- Data for Name: _registration; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._registration (id, userid, registrationsession_id) FROM stdin;
66	8	990
67	1	991
68	1	992
69	8	993
70	8	996
71	8	997
72	8	998
73	1	999
74	8	999
75	8	1001
\.


--
-- Data for Name: _registrationsession; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._registrationsession (id, meetingid, "interval", startdate, enddate) FROM stdin;
990	81	56	2021-10-14 07:10:53.045787	2021-10-14 07:10:54.471891
991	80	56	2021-10-15 06:25:08.956183	2021-10-15 06:25:23.416169
992	82	56	2021-10-15 09:26:18.402287	2021-10-15 09:26:19.849476
993	82	56	2021-10-16 09:56:57.057276	2021-10-16 09:57:03.877259
994	82	56	2021-10-17 18:52:05.534545	2021-10-17 18:52:06.922419
995	82	56	2021-10-17 18:56:57.708536	2021-10-17 18:57:00.112165
996	82	56	2021-10-17 18:59:42.018198	2021-10-17 18:59:48.948873
997	82	56	2021-10-17 19:01:17.376396	2021-10-17 19:01:22.764498
998	82	56	2021-10-17 20:16:35.489121	2021-10-17 20:16:41.507069
1000	80	56	2021-10-21 06:25:09.771818	2021-10-21 06:25:17.127715
1001	80	56	2021-10-21 06:25:25.149246	2021-10-21 06:25:33.954303
478	80	56	2021-09-24 08:20:38.230856	2021-09-24 08:20:39.895112
999	82	56	2021-10-18 02:32:49.23935	2021-10-18 02:32:50.1522
604	80	56	2021-10-08 05:44:56.235559	2021-10-08 05:44:57.332494
730	80	56	2021-10-08 06:25:20.418924	2021-10-08 06:25:21.250249
731	80	56	2021-10-08 06:25:23.84624	2021-10-08 06:25:24.966311
732	80	56	2021-10-08 06:25:27.801621	2021-10-08 06:25:34.051109
733	80	56	2021-10-08 06:25:37.468236	2021-10-08 06:25:48.345933
857	80	56	2021-10-08 07:03:32.059485	2021-10-08 07:03:33.839138
858	80	56	2021-10-08 07:04:08.248941	2021-10-08 07:04:09.204442
859	80	56	2021-10-08 07:04:11.254319	2021-10-08 07:04:27.987175
860	80	56	2021-10-08 07:04:30.260485	2021-10-08 07:04:31.435261
861	80	56	2021-10-08 07:04:33.803162	2021-10-08 07:04:35.413557
863	80	56	2021-10-08 07:04:47.880001	2021-10-08 07:04:49.160513
864	80	56	2021-10-08 07:04:51.176619	2021-10-08 07:04:54.068733
479	80	56	2021-09-24 08:20:55.124986	2021-09-24 08:20:58.90298
480	80	56	2021-09-24 09:01:56.466015	2021-09-24 09:02:24.027061
481	80	56	2021-09-24 09:02:31.375289	2021-09-24 09:02:38.157414
482	80	56	2021-09-24 09:05:11.256254	2021-09-24 09:06:08.104087
483	80	56	2021-09-25 13:09:24.284319	2021-09-25 13:09:27.143059
484	80	56	2021-09-26 16:10:24.240341	2021-09-26 16:10:29.804977
485	80	56	2021-09-27 17:12:30.59084	2021-09-27 17:12:31.827555
486	80	56	2021-09-28 12:18:52.006633	2021-09-28 12:18:55.182058
487	80	56	2021-09-28 12:19:59.519248	2021-09-28 12:20:56.599033
488	80	56	2021-09-28 12:58:03.785523	2021-09-28 12:58:34.165112
489	80	56	2021-09-28 13:03:19.426266	2021-09-28 13:03:29.383252
490	80	56	2021-09-28 13:03:33.744428	2021-09-28 13:03:40.18794
491	80	56	2021-09-28 13:04:03.904398	2021-09-28 13:04:45.69116
492	80	56	2021-09-28 13:05:10.250036	2021-09-28 13:05:15.880922
493	80	56	2021-09-28 13:06:17.06077	2021-09-28 13:06:23.612712
494	80	56	2021-09-28 13:07:07.735543	2021-09-28 13:07:13.309877
495	80	56	2021-10-01 00:53:17.582881	2021-10-01 00:53:34.013392
497	80	56	2021-10-01 00:56:13.147401	2021-10-01 00:56:15.164338
498	80	56	2021-10-01 00:56:24.692027	2021-10-01 00:56:32.027443
499	80	56	2021-10-01 00:56:37.043868	2021-10-01 00:56:40.659925
496	80	56	2021-10-01 00:56:08.524648	2021-10-01 00:58:15.568886
500	80	56	2021-10-01 01:08:09.901824	2021-10-01 01:08:11.655158
501	80	56	2021-10-01 01:08:20.934247	2021-10-01 01:08:37.230834
503	80	56	2021-10-05 02:23:26.288761	2021-10-05 02:23:47.555212
504	80	56	2021-10-05 02:24:16.273875	2021-10-05 02:24:20.254301
505	80	56	2021-10-05 02:24:21.9865	2021-10-05 02:24:24.813062
506	80	56	2021-10-05 02:25:13.55687	2021-10-05 02:26:07.145751
502	80	56	2021-10-05 02:23:19.999848	2021-10-05 04:14:09.793859
507	80	56	2021-10-05 02:26:08.705218	2021-10-05 04:14:09.793859
508	80	56	2021-10-05 11:33:25.023569	2021-10-05 11:33:45.569383
509	80	56	2021-10-07 10:28:14.12106	2021-10-07 10:28:19.573386
510	80	56	2021-10-08 05:17:36.861715	2021-10-08 05:17:38.118895
511	80	56	2021-10-08 05:17:40.396795	2021-10-08 05:17:42.319462
512	80	56	2021-10-08 05:17:44.298098	2021-10-08 05:17:45.555471
513	80	56	2021-10-08 05:17:47.184504	2021-10-08 05:17:48.141187
514	80	56	2021-10-08 05:17:50.224888	2021-10-08 05:17:51.22466
515	80	56	2021-10-08 05:17:53.487308	2021-10-08 05:18:08.865828
516	80	56	2021-10-08 05:18:10.823941	2021-10-08 05:18:12.588354
517	80	56	2021-10-08 05:19:57.140313	2021-10-08 05:20:02.12278
518	80	56	2021-10-08 05:20:04.140666	2021-10-08 05:20:08.955984
519	80	56	2021-10-08 05:20:10.78635	2021-10-08 05:21:01.401481
520	80	56	2021-10-08 05:21:03.120554	2021-10-08 05:21:08.735295
521	80	56	2021-10-08 05:21:10.896119	2021-10-08 05:21:38.460473
522	80	56	2021-10-08 05:21:45.105418	2021-10-08 05:21:50.485746
523	80	56	2021-10-08 05:21:56.037616	2021-10-08 05:22:03.012362
524	80	56	2021-10-08 05:22:10.039961	2021-10-08 05:22:18.047122
525	80	56	2021-10-08 05:22:19.973322	2021-10-08 05:22:21.116686
526	80	56	2021-10-08 05:23:35.597088	2021-10-08 05:23:36.619718
527	80	56	2021-10-08 05:23:38.631347	2021-10-08 05:23:40.130129
528	80	56	2021-10-08 05:23:41.972314	2021-10-08 05:23:42.99628
529	80	56	2021-10-08 05:23:44.732919	2021-10-08 05:24:41.33504
530	80	56	2021-10-08 05:25:35.337785	2021-10-08 05:25:36.224956
531	80	56	2021-10-08 05:25:37.916843	2021-10-08 05:25:39.224295
532	80	56	2021-10-08 05:25:41.946309	2021-10-08 05:25:43.58929
533	80	56	2021-10-08 05:25:45.127617	2021-10-08 05:25:46.495788
534	80	56	2021-10-08 05:25:50.412182	2021-10-08 05:25:51.774812
535	80	56	2021-10-08 05:25:54.614746	2021-10-08 05:25:55.610974
536	80	56	2021-10-08 05:25:57.527046	2021-10-08 05:25:58.906953
537	80	56	2021-10-08 05:26:00.610898	2021-10-08 05:26:01.581754
538	80	56	2021-10-08 05:26:03.112609	2021-10-08 05:26:04.180721
539	80	56	2021-10-08 05:26:07.781354	2021-10-08 05:26:08.888098
540	80	56	2021-10-08 05:26:13.763706	2021-10-08 05:26:14.799225
541	80	56	2021-10-08 05:26:19.175412	2021-10-08 05:26:20.542713
542	80	56	2021-10-08 05:26:22.501442	2021-10-08 05:26:23.492904
543	80	56	2021-10-08 05:28:59.841914	2021-10-08 05:29:00.71851
544	80	56	2021-10-08 05:29:02.322834	2021-10-08 05:29:03.128411
545	80	56	2021-10-08 05:29:04.525254	2021-10-08 05:29:05.232545
546	80	56	2021-10-08 05:29:06.717495	2021-10-08 05:29:07.568554
547	80	56	2021-10-08 05:30:07.094786	2021-10-08 05:30:09.075205
548	80	56	2021-10-08 05:30:10.804146	2021-10-08 05:30:12.095065
549	80	56	2021-10-08 05:30:13.635865	2021-10-08 05:30:14.862583
550	80	56	2021-10-08 05:30:16.290268	2021-10-08 05:30:17.275098
551	80	56	2021-10-08 05:30:19.447254	2021-10-08 05:30:20.51463
552	80	56	2021-10-08 05:30:22.512623	2021-10-08 05:30:23.479133
553	80	56	2021-10-08 05:30:26.237341	2021-10-08 05:30:27.163504
554	80	56	2021-10-08 05:30:28.650718	2021-10-08 05:30:29.480172
555	80	56	2021-10-08 05:30:30.936356	2021-10-08 05:30:31.663604
556	80	56	2021-10-08 05:30:33.163295	2021-10-08 05:30:33.933621
557	80	56	2021-10-08 05:30:35.077638	2021-10-08 05:30:35.866172
558	80	56	2021-10-08 05:30:37.142711	2021-10-08 05:30:38.305056
559	80	56	2021-10-08 05:30:39.928912	2021-10-08 05:30:40.720251
560	80	56	2021-10-08 05:30:42.988456	2021-10-08 05:31:40.33499
561	80	56	2021-10-08 05:35:08.717093	2021-10-08 05:35:10.141805
562	80	56	2021-10-08 05:35:11.903286	2021-10-08 05:35:46.435859
563	80	56	2021-10-08 05:35:50.182748	2021-10-08 05:35:51.90928
564	80	56	2021-10-08 05:35:54.593934	2021-10-08 05:35:55.695582
565	80	56	2021-10-08 05:35:57.478905	2021-10-08 05:35:58.796779
566	80	56	2021-10-08 05:36:00.314283	2021-10-08 05:36:01.609776
567	80	56	2021-10-08 05:36:03.027525	2021-10-08 05:36:04.001527
568	80	56	2021-10-08 05:36:05.542663	2021-10-08 05:36:06.701313
569	80	56	2021-10-08 05:36:08.371954	2021-10-08 05:36:09.621418
570	80	56	2021-10-08 05:36:11.236539	2021-10-08 05:36:15.508331
571	80	56	2021-10-08 05:36:17.674737	2021-10-08 05:36:19.238122
572	80	56	2021-10-08 05:36:34.231659	2021-10-08 05:36:35.983071
573	80	56	2021-10-08 05:36:37.513963	2021-10-08 05:36:38.280196
574	80	56	2021-10-08 05:36:40.337436	2021-10-08 05:36:41.293605
575	80	56	2021-10-08 05:36:43.001508	2021-10-08 05:36:44.46951
576	80	56	2021-10-08 05:36:46.576886	2021-10-08 05:37:43.33503
577	80	56	2021-10-08 05:38:24.651147	2021-10-08 05:39:21.335008
578	80	56	2021-10-08 05:42:23.143114	2021-10-08 05:43:11.264627
579	80	56	2021-10-08 05:43:13.237713	2021-10-08 05:43:14.069369
580	80	56	2021-10-08 05:43:15.591319	2021-10-08 05:43:16.510984
581	80	56	2021-10-08 05:43:17.973233	2021-10-08 05:43:18.907173
582	80	56	2021-10-08 05:43:20.04007	2021-10-08 05:43:21.082772
583	80	56	2021-10-08 05:43:22.516922	2021-10-08 05:43:23.955144
584	80	56	2021-10-08 05:43:25.569131	2021-10-08 05:43:26.478831
585	80	56	2021-10-08 05:44:03.107464	2021-10-08 05:44:04.428653
586	80	56	2021-10-08 05:44:05.832432	2021-10-08 05:44:07.517269
587	80	56	2021-10-08 05:44:09.36155	2021-10-08 05:44:10.752672
588	80	56	2021-10-08 05:44:12.639402	2021-10-08 05:44:13.599642
589	80	56	2021-10-08 05:44:14.825694	2021-10-08 05:44:15.945401
904	80	56	2021-10-08 07:16:52.539446	2021-10-08 09:40:02.226122
905	80	56	2021-10-08 07:16:54.052693	2021-10-08 09:40:02.226122
906	80	56	2021-10-08 07:16:54.2857	2021-10-08 09:40:02.226122
907	80	56	2021-10-08 07:16:54.661797	2021-10-08 09:40:02.226122
908	80	56	2021-10-08 07:16:54.981688	2021-10-08 09:40:02.226122
909	80	56	2021-10-08 07:16:55.284442	2021-10-08 09:40:02.226122
954	80	56	2021-10-08 07:24:17.957125	2021-10-08 09:40:02.226122
590	80	56	2021-10-08 05:44:17.227204	2021-10-08 05:44:18.480532
591	80	56	2021-10-08 05:44:20.243645	2021-10-08 05:44:21.492149
592	80	56	2021-10-08 05:44:23.21746	2021-10-08 05:44:25.581613
593	80	56	2021-10-08 05:44:27.423648	2021-10-08 05:44:28.789683
594	80	56	2021-10-08 05:44:30.783596	2021-10-08 05:44:31.936878
595	80	56	2021-10-08 05:44:33.478485	2021-10-08 05:44:34.468509
596	80	56	2021-10-08 05:44:36.004672	2021-10-08 05:44:36.745628
597	80	56	2021-10-08 05:44:38.240534	2021-10-08 05:44:39.023311
598	80	56	2021-10-08 05:44:40.183639	2021-10-08 05:44:41.400256
599	80	56	2021-10-08 05:44:43.587597	2021-10-08 05:44:44.859447
600	80	56	2021-10-08 05:44:46.30677	2021-10-08 05:44:47.213481
601	80	56	2021-10-08 05:44:48.886249	2021-10-08 05:44:49.753442
602	80	56	2021-10-08 05:44:51.110224	2021-10-08 05:44:52.01221
603	80	56	2021-10-08 05:44:53.023238	2021-10-08 05:44:53.898835
605	80	56	2021-10-08 05:44:59.842077	2021-10-08 05:45:00.636818
606	80	56	2021-10-08 05:45:02.045213	2021-10-08 05:45:03.497287
607	80	56	2021-10-08 05:45:05.585407	2021-10-08 05:45:06.600855
608	80	56	2021-10-08 05:45:08.389622	2021-10-08 05:45:09.156222
609	80	56	2021-10-08 05:45:10.630602	2021-10-08 05:45:11.776821
610	80	56	2021-10-08 05:45:13.127341	2021-10-08 05:45:13.870759
611	80	56	2021-10-08 05:45:15.325018	2021-10-08 05:45:16.081644
612	80	56	2021-10-08 05:45:17.420111	2021-10-08 05:45:18.11479
613	80	56	2021-10-08 05:45:19.503882	2021-10-08 05:45:20.695302
614	80	56	2021-10-08 05:45:26.110845	2021-10-08 05:45:27.002992
615	80	56	2021-10-08 05:45:28.480834	2021-10-08 05:45:29.768416
616	80	56	2021-10-08 05:45:31.158449	2021-10-08 05:45:32.329393
617	80	56	2021-10-08 05:45:33.904246	2021-10-08 05:46:31.334997
618	80	56	2021-10-08 05:47:13.730085	2021-10-08 05:48:10.335
619	80	56	2021-10-08 05:48:38.461029	2021-10-08 05:49:35.335
620	80	56	2021-10-08 05:49:55.589595	2021-10-08 05:50:12.914416
621	80	56	2021-10-08 05:50:22.228922	2021-10-08 05:51:19.335122
622	80	56	2021-10-08 05:51:41.295574	2021-10-08 05:52:38.335014
623	80	56	2021-10-08 05:54:05.960021	2021-10-08 05:55:03.335005
624	80	56	2021-10-08 05:55:39.694381	2021-10-08 05:56:36.335032
625	80	56	2021-10-08 05:58:15.305166	2021-10-08 05:58:30.488306
626	80	56	2021-10-08 05:58:32.361397	2021-10-08 05:58:34.099467
627	80	56	2021-10-08 05:58:35.888805	2021-10-08 05:58:37.322503
628	80	56	2021-10-08 06:00:08.48565	2021-10-08 06:00:10.199046
629	80	56	2021-10-08 06:00:12.20583	2021-10-08 06:00:13.456819
630	80	56	2021-10-08 06:00:14.987225	2021-10-08 06:00:16.389177
631	80	56	2021-10-08 06:00:56.305349	2021-10-08 06:00:57.509841
632	80	56	2021-10-08 06:01:00.088642	2021-10-08 06:01:01.217852
633	80	56	2021-10-08 06:01:03.069522	2021-10-08 06:01:04.07042
634	80	56	2021-10-08 06:01:05.610709	2021-10-08 06:01:06.505169
635	80	56	2021-10-08 06:01:08.716557	2021-10-08 06:01:09.628935
670	80	56	2021-10-08 06:09:41.757986	2021-10-08 06:09:43.632954
636	80	56	2021-10-08 06:01:11.058528	2021-10-08 06:01:20.511316
637	80	56	2021-10-08 06:01:28.023162	2021-10-08 06:01:29.422119
638	80	56	2021-10-08 06:01:31.320765	2021-10-08 06:01:32.65775
639	80	56	2021-10-08 06:01:34.309097	2021-10-08 06:01:35.190682
640	80	56	2021-10-08 06:01:36.670283	2021-10-08 06:01:37.581089
641	80	56	2021-10-08 06:01:39.552853	2021-10-08 06:02:29.694245
642	80	56	2021-10-08 06:02:31.618512	2021-10-08 06:02:33.008567
643	80	56	2021-10-08 06:02:34.71481	2021-10-08 06:02:38.290568
644	80	56	2021-10-08 06:02:41.196602	2021-10-08 06:02:42.257425
645	80	56	2021-10-08 06:02:44.837828	2021-10-08 06:02:45.888366
646	80	56	2021-10-08 06:02:47.279518	2021-10-08 06:02:48.069504
647	80	56	2021-10-08 06:03:36.726035	2021-10-08 06:03:38.152697
648	80	56	2021-10-08 06:03:40.248888	2021-10-08 06:03:41.780927
649	80	56	2021-10-08 06:03:43.515043	2021-10-08 06:03:44.374103
650	80	56	2021-10-08 06:04:05.141837	2021-10-08 06:04:07.348469
651	80	56	2021-10-08 06:04:10.528634	2021-10-08 06:04:11.559846
652	80	56	2021-10-08 06:04:13.850667	2021-10-08 06:04:14.46011
653	80	56	2021-10-08 06:04:22.799443	2021-10-08 06:04:24.129022
654	80	56	2021-10-08 06:04:25.848127	2021-10-08 06:04:26.89526
655	80	56	2021-10-08 06:04:28.511998	2021-10-08 06:04:30.319819
656	80	56	2021-10-08 06:06:56.1678	2021-10-08 06:06:57.695379
657	80	56	2021-10-08 06:06:59.560514	2021-10-08 06:07:00.704859
658	80	56	2021-10-08 06:07:02.441455	2021-10-08 06:07:04.33489
659	80	56	2021-10-08 06:07:06.21328	2021-10-08 06:07:07.404189
660	80	56	2021-10-08 06:07:09.094225	2021-10-08 06:07:10.56754
661	80	56	2021-10-08 06:07:12.06269	2021-10-08 06:08:03.816586
662	80	56	2021-10-08 06:08:05.79119	2021-10-08 06:08:07.02567
663	80	56	2021-10-08 06:08:08.689293	2021-10-08 06:08:09.931989
664	80	56	2021-10-08 06:08:11.696875	2021-10-08 06:08:12.730128
665	80	56	2021-10-08 06:08:14.160807	2021-10-08 06:08:15.169614
666	80	56	2021-10-08 06:08:16.706733	2021-10-08 06:08:18.339018
667	80	56	2021-10-08 06:08:19.669341	2021-10-08 06:08:20.686683
668	80	56	2021-10-08 06:08:22.020084	2021-10-08 06:09:19.335011
669	80	56	2021-10-08 06:09:37.259033	2021-10-08 06:09:39.283556
671	80	56	2021-10-08 06:09:45.40558	2021-10-08 06:09:47.774092
672	80	56	2021-10-08 06:09:50.278244	2021-10-08 06:09:52.134928
673	80	56	2021-10-08 06:09:54.471494	2021-10-08 06:10:18.091443
674	80	56	2021-10-08 06:10:20.09308	2021-10-08 06:10:21.106942
675	80	56	2021-10-08 06:10:23.593654	2021-10-08 06:10:24.54516
676	80	56	2021-10-08 06:10:26.22216	2021-10-08 06:10:29.306227
677	80	56	2021-10-08 06:10:31.389747	2021-10-08 06:10:32.643403
678	80	56	2021-10-08 06:10:34.255676	2021-10-08 06:10:34.958347
679	80	56	2021-10-08 06:10:36.402304	2021-10-08 06:10:37.202863
680	80	56	2021-10-08 06:10:38.439689	2021-10-08 06:11:35.334994
681	80	56	2021-10-08 06:11:38.261971	2021-10-08 06:11:39.357894
682	80	56	2021-10-08 06:11:40.996116	2021-10-08 06:11:42.060559
683	80	56	2021-10-08 06:11:43.564533	2021-10-08 06:11:44.878206
684	80	56	2021-10-08 06:11:46.770738	2021-10-08 06:11:47.766691
685	80	56	2021-10-08 06:11:49.453835	2021-10-08 06:11:50.546767
686	80	56	2021-10-08 06:11:53.022776	2021-10-08 06:11:56.595216
687	80	56	2021-10-08 06:11:58.43298	2021-10-08 06:11:59.620313
688	80	56	2021-10-08 06:12:00.979244	2021-10-08 06:12:03.368513
689	80	56	2021-10-08 06:12:05.104793	2021-10-08 06:12:05.882905
690	80	56	2021-10-08 06:12:08.457525	2021-10-08 06:12:09.592588
691	80	56	2021-10-08 06:12:10.926513	2021-10-08 06:12:12.111497
692	80	56	2021-10-08 06:12:14.514601	2021-10-08 06:12:15.624674
693	80	56	2021-10-08 06:12:16.933968	2021-10-08 06:12:18.046109
694	80	56	2021-10-08 06:12:19.915858	2021-10-08 06:12:20.889943
695	80	56	2021-10-08 06:12:22.073426	2021-10-08 06:12:23.642547
696	80	56	2021-10-08 06:12:25.558206	2021-10-08 06:12:26.838568
697	80	56	2021-10-08 06:12:28.599475	2021-10-08 06:12:30.544625
698	80	56	2021-10-08 06:12:33.382564	2021-10-08 06:12:34.551174
699	80	56	2021-10-08 06:12:36.20413	2021-10-08 06:12:37.046596
700	80	56	2021-10-08 06:12:38.864898	2021-10-08 06:12:39.628244
701	80	56	2021-10-08 06:12:41.022689	2021-10-08 06:12:41.803963
702	80	56	2021-10-08 06:12:43.240674	2021-10-08 06:12:44.102261
703	80	56	2021-10-08 06:12:46.369407	2021-10-08 06:12:54.345313
704	80	56	2021-10-08 06:12:56.401554	2021-10-08 06:12:57.899502
705	80	56	2021-10-08 06:12:59.79389	2021-10-08 06:13:00.981473
706	80	56	2021-10-08 06:13:02.959599	2021-10-08 06:13:05.09713
707	80	56	2021-10-08 06:13:06.742259	2021-10-08 06:14:03.335017
708	80	56	2021-10-08 06:14:15.454522	2021-10-08 06:14:16.613093
709	80	56	2021-10-08 06:14:18.365888	2021-10-08 06:14:19.381187
710	80	56	2021-10-08 06:14:21.055828	2021-10-08 06:14:21.984542
711	80	56	2021-10-08 06:14:23.811819	2021-10-08 06:14:24.974463
712	80	56	2021-10-08 06:14:26.49515	2021-10-08 06:14:27.524011
713	80	56	2021-10-08 06:14:29.190162	2021-10-08 06:14:30.030437
714	80	56	2021-10-08 06:14:31.493606	2021-10-08 06:14:32.339979
715	80	56	2021-10-08 06:14:34.105022	2021-10-08 06:14:35.152811
716	80	56	2021-10-08 06:14:36.668203	2021-10-08 06:14:37.863056
717	80	56	2021-10-08 06:14:39.574801	2021-10-08 06:14:40.831313
718	80	56	2021-10-08 06:14:42.304631	2021-10-08 06:15:39.33501
719	80	56	2021-10-08 06:15:44.684399	2021-10-08 06:15:48.591629
720	80	56	2021-10-08 06:15:58.038648	2021-10-08 06:16:01.25882
721	80	56	2021-10-08 06:16:05.206715	2021-10-08 06:16:06.805335
722	80	56	2021-10-08 06:16:08.265552	2021-10-08 06:16:09.552646
723	80	56	2021-10-08 06:16:11.634351	2021-10-08 06:16:12.564258
724	80	56	2021-10-08 06:16:14.111908	2021-10-08 06:16:15.270852
725	80	56	2021-10-08 06:16:17.18045	2021-10-08 06:16:18.624732
726	80	56	2021-10-08 06:16:19.911731	2021-10-08 06:17:17.334999
727	80	56	2021-10-08 06:25:11.422168	2021-10-08 06:25:12.302226
728	80	56	2021-10-08 06:25:13.934572	2021-10-08 06:25:15.741987
729	80	56	2021-10-08 06:25:17.54574	2021-10-08 06:25:18.574037
734	80	56	2021-10-08 06:25:50.843332	2021-10-08 06:25:51.924143
735	80	56	2021-10-08 06:25:54.045945	2021-10-08 06:25:55.418281
736	80	56	2021-10-08 06:25:57.130209	2021-10-08 06:25:58.21368
737	80	56	2021-10-08 06:25:59.732239	2021-10-08 06:26:00.667712
738	80	56	2021-10-08 06:26:02.624149	2021-10-08 06:26:03.572907
739	80	56	2021-10-08 06:26:05.217062	2021-10-08 06:26:06.396659
740	80	56	2021-10-08 06:26:08.103429	2021-10-08 06:26:09.102362
741	80	56	2021-10-08 06:26:10.394981	2021-10-08 06:26:11.977616
742	80	56	2021-10-08 06:26:13.465845	2021-10-08 06:26:14.585357
743	80	56	2021-10-08 06:26:16.439693	2021-10-08 06:26:17.217538
744	80	56	2021-10-08 06:26:19.062572	2021-10-08 06:26:20.000467
745	80	56	2021-10-08 06:26:21.783117	2021-10-08 06:26:22.717861
746	80	56	2021-10-08 06:26:24.577898	2021-10-08 06:26:33.147967
747	80	56	2021-10-08 06:26:35.431214	2021-10-08 06:26:36.563315
748	80	56	2021-10-08 06:26:38.102875	2021-10-08 06:26:39.092329
749	80	56	2021-10-08 06:26:40.851239	2021-10-08 06:26:41.679879
750	80	56	2021-10-08 06:26:43.462677	2021-10-08 06:26:44.523482
751	80	56	2021-10-08 06:26:46.44757	2021-10-08 06:26:47.279984
752	80	56	2021-10-08 06:26:48.89236	2021-10-08 06:27:46.335004
753	80	56	2021-10-08 06:28:19.563855	2021-10-08 06:28:20.268876
754	80	56	2021-10-08 06:28:21.580104	2021-10-08 06:28:22.072182
755	80	56	2021-10-08 06:28:23.722438	2021-10-08 06:28:24.557337
756	80	56	2021-10-08 06:28:27.159929	2021-10-08 06:28:27.937641
757	80	56	2021-10-08 06:28:30.245083	2021-10-08 06:28:31.07555
758	80	56	2021-10-08 06:28:32.684627	2021-10-08 06:28:33.517773
759	80	56	2021-10-08 06:28:35.321872	2021-10-08 06:28:36.438111
760	80	56	2021-10-08 06:28:38.082849	2021-10-08 06:29:35.334985
761	80	56	2021-10-08 06:41:35.795846	2021-10-08 06:41:37.155579
762	80	56	2021-10-08 06:41:38.908708	2021-10-08 06:41:40.608224
763	80	56	2021-10-08 06:41:42.244774	2021-10-08 06:41:43.091104
764	80	56	2021-10-08 06:41:44.527571	2021-10-08 06:41:45.395116
765	80	56	2021-10-08 06:41:47.792457	2021-10-08 06:41:48.539003
766	80	56	2021-10-08 06:41:50.437262	2021-10-08 06:41:51.374657
767	80	56	2021-10-08 06:41:53.441178	2021-10-08 06:41:54.551495
768	80	56	2021-10-08 06:41:56.435698	2021-10-08 06:41:57.321337
769	80	56	2021-10-08 06:42:19.847653	2021-10-08 06:42:21.098303
770	80	56	2021-10-08 06:42:22.793461	2021-10-08 06:42:23.6209
771	80	56	2021-10-08 06:42:25.234678	2021-10-08 06:42:26.092544
772	80	56	2021-10-08 06:42:27.615532	2021-10-08 06:42:28.539738
773	80	56	2021-10-08 06:42:30.360118	2021-10-08 06:42:31.625354
774	80	56	2021-10-08 06:42:33.223528	2021-10-08 06:42:34.176075
775	80	56	2021-10-08 06:42:35.710612	2021-10-08 06:43:12.166413
776	80	56	2021-10-08 06:43:14.559036	2021-10-08 06:43:15.164419
777	80	56	2021-10-08 06:43:17.059642	2021-10-08 06:43:17.797644
778	80	56	2021-10-08 06:43:19.269491	2021-10-08 06:43:20.013082
779	80	56	2021-10-08 06:43:21.882198	2021-10-08 06:43:22.644211
781	80	56	2021-10-08 06:43:34.82565	2021-10-08 06:43:36.802676
782	80	56	2021-10-08 06:43:38.236219	2021-10-08 06:43:39.30439
783	80	56	2021-10-08 06:43:40.821705	2021-10-08 06:43:42.756318
784	80	56	2021-10-08 06:43:50.609129	2021-10-08 06:43:52.140772
785	80	56	2021-10-08 06:44:02.378169	2021-10-08 06:44:05.021461
786	80	56	2021-10-08 06:44:08.77391	2021-10-08 06:44:10.421965
787	80	56	2021-10-08 06:44:12.334803	2021-10-08 06:44:55.316815
788	80	56	2021-10-08 06:44:57.802966	2021-10-08 06:44:59.120898
789	80	56	2021-10-08 06:45:00.898655	2021-10-08 06:45:01.788461
790	80	56	2021-10-08 06:45:03.434376	2021-10-08 06:45:04.377446
791	80	56	2021-10-08 06:45:05.857745	2021-10-08 06:45:55.821118
792	80	56	2021-10-08 06:45:57.899102	2021-10-08 06:45:58.949532
793	80	56	2021-10-08 06:46:00.761361	2021-10-08 06:46:01.878538
794	80	56	2021-10-08 06:46:03.62585	2021-10-08 06:46:04.550882
795	80	56	2021-10-08 06:46:06.019634	2021-10-08 06:46:08.185056
796	80	56	2021-10-08 06:46:10.016777	2021-10-08 06:46:11.074339
797	80	56	2021-10-08 06:46:12.677261	2021-10-08 06:46:13.577266
798	80	56	2021-10-08 06:46:15.209616	2021-10-08 06:47:09.241419
799	80	56	2021-10-08 06:47:11.144837	2021-10-08 06:47:12.782068
800	80	56	2021-10-08 06:47:14.282672	2021-10-08 06:47:15.510289
801	80	56	2021-10-08 06:47:16.944342	2021-10-08 06:47:17.926645
802	80	56	2021-10-08 06:47:19.53555	2021-10-08 06:47:20.552145
803	80	56	2021-10-08 06:47:21.813503	2021-10-08 06:47:22.910104
805	80	56	2021-10-08 06:47:31.437459	2021-10-08 06:47:32.687827
806	80	56	2021-10-08 06:47:34.2181	2021-10-08 06:47:35.094177
807	80	56	2021-10-08 06:47:37.801451	2021-10-08 06:47:38.780215
808	80	56	2021-10-08 06:47:40.39121	2021-10-08 06:47:41.216421
809	80	56	2021-10-08 06:47:42.664592	2021-10-08 06:47:43.532876
810	80	56	2021-10-08 06:47:44.897479	2021-10-08 06:48:00.571289
811	80	56	2021-10-08 06:48:02.952589	2021-10-08 06:48:03.961301
812	80	56	2021-10-08 06:48:05.337507	2021-10-08 06:48:06.514911
813	80	56	2021-10-08 06:48:08.364672	2021-10-08 06:48:09.208487
814	80	56	2021-10-08 06:48:10.887764	2021-10-08 06:48:11.553729
815	80	56	2021-10-08 06:48:12.808201	2021-10-08 06:48:13.395821
817	80	56	2021-10-08 06:48:20.667225	2021-10-08 06:48:22.609034
819	80	56	2021-10-08 06:48:32.122801	2021-10-08 06:49:13.55163
820	80	56	2021-10-08 06:49:15.733293	2021-10-08 06:49:16.560556
821	80	56	2021-10-08 06:49:18.411172	2021-10-08 06:49:19.684949
822	80	56	2021-10-08 06:49:21.495852	2021-10-08 06:49:22.21649
823	80	56	2021-10-08 06:49:28.825027	2021-10-08 06:49:29.814526
824	80	56	2021-10-08 06:49:31.499243	2021-10-08 06:49:32.205493
825	80	56	2021-10-08 06:49:34.019864	2021-10-08 06:49:34.715235
826	80	56	2021-10-08 06:49:36.282791	2021-10-08 06:49:37.056129
827	80	56	2021-10-08 06:49:38.730719	2021-10-08 06:49:39.701143
828	80	56	2021-10-08 06:49:41.544597	2021-10-08 06:49:42.81488
829	80	56	2021-10-08 06:49:44.509606	2021-10-08 06:49:47.043373
830	80	56	2021-10-08 06:49:50.01752	2021-10-08 06:49:50.819584
832	80	56	2021-10-08 06:50:02.025821	2021-10-08 06:50:04.851648
833	80	56	2021-10-08 06:52:25.113467	2021-10-08 06:52:26.106802
834	80	56	2021-10-08 06:52:28.099756	2021-10-08 06:52:28.897686
835	80	56	2021-10-08 06:52:30.706324	2021-10-08 06:52:31.428301
836	80	56	2021-10-08 06:52:33.249439	2021-10-08 06:52:34.011985
837	80	56	2021-10-08 06:52:35.784333	2021-10-08 06:52:36.526205
838	80	56	2021-10-08 06:52:38.24275	2021-10-08 06:52:39.232419
839	80	56	2021-10-08 06:52:40.938729	2021-10-08 06:52:42.063158
840	80	56	2021-10-08 06:52:47.223613	2021-10-08 06:52:48.097519
841	80	56	2021-10-08 06:52:49.663586	2021-10-08 06:52:50.537108
842	80	56	2021-10-08 06:58:24.86087	2021-10-08 06:58:26.822209
843	80	56	2021-10-08 06:58:28.649044	2021-10-08 06:58:29.794708
844	80	56	2021-10-08 06:58:31.279399	2021-10-08 06:58:32.348258
845	80	56	2021-10-08 06:58:33.838004	2021-10-08 06:59:31.335002
846	80	56	2021-10-08 07:00:48.930999	2021-10-08 07:00:50.278912
847	80	56	2021-10-08 07:00:51.953171	2021-10-08 07:00:53.260472
848	80	56	2021-10-08 07:00:54.706785	2021-10-08 07:00:55.695933
849	80	56	2021-10-08 07:03:06.556296	2021-10-08 07:03:07.821658
850	80	56	2021-10-08 07:03:09.964401	2021-10-08 07:03:11.186888
851	80	56	2021-10-08 07:03:13.19409	2021-10-08 07:03:13.879294
852	80	56	2021-10-08 07:03:15.438598	2021-10-08 07:03:16.730475
853	80	56	2021-10-08 07:03:18.835415	2021-10-08 07:03:19.519862
854	80	56	2021-10-08 07:03:22.177701	2021-10-08 07:03:23.140442
855	80	56	2021-10-08 07:03:24.987939	2021-10-08 07:03:25.652751
856	80	56	2021-10-08 07:03:28.529568	2021-10-08 07:03:29.113341
780	80	56	2021-10-08 06:43:23.999542	2021-10-08 07:15:31.867149
865	80	56	2021-10-08 07:04:56.472218	2021-10-08 07:04:57.127769
866	80	56	2021-10-08 07:04:59.149158	2021-10-08 07:05:01.739156
867	80	56	2021-10-08 07:06:54.639013	2021-10-08 07:06:55.890528
868	80	56	2021-10-08 07:06:58.458819	2021-10-08 07:06:59.159445
869	80	56	2021-10-08 07:07:01.131886	2021-10-08 07:07:02.374629
870	80	56	2021-10-08 07:07:04.492247	2021-10-08 07:07:17.179808
871	80	56	2021-10-08 07:07:19.376144	2021-10-08 07:07:20.204436
872	80	56	2021-10-08 07:07:21.959721	2021-10-08 07:07:24.016239
873	80	56	2021-10-08 07:07:26.197429	2021-10-08 07:07:26.812361
874	80	56	2021-10-08 07:07:29.551409	2021-10-08 07:07:30.052246
875	80	56	2021-10-08 07:07:33.192679	2021-10-08 07:07:33.893928
876	80	56	2021-10-08 07:07:36.459046	2021-10-08 07:07:37.307724
877	80	56	2021-10-08 07:09:39.434617	2021-10-08 07:09:40.704979
878	80	56	2021-10-08 07:09:43.010202	2021-10-08 07:09:43.803727
879	80	56	2021-10-08 07:09:45.629027	2021-10-08 07:09:46.731406
880	80	56	2021-10-08 07:09:48.487717	2021-10-08 07:09:49.669777
881	80	56	2021-10-08 07:09:51.451169	2021-10-08 07:09:52.298816
882	80	56	2021-10-08 07:09:54.093313	2021-10-08 07:09:54.757534
883	80	56	2021-10-08 07:09:57.493	2021-10-08 07:09:58.087867
884	80	56	2021-10-08 07:09:59.827353	2021-10-08 07:10:00.216086
924	80	56	2021-10-08 07:19:44.761339	2021-10-08 07:19:46.109795
885	80	56	2021-10-08 07:10:01.894	2021-10-08 07:10:02.54392
886	80	56	2021-10-08 07:10:04.994838	2021-10-08 07:10:05.409682
887	80	56	2021-10-08 07:10:07.870053	2021-10-08 07:10:08.387655
888	80	56	2021-10-08 07:10:11.045817	2021-10-08 07:10:11.693391
889	80	56	2021-10-08 07:10:13.893924	2021-10-08 07:10:32.54359
890	80	56	2021-10-08 07:10:34.686607	2021-10-08 07:10:36.600442
891	80	56	2021-10-08 07:10:38.859947	2021-10-08 07:10:40.542031
892	80	56	2021-10-08 07:10:42.65563	2021-10-08 07:10:43.510147
893	80	56	2021-10-08 07:10:45.605847	2021-10-08 07:10:45.955263
895	80	56	2021-10-08 07:10:49.459032	2021-10-08 07:10:50.130625
804	80	56	2021-10-08 06:47:24.777732	2021-10-08 07:15:31.867149
816	80	56	2021-10-08 06:48:14.613384	2021-10-08 07:15:31.867149
818	80	56	2021-10-08 06:48:24.347422	2021-10-08 07:15:31.867149
831	80	56	2021-10-08 06:49:56.63254	2021-10-08 07:15:31.867149
862	80	56	2021-10-08 07:04:37.73251	2021-10-08 07:15:31.867149
894	80	56	2021-10-08 07:10:47.444244	2021-10-08 07:15:31.867149
896	80	56	2021-10-08 07:10:52.656303	2021-10-08 07:15:31.867149
897	80	56	2021-10-08 07:16:18.096519	2021-10-08 07:16:19.350194
898	80	56	2021-10-08 07:16:22.044952	2021-10-08 07:16:23.195274
899	80	56	2021-10-08 07:16:25.524639	2021-10-08 07:16:26.265782
900	80	56	2021-10-08 07:16:28.54934	2021-10-08 07:16:29.239836
901	80	56	2021-10-08 07:16:31.555187	2021-10-08 07:16:32.199049
903	80	56	2021-10-08 07:16:34.944315	2021-10-08 07:16:43.865661
910	80	56	2021-10-08 07:16:55.500773	2021-10-08 07:16:59.300136
911	80	56	2021-10-08 07:18:30.461124	2021-10-08 07:18:31.913587
912	80	56	2021-10-08 07:18:34.137026	2021-10-08 07:18:35.5482
913	80	56	2021-10-08 07:18:37.603435	2021-10-08 07:18:39.29643
914	80	56	2021-10-08 07:18:41.571772	2021-10-08 07:18:42.912834
915	80	56	2021-10-08 07:18:45.020922	2021-10-08 07:18:46.127216
916	80	56	2021-10-08 07:18:48.189458	2021-10-08 07:18:49.391419
917	80	56	2021-10-08 07:18:51.30536	2021-10-08 07:18:52.295586
918	80	56	2021-10-08 07:18:54.30774	2021-10-08 07:18:56.057028
919	80	56	2021-10-08 07:18:58.72153	2021-10-08 07:18:59.88482
920	80	56	2021-10-08 07:19:01.821566	2021-10-08 07:19:02.877824
921	80	56	2021-10-08 07:19:12.535768	2021-10-08 07:19:14.009015
922	80	56	2021-10-08 07:19:15.836047	2021-10-08 07:19:40.161808
923	80	56	2021-10-08 07:19:41.934971	2021-10-08 07:19:43.362038
925	80	56	2021-10-08 07:19:47.353156	2021-10-08 07:19:50.46319
926	80	56	2021-10-08 07:19:51.934785	2021-10-08 07:19:52.983461
927	80	56	2021-10-08 07:19:54.397267	2021-10-08 07:19:56.144644
928	80	56	2021-10-08 07:19:57.547271	2021-10-08 07:19:59.558711
929	80	56	2021-10-08 07:20:01.163732	2021-10-08 07:20:02.503045
930	80	56	2021-10-08 07:20:04.448905	2021-10-08 07:20:07.242302
931	80	56	2021-10-08 07:20:09.048596	2021-10-08 07:20:10.289546
932	80	56	2021-10-08 07:20:42.102951	2021-10-08 07:20:43.095996
933	80	56	2021-10-08 07:20:44.614644	2021-10-08 07:20:46.339485
934	80	56	2021-10-08 07:20:47.776438	2021-10-08 07:20:49.125874
935	80	56	2021-10-08 07:20:50.445761	2021-10-08 07:20:52.173409
936	80	56	2021-10-08 07:20:53.911198	2021-10-08 07:20:55.375566
937	80	56	2021-10-08 07:20:58.896613	2021-10-08 07:21:00.008702
938	80	56	2021-10-08 07:21:01.591929	2021-10-08 07:21:02.874494
939	80	56	2021-10-08 07:21:04.340172	2021-10-08 07:21:06.907852
940	80	56	2021-10-08 07:21:10.994322	2021-10-08 07:21:11.973556
941	80	56	2021-10-08 07:21:13.726636	2021-10-08 07:21:15.180846
942	80	56	2021-10-08 07:22:38.14866	2021-10-08 07:22:38.966076
943	80	56	2021-10-08 07:22:40.506466	2021-10-08 07:22:42.250486
944	80	56	2021-10-08 07:22:43.705566	2021-10-08 07:22:44.804175
945	80	56	2021-10-08 07:22:46.191363	2021-10-08 07:22:48.208723
946	80	56	2021-10-08 07:22:49.692686	2021-10-08 07:22:52.536741
947	80	56	2021-10-08 07:23:28.01991	2021-10-08 07:23:29.167383
948	80	56	2021-10-08 07:23:30.621888	2021-10-08 07:23:31.416539
949	80	56	2021-10-08 07:23:32.621551	2021-10-08 07:23:35.751708
950	80	56	2021-10-08 07:23:37.069649	2021-10-08 07:23:37.738151
951	80	56	2021-10-08 07:23:39.257114	2021-10-08 07:23:39.997309
952	80	56	2021-10-08 07:23:46.308969	2021-10-08 07:24:13.530373
953	80	56	2021-10-08 07:24:15.598528	2021-10-08 07:24:16.374562
955	80	56	2021-10-08 07:24:24.877773	2021-10-08 07:24:26.605981
956	80	56	2021-10-08 07:24:31.753668	2021-10-08 07:24:33.194691
957	80	56	2021-10-08 07:24:37.662595	2021-10-08 07:24:39.330747
958	80	56	2021-10-08 07:24:43.642904	2021-10-08 07:24:47.055797
959	80	56	2021-10-08 07:24:52.113523	2021-10-08 07:24:53.281942
960	80	56	2021-10-08 07:33:47.445312	2021-10-08 07:33:49.547712
961	80	56	2021-10-08 07:33:51.961638	2021-10-08 07:33:52.87532
962	80	56	2021-10-08 07:33:54.653404	2021-10-08 07:33:55.632471
963	80	56	2021-10-08 07:33:57.002756	2021-10-08 07:33:57.954069
965	80	56	2021-10-08 07:34:10.004925	2021-10-08 07:34:11.902967
966	80	56	2021-10-08 07:34:19.96638	2021-10-08 07:34:21.173347
967	80	56	2021-10-08 07:34:26.497656	2021-10-08 07:34:28.766526
968	80	56	2021-10-08 07:34:34.228177	2021-10-08 07:34:35.167567
969	80	56	2021-10-08 07:34:40.453875	2021-10-08 07:34:41.902199
970	80	56	2021-10-08 07:34:43.556705	2021-10-08 07:34:44.387317
971	80	56	2021-10-08 07:34:45.926326	2021-10-08 07:34:47.118747
972	80	56	2021-10-08 07:34:51.372878	2021-10-08 07:34:52.14615
973	80	56	2021-10-08 07:34:54.155049	2021-10-08 07:34:55.332681
974	80	56	2021-10-08 07:34:56.92557	2021-10-08 07:35:04.750019
975	80	56	2021-10-08 07:35:06.488562	2021-10-08 07:35:07.585133
976	80	56	2021-10-08 07:36:01.919389	2021-10-08 07:36:02.867243
977	80	56	2021-10-08 07:36:04.128761	2021-10-08 07:36:05.381783
978	80	56	2021-10-08 07:37:06.71126	2021-10-08 07:37:07.902391
979	80	56	2021-10-08 07:37:09.119386	2021-10-08 07:37:10.194639
980	80	56	2021-10-08 07:37:17.154811	2021-10-08 07:37:18.250909
902	80	56	2021-10-08 07:16:34.57238	2021-10-08 09:40:02.226122
964	80	56	2021-10-08 07:33:59.340651	2021-10-08 09:40:02.226122
981	80	56	2021-10-08 10:15:10.419378	2021-10-08 10:15:16.651275
982	80	56	2021-10-08 10:15:18.233216	2021-10-08 10:15:19.223244
983	80	56	2021-10-08 10:15:20.691874	2021-10-08 10:15:21.608898
984	80	56	2021-10-08 10:15:23.227862	2021-10-08 10:15:24.283419
986	80	56	2021-10-08 10:15:31.946146	2021-10-08 10:15:38.060167
987	80	56	2021-10-08 10:15:47.379482	2021-10-08 10:15:48.842232
988	80	56	2021-10-08 10:15:59.343866	2021-10-08 10:16:00.673066
989	80	56	2021-10-08 10:16:05.462131	2021-10-08 10:16:06.70981
985	80	56	2021-10-08 10:15:26.916597	2021-10-08 14:20:57.81735
\.


--
-- Data for Name: _result; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._result (id, questionsession_id, userid, result) FROM stdin;
159	519	8	ВОЗДЕРЖАЛСЯ
160	550	8	ПРОТИВ
161	551	8	ЗА
162	588	8	ПРОТИВ
163	592	8	ЗА
164	593	8	ПРОТИВ
165	595	8	ВОЗДЕРЖАЛСЯ
166	596	8	ВОЗДЕРЖАЛСЯ
167	597	8	ВОЗДЕРЖАЛСЯ
168	599	8	ЗА
\.


--
-- Data for Name: _settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._settings (id, pallettesettings, operatorschemesettings, managerschemesettings, votingsettings, storeboardsettings, licensesettings, soundsettings) FROM stdin;
5	{"backgroundColor":4288585374,"schemeBackgroundColor":1040187391,"cellColor":520093696,"alternateCellColor":4288318046,"alternateRowNumbers":"4,5,6","alternateRowPadding":10,"paddingRowNumbers":"4,5,6,9","cellTextColor":4288194616,"cellBorderColor":2315255808,"unRegistredColor":4294967295,"registredColor":4280391411,"voteYesColor":4284084398,"voteNoColor":4294937216,"voteIndifferentColor":4293935355,"askWordColor":4294961979,"onSpeechColor":4289961435,"buttonTextColor":4294967295,"iconOnlineColor":4283215696,"iconOfflineColor":4294198070,"iconDocumentsDownloadedColor":4283215696,"iconDocumentsNotDownloadedColor":4294198070}	{"inverseScheme":false,"cellWidth":120,"cellBorder":1,"cellInnerPadding":4,"cellOuterPaddingVertical":5,"cellOuterPaddingHorisontal":4,"isShortNamesUsed":false,"cellTextSize":14,"overflowOption":"Обрезать текст","textMaxLines":1,"showOverflow":true,"iconSize":20}	{"inverseScheme":true,"cellWidth":110,"cellBorder":1,"cellInnerPadding":5,"cellOuterPaddingVertical":20,"cellOuterPaddingHorisontal":5,"isShortNamesUsed":true,"cellTextSize":14,"overflowOption":"Обрезать текст","textMaxLines":1,"showOverflow":true,"iconSize":32,"deputyFontSize":21,"deputyNumberFontSize":22,"deputyCaptionFontSize":26,"deputyFilesListHeight":350}	{"isVotingFixed":true,"defaultRegistrationInterval":56,"defaultVotingInterval":17,"defaultShowResultInterval":10,"defaultNewQuestionName":"Вопрос","defaultFirstQuestionName":"Регламентные вопросы","defaultFirstQuestionVotingName":"регламентным вопросам","defaultQuestionNumberPrefix":"","isFirstQuestionUseNumber":false,"defaultVotingModeId":2,"reportsFolderPath":"/home/vladimir/Desktop/reports"}	{"backgroundColor":4278255718,"textColor":4294967295,"height":255,"width":450,"padding":10,"meetingDescriptionTemplate":"Очередное \\nпленарное заседание\\nЗаконодательного собрания\\nКраснодарского Края\\nшестого созыва","speakerInterval":300,"breakInterval":1800,"meetingDescriptionFontSize":16,"meetingFontSize":14,"groupFontSize":14,"customCaptionFontSize":18,"customTextFontSize":16,"resultItemsFontSize":18,"resultTotalFontSize":24,"timersFontSize":24,"questionNameFontSize":14,"questionDescriptionFontSize":14,"justifyQuestionDescription":true,"clockFontSize":14,"clockFontBold":false,"detailsAnimationDuration":3,"detailsRowsCount":5,"detailsFontSize":18}	{"licenseKey":"11113-11317-11119-11118-11117"}	{"registrationStart":"/home/vladimir/Desktop/ding.mp3","registrationEnd":"","votingStart":"/home/vladimir/Desktop/ding.mp3","votingEnd":"","hymnStart":"","hymnEnd":"","defaultStreamUrl":""}
\.


--
-- Data for Name: _user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._user (id, firstname, secondname, lastname, login, password, lastsession, isvoter, cardid) FROM stdin;
5	тест	тест	тест	тест	тест	\N	t	
6	ОченьДлинноеИмя	ОЧеньДлиннаяФамилия	ОченьДлинноеОтчество	йцуке	йцуке	\N	t	
7	12345566111ZZXXVVV	12345566	12345566	12345566	12345566	\N	t	
9	2	2	2	2	2	\N	t	
10	3	3	3	3	3	\N	t	
11	4	4	4	4	4	\N	t	
12	5	5	5	5	5	\N	t	
13	6	6	6	6	6	\N	t	
14	7	7	7	7	7	\N	t	
15	8	8	8	8	8	\N	t	
16	9	9	9	9	9	\N	t	
17	0	0	0	0	0	\N	t	
18	Дмитрий	Бойцов	Евгеньевич	Бойцов	123456	\N	t	
47	firstname	secondname	lastname	login	password	\N	t	
48	тест1	тест1	тест1	01	01	\N	t	
49	тест12	тест12	тест12	02	02	\N	t	
1	Дмитрий	Бойцов	Евгеньевич	12345	12345	\N	t	
2	123	123	123	123	123	\N	t	
4	12	12	12	12	12	\N	t	
3	1234	1234	1234	1234	1234	\N	t	
8	1	1	1	1	1	\N	t	003
\.


--
-- Data for Name: _votingmode; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public._votingmode (id, name, defaultdecision, ordernum, includeddecisions) FROM stdin;
1	Принять	2/3 от установленного числа	0	Большинство от установленного числа;2/3 от установленного числа;1/3 от установленного числа;Большинство от выбранных членов;2/3 от выбранных членов;1/3 от выбранных членов;Большинство от зарегистрированных членов;2/3 от зарегистрированных членов;1/3 от зарегистрированных членов;
2	Отклонить	Большинство от зарегистрированных членов	1	Большинство от установленного числа;2/3 от установленного числа;1/3 от установленного числа;2/3 от зарегистрированных членов;1/3 от зарегистрированных членов;2/3 от выбранных членов;Большинство от выбранных членов;1/3 от выбранных членов;Большинство от зарегистрированных членов;
\.


--
-- Name: _agenda_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._agenda_id_seq', 38, true);


--
-- Name: _file_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._file_id_seq', 2786, true);


--
-- Name: _group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._group_id_seq', 14, true);


--
-- Name: _groupuser_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._groupuser_id_seq', 909, true);


--
-- Name: _meeting_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._meeting_id_seq', 83, true);


--
-- Name: _meetingsession_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._meetingsession_id_seq', 198, true);


--
-- Name: _question_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._question_id_seq', 952, true);


--
-- Name: _questionsession_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._questionsession_id_seq', 600, true);


--
-- Name: _registration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._registration_id_seq', 75, true);


--
-- Name: _registrationsession_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._registrationsession_id_seq', 1001, true);


--
-- Name: _result_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._result_id_seq', 168, true);


--
-- Name: _settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._settings_id_seq', 5, true);


--
-- Name: _user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public._user_id_seq', 49, true);


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
-- Name: _user _user_login_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public._user
    ADD CONSTRAINT _user_login_key UNIQUE (login);


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

