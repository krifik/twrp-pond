--
-- PostgreSQL database dump
--

\restrict b1ZGMh0JpW83NAkk2KXYtWfiqJpvoL7wrlegMI5IayPH1U99gN0NUC0SrhDJzvS

-- Dumped from database version 16.15
-- Dumped by pg_dump version 16.15

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

DROP INDEX IF EXISTS public.idx_energy_logs_timestamp;
DROP INDEX IF EXISTS public.idx_energy_logs_device;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_username_key;
ALTER TABLE IF EXISTS ONLY public.users DROP CONSTRAINT IF EXISTS users_pkey;
ALTER TABLE IF EXISTS ONLY public.telegram_config DROP CONSTRAINT IF EXISTS telegram_config_pkey;
ALTER TABLE IF EXISTS ONLY public.schedules DROP CONSTRAINT IF EXISTS schedules_pkey;
ALTER TABLE IF EXISTS ONLY public.scenes DROP CONSTRAINT IF EXISTS scenes_pkey;
ALTER TABLE IF EXISTS ONLY public.power_guard_config DROP CONSTRAINT IF EXISTS power_guard_config_pkey;
ALTER TABLE IF EXISTS ONLY public.permissions DROP CONSTRAINT IF EXISTS permissions_pkey;
ALTER TABLE IF EXISTS ONLY public.energy_logs DROP CONSTRAINT IF EXISTS energy_logs_pkey;
ALTER TABLE IF EXISTS ONLY public.devices DROP CONSTRAINT IF EXISTS devices_pkey;
ALTER TABLE IF EXISTS ONLY public.device_timers DROP CONSTRAINT IF EXISTS device_timers_pkey;
ALTER TABLE IF EXISTS ONLY public.device_name_history DROP CONSTRAINT IF EXISTS device_name_history_pkey;
ALTER TABLE IF EXISTS ONLY public.budget_settings DROP CONSTRAINT IF EXISTS budget_settings_pkey;
ALTER TABLE IF EXISTS public.users ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.schedules ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.energy_logs ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.users_id_seq;
DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.telegram_config;
DROP SEQUENCE IF EXISTS public.schedules_id_seq;
DROP TABLE IF EXISTS public.schedules;
DROP TABLE IF EXISTS public.scenes;
DROP TABLE IF EXISTS public.power_guard_config;
DROP TABLE IF EXISTS public.permissions;
DROP SEQUENCE IF EXISTS public.energy_logs_id_seq;
DROP TABLE IF EXISTS public.energy_logs;
DROP TABLE IF EXISTS public.devices;
DROP TABLE IF EXISTS public.device_timers;
DROP TABLE IF EXISTS public.device_name_history;
DROP TABLE IF EXISTS public.budget_settings;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: budget_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.budget_settings (
    id integer DEFAULT 1 NOT NULL,
    monthly_budget_idr double precision DEFAULT 750000,
    warning_threshold_pct double precision DEFAULT 80
);


ALTER TABLE public.budget_settings OWNER TO postgres;

--
-- Name: device_name_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device_name_history (
    device_id text NOT NULL,
    name text
);


ALTER TABLE public.device_name_history OWNER TO postgres;

