#!/usr/bin/env bash

test_success_json_convert() {
    ctra_convert resources/premium-splitted-tra.csv resources/map-tra.mlr /tmp/
    assert "diff resources/premium-splitted-tra_im.csv /tmp/premium-splitted-tra_im.csv"
    assert "diff resources/premium-splitted-tra.beancount /tmp/premium-splitted-tra.beancount"
}


setup_suite() {
  source ../bin/beangen.sh

}