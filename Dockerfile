FROM python:3.12-slim

WORKDIR /app

COPY . /app

RUN pip install psycopg2-binary faker pymysql cryptography

CMD ["python", "main.py"]
