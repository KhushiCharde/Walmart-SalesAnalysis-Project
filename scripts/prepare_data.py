"""Rebuild the processed CSV and browser dataset from the bundled raw CSV."""
from pathlib import Path
import json
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]

def prepare(source):
    df = source.copy()
    df.columns = df.columns.str.strip().str.lower()
    duplicates = int(df.duplicated().sum())
    df = df.drop_duplicates().copy()
    df['unit_price'] = pd.to_numeric(df['unit_price'].astype('string').str.replace('$', '', regex=False), errors='coerce')
    df['quantity'] = pd.to_numeric(df['quantity'], errors='coerce')
    df['date'] = pd.to_datetime(df['date'], format='%d/%m/%y', errors='coerce')
    bad = df[['unit_price', 'quantity', 'date']].isna().any(axis=1)
    rejected = df.loc[bad].copy()
    df = df.loc[~bad].copy()
    if not df.invoice_id.is_unique:
        raise ValueError('Conflicting invoice identifiers require review')
    if (df.unit_price < 0).any() or (df.quantity <= 0).any() or (df.quantity % 1 != 0).any():
        raise ValueError('Invalid price or quantity requires review')
    if not df.profit_margin.between(0, 1).all():
        raise ValueError('Expected fractional profit margins')
    df['time'] = pd.to_datetime(df['time'], format='%H:%M:%S', errors='raise').dt.strftime('%H:%M:%S')
    df['quantity'] = df.quantity.astype(int)
    df['date'] = df.date.dt.strftime('%Y-%m-%d')
    df['total'] = (df.unit_price * df.quantity).round(2)
    if df.isna().any().any():
        raise ValueError('Unexpected missing values require review')
    return df, rejected, duplicates

if __name__ == '__main__':
    raw = pd.read_csv(ROOT / 'Walmart.csv')
    df, rejected, duplicates = prepare(raw)
    df.to_csv(ROOT / 'Walmart_processed.csv', index=False)
    dashboard = ROOT / 'dashboard'
    dashboard.mkdir(exist_ok=True)
    df.to_json(dashboard / 'data.json', orient='records')
    df.to_csv(dashboard / 'Walmart_processed.csv', index=False)
    report = {'raw_rows': len(raw), 'duplicates_removed': duplicates,
              'incomplete_rows_removed': len(rejected), 'processed_rows': len(df),
              'branches': int(df.branch.nunique()), 'sales': round(float(df.total.sum()), 2)}
    (ROOT / 'data_quality.json').write_text(json.dumps(report, indent=2) + '\n')
    rejected.to_csv(ROOT / 'rejected_rows.csv', index=False)
    print(json.dumps(report, indent=2))
