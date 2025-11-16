--
-- PostgreSQL database dump
--

\restrict bbfHVEF8KUBFQlbn7R4aYN4bsjKOJkDpkDLArEcHJdJq7wkuVbvyXazEfhKWwp1

-- Dumped from database version 17.0 (Debian 17.0-1.pgdg120+1)
-- Dumped by pg_dump version 17.7 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bookings (
    id uuid NOT NULL,
    period daterange NOT NULL,
    state character varying(255) NOT NULL,
    total_price numeric,
    place_id uuid NOT NULL,
    user_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: guardian_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.guardian_tokens (
    jti character varying(255) NOT NULL,
    aud character varying(255) NOT NULL,
    typ character varying(255),
    iss character varying(255),
    sub character varying(255),
    exp bigint,
    jwt text,
    claims jsonb,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: places; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.places (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    location character varying(255) NOT NULL,
    price_per_night numeric NOT NULL,
    image character varying(255) NOT NULL,
    image_thumbnail character varying(255) NOT NULL,
    max_guests integer NOT NULL,
    pet_friendly boolean DEFAULT false NOT NULL,
    pool boolean DEFAULT false NOT NULL,
    wifi boolean DEFAULT false NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: reviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reviews (
    id uuid NOT NULL,
    rating integer NOT NULL,
    comment character varying(255) NOT NULL,
    place_id uuid NOT NULL,
    user_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    email public.citext NOT NULL,
    password_hash character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: guardian_tokens guardian_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.guardian_tokens
    ADD CONSTRAINT guardian_tokens_pkey PRIMARY KEY (jti, aud);


--
-- Name: places places_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.places
    ADD CONSTRAINT places_pkey PRIMARY KEY (id);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: bookings_place_id_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bookings_place_id_user_id_index ON public.bookings USING btree (place_id, user_id);


--
-- Name: places_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX places_name_index ON public.places USING btree (name);


--
-- Name: places_slug_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX places_slug_index ON public.places USING btree (slug);


--
-- Name: reviews_place_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX reviews_place_id_index ON public.reviews USING btree (place_id);


--
-- Name: reviews_user_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX reviews_user_id_index ON public.reviews USING btree (user_id);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: users_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX users_name_index ON public.users USING btree (name);


--
-- Name: bookings bookings_place_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_place_id_fkey FOREIGN KEY (place_id) REFERENCES public.places(id);


--
-- Name: bookings bookings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: reviews reviews_place_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_place_id_fkey FOREIGN KEY (place_id) REFERENCES public.places(id);


--
-- Name: reviews reviews_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reviews
    ADD CONSTRAINT reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict bbfHVEF8KUBFQlbn7R4aYN4bsjKOJkDpkDLArEcHJdJq7wkuVbvyXazEfhKWwp1

INSERT INTO public."schema_migrations" (version) VALUES (20251029224041);
INSERT INTO public."schema_migrations" (version) VALUES (20251030185548);
INSERT INTO public."schema_migrations" (version) VALUES (20251030185753);
INSERT INTO public."schema_migrations" (version) VALUES (20251030190017);
INSERT INTO public."schema_migrations" (version) VALUES (20251111114647);
