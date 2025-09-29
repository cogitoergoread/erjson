#!/usr/bin/env bash

display_help() {
    echo "Usage: $0 {-h|j2c|csp}" >&2
    echo
    echo "   -h                              Display help"
    echo "   bgt <infile> <config> <outdir>  Convert CSV to beancount, TRA"
    echo
    exit 1
}

function main() {
    menu "$@" 
}

function menu() {
    case "$1" in
        bgt) echo $1 not implemented. Yet.
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
  mlr --c2p --from "$1" put -q 'print $date." * \"".$payee."\" \"".$narration."\"\n  ".$account." ".$amount." HUF\n  ".$account2."\n"' > "$2"
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
    mlr -c --from "${1}" put -f "$2" then rename booking,date,partnerName,payee,senderReference,narration,amount.value,amount then cut -o -f date,payee,narration,account,amount,account2 > "$3"/"$imcsv"
    imcsv_beancount "$3"/"$imcsv" "$3"/"$bcfil" 
}


# Split file, into 3 parts
# Param1: Input file
# Param2: Output directory
function csvsplit () {
      if [ ! -r "$1" ]
    then
      echo Can not read "$1"
      exit 1
    fi

    if [ ! -w "$2" ]; then
      echo Can not write to "$2"
      exit 1
    fi
    # shellcheck disable=SC2155
    local fname=$(basename "$1")
    local of1=${fname%.csv}_tra.csv
    local of2=${fname%.csv}_buy.csv
    local of3=${fname%.csv}_int.csv

    csvsplit_tra "$1" "${2}"/"${of1}"
    csvsplit_buy "$1" "${2}"/"${of2}"
    csvsplit_int "$1" "${2}"/"${of3}"
}

# do not run main when sourcing the script
if [[ "$0" == "${BASH_SOURCE[0]}" ]]
then
  main "$@"
else
  true
fi
