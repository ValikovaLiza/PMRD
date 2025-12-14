DROP PROCEDURE IF EXISTS fn_dm_data_stg_to_dm_load;

CREATE PROCEDURE fn_dm_data_stg_to_dm_load(
    IN start_dt DATE,
    IN end_dt DATE
)
BEGIN
    DELETE FROM t_dm_task
    WHERE signup_date_id BETWEEN start_dt AND end_dt;

    INSERT INTO t_dm_task (
        first_name_id,
        last_name_id,
        email_id,
        age_id,
        country_id,
        signup_date_id
    )
    SELECT
        first_name_id,
        last_name_id,
        email_id,
        age_id,
        country_id,
        signup_date_id
    FROM t_dm_stg_task;
END;
