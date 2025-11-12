import psycopg2
from datetime import date
from etl.etl_function import etl_func, conn_params
import time

def wait_for_db(params, retries=10, delay=2):
    for i in range(retries):
        try:
            conn = psycopg2.connect(**params)
            conn.close()
            return
        except psycopg2.OperationalError:
            time.sleep(delay)
    raise Exception("PostgreSQL не доступен после нескольких попыток")

def execute_sql_file(conn_params, filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        sql_script = f.read()
    conn = psycopg2.connect(**conn_params)
    cur = conn.cursor()
    cur.execute(sql_script)
    conn.commit()
    cur.close()
    conn.close()

def main():
    wait_for_db(conn_params)

    execute_sql_file(conn_params, "sql/create_tables.sql")

    execute_sql_file(conn_params, "sql/fn_etl_data_load.sql")

    etl_func()

if __name__ == "__main__":
    main()
