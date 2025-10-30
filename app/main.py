import random
import pandas as pd
import numpy as np
from faker import Faker
from io import StringIO
from app.db import copy_from_dataframe, execute_sql, get_conn, get_engine
import datetime

fake = Faker()

def get_dataset(num_rows=5000, seed=42):
    random.seed(seed)
    np.random.seed(seed)
    Faker.seed(seed)
    rows = []
    for _ in range(num_rows):
        row = {
            "id": random.choice([fake.uuid4(), None, "", fake.uuid4()[:8]]),
            "name": random.choice([
                fake.name(),
                fake.name().upper(),
                fake.first_name(),
                fake.last_name().lower(),
                None,
                "  " + fake.name() + "  "
            ]),
            "email": random.choice([
                fake.email(),
                fake.email().replace("@", " [at] "),
                fake.email().upper(),
                None,
                fake.user_name()
            ]),
            "age": random.choice([
                random.randint(15, 90),
                str(random.randint(15, 90)),
                None,
                "unknown",
                -1
            ]),
            "country": random.choice([
                fake.country(),
                fake.country_code(),
                "",
                None,
                fake.country().upper(),
                "Россия" if random.random() < 0.1 else fake.country()
            ]),
            "salary": random.choice([
                round(random.uniform(300, 10000), 2),
                f"{random.randint(300, 5000)} USD",
                "",
                None,
                random.choice(["-", "н/д", "неизв."]),
                random.uniform(300, 10000)
            ]),
            "join_date": random.choice([
                fake.date(),  # гггг-мм-дд
                fake.date_of_birth().strftime("%d.%m.%Y"),
                fake.date_time_this_decade().strftime("%Y/%m/%d"),
                None,
                "unknown",
                fake.date_time_this_century().strftime("%m-%d-%Y")
            ]),
            "is_active": random.choice([
                True, False, "yes", "no", "1", "0", None, ""
            ])
        }
        rows.append(row)
    df = pd.DataFrame(rows)
    # дубликаты ~10%
    df = pd.concat([df, df.sample(int(len(df)*0.1), replace=True)], ignore_index=True)
    df = df.sample(frac=1, random_state=seed).reset_index(drop=True)
    return df

def load_data_to_db(df, schema="s_psql_dds", table="t_sql_source_unstructured"):
    df = df.rename(columns={c: c.lower() for c in df.columns})
    copy_from_dataframe(df, f"{schema}.{table}")
    print(f"Loaded {len(df)} rows into {schema}.{table}")

def fill_structured_table(start_date: str, end_date: str):
    engine = get_engine()
    sql = "SELECT s_psql_dds.fn_etl_data_load(:start_date, :end_date);"
    conn = get_conn()
    try:
        with engine.connect() as conn:
            conn.execute(sql, {"start_date": start_date, "end_date": end_date})
            print("fn_etl_data_load executed")
    finally:
        conn.close()

def etl():
    df = get_dataset(num_rows=5000)
    load_data_to_db(df)
    fill_structured_table("2025-01-01", "2025-12-31")

if __name__ == "__main__":
    etl()
