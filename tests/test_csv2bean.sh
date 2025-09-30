#!/usr/bin/env bash

test_success_json_converttra() {
    ctra_convert resources/premium-splitted-tra.csv resources/map-tra.mlr /tmp/
    assert "diff resources/premium-splitted-tra_im.csv /tmp/premium-splitted-tra_im.csv"
    assert "diff resources/premium-splitted-tra.beancount /tmp/premium-splitted-tra.beancount"
}

test_success_json_convertbuy() {
    ctra_convert resources/premium-splitted-buy.csv resources/map-buy.mlr /tmp/
    assert "diff resources/premium-splitted-buy_im.csv /tmp/premium-splitted-buy_im.csv"
}


setup_suite() {
  source ../bin/beangen.sh

}