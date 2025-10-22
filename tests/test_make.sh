#!/usr/bin/env bash

export TEST_DIR=/tmp/erjsonmk

# Make tests
test_01_pre_make() {
  cp resources/pre.json  resources/pre.*.mlr makefile/Makefile "$TEST_DIR"
  pushd "$TEST_DIR"
  make all
  popd
  
  assert "diff  resources/pre.tra.csv ${TEST_DIR}/pre.tra.csv"
  assert "diff  resources/pre.buy.csv ${TEST_DIR}/pre.buy.csv"
  assert "diff  resources/pre.int.csv ${TEST_DIR}/pre.int.csv"
  assert "diff  resources/pre.bean ${TEST_DIR}/pre.bean"
}


setup_suite() {
  rm -rf "$TEST_DIR"
  mkdir -p "$TEST_DIR"
}