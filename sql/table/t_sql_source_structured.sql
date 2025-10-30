CREATE SCHEMA IF NOT EXISTS s_psql_dds;

CREATE TABLE IF NOT EXISTS s_psql_dds.t_sql_source_structured (
    id SERIAL PRIMARY KEY,
    name TEXT,
    email TEXT,
    age INT,
    country TEXT,
    salary NUMERIC,
    join_date DATE,
    is_active BOOLEAN,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);