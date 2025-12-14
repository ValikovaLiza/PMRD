CREATE TABLE IF NOT EXISTS t_dm_stg_task (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name_id INT,
    last_name_id INT,
    email_id INT,
    age_id INT,
    country_id INT,
    signup_date_id INT
);
CREATE TABLE IF NOT EXISTS t_dm_task LIKE t_dm_stg_task;