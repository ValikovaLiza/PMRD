CREATE OR REPLACE VIEW s_psql_dm.v_users AS
SELECT
    f.id,
    fn.first_name,
    ln.last_name,
    em.email,
    a.age,
    c.country,
    sd.signup_date
FROM s_psql_dm.f_users f
LEFT JOIN s_psql_dm.d_first_name fn ON f.first_name_id = fn.id
LEFT JOIN s_psql_dm.d_last_name ln ON f.last_name_id = ln.id
LEFT JOIN s_psql_dm.d_email em ON f.email_id = em.id
LEFT JOIN s_psql_dm.d_age a ON f.age_id = a.id
LEFT JOIN s_psql_dm.d_country c ON f.country_id = c.id
LEFT JOIN s_psql_dm.d_signup_date sd ON f.signup_date_id = sd.id;