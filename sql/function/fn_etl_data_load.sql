CREATE OR REPLACE FUNCTION s_psql_dds.fn_etl_data_load(
    start_date DATE,
    end_date DATE
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO s_psql_dds.t_sql_source_structured (
        name, email, age, country, salary, join_date, is_active
    )
    SELECT
        -- имя: убираем лишние пробелы и NULL -> ''
        COALESCE(NULLIF(TRIM(raw_data->>'name'), ''), 'Unknown') AS name,

        -- email: NULL -> ''
        COALESCE(NULLIF(TRIM(raw_data->>'email'), ''), 'unknown@example.com') AS email,

        -- age: только положительные числа, строки преобразуем, остальные NULL
        CASE
            WHEN (raw_data->>'age') ~ '^\d+$' AND (raw_data->>'age')::INT > 0
                THEN (raw_data->>'age')::INT
            ELSE NULL
        END AS age,

        -- country: NULL -> 'Unknown'
        COALESCE(NULLIF(TRIM(raw_data->>'country'), ''), 'Unknown') AS country,

        -- salary: только числа, убираем валюты и прочее, NULL если не число
        CASE
            WHEN (raw_data->>'salary') ~ '^\d+(\.\d+)?$'
                THEN (raw_data->>'salary')::NUMERIC
            ELSE NULL
        END AS salary,

        -- join_date: приводим к YYYY-MM-DD, NULL если невалидная
        TO_DATE(NULLIF(raw_data->>'join_date', ''), 'YYYY-MM-DD') AS join_date,

        -- is_active: приводим к булевому значению
        CASE
            WHEN LOWER(raw_data->>'is_active') IN ('true','yes','1') THEN TRUE
            WHEN LOWER(raw_data->>'is_active') IN ('false','no','0') THEN FALSE
            ELSE NULL
        END AS is_active

    FROM s_psql_dds.t_sql_source_unstructured
    WHERE load_timestamp::date BETWEEN start_date AND end_date;
END;
$$ LANGUAGE plpgsql;
