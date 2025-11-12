CREATE OR REPLACE FUNCTION s_psql_dds.fn_etl_data_load(start_date DATE, end_date DATE)
RETURNS VOID AS
$$
DECLARE
    rec RECORD;
    v_first_name TEXT;
    v_last_name TEXT;
    v_email TEXT;
    v_age INT;
    v_signup_date TIMESTAMP;
    v_country TEXT;
    v_date_text TEXT;
BEGIN
    FOR rec IN 
        SELECT id, raw_data
        FROM s_psql_dds.t_sql_source_unstructured
    LOOP
        BEGIN
            v_first_name := split_part(rec.raw_data->>'full_name', ' ', 1);
            v_last_name := split_part(rec.raw_data->>'full_name', ' ', 2);

            v_email := NULLIF(rec.raw_data->>'email', '');
            IF v_email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
                v_email := NULL;
            END IF;

            BEGIN
                v_age := NULLIF(regexp_replace(rec.raw_data->>'age', '\D', '', 'g'), '')::INT;
            EXCEPTION WHEN others THEN
                v_age := NULL;
            END;

            v_country := NULLIF(rec.raw_data->>'country', '');
            IF v_country = '??' THEN
                v_country := NULL;
            END IF;

            v_date_text := NULLIF(trim(rec.raw_data->>'signup_date'), '');

            v_signup_date := NULL;
            IF v_date_text IS NOT NULL THEN
                BEGIN
                    v_signup_date := v_date_text::timestamp;
                EXCEPTION WHEN others THEN
                    BEGIN
                        v_signup_date := to_timestamp(v_date_text, 'YYYY/MM/DD');
                    EXCEPTION WHEN others THEN
                        BEGIN
                            v_signup_date := to_timestamp(v_date_text, 'DD/MM/YYYY');
                        EXCEPTION WHEN others THEN
                            v_signup_date := NULL;
                        END;
                    END;
                END;
            END IF;

            IF v_signup_date IS NULL OR (v_signup_date BETWEEN start_date AND end_date) THEN
                INSERT INTO s_psql_dds.t_sql_source_structured(
                    first_name, last_name, email, age, signup_date, country
                )
                VALUES (v_first_name, v_last_name, v_email, v_age, v_signup_date, v_country);
            END IF;

        EXCEPTION WHEN others THEN
            RAISE NOTICE 'Ошибка при обработке id=%, msg=%', rec.id, SQLERRM;
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
