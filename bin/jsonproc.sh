#!/usr/bin/env bash

function main() {
    menu "$@" 
}

function menu() {
    case "$1" in
        j2c) json2csv "$2" "$3"
        ;;

        *) echo not implemented
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
function csvsplit_tra () {
  check_files "$1" "$2"

  # shellcheck disable=SC2016
  # shellcheck disable=SC1010
  mlr -c --from "${1}" filter '(is_not_empty($partneriban)) || (is_not_empty($partnerNumber))' then put 'is_not_empty($partnerNumber) {$partner = $partnerNumber};' then put 'is_not_empty($partneriban) {$partner = $partneriban};' then cut -f booking,ownerAccountNumber,amount,partner,senderReference,partnerName,reference > "$2"
}

# Split file, 2nd Buying (BUY)
# Param1: Input file
# Param2: Output file
function csvsplit_buy () {
  check_files "$1" "$2"

  # shellcheck disable=SC2016
  # shellcheck disable=SC1010
  mlr -c --from "${1}" filter '(is_empty($partneriban)) && (is_empty($partnerNumber)) && ("vásár." == $reference[-6:])'  then cut -f booking,ownerAccountNumber,amount,partner,partnerName,reference,cardNumber > "$2"
}



# Split file, 3rd Internal (INT)
# Param1: Input file
# Param2: Output file
function csvsplit_int () {
  check_files "$1" "$2"

  # shellcheck disable=SC2016
  # shellcheck disable=SC1010
  mlr -c --from "${1}" filter '(is_empty($partneriban)) && (is_empty($partnerNumber)) && ( (is_empty($reference)) || !("vásár." == $reference[-6:]) )'  then cut -f booking,ownerAccountNumber,amount,reference > "$2"
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
