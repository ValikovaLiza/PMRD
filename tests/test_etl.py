import pytest
import json
from unittest.mock import MagicMock, patch
from etl.etl_function import get_dataset, load_data_to_db, fill_structured_table
from main import execute_sql_file

@pytest.mark.parametrize("n", [10, 50])
def test_get_dataset_returns_json_list(n):
    data = get_dataset(n)
    assert isinstance(data, list)
    assert len(data) == n
    for row in data:
        record = json.loads(row)
        assert "full_name" in record
        assert "email" in record
        assert "age" in record
        assert "signup_date" in record
        assert "country" in record

def test_load_data_to_db_executes_correct_sql():
    mock_conn = MagicMock()
    mock_cur = MagicMock()
    mock_conn.cursor.return_value = mock_cur

    data = ['{"full_name": "John Doe", "email": "john@example.com"}']

    with patch("psycopg2.connect", return_value=mock_conn):
        load_data_to_db(data, conn_params={})

    mock_cur.execute.assert_called_with(
        "INSERT INTO s_psql_dds.t_sql_source_unstructured (raw_data) VALUES (%s)",
        (data[0],)
    )
    assert mock_conn.commit.called
    assert mock_cur.close.called
    assert mock_conn.close.called

@pytest.fixture
def mock_conn_and_cursor():
    mock_conn = MagicMock()
    mock_cur = MagicMock()
    mock_conn.cursor.return_value = mock_cur
    return mock_conn, mock_cur

def test_fill_structured_table_calls_sql():
    mock_conn = MagicMock()
    mock_cur = MagicMock()
    mock_conn.cursor.return_value = mock_cur

    fill_structured_table("2025-01-01", "2025-12-31", conn=mock_conn)

    mock_cur.execute.assert_called_with(
        "SELECT s_psql_dds.fn_etl_data_load(%s::date, %s::date)",
        ("2025-01-01", "2025-12-31")
    )

    assert mock_conn.commit.called
    assert mock_cur.close.called

def test_run_dq_checks_sql():
    mock_cursor = MagicMock()
    mock_conn = MagicMock()
    mock_conn.cursor.return_value = mock_cursor

    with patch("etl.etl_function.psycopg2.connect", return_value=mock_conn):
        execute_sql_file({"dbname": "test", "user": "test", "password": "test"}, "sql/run_dq_checks.sql")

    assert mock_cursor.execute.called

    called_sql = mock_cursor.execute.call_args[0][0]
    assert "fn_dq_checks_load" in called_sql

    mock_conn.commit.assert_called_once()
    mock_cursor.close.assert_called_once()
    mock_conn.close.assert_called_once()