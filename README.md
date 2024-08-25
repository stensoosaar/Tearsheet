# Tearsheet

This is a simple Swift/DuckDB-based library for analyzing and visualizing portfolio performance by calculating:

- Cash-weighted portfolio return using the modified Dietz formula, compared with a selected benchmark
- Drawdown
- Grouped returns
- Sharpe and Sortino ratios, Compound Annual Growth Rate (CAGR)
- Distribution of daily returns

Currently, you can analyze a CSV file or a PostgreSQL database table. The following columns are expected:
- date: The date in the format yyyy-mm-dd
- cash_flow: Net cash flow from deposits and withdrawals in the account's base currency
- end_balance: The ending balance of your portfolio/account (in the account's base currency)

At the moment, it's in the quick hack stage. It seems to work with Xcode 16 / Sequoia 15 but definitely requires further development.
