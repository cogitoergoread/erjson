# erjson

Processing Erste bank account statements in JSON format into Beancount format.

## Prerequisites

- `jq` - JSON processor for parsing bank statements
- `mlr` (Miller) - CSV/data transformation tool
- `bash` 4.0+ - Shell scripting environment

Install on Debian/Ubuntu:
```bash
apt-get install jq miller
```

## Overview

This project converts Erste Bank account statements through a two-phase pipeline:
1. **JSON → CSV**: Parse bank JSON files and normalize to intermediate CSV format
2. **CSV → Beancount**: Transform CSV to double-entry bookkeeping ledger entries

Supports three account types:
- **pre** - HUF Premium account statements
- **eur** - EUR account statements (with exchange rate lookup)
- **cre** - Credit card statements

Transactions are categorized into three types:
- **TRA** (Transfer) - Money transfers between accounts
- **BUY** (Purchase) - Merchant purchases and card payments
- **INT** (Internal) - Bank fees, interest, and internal operations

## Usage

### Phase 1: `jsonproc.sh` - JSON to CSV Conversion

Convert JSON bank statement to intermediate CSV format:
```bash
bin/jsonproc.sh j2c <input.json> <output.csv> [exchangerates_dir]
```

Split CSV file into transaction type files:
```bash
bin/jsonproc.sh csp <input.csv>
```

Convert and split in one command:
```bash
bin/jsonproc.sh j2s <input.json> [exchangerates_dir]
```

**Examples:**
```bash
# HUF account
bin/jsonproc.sh j2s pre.json

# EUR account (requires exchange rates)
bin/jsonproc.sh j2s eur.json ./exchangerates

# Credit card
bin/jsonproc.sh j2s cre.json
```

**Output Files:**
- `<basename>.csv` - Normalized CSV with all transactions
- `<basename>.tra.csv` - Transfer transactions
- `<basename>.buy.csv` - Purchase transactions  
- `<basename>.int.csv` - Internal transactions

### Phase 2: `beangen.sh` - CSV to Beancount Conversion

Convert specific transaction type to Beancount:
```bash
bin/beangen.sh tra <input.tra.csv> <config.mlr> <output_dir>
bin/beangen.sh buy <input.buy.csv> <config.mlr> <output_dir>
bin/beangen.sh int <input.int.csv> <config.mlr> <output_dir>
```

Auto-detect type and convert (recommended):
```bash
bin/beangen.sh bcg <input.tra.csv>
```

Check unique values for account mapping:
```bash
bin/beangen.sh chk <input.csv>
```

**Examples:**
```bash
# Convert all transaction types for premium account
bin/beangen.sh bcg pre.tra.csv
bin/beangen.sh bcg pre.buy.csv
bin/beangen.sh bcg pre.int.csv

# Result: pre.tra.beancount, pre.buy.beancount, pre.int.beancount
```

**Output Files:**
- `<basename>.im` - Intermediate format with account mappings
- `<basename>.beancount` - Final Beancount ledger entries

### Configuration Files

Each transaction type requires an MLR config file for account mapping:
- `<account>.<type>.mlr` - Mapping rules (e.g., `pre.tra.mlr`, `eur.buy.mlr`)

Config files define:
- Account number to Beancount account mapping
- Transaction categorization rules
- Currency handling
- Exchange rate processing

See [tests/resources/](tests/resources/) for configuration examples.

## Complete Workflow Example

Process a premium HUF account statement:

```bash
# Step 1: Convert JSON to CSV and split by transaction type
bin/jsonproc.sh j2s data/pre.json

# Step 2: Convert each transaction type to Beancount
# (Assumes pre.tra.mlr, pre.buy.mlr, pre.int.mlr are in data/)
bin/beangen.sh bcg data/pre.tra.csv
bin/beangen.sh bcg data/pre.buy.csv
bin/beangen.sh bcg data/pre.int.csv

# Step 3: Combine all Beancount files
cat data/pre.tra.beancount data/pre.buy.beancount data/pre.int.beancount > data/pre.bean

# Step 4: Validate with Beancount
bean-check data/pre.bean
```

## File Naming Convention

Input files must follow this pattern:
- `<account>.json` - Raw bank statement (e.g., `pre.json`, `eur.json`, `cre.json`)
- `<account>.<type>.csv` - Transaction type CSV (e.g., `pre.tra.csv`)
- `<account>.<type>.mlr` - MLR config for mapping (e.g., `pre.tra.mlr`)

Output files generated:
- `<account>.csv` - All transactions normalized
- `<account>.<type>.csv` - Split by transaction type
- `<account>.<type>.im` - Intermediate format with mappings
- `<account>.<type>.beancount` - Final ledger entries

## Testing

Run unit tests:
```bash
./bash_unit tests/*.sh
```

See [docs/bash-unittesting.md](docs/bash-unittesting.md) for details.

## Project Objectives

### First phase - `jsonproc.sh`
- [x] Parse JSON files from Erste bank account statements.
- [X] Three different types of statements are processex: EUR acccount statements, HUF account statements and credit card statements.
- [x] Convert parsed data to intermediate CSV format

### Second phase - `beangen.sh`
- [x] Add EUR - HUF exchange rates to EUR transactions
- [x] Beancount conversion account numbers mapped with `mlr` scripts within the conversion
- [x] Convert intermediate CSV format to Beancount format

