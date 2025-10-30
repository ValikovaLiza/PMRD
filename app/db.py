from sqlalchemy import create_engine
import os
import pandas as pd

def get_engine():
    user = os.getenv("DB_USER", "postgres")
    password = os.getenv("DB_PASSWORD", "postgres")
    host = os.getenv("DB_HOST", "etl_postgres")
    port = os.getenv("DB_PORT", "5432")
    db = os.getenv("DB_NAME", "etl_db")

    url = f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}"
    return create_engine(url)

def get_conn():
    """Возвращает соединение к БД"""
    engine = get_engine()
    return engine.connect()

def execute_sql(sql, params=None):
    """Выполнить SQL"""
    with get_conn() as conn:
        if params:
            conn.execute(sql, params)
        else:
            conn.execute(sql)

def copy_from_dataframe(df: pd.DataFrame, table_name: str):
    import json
    from sqlalchemy import text

    conn = get_conn()
    try:
        with conn.begin():
            for _, row in df.iterrows():
                json_data = json.dumps(row.to_dict(), default=str)
                conn.execute(
                    text(f"INSERT INTO {table_name} (raw_data) VALUES (:json_data)"),
                    {"json_data": json_data}
                )
        print(f"Loaded {len(df)} rows into {table_name}")
    finally:
        conn.close()
