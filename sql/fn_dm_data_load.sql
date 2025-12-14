CREATE OR REPLACE FUNCTION s_psql_dm.fn_dm_data_load(start_date DATE, end_date DATE)
RETURNS VOID AS
$$
BEGIN
    INSERT INTO s_psql_dm.d_first_name(first_name)
    SELECT DISTINCT first_name
    FROM s_psql_dds.t_sql_source_structured
    WHERE first_name IS NOT NULL
    ON CONFLICT DO NOTHING;

    INSERT INTO s_psql_dm.d_last_name(last_name)
    SELECT DISTINCT last_name
    FROM s_psql_dds.t_sql_source_structured
    WHERE last_name IS NOT NULL
    ON CONFLICT DO NOTHING;

    INSERT INTO s_psql_dm.d_email(email)
    SELECT DISTINCT email
    FROM s_psql_dds.t_sql_source_structured
    WHERE email IS NOT NULL
    ON CONFLICT DO NOTHING;

    INSERT INTO s_psql_dm.d_country(country)
    SELECT DISTINCT country
    FROM s_psql_dds.t_sql_source_structured
    WHERE country IS NOT NULL
    ON CONFLICT DO NOTHING;

    INSERT INTO s_psql_dm.d_age(age)
    SELECT DISTINCT age
    FROM s_psql_dds.t_sql_source_structured
    WHERE age IS NOT NULL
    ON CONFLICT DO NOTHING;

    INSERT INTO s_psql_dm.d_signup_date(signup_date)
    SELECT DISTINCT signup_date
    FROM s_psql_dds.t_sql_source_structured
    WHERE signup_date IS NOT NULL
    ON CONFLICT DO NOTHING;

    INSERT INTO s_psql_dm.f_users (
        first_name_id,
        last_name_id,
        email_id,
        age_id,
        country_id,
        signup_date_id
    )
    SELECT
        fn.id,
        ln.id,
        em.id,
        a.id,
        c.id,
        sd.id
    FROM s_psql_dds.t_sql_source_structured src
    LEFT JOIN s_psql_dm.d_first_name fn ON fn.first_name = src.first_name
    LEFT JOIN s_psql_dm.d_last_name ln ON ln.last_name = src.last_name
    LEFT JOIN s_psql_dm.d_email em ON em.email = src.email
    LEFT JOIN s_psql_dm.d_age a ON a.age = src.age
    LEFT JOIN s_psql_dm.d_country c ON c.country = src.country
    LEFT JOIN s_psql_dm.d_signup_date sd ON sd.signup_date = src.signup_date;

END;
$$ LANGUAGE plpgsql;