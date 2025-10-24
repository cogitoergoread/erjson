#!/usr/bin/env bash

export TEST_DIR=/tmp/erjsonunit

# Test JSON conversion
test_01a_pre_success_json_convert() {
    cp resources/pre.json "$TEST_DIR"
    json2csv "$TEST_DIR"/pre.json "$TEST_DIR"/pre.csv
    assert "diff resources/pre.csv ${TEST_DIR}/pre.csv"
}

test_01b_eur_success_json_convert() {
    cp resources/eur.json "$TEST_DIR"
    json2csv "$TEST_DIR"/eur.json "$TEST_DIR"/eur.csv
    assert "diff resources/eur.csv ${TEST_DIR}/eur.csv"
}

# Sad path JSON Conversion
test_02a_no_input_file() {
  assert_status_code 1  json2csv /cica /tmp/out.csv
}

test_02b_no_output_file() {
  assert_status_code 1  json2csv resources/premium-tosplit.json /cica
}

# CSV split tests, PRE
test_03a_pre_success_csv_tra() {
  csvsplit_tra resources/pre.csv "$TEST_DIR"/out2.csv
  assert "diff  resources/pre.tra.csv ${TEST_DIR}/out2.csv"
}

test_03b_pre_success_csv_buy() {
  csvsplit_buy resources/pre.csv "$TEST_DIR"/out3.csv
  assert "diff  resources/pre.buy.csv ${TEST_DIR}/out3.csv"
}

test_03c_pre_success_csv_int() {
  csvsplit_int resources/pre.csv "$TEST_DIR"/out4.csv
  assert "diff  resources/pre.int.csv ${TEST_DIR}/out4.csv"
}

test_03d_pre_success_csvsplit() {
  cp resources/pre.csv "$TEST_DIR"
  csvsplit "$TEST_DIR"/pre.csv 
  assert "diff  resources/pre.tra.csv ${TEST_DIR}/pre.tra.csv"
  assert "diff  resources/pre.buy.csv ${TEST_DIR}/pre.buy.csv"
  assert "diff  resources/pre.int.csv ${TEST_DIR}/pre.int.csv"
}

# CSV Split tests EUR
test_04a_eur_success_csv_tra() {
  csvsplit_tra resources/eur.csv "$TEST_DIR"/out5.csv "HU02119911199432851000000000"
  assert "diff  resources/eur.tra.csv ${TEST_DIR}/out5.csv"
}

test_04b_eur_success_csv_buy() {
  csvsplit_buy resources/eur.csv "$TEST_DIR"/out6.csv
  assert "diff  resources/eur.buy.csv ${TEST_DIR}/out6.csv"
}

test_04c_eur_success_csv_int() {
  csvsplit_int resources/eur.csv "$TEST_DIR"/out7.csv
  assert "diff  resources/eur.int.csv ${TEST_DIR}/out7.csv"
}

test_04d_eur_success_csvsplit() {
  cp resources/eur.csv "$TEST_DIR"
  csvsplit "$TEST_DIR"/eur.csv "$TEST_DIR" "HU02119911199432851000000000"
  assert "diff  resources/eur.tra.csv ${TEST_DIR}/eur.tra.csv"
  assert "diff  resources/eur.buy.csv ${TEST_DIR}/eur.buy.csv"
  assert "diff  resources/eur.int.csv ${TEST_DIR}/eur.int.csv"
}

# Credit tests
test_05a_cre_success_json_convert() {
    cp resources/cre.json "$TEST_DIR"
    json2csv "$TEST_DIR"/cre.json "$TEST_DIR"/cre.csv
    assert "diff resources/cre.csv ${TEST_DIR}/cre.csv"
}

test_05b_credit_split_success(){
  crecsv2split resources/cre.csv ${TEST_DIR}/cre.tra.csv ${TEST_DIR}/cre.buy.csv ${TEST_DIR}/cre.int.csv
  assert "diff  resources/cre.tra.csv ${TEST_DIR}/cre.tra.csv"
  assert "diff  resources/cre.int.csv ${TEST_DIR}/cre.int.csv"
  assert "diff  resources/cre.buy.csv ${TEST_DIR}/cre.buy.csv"
}


# Menu tests
test_06a_pre_success_menu() {
  cp resources/pre.json "$TEST_DIR"
  menu j2s "$TEST_DIR"/pre.json
  assert "diff  resources/pre.tra.csv ${TEST_DIR}/pre.tra.csv"
  assert "diff  resources/pre.buy.csv ${TEST_DIR}/pre.buy.csv"
  assert "diff  resources/pre.int.csv ${TEST_DIR}/pre.int.csv"
}

test_06a_cre_success_menu() {
  cp resources/cre.json "$TEST_DIR"
  menu j2s "$TEST_DIR"/cre.json
  assert "diff  resources/cre.tra.csv ${TEST_DIR}/cre.tra.csv"
  assert "diff  resources/cre.buy.csv ${TEST_DIR}/cre.buy.csv"
  assert "diff  resources/cre.int.csv ${TEST_DIR}/cre.int.csv"
}

setup_suite() {
  # shellcheck source=../bin/jsonproc.sh 
  source ../bin/jsonproc.sh 
  rm -rf "$TEST_DIR"
  mkdir -p "$TEST_DIR"
}