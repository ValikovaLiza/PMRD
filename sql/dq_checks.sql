-- полнота
SELECT
    COUNT(*) AS total_rows,
    COUNT(first_name) AS filled_first_name,
    COUNT(*) - COUNT(first_name) AS missing_first_name
FROM s_psql_dds.v_users;

--уникальность
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT id) AS distinct_ids
FROM s_psql_dds.v_users;

--валидность
SELECT COUNT(*) AS invalid_age_cnt
FROM s_psql_dds.v_users
WHERE age IS NOT NULL
  AND (age < 0 OR age > 120);

-- Непротиворечивость
SELECT COUNT(*) AS inconsistent_cnt
FROM s_psql_dds.v_users
WHERE email IS NOT NULL
  AND signup_date IS NULL;

--Правильность
SELECT COUNT(*) AS invalid_email_cnt
FROM s_psql_dds.v_users
WHERE email IS NOT NULL
  AND email NOT LIKE '%@%.%';

