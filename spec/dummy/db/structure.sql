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

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id integer NOT NULL,
    name character varying,
    active boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.accounts_id_seq OWNED BY public.accounts.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: constraint_examples; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.constraint_examples (
    id integer NOT NULL,
    name character varying,
    age integer,
    color character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: constraint_examples_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.constraint_examples_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: constraint_examples_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.constraint_examples_id_seq OWNED BY public.constraint_examples.id;


--
-- Name: defaulting_constraint_examples; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.defaulting_constraint_examples (
    id integer NOT NULL,
    name character varying,
    age integer,
    color uuid DEFAULT public.gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: defaulting_constraint_examples_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.defaulting_constraint_examples_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: defaulting_constraint_examples_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.defaulting_constraint_examples_id_seq OWNED BY public.defaulting_constraint_examples.id;


--
-- Name: defaulting_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.defaulting_records (
    id bigint NOT NULL,
    uuid uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: defaulting_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.defaulting_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: defaulting_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.defaulting_records_id_seq OWNED BY public.defaulting_records.id;


--
-- Name: my_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.my_records (
    id integer NOT NULL,
    name character varying,
    wisdom integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: my_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.my_records_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: my_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.my_records_id_seq OWNED BY public.my_records.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehicles (
    id integer NOT NULL,
    wheels_count integer,
    name character varying,
    make character varying,
    long_field character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    account_id integer,
    year integer
);


--
-- Name: vehicles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vehicles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vehicles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vehicles_id_seq OWNED BY public.vehicles.id;


--
-- Name: accounts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts ALTER COLUMN id SET DEFAULT nextval('public.accounts_id_seq'::regclass);


--
-- Name: constraint_examples id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constraint_examples ALTER COLUMN id SET DEFAULT nextval('public.constraint_examples_id_seq'::regclass);


--
-- Name: defaulting_constraint_examples id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.defaulting_constraint_examples ALTER COLUMN id SET DEFAULT nextval('public.defaulting_constraint_examples_id_seq'::regclass);


--
-- Name: defaulting_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.defaulting_records ALTER COLUMN id SET DEFAULT nextval('public.defaulting_records_id_seq'::regclass);


--
-- Name: my_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.my_records ALTER COLUMN id SET DEFAULT nextval('public.my_records_id_seq'::regclass);


--
-- Name: vehicles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles ALTER COLUMN id SET DEFAULT nextval('public.vehicles_id_seq'::regclass);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: constraint_examples constraint_examples_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constraint_examples
    ADD CONSTRAINT constraint_examples_pkey PRIMARY KEY (id);


--
-- Name: defaulting_constraint_examples defaulting_constraint_examples_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.defaulting_constraint_examples
    ADD CONSTRAINT defaulting_constraint_examples_pkey PRIMARY KEY (id);


--
-- Name: defaulting_records defaulting_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.defaulting_records
    ADD CONSTRAINT defaulting_records_pkey PRIMARY KEY (id);


--
-- Name: defaulting_constraint_examples my_defaulting_unique_constraint; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.defaulting_constraint_examples
    ADD CONSTRAINT my_defaulting_unique_constraint UNIQUE (name, age);


--
-- Name: my_records my_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.my_records
    ADD CONSTRAINT my_records_pkey PRIMARY KEY (id);


--
-- Name: constraint_examples my_unique_constraint; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.constraint_examples
    ADD CONSTRAINT my_unique_constraint UNIQUE (name, age);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (id);


--
-- Name: index_accounts_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_accounts_on_name ON public.accounts USING btree (name) WHERE (active IS TRUE);


--
-- Name: index_defaulting_records_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_defaulting_records_on_name ON public.defaulting_records USING btree (name);


--
-- Name: index_my_records_on_wisdom; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_my_records_on_wisdom ON public.my_records USING btree (wisdom);


--
-- Name: index_vehicles_on_account_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_vehicles_on_account_id ON public.vehicles USING btree (account_id);


--
-- Name: index_vehicles_on_make_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_vehicles_on_make_and_name ON public.vehicles USING btree (make, name);


--
-- Name: index_vehicles_on_md5_long_field; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_vehicles_on_md5_long_field ON public.vehicles USING btree (md5((long_field)::text));


--
-- Name: index_vehicles_on_year; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_vehicles_on_year ON public.vehicles USING btree (year);


--
-- Name: partial_index_vehicles_on_make_without_year; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX partial_index_vehicles_on_make_without_year ON public.vehicles USING btree (make) WHERE (year IS NULL);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20160419103547'),
('20160419124138'),
('20160419124140'),
('20190428142610'),
('20191212121212'),
('20200127225354'),
('20200128003633');


