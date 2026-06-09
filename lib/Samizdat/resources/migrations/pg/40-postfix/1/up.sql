--
-- PostgreSQL database dump
--


-- Dumped from database version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.14 (Ubuntu 16.14-0ubuntu0.24.04.1)


--
-- Name: postfix; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA IF NOT EXISTS postfix;


--
-- Name: SCHEMA postfix; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA postfix IS 'standard postfix schema';


--
-- Name: merge_quota(); Type: FUNCTION; Schema: postfix; Owner: -
--

CREATE FUNCTION postfix.merge_quota() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.messages < 0 OR NEW.messages IS NULL THEN
    -- ugly kludge: we came here from this function, really do try to insert
    IF NEW.messages IS NULL THEN
      NEW.messages = 0;
    ELSE
      NEW.messages = -NEW.messages;
    END IF;
    RETURN NEW;
  END IF;

  LOOP
    UPDATE quota
    SET
      bytes    = NEW.bytes,
      messages = NEW.messages
    WHERE username = NEW.username;
    IF found THEN
      RETURN NULL;
    END IF;

    BEGIN
      IF NEW.messages = 0 THEN
        INSERT INTO quota (bytes, messages, username)
        VALUES (NEW.bytes, NULL, NEW.username);
      ELSE
        INSERT INTO quota (bytes, messages, username)
        VALUES (NEW.bytes, -NEW.messages, NEW.username);
      END IF;
      RETURN NULL;
    EXCEPTION
      WHEN unique_violation THEN
      -- someone just inserted the record, update it
    END;
  END LOOP;
END;
$$;




--
-- Name: admin; Type: TABLE; Schema: postfix; Owner: -
--

CREATE TABLE postfix.admin (
    username character varying(255) NOT NULL,
    password character varying(255) DEFAULT ''::character varying NOT NULL,
    created timestamp with time zone DEFAULT now(),
    modified timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL,
    superadmin boolean DEFAULT false NOT NULL,
    phone character varying(30) DEFAULT ''::character varying NOT NULL,
    email_other character varying(255) DEFAULT ''::character varying NOT NULL,
    token character varying(255) DEFAULT ''::character varying NOT NULL,
    token_validity timestamp with time zone DEFAULT '2000-01-01 01:00:00+01'::timestamp with time zone
);


--
-- Name: TABLE admin; Type: COMMENT; Schema: postfix; Owner: -
--

COMMENT ON TABLE postfix.admin IS 'Postfix Admin - Virtual Admins';


--
-- Name: alias; Type: TABLE; Schema: postfix; Owner: -
--

CREATE TABLE postfix.alias (
    address character varying(255) NOT NULL,
    goto text NOT NULL,
    domain character varying(255) NOT NULL,
    created timestamp with time zone DEFAULT now(),
    modified timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL
);


--
-- Name: TABLE alias; Type: COMMENT; Schema: postfix; Owner: -
--

COMMENT ON TABLE postfix.alias IS 'Postfix Admin - Virtual Aliases';


--
-- Name: alias_domain; Type: TABLE; Schema: postfix; Owner: -
--

CREATE TABLE postfix.alias_domain (
    alias_domain character varying(255) NOT NULL,
    target_domain character varying(255) NOT NULL,
    created timestamp with time zone DEFAULT now(),
    modified timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL
);


--
-- Name: TABLE alias_domain; Type: COMMENT; Schema: postfix; Owner: -
--

COMMENT ON TABLE postfix.alias_domain IS 'Postfix Admin - Domain Aliases';


--
-- Name: config_id_seq; Type: SEQUENCE; Schema: postfix; Owner: -
--

CREATE SEQUENCE postfix.config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


--
-- Name: config; Type: TABLE; Schema: postfix; Owner: -
--

CREATE TABLE postfix.config (
    id integer DEFAULT nextval('postfix.config_id_seq'::regclass) NOT NULL,
    name character varying(20) NOT NULL,
    value character varying(20) NOT NULL
);


--
-- Name: domain; Type: TABLE; Schema: postfix; Owner: -
--

CREATE TABLE postfix.domain (
    domain character varying(255) NOT NULL,
    description character varying(255) DEFAULT ''::character varying NOT NULL,
    aliases integer DEFAULT 0 NOT NULL,
    mailboxes integer DEFAULT 0 NOT NULL,
    maxquota bigint DEFAULT 0 NOT NULL,
    quota bigint DEFAULT 0 NOT NULL,
    transport character varying(255) DEFAULT NULL::character varying,
    backupmx boolean DEFAULT false NOT NULL,
    created timestamp with time zone DEFAULT now(),
    modified timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL,
    password_expiry integer DEFAULT 0,
    customerid integer DEFAULT 0 NOT NULL
);


