CREATE SCHEMA IF NOT EXISTS s_psql_dds;

CREATE TABLE IF NOT EXISTS s_psql_dds.t_sql_source_unstructured (
    id SERIAL PRIMARY KEY,
    raw_data JSONB,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);