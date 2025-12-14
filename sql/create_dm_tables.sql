CREATE SCHEMA IF NOT EXISTS s_psql_dm;

CREATE TABLE IF NOT EXISTS s_psql_dm.d_first_name (
    id SERIAL PRIMARY KEY,
    first_name TEXT UNIQUE
);

CREATE TABLE IF NOT EXISTS s_psql_dm.d_last_name (
    id SERIAL PRIMARY KEY,
    last_name TEXT UNIQUE
);

CREATE TABLE IF NOT EXISTS s_psql_dm.d_email (
    id SERIAL PRIMARY KEY,
    email TEXT UNIQUE
);

CREATE TABLE IF NOT EXISTS s_psql_dm.d_country (
    id SERIAL PRIMARY KEY,
    country TEXT UNIQUE
);

CREATE TABLE IF NOT EXISTS s_psql_dm.d_age (
    id SERIAL PRIMARY KEY,
    age INT UNIQUE
);

CREATE TABLE IF NOT EXISTS s_psql_dm.d_signup_date (
    id SERIAL PRIMARY KEY,
    signup_date TIMESTAMP UNIQUE
);

CREATE TABLE IF NOT EXISTS s_psql_dm.f_users (
    id SERIAL PRIMARY KEY,
    first_name_id INT REFERENCES s_psql_dm.d_first_name(id),
    last_name_id INT REFERENCES s_psql_dm.d_last_name(id),
    email_id INT REFERENCES s_psql_dm.d_email(id),
    age_id INT REFERENCES s_psql_dm.d_age(id),
    country_id INT REFERENCES s_psql_dm.d_country(id),
    signup_date_id INT REFERENCES s_psql_dm.d_signup_date(id),
    loaded_at TIMESTAMP DEFAULT now()
);