--
-- Name: TABLE domain; Type: COMMENT; Schema: postfix; Owner: -
--

COMMENT ON TABLE postfix.domain IS 'Postfix Admin - Virtual Domains';


--
-- Name: domain_admins; Type: TABLE; Schema: postfix; Owner: -
--

CREATE TABLE postfix.domain_admins (
    username character varying(255) NOT NULL,
    domain character varying(255) NOT NULL,
    created timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL,
    id integer NOT NULL
);


--
-- Name: TABLE domain_admins; Type: COMMENT; Schema: postfix; Owner: -
--

COMMENT ON TABLE postfix.domain_admins IS 'Postfix Admin - Domain Admins';


--
-- Name: domain_admins_id_seq; Type: SEQUENCE; Schema: postfix; Owner: -
--

CREATE SEQUENCE postfix.domain_admins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: domain_admins_id_seq; Type: SEQUENCE OWNED BY; Schema: postfix; Owner: -
--

ALTER SEQUENCE postfix.domain_admins_id_seq OWNED BY postfix.domain_admins.id;


--
-- Name: fetchmail_id_seq; Type: SEQUENCE; Schema: postfix; Owner: -
--

CREATE SEQUENCE postfix.fetchmail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


--
-- Name: fetchmail; Type: TABLE; Schema: postfix; Owner: -
--

CREATE TABLE postfix.fetchmail (
    id integer DEFAULT nextval('postfix.fetchmail_id_seq'::regclass) NOT NULL,
    mailbox character varying(255) DEFAULT ''::character varying NOT NULL,
    src_server character varying(255) DEFAULT ''::character varying NOT NULL,
    src_auth character varying(15) NOT NULL,
    src_user character varying(255) DEFAULT ''::character varying NOT NULL,
    src_password character varying(255) DEFAULT ''::character varying NOT NULL,
    src_folder character varying(255) DEFAULT ''::character varying NOT NULL,
    poll_time integer DEFAULT 10 NOT NULL,
    fetchall boolean DEFAULT false NOT NULL,
    keep boolean DEFAULT false NOT NULL,
    protocol character varying(15) NOT NULL,
    extra_options text,
    returned_text text,
    mda character varying(255) DEFAULT ''::character varying NOT NULL,
    date timestamp with time zone DEFAULT now(),
    usessl boolean DEFAULT false NOT NULL,
    sslcertck boolean DEFAULT false NOT NULL,
    sslcertpath character varying(255) DEFAULT ''::character varying,
    sslfingerprint character varying(255) DEFAULT ''::character varying,
    domain character varying(255) DEFAULT ''::character varying,
    active boolean DEFAULT false NOT NULL,
    created timestamp with time zone DEFAULT '2000-01-01 01:00:00+01'::timestamp with time zone,
    modified timestamp with time zone DEFAULT now(),
    src_port integer DEFAULT 0 NOT NULL,
    CONSTRAINT fetchmail_protocol_check CHECK (((protocol)::text = ANY (ARRAY[('POP3'::character varying)::text, ('IMAP'::character varying)::text, ('POP2'::character varying)::text, ('ETRN'::character varying)::text, ('AUTO'::character varying)::text]))),
    CONSTRAINT fetchmail_src_auth_check CHECK (((src_auth)::text = ANY (ARRAY[('password'::character varying)::text, ('kerberos_v5'::character varying)::text, ('kerberos'::character varying)::text, ('kerberos_v4'::character varying)::text, ('gssapi'::character varying)::text, ('cram-md5'::character varying)::text, ('otp'::character varying)::text, ('ntlm'::character varying)::text, ('msn'::character varying)::text, ('ssh'::character varying)::text, ('any'::character varying)::text])))
);


--
-- Name: log_id_seq; Type: SEQUENCE; Schema: postfix; Owner: -
--

CREATE SEQUENCE postfix.log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


--
-- Name: log; Type: TABLE; Schema: postfix; Owner: -
--

