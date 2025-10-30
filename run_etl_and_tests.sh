#!/bin/bash
set -e

echo "=== Запуск ETL ==="
python app/main.py

echo "=== Запуск тестов ==="
pytest -v tests/
