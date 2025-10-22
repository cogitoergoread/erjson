#!/usr/bin/env bash

export TEST_DIR=/tmp/erjsonmk

# Make tests
test_01_pre_make() {
  cp resources/pre.json  resources/pre.*.mlr makefile/Makefile "$TEST_DIR"
  export SCRIPTS="$(cd ../bin; pwd)"
  pushd "$TEST_DIR"
  make all
  popd
  
  assert "diff  resources/pre.tra.im ${TEST_DIR}/pre.tra.im"
  assert "diff  resources/pre.buy.im ${TEST_DIR}/pre.buy.im"
  assert "diff  resources/pre.int.im ${TEST_DIR}/pre.int.im"
  assert "diff  resources/pre.bean ${TEST_DIR}/pre.bean"
}


setup_suite() {
  rm -rf "$TEST_DIR"
  mkdir -p "$TEST_DIR"
}
