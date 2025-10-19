#!/usr/bin/env bash

# Test JSON conversion
test_pre_success_json_convert() {
    json2csv resources/premium-tosplit.json /tmp/out.csv
    assert "diff resources/premium-splitted.csv /tmp/out.csv"
}

test_eur_success_json_convert() {
    json2csv resources/eursampl.json /tmp/oute.csv
    assert "diff resources/eursampl.csv /tmp/oute.csv"
}

# Sad path JSON Conversion
test_no_input_file() {
  assert_status_code 1  json2csv /cica /tmp/out.csv
}

test_no_output_file() {
  assert_status_code 1  json2csv resources/premium-tosplit.json /cica
}

# CSV split tests, PRE
test_pre_success_csv_tra() {
  csvsplit_tra resources/premium-splitted.csv /tmp/out2.csv
  assert "diff  resources/premium-splitted-tra.csv /tmp/out2.csv"
}

test_pre_success_csv_buy() {
  csvsplit_buy resources/premium-splitted.csv /tmp/out3.csv
  assert "diff  resources/premium-splitted-buy.csv /tmp/out3.csv"
}

test_pre_success_csv_int() {
  csvsplit_int resources/premium-splitted.csv /tmp/out4.csv
  assert "diff  resources/premium-splitted-int.csv /tmp/out4.csv"
}

test_pre_success_csvsplit() {
  csvsplit resources/premium-splitted.csv /tmp
  assert "diff  resources/premium-splitted-tra.csv /tmp/premium-splitted_tra.csv"
  assert "diff  resources/premium-splitted-buy.csv /tmp/premium-splitted_buy.csv"
  assert "diff  resources/premium-splitted-int.csv /tmp/premium-splitted_int.csv"
}

# CSV Split tests EUR
test_eur_success_csv_tra() {
  csvsplit_tra resources/eursampl.csv /tmp/out5.csv "HU02119911199432851000000000"
  assert "diff  resources/eursampl-tra.csv /tmp/out5.csv"
}

test_eur_success_csv_buy() {
  csvsplit_buy resources/eursampl.csv /tmp/out6.csv
  assert "diff  resources/eursampl-buy.csv /tmp/out6.csv"
}

test_eur_success_csv_int() {
  csvsplit_int resources/eursampl.csv /tmp/out7.csv
  assert "diff  resources/eursampl-int.csv /tmp/out7.csv"
}

test_eur_success_csvsplit() {
  csvsplit resources/eursampl.csv /tmp "HU02119911199432851000000000"
  assert "diff  resources/eursampl-tra.csv /tmp/eursampl_tra.csv"
  assert "diff  resources/eursampl-buy.csv /tmp/eursampl_buy.csv"
  assert "diff  resources/eursampl-int.csv /tmp/eursampl_int.csv"
}

setup_suite() {
  source ../bin/jsonproc.sh 

}