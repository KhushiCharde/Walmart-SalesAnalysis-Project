"""Load the prepared dataset into an existing empty MySQL table."""
import os
from pathlib import Path
import pandas as pd
from sqlalchemy import create_engine, URL, text

url = URL.create('mysql+pymysql', username=os.environ['DB_USER'],
                 password=os.environ['DB_PASSWORD'],
                 host=os.environ.get('DB_HOST', 'localhost'),
                 port=int(os.environ.get('DB_PORT', '3306')),
                 database=os.environ.get('DB_NAME', 'walmart_analysis'))
engine = create_engine(url)
df = pd.read_csv(Path(__file__).resolve().parents[1] / 'Walmart_processed.csv')
df['date'] = pd.to_datetime(df.date).dt.date
with engine.begin() as conn:
    if conn.execute(text('SELECT COUNT(*) FROM walmart')).scalar_one():
        raise SystemExit('Table is not empty. Load cancelled to prevent duplicate imports.')
    df.to_sql('walmart', conn, if_exists='append', index=False, chunksize=1000)
    count = conn.execute(text('SELECT COUNT(*) FROM walmart')).scalar_one()
    assert count == len(df), 'Loaded row count does not match CSV'
print(f'Loaded {count} records into MySQL.')