CREATE TABLE postfix.log (
    id integer DEFAULT nextval('postfix.log_id_seq'::regclass) NOT NULL,
    "timestamp" timestamp with time zone DEFAULT now(),
    username character varying(255) DEFAULT ''::character varying NOT NULL,
    domain character varying(255) DEFAULT ''::character varying NOT NULL,
    action character varying(255) DEFAULT ''::character varying NOT NULL,
    data text DEFAULT ''::text NOT NULL
);


--
-- Name: TABLE log; Type: COMMENT; Schema: postfix; Owner: -
--

COMMENT ON TABLE postfix.log IS 'Postfix Admin - Log';


--
-- Name: mailbox; Type: TABLE; Schema: postfix; Owner: -
--

CREATE TABLE postfix.mailbox (
    username character varying(255) NOT NULL,
    password character varying(255) DEFAULT ''::character varying NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    maildir character varying(255) DEFAULT ''::character varying NOT NULL,
    quota bigint DEFAULT 0 NOT NULL,
    created timestamp with time zone DEFAULT now(),
    modified timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL,
    domain character varying(255),
    local_part character varying(255) NOT NULL,
    phone character varying(30) DEFAULT ''::character varying NOT NULL,
    email_other character varying(255) DEFAULT ''::character varying NOT NULL,
    token character varying(255) DEFAULT ''::character varying NOT NULL,
    token_validity timestamp with time zone DEFAULT '2000-01-01 01:00:00+01'::timestamp with time zone,
    password_expiry timestamp with time zone DEFAULT '2000-01-01 01:00:00+01'::timestamp with time zone
);


--
-- Name: TABLE mailbox; Type: COMMENT; Schema: postfix; Owner: -
--

COMMENT ON TABLE postfix.mailbox IS 'Postfix Admin - Virtual Mailboxes';


--
-- Name: quota; Type: TABLE; Schema: postfix; Owner: -
--

CREATE TABLE postfix.quota (
    username character varying(100) NOT NULL,
    bytes bigint DEFAULT 0 NOT NULL,
    messages integer DEFAULT 0 NOT NULL
);


--
-- Name: vacation; Type: TABLE; Schema: postfix; Owner: -
--

CREATE TABLE postfix.vacation (
    email character varying(255) NOT NULL,
    subject character varying(255) NOT NULL,
    body text DEFAULT ''::text NOT NULL,
    created timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL,
    domain character varying(255),
    modified timestamp with time zone DEFAULT now(),
    activefrom timestamp with time zone DEFAULT '2000-01-01 01:00:00+01'::timestamp with time zone,
    activeuntil timestamp with time zone DEFAULT '2038-01-18 01:00:00+01'::timestamp with time zone,
    interval_time integer DEFAULT 0 NOT NULL
);


--
-- Name: vacation_notification; Type: TABLE; Schema: postfix; Owner: -
--

