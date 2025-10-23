#!/usr/bin/env bash

display_help() {
    echo "Usage: $0 {-h|j2c|csp}" >&2
    echo
    echo "   -h                       Display help"
    echo "   j2c <infile> <outfile>   Convert JSON to CSV and clean data"
    echo "   csp <infile>             Write different CSV files splitted by type"
    echo "   j2s <infile>             Convert to CSV and split into the same directory"
    echo
    exit 1
}

function main() {
    menu "$@" 
}

function menu() {
    case "$1" in
        j2c)
          # JSON to CSV conversion
          local outfile=${2%.json}.csv
          json2csv "$2" "$outfile"
        ;;

        csp)
          # Split CSV files by transaction type
          # shellcheck disable=SC2155
          local basedir=$(dirname -- "${2}")
          csvsplit "$2" "$basedir"
        ;;

        j2s)
          # Convert to JSON and split in one step
          local outfile=${2%.json}.csv
          json2csv "$2" "$outfile"
          # shellcheck disable=SC2155
          local basedir=$(dirname -- "${2}")
          csvsplit "$outfile" "$basedir"
        ;;

        -h) display_help
        ;;

        *) echo $1 not implemented.
           display_help
        ;;
    esac
}

function check_files() {
    if [ ! -r "$1" ]
    then
      echo Can not read "$1"
      exit 1
    fi

    if touch "$2"; then
      rm -f "$2"
    else
      echo Can not create "$2"
      exit 1
    fi
}

# Convert Erste JSON to intermediate CSV
# Param1: Input file
# Param2: Output file
function json2csv {
    check_files "$1" "$2"

    echo booking,ownerAccountNumber,amount,partneriban,partnerNumber,senderReference,partnerName,reference,cardNumber > "${2}"

    cat "${1}"\
    | tr -s ' ' \
    | jq --raw-output '.[] | [ .booking, .ownerAccountNumber, .amount.value, .partnerAccount.iban, .partnerAccount.number , .senderReference, .partnerName, .reference, .cardNumber ] | @csv' >> "${2}"
}

# Split file, first transfer transactions (TRA)
# Param1: Input file
# Param2: Output file
# Param3: Filter out account
function csvsplit_tra () {
  check_files "$1" "$2"

  if [ $# -eq 2 ]
  then
    # shellcheck disable=SC2016
    # shellcheck disable=SC1010
    mlr -c --from "${1}" filter '(is_not_empty($partneriban)) || (is_not_empty($partnerNumber))' then put 'is_not_empty($partnerNumber) {$partner = $partnerNumber};' then put 'is_not_empty($partneriban) {$partner = $partneriban};' then cut -f booking,ownerAccountNumber,amount,partner,senderReference,partnerName,reference then sort -f booking > "$2"
  else
    # shellcheck disable=SC2016
    # shellcheck disable=SC1010
    mlr -c --from "${1}" filter "\$partneriban != \"${3}\"" then filter '(is_not_empty($partneriban)) || (is_not_empty($partnerNumber))' then put 'is_not_empty($partnerNumber) {$partner = $partnerNumber};' then put 'is_not_empty($partneriban) {$partner = $partneriban};' then cut -f booking,ownerAccountNumber,amount,partner,senderReference,partnerName,reference then sort -f booking > "$2"
  fi
}

# Split file, 2nd Buying (BUY)
# Param1: Input file
# Param2: Output file
function csvsplit_buy () {
  check_files "$1" "$2"

  # shellcheck disable=SC2016
  # shellcheck disable=SC1010
  mlr -c --from "${1}" filter '(is_empty($partneriban)) && (is_empty($partnerNumber)) && ($reference =~ "vásár.")'  then cut -f booking,ownerAccountNumber,amount,partner,partnerName,reference,cardNumber then sort -f booking > "$2"
}



# Split file, 3rd Internal (INT)
# Param1: Input file
# Param2: Output file
function csvsplit_int () {
  check_files "$1" "$2"

  # shellcheck disable=SC2016
  # shellcheck disable=SC1010
  mlr -c --from "${1}" filter '(is_empty($partneriban)) && (is_empty($partnerNumber)) && ( (is_empty($reference)) || !($reference =~ "vásár.") )'  then cut -f booking,ownerAccountNumber,amount,reference then sort -f booking > "$2"
}

# Split file, into 3 parts
# Param1: Input file
function csvsplit () {
    if [ ! -r "$1" ]
    then
      echo Can not read "$1"
      exit 1
    fi

    # pre accouts has no filters
    local of1=${1%.csv}.tra.csv
    local of2=${1%.csv}.buy.csv
    local of3=${1%.csv}.int.csv

    # pre accouts has no filters
    local fname=$(basename "$1")
    if [[ "$fname" == pre* ]]; then
      csvsplit_tra "$1" "${of1}"
    else
      csvsplit_tra "$1" "${of1}" "HU02119911199432851000000000"
    fi
    csvsplit_buy "$1" "${of2}"
    csvsplit_int "$1" "${of3}"

    # Count file length, pre
    if [[ "$fname" == pre* ]]; then
      w1=$(wc -l "${of1}")
      w2=$(wc -l "${of2}")
      w3=$(wc -l "${of3}")
      winfile=$(wc -l "${1}")
      if [ $(( ${w1% *} + ${w2% *} + ${w3% *} - 3)) -ne $(( ${winfile% *} - 1 )) ]; then
        echo input and outfile length not equal, infile: "$winfile" , Outfile: "$w1" , "$w2", "$w3"
        exit 1
      fi
    fi
}

# do not run main when sourcing the script
if [[ "$0" == "${BASH_SOURCE[0]}" ]]
then
  main "$@"
else
  true
fi
