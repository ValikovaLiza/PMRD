DROP TABLE IF EXISTS s_psql_dds.t_dq_check_results;

CREATE TABLE s_psql_dds.t_dq_check_results (
    check_id SERIAL PRIMARY KEY,
    check_type VARCHAR(50),      
    table_name VARCHAR(100),    
    execution_date TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20),         
    error_message VARCHAR(500) 
);
