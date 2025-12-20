DROP FUNCTION IF EXISTS s_psql_dds.fn_dq_checks_load(date, date);

CREATE OR REPLACE FUNCTION s_psql_dds.fn_dq_checks_load(
    start_dt DATE,
    end_dt   DATE
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_cnt INT;
BEGIN
    SELECT COUNT(*)
    INTO v_cnt
    FROM s_psql_dm.v_users
    WHERE first_name IS NULL;

    INSERT INTO s_psql_dds.t_dq_check_results
        (check_type, table_name, status, error_message)
    VALUES
        (
            'completeness',
            's_psql_dm.v_users',
            CASE WHEN v_cnt = 0 THEN 'passed' ELSE 'failed' END,
            CASE WHEN v_cnt = 0 THEN NULL ELSE 'Missing first_name rows: ' || v_cnt END
        );

    SELECT COUNT(*) - COUNT(DISTINCT id)
    INTO v_cnt
    FROM s_psql_dm.v_users;

    INSERT INTO s_psql_dds.t_dq_check_results
        (check_type, table_name, status, error_message)
    VALUES
        (
            'uniqueness',
            's_psql_dm.v_users',
            CASE WHEN v_cnt = 0 THEN 'passed' ELSE 'failed' END,
            CASE WHEN v_cnt = 0 THEN NULL ELSE 'Duplicate IDs: ' || v_cnt END
        );

    SELECT COUNT(*)
    INTO v_cnt
    FROM s_psql_dm.v_users
    WHERE age IS NOT NULL
      AND (age < 0 OR age > 120);

    INSERT INTO s_psql_dds.t_dq_check_results
        (check_type, table_name, status, error_message)
    VALUES
        (
            'validity',
            's_psql_dm.v_users',
            CASE WHEN v_cnt = 0 THEN 'passed' ELSE 'failed' END,
            CASE WHEN v_cnt = 0 THEN NULL ELSE 'Invalid age rows: ' || v_cnt END
        );

    SELECT COUNT(*)
    INTO v_cnt
    FROM s_psql_dm.v_users
    WHERE email IS NOT NULL
      AND signup_date IS NULL;

    INSERT INTO s_psql_dds.t_dq_check_results
        (check_type, table_name, status, error_message)
    VALUES
        (
            'consistency',
            's_psql_dm.v_users',
            CASE WHEN v_cnt = 0 THEN 'passed' ELSE 'failed' END,
            CASE WHEN v_cnt = 0 THEN NULL ELSE 'Email without signup_date: ' || v_cnt END
        );

    SELECT COUNT(*)
    INTO v_cnt
    FROM s_psql_dm.v_users
    WHERE email IS NOT NULL
    AND email NOT LIKE '%@%.%';

    INSERT INTO s_psql_dds.t_dq_check_results
        (check_type, table_name, status, error_message)
    VALUES
        (
            'correctness',
            's_psql_dm.v_users',
            CASE WHEN v_cnt = 0 THEN 'passed' ELSE 'failed' END,
            CASE WHEN v_cnt = 0 THEN NULL ELSE 'Invalid email rows: ' || v_cnt END
        );

EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO s_psql_dds.t_dq_check_results
            (check_type, table_name, status, error_message)
        VALUES
            ('dq_pipeline', 's_psql_dm.v_users', 'error', SQLERRM);
END;
$$;
