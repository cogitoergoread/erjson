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
    local wrk_dir="$1"/wrk
    local input_dir="$1"/input

    # Clean
    rm -rf "$wrk_dir"/*
    "$script_dir"/jsonproc.sh csp "$input_dir"/pre.json "$wrk_dir"
}

# do not run main when sourcing the script
if [[ "$0" == "${BASH_SOURCE[0]}" ]]
then
  main "$@"
else
  true
fi