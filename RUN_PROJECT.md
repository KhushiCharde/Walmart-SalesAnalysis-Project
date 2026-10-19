# Run the Walmart Sales Analysis project

## Dashboard: no database needed

From the repository root:

```bash
python -m http.server 8000 --directory dashboard
```

Open http://localhost:8000. Do not open index.html directly: browsers usually block its dataset fetch on file URLs. The dashboard includes year, branch and category filters, CSV export, payment and category summaries, annual trends, branch revenue decline and record search.

The current hosted demonstration is private to its owner:
https://walmart-sales-insights-dashboard.krushnask191204.chatgpt.site

This dashboard runs calculations in the browser. It does not run SQL or Python on the hosted website. The Python and MySQL workflow below is separate.

## Rebuild the data with Python

Use Python 3.10 or later.

```bash
python -m venv .venv
```

Activate on Windows PowerShell with `.\.venv\Scripts\Activate.ps1`, or on macOS/Linux with `source .venv/bin/activate`.

```bash
python -m pip install -r requirements.txt
python scripts/prepare_data.py
```

Expected: 10,051 raw rows, 51 exact duplicates removed, 31 incomplete rows excluded, 9,969 processed rows, 100 branches and total calculated sales of 1,209,726.38. Missing price, quantity or unparseable dates cause exclusion; rejected rows are saved locally for review. Conflicting identifiers and other invalid values stop the script.

The script refreshes Walmart_processed.csv, dashboard/data.json, dashboard/Walmart_processed.csv and data_quality.json. It preserves the raw CSV. Monetary totals are rounded to two decimals.

## Optional MySQL analysis

Install and start MySQL 8.0 or later. In MySQL Workbench, run `sql/schema.sql`. Configure these environment variables in your terminal: DB_USER, DB_PASSWORD, and optionally DB_HOST, DB_PORT, DB_NAME (default walmart_analysis). Never commit passwords.

PowerShell example:

```powershell
$env:DB_USER = 'your_mysql_user'
$env:DB_PASSWORD = 'your_mysql_password'
python scripts/load_mysql.py
```

Then select the walmart_analysis database in Workbench and run `Sql_script_solving_business_questions.sql`. The loader deliberately refuses a nonempty table to avoid accidental duplicate imports. It does not erase an existing database.

## Scope and verification

The preparation script reproduces the cleaned invoice set and sales totals from the bundled dataset. Dashboard logic was checked for initial totals, year filtering, branch decline and empty results. The MySQL loader and schema are provided but have not been executed against a running MySQL server in the preparation environment.

The exact Kaggle source and dataset licence still need documenting. Do not claim this is verified internal Walmart data. Profit estimates use the supplied fractional margins; the analysis does not establish causality or measured business impact.

## Hosting elsewhere

After rebuilding data, publish the contents of dashboard/ on a static host. For GitHub Pages, choose an appropriate Pages deployment workflow or serving directory; adding these files alone does not enable Pages or change the existing private hosted Site.
