from app.db import get_conn

def test_fn_etl_data_load_test():
    conn = get_conn()
    try:
        with conn:
            with conn.cursor() as cur:
                # Очищаем тестовую таблицу
                cur.execute("TRUNCATE s_psql_dds.t_sql_source_structured_copy;")
                
                # Вызываем SQL-функцию для теста
                cur.execute("SELECT s_psql_dds.fn_etl_data_load_test('2025-01-01', '2025-12-31');")
                
                # Проверяем, что данные появились
                cur.execute("SELECT COUNT(*) FROM s_psql_dds.t_sql_source_structured_copy;")
                count = cur.fetchone()[0]
                assert count > 0
    finally:
        conn.close()
