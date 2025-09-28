#!/usr/bin/env bash

test_success_json_convert() {
    json2csv resources/premium-tosplit.json /tmp/out.csv
    assert "diff resources/premium-splitted.csv /tmp/out.csv"
}

test_no_input_file() {
  assert_status_code 1  json2csv /cica /tmp/out.csv
}

test_no_output_file() {
  assert_status_code 1  json2csv resources/premium-tosplit.json /cica
}

test_success_csv_tra() {
  csvsplit_tra resources/premium-splitted.csv /tmp/out2.csv
  assert "diff  resources/premium-splitted-tra.csv /tmp/out2.csv"
}

setup_suite() {
  source ../bin/jsonproc.sh 
}