CREATE TABLE postfix.vacation_notification (
    on_vacation character varying(255) NOT NULL,
    notified character varying(255) NOT NULL,
    notified_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: domain_admins id; Type: DEFAULT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.domain_admins ALTER COLUMN id SET DEFAULT nextval('postfix.domain_admins_id_seq'::regclass);


--
-- Name: admin admin_key; Type: CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.admin
    ADD CONSTRAINT admin_key PRIMARY KEY (username);


--
-- Name: alias_domain alias_domain_pkey; Type: CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.alias_domain
    ADD CONSTRAINT alias_domain_pkey PRIMARY KEY (alias_domain);


--
-- Name: alias alias_key; Type: CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.alias
    ADD CONSTRAINT alias_key PRIMARY KEY (address);


--
-- Name: config config_name_key; Type: CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.config
    ADD CONSTRAINT config_name_key UNIQUE (name);


--
-- Name: config config_pkey; Type: CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.config
    ADD CONSTRAINT config_pkey PRIMARY KEY (id);


--
-- Name: domain_admins domain_admins_pkey; Type: CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.domain_admins
    ADD CONSTRAINT domain_admins_pkey PRIMARY KEY (id);


--
-- Name: domain_admins domain_admins_username_domain_key; Type: CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.domain_admins
    ADD CONSTRAINT domain_admins_username_domain_key UNIQUE (username, domain);


--
-- Name: domain domain_key; Type: CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.domain
    ADD CONSTRAINT domain_key PRIMARY KEY (domain);


--
-- Name: fetchmail fetchmail_pkey; Type: CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.fetchmail
    ADD CONSTRAINT fetchmail_pkey PRIMARY KEY (id);


--
-- Name: log log_pkey; Type: CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.log
    ADD CONSTRAINT log_pkey PRIMARY KEY (id);


--
-- Name: mailbox mailbox_key; Type: CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.mailbox
    ADD CONSTRAINT mailbox_key PRIMARY KEY (username);


--
-- Name: quota quota2_pkey; Type: CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.quota
    ADD CONSTRAINT quota2_pkey PRIMARY KEY (username);


--
-- Name: vacation_notification vacation_notification_pkey; Type: CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.vacation_notification
    ADD CONSTRAINT vacation_notification_pkey PRIMARY KEY (on_vacation, notified);


--
-- Name: vacation vacation_pkey; Type: CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.vacation
    ADD CONSTRAINT vacation_pkey PRIMARY KEY (email);


--
-- Name: alias_address_active; Type: INDEX; Schema: postfix; Owner: -
--

CREATE INDEX alias_address_active ON postfix.alias USING btree (address, active) WITH (fillfactor='90');


--
-- Name: alias_domain_active; Type: INDEX; Schema: postfix; Owner: -
--

CREATE INDEX alias_domain_active ON postfix.alias_domain USING btree (alias_domain, active) WITH (fillfactor='90');


--
-- Name: alias_domain_idx; Type: INDEX; Schema: postfix; Owner: -
--

CREATE INDEX alias_domain_idx ON postfix.alias USING btree (domain) WITH (fillfactor='90');


--
-- Name: domain_domain_active; Type: INDEX; Schema: postfix; Owner: -
--

CREATE INDEX domain_domain_active ON postfix.domain USING btree (domain, active) WITH (fillfactor='90');


--
-- Name: idx; Type: INDEX; Schema: postfix; Owner: -
--

CREATE INDEX idx ON postfix.log USING btree (username, "timestamp");


--
-- Name: mailbox_domain_idx; Type: INDEX; Schema: postfix; Owner: -
--

CREATE INDEX mailbox_domain_idx ON postfix.mailbox USING btree (domain) WITH (fillfactor='90');


--
-- Name: mailbox_username_active; Type: INDEX; Schema: postfix; Owner: -
--

CREATE INDEX mailbox_username_active ON postfix.mailbox USING btree (username, active) WITH (fillfactor='90');


--
-- Name: vacation_email_active; Type: INDEX; Schema: postfix; Owner: -
--

CREATE INDEX vacation_email_active ON postfix.vacation USING btree (email, active) WITH (fillfactor='90');


--
-- Name: quota mergequota; Type: TRIGGER; Schema: postfix; Owner: -
--

CREATE TRIGGER mergequota BEFORE INSERT ON postfix.quota FOR EACH ROW EXECUTE FUNCTION postfix.merge_quota();


--
-- Name: alias_domain alias_domain_alias_domain_fkey; Type: FK CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.alias_domain
    ADD CONSTRAINT alias_domain_alias_domain_fkey FOREIGN KEY (alias_domain) REFERENCES postfix.domain(domain) ON DELETE CASCADE;


--
-- Name: alias alias_domain_fkey; Type: FK CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.alias
    ADD CONSTRAINT alias_domain_fkey FOREIGN KEY (domain) REFERENCES postfix.domain(domain);


--
-- Name: alias_domain alias_domain_target_domain_fkey; Type: FK CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.alias_domain
    ADD CONSTRAINT alias_domain_target_domain_fkey FOREIGN KEY (target_domain) REFERENCES postfix.domain(domain) ON DELETE CASCADE;


--
-- Name: domain_admins domain_admins_domain_fkey; Type: FK CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.domain_admins
    ADD CONSTRAINT domain_admins_domain_fkey FOREIGN KEY (domain) REFERENCES postfix.domain(domain);


--
-- Name: mailbox mailbox_domain_fkey1; Type: FK CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.mailbox
    ADD CONSTRAINT mailbox_domain_fkey1 FOREIGN KEY (domain) REFERENCES postfix.domain(domain);


--
-- Name: vacation vacation_domain_fkey1; Type: FK CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.vacation
    ADD CONSTRAINT vacation_domain_fkey1 FOREIGN KEY (domain) REFERENCES postfix.domain(domain);


--
-- Name: vacation_notification vacation_notification_on_vacation_fkey; Type: FK CONSTRAINT; Schema: postfix; Owner: -
--

ALTER TABLE ONLY postfix.vacation_notification
    ADD CONSTRAINT vacation_notification_on_vacation_fkey FOREIGN KEY (on_vacation) REFERENCES postfix.vacation(email) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--
