#!/usr/bin/env bash

display_help() {
    echo "Usage: $0 {-h|j2c|csp}" >&2
    echo
    echo "   -h           Display help"
    echo "   gen <dir>    Convert JSON to beancount files in a directory."
    echo
    exit 1
}

function main() {
    menu "$@" 
}

function menu() {
    case "$1" in
        gen) yeargen "$2"
        ;;

        -h) display_help
        ;;

        *) echo $1 not implemented.
           display_help
        ;;
    esac
}

function yeargen(){
    local script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    local config_dir="$1"/config
    local wrk_dir="$1"
    local input_dir="$1"

    # Clean
    rm -rf "$wrk_dir"/*
    # JSON  -> CSV
    "$script_dir"/jsonproc.sh j2c "$input_dir"/pre.json "$wrk_dir"/pre.csv
    # CSV -> 3x CSV
    "$script_dir"/jsonproc.sh csp "$wrk_dir"/pre.csv "$wrk_dir"
    # 3x CSV -> 3x Beancount
    "$script_dir"/beange.sh tra "$wrk_dir"/pre_tra.csv "$config_dir"/map-tra.mlr "$1"
    "$script_dir"/beange.sh buy "$wrk_dir"/pre_buy.csv "$config_dir"/map-buy.mlr "$1"
    "$script_dir"/beange.sh int "$wrk_dir"/pre_int.csv "$config_dir"/map-int.mlr "$1"
}

# do not run main when sourcing the script
if [[ "$0" == "${BASH_SOURCE[0]}" ]]
then
  main "$@"
else
  true
fi