import pytest
from app.main import get_dataset, load_data_to_db, fill_structured_table
from app.db import get_conn

def test_fill_structured_table_runs():
    fill_structured_table("2025-01-01", "2025-12-31")
    conn = get_conn()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT COUNT(*) FROM s_psql_dds.t_sql_source_structured;")
            count = cur.fetchone()[0]
            assert count > 0
    finally:
        conn.close()
