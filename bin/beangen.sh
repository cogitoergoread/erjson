#!/usr/bin/env bash

display_help() {
    echo "Usage: $0 {-h|j2c|csp}" >&2
    echo
    echo "   -h                              Display help"
    echo "   tra <infile> <config> <outdir>  Convert CSV to beancount, TRA"
    echo "   buy <infile> <config> <outdir>  Convert CSV to beancount, BUY"
    echo "   int <infile> <config> <outdir>  Convert CSV to beancount, INT"
    echo
    exit 1
}

function main() {
    menu "$@" 
}

function menu() {
    case "$1" in
        tra) ctra_convert "$2" "$3" "$4"
        ;;

        buy) cbuy_convert "$2" "$3" "$4"
        ;;

        int) cint_convert "$2" "$3" "$4"
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
      echo Can not read "$1" input file
      exit 1
    fi

    if [ ! -r "$2" ]
    then
      echo Can not read "$2" config file
      exit 1
    fi

    if [ ! -w "$3" ]; then
      echo Can not write to "$3" outdir
      exit 1
    fi
}

# Convert Immediate CSV to Beancount
# Param1: Input file
# Param2: Output file
function imcsv_beancount {
  # shellcheck disable=SC2016
  mlr --c2p --from "$1" put -q '
# Without currency
is_empty($currency) {print $date." * \"".$payee."\" \"".$narration."\"\n  ".$account." ".$amount." ".$acccurr."\n  ".$account2."\n"};

# With currency
is_not_empty($currency) {print $date." * \"".$payee."\" \"".$narration."\"\n  ".$account." ".$amount." ".$acccurr." @ ".$xchgrate." ".$currency."\n  ".$account2."\n"};
' > "$2"
}

# Convert TRA  CSV to Beancount
# Param1: Input file
# Param2: Config file
# Param3: Out Dir
function ctra_convert {
    check_files "$1" "$2" "$3"
    # shellcheck disable=SC2155
    local fname=$(basename "$1")
    local imcsv=${fname%.csv}_im.csv
    local bcfil=${fname%.csv}.beancount

    # shellcheck disable=SC1010
    mlr -c --from "${1}" put -f "$2" then rename booking,date,partnerName,payee,senderReference,narration,amount.value,amount then cut -o -f date,payee,narration,account,amount,account2,currency,xchgrate,acccurr > "$3"/"$imcsv"
    imcsv_beancount "$3"/"$imcsv" "$3"/"$bcfil" 
}

# Convert BUY CSV to Beancount
# Param1: Input file
# Param2: Config file
# Param3: Out Dir
function cbuy_convert {
    check_files "$1" "$2" "$3"
    # shellcheck disable=SC2155
    local fname=$(basename "$1")
    local imcsv=${fname%.csv}_im.csv
    local bcfil=${fname%.csv}.beancount

    # shellcheck disable=SC1010
    mlr -c --from "${1}" put -f "$2" then rename booking,date,partnerName,payee,amount.value,amount then cut -o -f date,payee,narration,account,amount,account2,currency,xchgrate,acccurr > "$3"/"$imcsv"
    imcsv_beancount "$3"/"$imcsv" "$3"/"$bcfil" 
}

# Convert BUY CSV to Beancount
# Param1: Input file
# Param2: Config file
# Param3: Out Dir
function cint_convert {
    check_files "$1" "$2" "$3"
    # shellcheck disable=SC2155
    local fname=$(basename "$1")
    local imcsv=${fname%.csv}_im.csv
    local bcfil=${fname%.csv}.beancount

    # shellcheck disable=SC1010
    mlr -c --from "${1}" put -f "$2" then rename booking,date,amount.value,amount then cut -o -f date,payee,narration,account,amount,account2,currency,xchgrate,acccurr > "$3"/"$imcsv"
    imcsv_beancount "$3"/"$imcsv" "$3"/"$bcfil" 
}

# do not run main when sourcing the script
if [[ "$0" == "${BASH_SOURCE[0]}" ]]
then
  main "$@"
else
  true
fi
