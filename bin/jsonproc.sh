#!/usr/bin/env bash

set -euo pipefail

display_help() {
    echo "Usage: $0 {-h|j2c|csp|j2s}"
    echo
    echo "   -h                                  Display help"
    echo "   j2c <infile> <outfile>  <xchgpath> Convert JSON to CSV and clean data"
    echo "   csp <infile>                        Write different CSV files splitted by type"
    echo "   j2s <infile> <xchgpath>             Convert to CSV and split into the same directory"
    echo
    exit 1
}

function main() {
    menu "$@" 
}

function menu() {
  if [[ "$1" == "-d" ]]
  then
    echo Running in Debug mode
    set -o xtrace
    shift
  fi

    case "$1" in
        j2c)
          # JSON to CSV conversion
          local outfile="${2%.json}.csv"
          json2csv "$2" "$outfile" "${3:-}"
        ;;

        csp)
          # Split CSV files by transaction type
          local basedir
          basedir=$(dirname -- "${2}")
          csvsplit "$2" "$basedir"
        ;;

        j2s)
          # Convert to JSON and split in one step
          local outfile="${2%.json}.csv"
          json2csv "$2" "$outfile" "${3:-}"
          local basedir
          basedir=$(dirname -- "${2}")
          csvsplit "$outfile" "$basedir"
        ;;

        -h) display_help
        ;;

        *) echo "'$1' not implemented" >&2
           display_help
        ;;
    esac
}

# Validate input file readability and output file writability
# Arguments:
#   $1 - Input file path to check for read access
#   $2 - Output file path to check for write access
# Exits:
#   1 if validation fails
function check_files() {
    if [[ ! -r "$1" ]]; then
      echo "Error: Cannot read input file '$1'" >&2
      exit 1
    fi

    if touch "$2" 2>/dev/null; then
      rm -f "$2"
    else
      echo "Error: Cannot create output file '$2'" >&2
      exit 1
    fi
}

# Convert Erste JSON bank statement to intermediate CSV format
# Extracts transaction data and adds exchange rate column
# Arguments:
#   $1 - Input JSON file path
#   $2 - Output CSV file path
#   $3 - (Optional) Exchange rates directory path (required for EUR files)
# Exits:
#   1 if file validation or exchange rate lookup fails
function json2csv {
    check_files "$1" "$2"

    echo booking,ownerAccountNumber,amount,partneriban,partnerNumber,senderReference,partnerName,reference,cardNumber > "${2}"

    cat "${1}"\
    | tr -s ' ' \
    | jq --raw-output '.[] | [ .booking, .ownerAccountNumber, .amount.value, .partnerAccount.iban, .partnerAccount.number , .senderReference, .partnerName, .reference, .cardNumber ] | @csv' >> "${2}"

    # EUR files should have exchgrate
    local fname
    fname=$(basename "$1")
    local typ=${fname%.*}
    if [[ "$typ" == "eur" ]]; then
      # Check exchange rate file
      local xchgfile="$3"/exchangerates.csv
      if [[ ! -r "$xchgfile" ]]; then
        echo "Error: Cannot read exchange rate file '$xchgfile' (required for EUR transactions)" >&2
        exit 1
      fi
      # eur account has real exchange rates joined from file exchangerates.csv
      mlr -I --csv cut -x -f xchgrate then put '$date=$booking[:10]' then join -f  "$xchgfile" -j date then rename -r EUR,xchgrate  then cut -o -f booking,ownerAccountNumber,amount,partneriban,partnerNumber,senderReference,partnerName,reference,cardNumber,xchgrate "$2"
    else  
      # other accounts have empty exchange rate
      # shellcheck disable=SC2016
      mlr -I --csv put '$xchgrate = ""' "$2"
    fi
}

# Split credit card CSV into transaction types
# Credit card transactions are categorized into TRA (empty), BUY, and INT types
# Arguments:
#   $1 - Input CSV file
#   $2 - Output file for TRA (transfer) transactions
#   $3 - Output file for BUY (purchase) transactions
#   $4 - Output file for INT (internal) transactions
function crecsv2split {
  # TRA is empty for credit cards
  echo booking,ownerAccountNumber,amount,senderReference,partnerName,reference,partner > "$2"
  # BUY filter
  # shellcheck disable=SC2016
  mlr -c --from "$1" filter '$cardNumber == "428942******5024"' then put '$ownerAccountNumber = "HU02116000060000000049658752"' then cut -f booking,ownerAccountNumber,amount,partner,partnerName,reference,cardNumber,xchgrate then sort -f booking > "$3"
  # INT filter
  # shellcheck disable=SC2016
  mlr -c --from "$1" filter 'is_empty($cardNumber) && is_empty($partnerNumber )' then put '$ownerAccountNumber = "HU02116000060000000049658752"' then cut -f booking,ownerAccountNumber,amount,reference,xchgrate then sort -f booking > "$4"
}


