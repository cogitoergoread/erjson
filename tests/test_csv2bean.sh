#!/usr/bin/env bash

export TEST_DIR=/tmp/erbeanunit

# Premium account tests
test_01a_pre_bean_converttra() {
    ctra_convert resources/pre.tra.csv resources/pre.tra.mlr "$TEST_DIR"
    assert "diff resources/pre.tra.im ${TEST_DIR}/pre.tra.im"
    assert "diff resources/pre.tra.beancount ${TEST_DIR}/pre.tra.beancount"
}

test_01b_pre_bean_curr() {
    ctra_convert resources/pre2.tra.csv resources/pre.tra.mlr "$TEST_DIR"
    assert "diff resources/pre2.tra.im ${TEST_DIR}/pre2.tra.im"
    assert "diff resources/pre2.tra.beancount ${TEST_DIR}/pre2.tra.beancount"
}

test_01c_pre_bean_convertbuy() {
    ctra_convert resources/pre.buy.csv resources/pre.buy.mlr "$TEST_DIR"
    assert "diff resources/pre.buy.im ${TEST_DIR}/pre.buy.im"
}

test_01d_pre_bean_convertint() {
    ctra_convert resources/pre.int.csv resources/pre.int.mlr "$TEST_DIR"
    assert "diff resources/pre.int.im ${TEST_DIR}/pre.int.im"
}

# EUR Account tests
test_02a_eur_bean_converttra() {
    ctra_convert resources/eur.tra.csv resources/eur.tra.mlr "$TEST_DIR"
    assert "diff resources/eur.tra.im ${TEST_DIR}/eur.tra.im"
    assert "diff resources/eur.tra.beancount ${TEST_DIR}/eur.tra.beancount"
}

test_02b_eur_bean_convertbuy() {
    ctra_convert resources/eur.buy.csv resources/eur.buy.mlr "$TEST_DIR"
    assert "diff resources/eur.buy.im ${TEST_DIR}/eur.buy.im"
}

test_02c_eur_bean_convertint() {
    ctra_convert resources/eur.int.csv resources/eur.int.mlr "$TEST_DIR"
    assert "diff resources/eur.int.im ${TEST_DIR}/eur.int.im"
}

# EUR Account tests
test_03a_cre_bean_converttra() {
    ctra_convert resources/cre.tra.csv resources/cre.tra.mlr "$TEST_DIR"
    assert "diff resources/cre.tra.im ${TEST_DIR}/cre.tra.im"
    assert "diff resources/cre.tra.beancount ${TEST_DIR}/cre.tra.beancount"
}

test_03b_cre_bean_convertbuy() {
    ctra_convert resources/cre.buy.csv resources/cre.buy.mlr "$TEST_DIR"
    assert "diff resources/cre.buy.im ${TEST_DIR}/cre.buy.im"
}

test_03c_cre_bean_convertint() {
    ctra_convert resources/cre.int.csv resources/cre.int.mlr "$TEST_DIR"
    assert "diff resources/cre.int.im ${TEST_DIR}/cre.int.im"
}

# Agnostic convert test (bcg)
test_04_success_convert() {
  for acct in pre eur cre
  do
    cp resources/"$acct".*.csv resources/"$acct".*.mlr "$TEST_DIR"
    for ttyp in tra buy int
    do
      menu bcg "$TEST_DIR"/${acct}.${ttyp}.csv
      assert "diff resources/${acct}.${ttyp}.im ${TEST_DIR}/${acct}.${ttyp}.im"
    done
  done
}

setup_suite() {
  source ../bin/beangen.sh
  rm -rf "$TEST_DIR"
  mkdir -p "$TEST_DIR"
}
