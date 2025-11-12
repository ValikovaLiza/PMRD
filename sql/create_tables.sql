CREATE SCHEMA IF NOT EXISTS s_psql_dds;

CREATE TABLE IF NOT EXISTS s_psql_dds.t_sql_source_unstructured (
    id SERIAL PRIMARY KEY,
    raw_data JSONB
);

CREATE TABLE IF NOT EXISTS s_psql_dds.t_sql_source_structured (
    id SERIAL PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    age INT,
    signup_date TIMESTAMP,
    country TEXT
);