# Extract transfer transactions (TRA) from CSV
# Filters rows with partner IBAN or account number
# Arguments:
#   $1 - Input CSV file
#   $2 - Output CSV file for transfer transactions
#   $3 - (Optional) Partner IBAN to exclude from results
function csvsplit_tra () {
  check_files "$1" "$2"

  if [[ $# -eq 2 ]]; then
    # shellcheck disable=SC2016
    mlr -c --from "${1}" filter '(is_not_empty($partneriban)) || (is_not_empty($partnerNumber))' then put 'is_not_empty($partnerNumber) {$partner = $partnerNumber};' then put 'is_not_empty($partneriban) {$partner = $partneriban};' then cut -o -f booking,ownerAccountNumber,amount,partner,senderReference,partnerName,reference,xchgrate then sort -f booking > "$2"
  else
    # shellcheck disable=SC2016
    mlr -c --from "${1}" filter "\$partneriban != \"${3}\"" then filter '(is_not_empty($partneriban)) || (is_not_empty($partnerNumber))' then put 'is_not_empty($partnerNumber) {$partner = $partnerNumber};' then put 'is_not_empty($partneriban) {$partner = $partneriban};' then cut -o -f booking,ownerAccountNumber,amount,partner,senderReference,partnerName,reference,xchgrate then sort -f booking > "$2"
  fi
}

# Extract purchase transactions (BUY) from CSV
# Filters rows with no partner info and reference containing "vásár."
# Arguments:
#   $1 - Input CSV file
#   $2 - Output CSV file for purchase transactions
function csvsplit_buy () {
  check_files "$1" "$2"

  # shellcheck disable=SC2016
  mlr -c --from "${1}" filter '(is_empty($partneriban)) && (is_empty($partnerNumber)) && ($reference =~ "vásár.")'  then cut -o -f booking,ownerAccountNumber,amount,partner,partnerName,reference,cardNumber,xchgrate then sort -f booking > "$2"
}



# Extract internal transactions (INT) from CSV
# Filters rows with no partner info and no purchase reference
# Arguments:
#   $1 - Input CSV file
#   $2 - Output CSV file for internal transactions
function csvsplit_int () {
  check_files "$1" "$2"

  # shellcheck disable=SC2016
  mlr -c --from "${1}" filter '(is_empty($partneriban)) && (is_empty($partnerNumber)) && ( (is_empty($reference)) || !($reference =~ "vásár.") )'  then cut -o -f booking,ownerAccountNumber,amount,reference,xchgrate then sort -f booking > "$2"
}

# Split CSV file into three transaction type files (TRA, BUY, INT)
# Handles different account types: pre (premium), eur (EUR account), cre (credit card)
# Arguments:
#   $1 - Input CSV file path
# Outputs:
#   Creates three files: <basename>.tra.csv, <basename>.buy.csv, <basename>.int.csv
# Exits:
#   1 if file unreadable or validation fails
function csvsplit () {
  if [[ ! -r "$1" ]]; then
    echo "Error: Cannot read input file '$1'" >&2
    exit 1
  fi

  # pre accouts has no filters
  local of1=${1%.csv}.tra.csv
  local of2=${1%.csv}.buy.csv
  local of3=${1%.csv}.int.csv

  # Different processes by file type
  local fname
  fname=$(basename "$1")
  local typ=${fname%.*}
  case $typ in
    pre) 
      csvsplit_tra "$1" "${of1}"
      csvsplit_buy "$1" "${of2}"
      csvsplit_int "$1" "${of3}"
      w1=$(wc -l "${of1}")
      w2=$(wc -l "${of2}")
      w3=$(wc -l "${of3}")
      winfile=$(wc -l "${1}")
      local total_out=$(( ${w1% *} + ${w2% *} + ${w3% *} - 3 ))
      local expected=$(( ${winfile% *} - 1 ))
      if [[ $total_out -ne $expected ]]; then
        echo "Error: Row count mismatch - Input: $expected, Output total: $total_out (TRA: ${w1% *}, BUY: ${w2% *}, INT: ${w3% *})" >&2
        exit 1
      fi
    ;;
    eur)
      csvsplit_tra "$1" "${of1}" "HU02119911199432851000000000"
      csvsplit_buy "$1" "${of2}"
      csvsplit_int "$1" "${of3}"
    ;;
    cre)
      crecsv2split "$1" "${of1}" "${of2}" "${of3}"
    ;;

    *) echo "Error: Invalid file type '$typ' (must be 'pre', 'eur', or 'cre')" >&2
       exit 1
    ;;
  esac
}

# do not run main when sourcing the script
if [[ "$0" == "${BASH_SOURCE[0]}" ]]
then
  main "$@"
else
  true
fi
