CREATE TABLE IF NOT EXISTS s_psql_dds.t_sql_source_structured_copy AS
TABLE s_psql_dds.t_sql_source_structured WITH NO DATA;

-- Тестовая функция
CREATE OR REPLACE FUNCTION s_psql_dds.fn_etl_data_load_test(start_date date, end_date date)
RETURNS void AS $$
BEGIN
    INSERT INTO s_psql_dds.t_sql_source_structured_copy (name, email, age, country, salary, join_date, is_active)
    SELECT
        NULLIF(TRIM(name), '') AS name,
        NULLIF(email, '') AS email,
        CASE WHEN age::int < 0 THEN NULL ELSE age::int END AS age,
        NULLIF(country, '') AS country,
        CASE WHEN salary ~ '^\d+(\.\d+)?$' THEN salary::numeric ELSE NULL END AS salary,
        TO_DATE(join_date, 'YYYY-MM-DD') AS join_date,
        CASE WHEN is_active IN ('1','yes','true', TRUE) THEN TRUE ELSE FALSE END AS is_active
    FROM s_psql_dds.t_sql_source_unstructured
    WHERE (join_date IS NULL OR join_date::date BETWEEN start_date AND end_date);
END;
$$ LANGUAGE plpgsql;
