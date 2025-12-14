import psycopg2
from datetime import date
from etl.etl_function import etl_func, fill_dm_table, load_dm_to_mysql, conn_params, start_date, end_date, mysql_conn_params
import time
import pymysql

def wait_for_db(params, retries=10, delay=2):
    for i in range(retries):
        try:
            conn = psycopg2.connect(**params)
            conn.close()
            return
        except psycopg2.OperationalError:
            time.sleep(delay)
    raise Exception("PostgreSQL не доступен после нескольких попыток")

def wait_for_mysql(params, retries=15, delay=3):
    for i in range(retries):
        try:
            conn = pymysql.connect(**params)
            conn.close()
            return
        except pymysql.err.OperationalError:
            print(f"MySQL ещё не готов, пробуем снова ({i+1}/{retries})...")
            time.sleep(delay)
    raise Exception("MySQL не доступен после нескольких попыток")

def execute_sql_file(conn_params, filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        sql_script = f.read()
    conn = psycopg2.connect(**conn_params)
    cur = conn.cursor()
    cur.execute(sql_script)
    conn.commit()
    cur.close()
    conn.close()

def execute_mysql_sql_file(conn_params, file_path):
    mysql_conn = pymysql.connect(**conn_params)
    cur = mysql_conn.cursor()

    with open(file_path, "r") as f:
        sql_script = f.read()

    statements = [s.strip() for s in sql_script.split(";") if s.strip()]

    for statement in sql_script.split(";"):
        stmt = statement.strip()
        if not stmt:
            continue 
        cur.execute(stmt + ";")

    mysql_conn.commit()
    cur.close()
    mysql_conn.close()

def execute_procedure_mysql_sql_file(mysql_params, filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        sql_script = f.read()

    commands = sql_script.split("CREATE PROCEDURE")

    drop_stmt = commands[0].strip()
    procedure_body = "CREATE PROCEDURE " + commands[1].strip()

    conn = pymysql.connect(**mysql_params)
    cur = conn.cursor()

    if drop_stmt:
        cur.execute(drop_stmt)

    cur.execute(procedure_body)

    conn.commit()
    cur.close()
    conn.close()



def main():
    wait_for_db(conn_params)

    execute_sql_file(conn_params, "sql/create_tables.sql")
    execute_sql_file(conn_params, "sql/fn_etl_data_load.sql")

    etl_func()
    print('---------------ЛАБА 2--------------------')
    execute_sql_file(conn_params, "sql/create_dm_tables.sql")
    execute_sql_file(conn_params, "sql/fn_dm_data_load.sql")
    execute_sql_file(conn_params, "sql/create_dm_view.sql")

    fill_dm_table(start_date, end_date)

    wait_for_mysql(mysql_conn_params)

    execute_mysql_sql_file(mysql_conn_params, "sql/mysql_create_tables.sql")


    execute_procedure_mysql_sql_file(mysql_conn_params, "sql/fn_dm_data_stg_to_dm_load.sql")

    load_dm_to_mysql(start_date, end_date)

if __name__ == "__main__":
    main()
