import json
import random
import psycopg2
from faker import Faker
from datetime import date
import os

import pymysql

fake = Faker()

conn_params = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", 5432)),
    "user": os.getenv("DB_USER", "dds_user"),
    "password": os.getenv("DB_PASSWORD", "dds_pass"),
    "dbname": os.getenv("DB_NAME", "dds_db")
}

mysql_conn_params = {
    "host": os.getenv("MYSQL_HOST", "localhost"),
    "port": int(os.getenv("MYSQL_PORT", 3306)),
    "user": os.getenv("MYSQL_USER", "dm_user"),
    "password": os.getenv("MYSQL_PASSWORD", "dm_pass"),
    "database": os.getenv("MYSQL_DB", "dm_db")
}

start_date = date(2025, 1, 1)
end_date = date(2025, 12, 31)

def get_dataset(n=100):
    data = []
    for _ in range(n):
        record = {
            "full_name": random.choice([fake.name(), fake.first_name()]),
            "email": random.choice([fake.email(), "invalid_email@", "", None]),
            "age": random.choice([str(random.randint(18, 70)), "", "N/A", "unknown"]),
            "signup_date": random.choice([
                fake.date_time().strftime("%Y-%m-%d %H:%M:%S"),
                "2025/31/12",
                "not_a_date",
                ""
            ]),
            "country": random.choice([fake.country(), "", None, "??"])
        }
        data.append(json.dumps(record))
    return data

def load_data_to_db(data, conn_params):
    conn = psycopg2.connect(**conn_params)
    cur = conn.cursor()
    for row in data:
        cur.execute("INSERT INTO s_psql_dds.t_sql_source_unstructured (raw_data) VALUES (%s)", (row,))
    conn.commit()
    cur.close()
    conn.close()

def fill_structured_table(start_date, end_date, conn=None):
    close_conn = False
    if conn is None:
        import psycopg2
        conn = psycopg2.connect(**conn_params)
        close_conn = True

    cur = conn.cursor()
    cur.execute("SELECT s_psql_dds.fn_etl_data_load(%s::date, %s::date)", (start_date, end_date))
    conn.commit()
    cur.close()
    if close_conn:
        conn.close()

def fill_dm_table(start_date, end_date, conn=None):
    close_conn = False
    if conn is None:
        conn = psycopg2.connect(**conn_params)
        close_conn = True

    cur = conn.cursor()
    cur.execute(
        "SELECT s_psql_dm.fn_dm_data_load(%s::date, %s::date)", (start_date, end_date))
    conn.commit()
    cur.close()
    if close_conn:
        conn.close()

def load_dm_to_mysql(start_date, end_date):
    pg_conn = psycopg2.connect(**conn_params)
    pg_cur = pg_conn.cursor()
    pg_cur.execute("""
        SELECT
            first_name_id,
            last_name_id,
            email_id,
            age_id,
            country_id,
            signup_date_id
        FROM s_psql_dm.f_users
    """)
    rows = pg_cur.fetchall()
    pg_cur.close()
    pg_conn.close()

    mysql_conn = pymysql.connect(**mysql_conn_params)
    mysql_cur = mysql_conn.cursor()
    mysql_cur.executemany(
        "INSERT INTO t_dm_stg_task (first_name_id, last_name_id, email_id, age_id, country_id, signup_date_id) VALUES (%s,%s,%s,%s,%s,%s)",
        rows
    )
    mysql_conn.commit()

    mysql_cur.execute("CALL fn_dm_data_stg_to_dm_load(%s, %s)", (start_date, end_date))
    mysql_conn.commit()
    mysql_cur.close()
    mysql_conn.close()

def etl_func():

    start_date = date(2025, 1, 1)
    end_date = date(2025, 12, 31)
    n = 100

    data = get_dataset(n)

    load_data_to_db(data, conn_params)

    fill_structured_table(start_date, end_date)
