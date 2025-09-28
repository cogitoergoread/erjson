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
    exit 0
}

# do not run main when sourcing the script
if [[ "$0" == "${BASH_SOURCE[0]}" ]]
then
  main "$@"
else
  true
fi