--
-- Name: device_timers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device_timers (
    device_id text NOT NULL,
    target_action text DEFAULT 'OFF'::text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    duration_minutes integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.device_timers OWNER TO postgres;

--
-- Name: devices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices (
    id text NOT NULL,
    name text,
    ip text,
    local_key text,
    status boolean DEFAULT false,
    power integer DEFAULT 0,
    allowed_roles text DEFAULT 'admin,operator'::text,
    priority integer DEFAULT 2
);


ALTER TABLE public.devices OWNER TO postgres;

--
-- Name: energy_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.energy_logs (
    id integer NOT NULL,
    device_id text,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    power_watt integer,
    kwh double precision,
    cost_idr double precision
);


ALTER TABLE public.energy_logs OWNER TO postgres;

--
-- Name: energy_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.energy_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.energy_logs_id_seq OWNER TO postgres;

--
-- Name: energy_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.energy_logs_id_seq OWNED BY public.energy_logs.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permissions (
    id text NOT NULL,
    feature text,
    desc_text text,
    admin boolean DEFAULT true,
    operator boolean DEFAULT true,
    viewer boolean DEFAULT false
);


ALTER TABLE public.permissions OWNER TO postgres;

--
-- Name: power_guard_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.power_guard_config (
    id integer DEFAULT 1 NOT NULL,
    max_watt_limit integer DEFAULT 1150,
    is_enabled boolean DEFAULT true,
    cutoff_duration_sec integer DEFAULT 8,
    last_triggered_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.power_guard_config OWNER TO postgres;

--
-- Name: scenes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scenes (
    id text NOT NULL,
    name text NOT NULL,
    icon text NOT NULL,
    description text,
    actions text NOT NULL,
    is_preset boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.scenes OWNER TO postgres;

--
-- Name: schedules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schedules (
    id integer NOT NULL,
    device_id text NOT NULL,
    device_name text,
    action text DEFAULT 'ON'::text NOT NULL,
    time_target text NOT NULL,
    days text DEFAULT 'ALL'::text,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.schedules OWNER TO postgres;

--
-- Name: schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.schedules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.schedules_id_seq OWNER TO postgres;

--
-- Name: schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.schedules_id_seq OWNED BY public.schedules.id;


--
-- Name: telegram_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.telegram_config (
    id integer DEFAULT 1 NOT NULL,
    bot_token text DEFAULT ''::text,
    chat_id text DEFAULT ''::text,
    is_enabled boolean DEFAULT false,
    notify_on_overload boolean DEFAULT true,
    notify_on_leak boolean DEFAULT true,
    daily_digest_time text DEFAULT '21:00'::text
);


ALTER TABLE public.telegram_config OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username text,
    name text,
    role text,
    password text
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: energy_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.energy_logs ALTER COLUMN id SET DEFAULT nextval('public.energy_logs_id_seq'::regclass);


--
-- Name: schedules id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedules ALTER COLUMN id SET DEFAULT nextval('public.schedules_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: budget_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.budget_settings (id, monthly_budget_idr, warning_threshold_pct) FROM stdin;
1	550000	80
\.


--
-- Data for Name: device_name_history; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.device_name_history (device_id, name) FROM stdin;
\.


--
-- Data for Name: device_timers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.device_timers (device_id, target_action, expires_at, duration_minutes, created_at) FROM stdin;
\.


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.devices (id, name, ip, local_key, status, power, allowed_roles, priority) FROM stdin;
a31a5c95501212e37f2fld	PC	\N	\N	t	220	admin	1
a37cb5dfb4d22c266f7wxo	AIR	\N	\N	f	0	admin,operator,viewer	2
\.


--
-- Data for Name: energy_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.energy_logs (id, device_id, "timestamp", power_watt, kwh, cost_idr) FROM stdin;
8866	a37cb5dfb4d22c266f7wxo	2026-10-04 10:23:28.169+07	119	0.06	86.682
8867	a37cb5dfb4d22c266f7wxo	2026-10-04 12:42:34.618+07	0	0.001	1.4447
8868	a37cb5dfb4d22c266f7wxo	2026-10-04 13:12:52.255+07	158	0.08	115.57600000000001
8869	a37cb5dfb4d22c266f7wxo	2026-10-04 13:43:05.096+07	101	0.051	73.6797
8870	a37cb5dfb4d22c266f7wxo	2026-10-04 14:41:41.614+07	1	0.001	1.4447
8871	a37cb5dfb4d22c266f7wxo	2026-10-04 15:11:49.574+07	67	0.034	49.119800000000005
8872	a37cb5dfb4d22c266f7wxo	2026-10-04 15:41:57.716+07	3	0.002	2.8894
8873	a37cb5dfb4d22c266f7wxo	2026-10-04 16:12:15.645+07	83	0.042	60.677400000000006
8874	a37cb5dfb4d22c266f7wxo	2026-10-04 16:42:13.325+07	162	0.081	117.0207
8875	a37cb5dfb4d22c266f7wxo	2026-10-04 17:12:21.333+07	43	0.022	31.7834
8876	a37cb5dfb4d22c266f7wxo	2026-10-04 17:43:59.378+07	1	0.001	1.4447
7770	a37cb5dfb4d22c266f7wxo	2026-10-03 22:06:46.471+07	4	0.002	2.8894
8877	a37cb5dfb4d22c266f7wxo	2026-10-04 18:14:07.148+07	139	0.07	101.12900000000002
5961	a37cb5dfb4d22c266f7wxo	2026-10-03 19:00:24+07	4	0.002	2.8894
5962	a37cb5dfb4d22c266f7wxo	2026-10-03 19:00:26.817+07	2555	0.002	2.8894
7094	a37cb5dfb4d22c266f7wxo	2026-10-03 21:06:35.628+07	2	0.001	1.4447
8558	a37cb5dfb4d22c266f7wxo	2026-10-03 23:34:01.1+07	2	0.001	1.4447
8808	a31a5c95501212e37f2fld	2026-10-04 23:59:02+07	3422	1.711	2471.8817000000004
8809	a31a5c95501212e37f2fld	2026-10-05 00:30:23.148+07	65	0.034	49.119800000000005
8810	a31a5c95501212e37f2fld	2026-10-05 01:00:35.988+07	91	0.046	66.4562
8811	a31a5c95501212e37f2fld	2026-10-05 01:30:58.828+07	82	0.042	60.677400000000006
8812	a31a5c95501212e37f2fld	2026-10-05 02:01:21.657+07	84	0.043	62.122099999999996
8813	a31a5c95501212e37f2fld	2026-10-05 02:31:19.516+07	86	0.043	62.122099999999996
8814	a31a5c95501212e37f2fld	2026-10-05 03:01:32.408+07	69	0.035	50.56450000000001
8815	a31a5c95501212e37f2fld	2026-10-05 03:31:40.254+07	65	0.033	47.6751
8816	a31a5c95501212e37f2fld	2026-10-05 04:01:38.149+07	64	0.032	46.2304
8817	a31a5c95501212e37f2fld	2026-10-05 04:31:41.001+07	59	0.03	43.341
8818	a31a5c95501212e37f2fld	2026-10-05 05:01:43.932+07	61	0.031	44.7857
8819	a31a5c95501212e37f2fld	2026-10-05 05:31:51.793+07	61	0.031	44.7857
6240	a37cb5dfb4d22c266f7wxo	2026-10-03 19:29:11.488+07	102	0.051	73.6797
8820	a31a5c95501212e37f2fld	2026-10-05 06:01:49.696+07	58	0.029	41.896300000000004
8821	a31a5c95501212e37f2fld	2026-10-05 06:31:52.527+07	59	0.03	43.341
8822	a31a5c95501212e37f2fld	2026-10-05 07:01:50.403+07	58	0.029	41.896300000000004
8823	a31a5c95501212e37f2fld	2026-10-05 07:31:53.279+07	57	0.029	41.896300000000004
8824	a31a5c95501212e37f2fld	2026-10-05 08:01:56.169+07	59	0.03	43.341
8825	a31a5c95501212e37f2fld	2026-10-05 08:31:54.112+07	60	0.03	43.341
8826	a31a5c95501212e37f2fld	2026-10-05 09:01:57.001+07	59	0.03	43.341
8827	a31a5c95501212e37f2fld	2026-10-05 09:31:54.868+07	60	0.03	43.341
8828	a31a5c95501212e37f2fld	2026-10-05 10:01:57.751+07	59	0.03	43.341
8829	a31a5c95501212e37f2fld	2026-10-05 10:31:55.587+07	62	0.031	44.7857
8830	a31a5c95501212e37f2fld	2026-10-05 11:01:58.465+07	59	0.03	43.341
8831	a31a5c95501212e37f2fld	2026-10-05 11:31:56.359+07	58	0.029	41.896300000000004
8832	a31a5c95501212e37f2fld	2026-10-05 12:01:59.279+07	59	0.03	43.341
8833	a31a5c95501212e37f2fld	2026-10-05 12:31:57.173+07	56	0.028	40.4516
8834	a31a5c95501212e37f2fld	2026-10-05 13:02:00.073+07	57	0.029	41.896300000000004
8835	a31a5c95501212e37f2fld	2026-10-05 13:32:07.991+07	57	0.029	41.896300000000004
8836	a31a5c95501212e37f2fld	2026-10-05 14:02:15.88+07	57	0.029	41.896300000000004
8837	a31a5c95501212e37f2fld	2026-10-05 14:32:18.742+07	59	0.03	43.341
8838	a31a5c95501212e37f2fld	2026-10-05 15:02:16.625+07	58	0.029	41.896300000000004
8839	a31a5c95501212e37f2fld	2026-10-05 15:32:19.562+07	59	0.03	43.341
8840	a31a5c95501212e37f2fld	2026-10-05 16:02:17.427+07	60	0.03	43.341
8162	a37cb5dfb4d22c266f7wxo	2026-10-03 22:56:23.425+07	2	0.001	1.4447
8841	a31a5c95501212e37f2fld	2026-10-05 16:32:20.308+07	59	0.03	43.341
8842	a31a5c95501212e37f2fld	2026-10-05 17:02:23.187+07	59	0.03	43.341
8843	a31a5c95501212e37f2fld	2026-10-05 17:32:21.095+07	60	0.03	43.341
8844	a31a5c95501212e37f2fld	2026-10-05 18:02:24.011+07	59	0.03	43.341
8845	a31a5c95501212e37f2fld	2026-10-05 18:32:21.9+07	60	0.03	43.341
8846	a31a5c95501212e37f2fld	2026-10-05 19:02:24.814+07	59	0.03	43.341
8847	a31a5c95501212e37f2fld	2026-10-05 19:32:22.727+07	60	0.03	43.341
8848	a31a5c95501212e37f2fld	2026-10-05 20:02:25.62+07	59	0.03	43.341
8849	a31a5c95501212e37f2fld	2026-10-05 20:32:23.526+07	60	0.03	43.341
8850	a31a5c95501212e37f2fld	2026-10-05 21:02:26.36+07	59	0.03	43.341
8851	a31a5c95501212e37f2fld	2026-10-05 21:32:29.274+07	59	0.03	43.341
8852	a31a5c95501212e37f2fld	2026-10-05 22:02:32.171+07	61	0.031	44.7857
8853	a31a5c95501212e37f2fld	2026-10-05 22:32:30.046+07	58	0.029	41.896300000000004
8854	a31a5c95501212e37f2fld	2026-10-05 23:02:32.989+07	59	0.03	43.341
8855	a31a5c95501212e37f2fld	2026-10-05 23:32:35.773+07	161	0.081	117.0207
8856	a37cb5dfb4d22c266f7wxo	2026-10-04 01:32:48.768+07	2	0.001	1.4447
8857	a37cb5dfb4d22c266f7wxo	2026-10-04 02:02:51.809+07	45	0.023	33.2281
8858	a37cb5dfb4d22c266f7wxo	2026-10-04 06:00:42.387+07	0	0.001	1.4447
8859	a37cb5dfb4d22c266f7wxo	2026-10-04 06:30:50.065+07	165	0.083	119.91010000000001
8860	a37cb5dfb4d22c266f7wxo	2026-10-04 07:01:02.754+07	152	0.077	111.2419
8861	a37cb5dfb4d22c266f7wxo	2026-10-04 07:31:15.429+07	160	0.081	117.0207
8862	a37cb5dfb4d22c266f7wxo	2026-10-04 08:01:23.056+07	163	0.082	118.4654
8863	a37cb5dfb4d22c266f7wxo	2026-10-04 08:31:25.809+07	123	0.062	89.5714
8864	a37cb5dfb4d22c266f7wxo	2026-10-04 09:23:22.631+07	2	0.002	2.8894
8865	a37cb5dfb4d22c266f7wxo	2026-10-04 09:53:25.337+07	155	0.078	112.6866
8878	a37cb5dfb4d22c266f7wxo	2026-10-04 18:44:20.091+07	75	0.038	54.8986
8879	a37cb5dfb4d22c266f7wxo	2026-10-04 19:14:23.138+07	47	0.024	34.6728
8880	a37cb5dfb4d22c266f7wxo	2026-10-04 21:26:39.946+07	0	0.002	2.8894
8881	a37cb5dfb4d22c266f7wxo	2026-10-04 21:56:37.862+07	88	0.044	63.5668
8882	a37cb5dfb4d22c266f7wxo	2026-10-04 22:26:40.965+07	15	0.008	11.5576
8883	a37cb5dfb4d22c266f7wxo	2026-10-05 01:31:44.555+07	0	0.001	1.4447
8884	a37cb5dfb4d22c266f7wxo	2026-10-05 02:02:07.689+07	5	0.003	4.3341
8885	a37cb5dfb4d22c266f7wxo	2026-10-05 04:52:17.129+07	0	0.002	2.8894
8886	a37cb5dfb4d22c266f7wxo	2026-10-05 05:22:19.803+07	159	0.08	115.57600000000001
8887	a37cb5dfb4d22c266f7wxo	2026-10-05 05:52:17.49+07	158	0.079	114.13130000000001
8888	a37cb5dfb4d22c266f7wxo	2026-10-05 06:22:30.285+07	123	0.062	89.5714
8889	a37cb5dfb4d22c266f7wxo	2026-10-05 06:52:33.364+07	21	0.011	15.8917
8890	a37cb5dfb4d22c266f7wxo	2026-10-05 08:52:35.929+07	0	0.002	2.8894
8891	a37cb5dfb4d22c266f7wxo	2026-10-05 09:22:43.711+07	115	0.058	83.79260000000001
8892	a37cb5dfb4d22c266f7wxo	2026-10-05 10:54:13.14+07	0	0.001	1.4447
8893	a37cb5dfb4d22c266f7wxo	2026-10-05 11:24:15.955+07	105	0.053	76.5691
8894	a37cb5dfb4d22c266f7wxo	2026-10-05 11:54:33.937+07	51	0.026	37.5622
8895	a37cb5dfb4d22c266f7wxo	2026-10-05 12:47:35.675+07	2	0.002	2.8894
8896	a37cb5dfb4d22c266f7wxo	2026-10-05 13:17:43.463+07	121	0.061	88.1267
8897	a37cb5dfb4d22c266f7wxo	2026-10-05 14:18:19.737+07	0	0.001	1.4447
8898	a37cb5dfb4d22c266f7wxo	2026-10-05 14:48:22.445+07	155	0.078	112.6866
8899	a37cb5dfb4d22c266f7wxo	2026-10-05 15:18:25.273+07	129	0.065	93.9055
8900	a37cb5dfb4d22c266f7wxo	2026-10-05 17:38:01.649+07	0	0.001	1.4447
8901	a37cb5dfb4d22c266f7wxo	2026-10-05 18:08:09.394+07	145	0.073	105.4631
8902	a37cb5dfb4d22c266f7wxo	2026-10-05 18:38:12.465+07	29	0.015	21.6705
8903	a37cb5dfb4d22c266f7wxo	2026-10-05 19:08:15.444+07	57	0.029	41.896300000000004
8904	a37cb5dfb4d22c266f7wxo	2026-10-05 19:38:28.481+07	43	0.022	31.7834
8905	a37cb5dfb4d22c266f7wxo	2026-10-05 22:00:39.737+07	0	0.001	1.4447
8906	a37cb5dfb4d22c266f7wxo	2026-10-05 22:30:37.628+07	102	0.051	73.6797
7480	a37cb5dfb4d22c266f7wxo	2026-10-03 21:36:38.34+07	156	0.078	112.6866
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.permissions (id, feature, desc_text, admin, operator, viewer) FROM stdin;
read_telemetry	Membaca Perangkat & Telemetri Analitik	Melihat status saklar, daya (Watt), tegangan (V), dan arus (A) secara live	t	t	t
switch_control	Saklar Kontrol ON/OFF Perangkat	Mengontrol atau mematikan saklar daya fisik via API / Tuya Cloud	t	t	f
change_tariff	Ubah Preferensi Golongan Tarif PLN	Mengubah tarif subsidi/non-subsidi PLN untuk estimasi biaya	t	t	f
manage_schedules	Atur Penjadwalan & Timer Otomatis	Menambah, mengubah, dan menghapus jadwal atau timer saklar perangkat	t	t	f
register_device	Daftarkan Perangkat Baru	Menambahkan ID perangkat baru & konfigurasinya ke sistem	t	f	f
delete_device	Hapus Perangkat & Riwayat Daya	Menghapus perangkat fisik beserta riwayat log daya dari database	t	f	f
manage_rbac	Pengaturan RBAC & Hak Akses User	Mengubah peran (Admin, Operator, Viewer) pada pengguna terdaftar	t	f	f
\.


--
-- Data for Name: power_guard_config; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.power_guard_config (id, max_watt_limit, is_enabled, cutoff_duration_sec, last_triggered_at, created_at) FROM stdin;
1	1300	f	8	\N	2026-10-05 02:45:47.4559+07
\.


--
-- Data for Name: scenes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.scenes (id, name, icon, description, actions, is_preset, created_at) FROM stdin;
away	Keluar Rumah	🚶‍♂️	Matikan semua AC dan pompa kolam saat keluar rumah	[{"device_id":"eb8a1b2c3d4e5f6g","status":false},{"device_id":"eb9b2c3d4e5f6g7h","status":false}]	t	2026-10-05 02:45:47.457473+07
night	Tidur / Malam	🌙	Matikan lampu utama dan pompa, nyalakan AC kamar	[{"device_id":"eb8a1b2c3d4e5f6g","status":true},{"device_id":"eb9b2c3d4e5f6g7h","status":false},{"device_id":"eb0c3d4e5f6g7h8i","status":false}]	t	2026-10-05 02:45:47.457473+07
eco	Hemat Daya	🍃	Matikan perangkat beban sekunder untuk penghematan listrik	[{"device_id":"eb9b2c3d4e5f6g7h","status":false}]	t	2026-10-05 02:45:47.457473+07
normal	Semua Nyala	☀️	Nyalakan semua perangkat utama di rumah	[{"device_id":"eb8a1b2c3d4e5f6g","status":true},{"device_id":"eb9b2c3d4e5f6g7h","status":true},{"device_id":"eb0c3d4e5f6g7h8i","status":true}]	t	2026-10-05 02:45:47.457473+07
\.


--
-- Data for Name: schedules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schedules (id, device_id, device_name, action, time_target, days, is_active, created_at) FROM stdin;
\.


--
-- Data for Name: telegram_config; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.telegram_config (id, bot_token, chat_id, is_enabled, notify_on_overload, notify_on_leak, daily_digest_time) FROM stdin;
1	8862661445:AAEqxzOOEVRJbyIyfFEBTIzBPAKyQDrZwGQ	2130130379	t	t	t	21:00
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, name, role, password) FROM stdin;
2	operator	Anggota Keluarga / Operator	operator	operator123
3	guest	Pengunjung / Tamu	viewer	guest123
1	admin	System Administrator	admin	fikri
\.


--
-- Name: energy_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.energy_logs_id_seq', 8906, true);


--
-- Name: schedules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.schedules_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 33, true);


--
-- Name: budget_settings budget_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.budget_settings
    ADD CONSTRAINT budget_settings_pkey PRIMARY KEY (id);


--
-- Name: device_name_history device_name_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_name_history
    ADD CONSTRAINT device_name_history_pkey PRIMARY KEY (device_id);


--
-- Name: device_timers device_timers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_timers
    ADD CONSTRAINT device_timers_pkey PRIMARY KEY (device_id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: energy_logs energy_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.energy_logs
    ADD CONSTRAINT energy_logs_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: power_guard_config power_guard_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.power_guard_config
    ADD CONSTRAINT power_guard_config_pkey PRIMARY KEY (id);


--
-- Name: scenes scenes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scenes
    ADD CONSTRAINT scenes_pkey PRIMARY KEY (id);


--
-- Name: schedules schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (id);


--
-- Name: telegram_config telegram_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.telegram_config
    ADD CONSTRAINT telegram_config_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_energy_logs_device; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_energy_logs_device ON public.energy_logs USING btree (device_id);


--
-- Name: idx_energy_logs_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_energy_logs_timestamp ON public.energy_logs USING btree ("timestamp");


--
-- PostgreSQL database dump complete
--

\unrestrict b1ZGMh0JpW83NAkk2KXYtWfiqJpvoL7wrlegMI5IayPH1U99gN0NUC0SrhDJzvS

