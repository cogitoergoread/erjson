#!/usr/bin/env bash

set -euo pipefail

display_help() {
    echo "Usage: $0 {-h|-d|tra|buy|int|bcg}"
    echo
    echo "   -h                              Display help"
    echo "   -d                              Debug Mode, echo commands"
    echo "   tra <infile> <config> <outdir>  Convert CSV to beancount, TRA"
    echo "   buy <infile> <config> <outdir>  Convert CSV to beancount, BUY"
    echo "   int <infile> <config> <outdir>  Convert CSV to beancount, INT"
    echo "   bcg <infile>                    Convert CSV to beancount any type"
    echo
    exit 1
}

function main() {
    menu "$@" 
}

function menu() {
  if [[ "$1" == "-d" ]]; then
    echo "Running in Debug mode" >&2
    set -o xtrace
    shift
  fi

    case "$1" in
        tra) ctra_convert "$2" "$3" "$4"
        ;;

        buy) cbuy_convert "$2" "$3" "$4"
        ;;

        int) cint_convert "$2" "$3" "$4"
        ;;

        bcg) bcgen "$2"
        ;;

        chk) chk_file "$2"
        ;;

        -h) display_help
        ;;

        *) echo "Error: '$1' not implemented" >&2
           display_help
        ;;
    esac
}

# Validate input file, config file, and output directory
# Arguments:
#   $1 - Input file path to check for read access
#   $2 - Config file path to check for read access
#   $3 - Output directory path to check for write access
# Exits:
#   1 if validation fails
function check_files() {
    if [[ ! -r "$1" ]]; then
      echo "Error: Cannot read input file '$1'" >&2
      exit 1
    fi

    if [[ ! -r "$2" ]]; then
      echo "Error: Cannot read config file '$2'" >&2
      exit 1
    fi

    if [[ ! -w "$3" ]]; then
      echo "Error: Cannot write to output directory '$3'" >&2
      exit 1
    fi
}

# Convert intermediate CSV format to Beancount double-entry format
# Handles transactions with and without currency conversion
# Arguments:
#   $1 - Input intermediate CSV file (.im format)
#   $2 - Output Beancount file path
function imcsv_beancount {
  # shellcheck disable=SC2016
  mlr --c2p --from "$1" put -q '
# Without currency
is_empty($currency) {print $date." * \"".$payee."\" \"".$narration."\"\n  ".$account." ".$amount." ".$acccurr."\n  ".$account2."\n"};

# With currency
is_not_empty($currency) {print $date." * \"".$payee."\" \"".$narration."\"\n  ".$account." ".$amount." ".$acccurr." @ ".$xchgrate." ".$currency."\n  ".$account2."\n"};
' > "$2"
}

# Convert TRA (transfer) CSV to Beancount format
# Applies mlr config to map accounts and transform data
# Arguments:
#   $1 - Input CSV file (TRA type)
#   $2 - MLR config file with account mapping rules
#   $3 - Output directory path
# Outputs:
#   Creates <basename>.im and <basename>.beancount files
function ctra_convert {
    check_files "$1" "$2" "$3"
    local fname
    fname=$(basename "$1")
    local imcsv=${fname%.csv}.im
    local bcfil=${fname%.csv}.beancount

    # shellcheck disable=SC2016
    mlr -c --from "${1}" put -f "$2" then rename booking,date,partnerName,payee,senderReference,narration,amount.value,amount then cut -o -f date,payee,narration,account,amount,account2,currency,xchgrate,acccurr > "$3"/"$imcsv"
    imcsv_beancount "$3"/"$imcsv" "$3"/"$bcfil" 
}

# Convert BUY (purchase) CSV to Beancount format
# Applies mlr config to map accounts and transform data
# Arguments:
#   $1 - Input CSV file (BUY type)
#   $2 - MLR config file with account mapping rules
#   $3 - Output directory path
# Outputs:
#   Creates <basename>.im and <basename>.beancount files
function cbuy_convert {
    check_files "$1" "$2" "$3"
    local fname
    fname=$(basename "$1")
    local imcsv=${fname%.csv}.im
    local bcfil=${fname%.csv}.beancount

    # shellcheck disable=SC2016
    mlr -c --from "${1}" put -f "$2" then rename booking,date,partnerName,payee,amount.value,amount then cut -o -f date,payee,narration,account,amount,account2,currency,xchgrate,acccurr > "$3"/"$imcsv"
    imcsv_beancount "$3"/"$imcsv" "$3"/"$bcfil" 
}

# Convert INT (internal) CSV to Beancount format
# Applies mlr config to map accounts and transform data
# Arguments:
#   $1 - Input CSV file (INT type)
#   $2 - MLR config file with account mapping rules
#   $3 - Output directory path
# Outputs:
#   Creates <basename>.im and <basename>.beancount files
function cint_convert {
    check_files "$1" "$2" "$3"
    local fname
    fname=$(basename "$1")
    local imcsv=${fname%.csv}.im
    local bcfil=${fname%.csv}.beancount

    # shellcheck disable=SC2016
    mlr -c --from "${1}" put -f "$2" then rename booking,date,amount.value,amount then cut -o -f date,payee,narration,account,amount,account2,currency,xchgrate,acccurr > "$3"/"$imcsv"
    imcsv_beancount "$3"/"$imcsv" "$3"/"$bcfil" 
}

# Convert any CSV to Beancount format (auto-detects transaction type)
# Determines transaction type from filename pattern: <account>.<type>.csv
# Arguments:
#   $1 - Input CSV file path (must match pattern: <account>.<type>.csv)
# Expects:
#   MLR config file <account>.<type>.mlr in same directory
# Outputs:
#   Creates .im and .beancount files in same directory
# Exits:
#   1 if transaction type is invalid
function bcgen {
    [[ $# -lt 1 ]] && { echo "Error: bcgen requires input file argument" >&2; exit 1; }
    
    local fname
    fname=$(basename "$1")
    local acctplustyp=${fname%.csv}
    local typ=${acctplustyp#*.}
    local outdir
    outdir=$(dirname -- "${1}")
    local mlrname=${acctplustyp}.mlr

    case $typ in
      tra) ctra_convert "$1" "$outdir"/"$mlrname" "$outdir"
      ;;
      buy) cbuy_convert "$1" "$outdir"/"$mlrname" "$outdir"
      ;;
      int) cint_convert "$1" "$outdir"/"$mlrname" "$outdir"
      ;;

      *) echo "Error: Invalid transaction type '$typ' in filename (must be 'tra', 'buy', or 'int')" >&2
         exit 1
      ;;
    esac
}

# Check and display unique values from CSV file by transaction type
# Helps verify data quality and identify unique partners/merchants
# Arguments:
#   $1 - Input CSV file path
# Outputs:
#   Prints unique values for key field based on transaction type
function chk_file {
    [[ $# -lt 1 ]] && { echo "Error: chk_file requires input file argument" >&2; exit 1; }
    
    local fname
    fname=$(basename "$1")
    local acctplustyp=${fname%.csv}
    local typ=${acctplustyp#*.}
    case $typ in
      tra) mlr --c2p --from "$1" uniq -f partner
      ;;
      buy) mlr --c2p --from "$1" uniq -f partnerName
      ;;
      int) mlr --c2p --from "$1" uniq -f reference
      ;;

      *) echo "Error: Invalid transaction type '$typ' in filename (must be 'tra', 'buy', or 'int')" >&2
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
