#!/usr/bin/env bash

# Premium account tests
test_pre_bean_converttra() {
    ctra_convert resources/premium-splitted-tra.csv resources/map-tra.mlr /tmp/
    assert "diff resources/premium-splitted-tra_im.csv /tmp/premium-splitted-tra_im.csv"
    assert "diff resources/premium-splitted-tra.beancount /tmp/premium-splitted-tra.beancount"
}

test_pre_bean_curr() {
    ctra_convert resources/sample-curr-tra.csv resources/map-tra.mlr /tmp/
    assert "diff resources/sample-curr-tra_im.csv /tmp/sample-curr-tra_im.csv"
    assert "diff resources/sample-curr-tra.beancount /tmp/sample-curr-tra.beancount"
}

test_pre_bean_convertbuy() {
    ctra_convert resources/premium-splitted-buy.csv resources/map-buy.mlr /tmp/
    assert "diff resources/premium-splitted-buy_im.csv /tmp/premium-splitted-buy_im.csv"
}

test_pre_bean_convertint() {
    ctra_convert resources/premium-splitted-int.csv resources/map-int.mlr /tmp/
    assert "diff resources/premium-splitted-int_im.csv /tmp/premium-splitted-int_im.csv"
}

# EUR Account tests
test_eur_bean_converttra() {
    ctra_convert resources/eursampl-tra.csv resources/meu-tra.mlr /tmp/
    assert "diff resources/eursampl-tra_im.csv /tmp/eursampl-tra_im.csv"
    assert "diff resources/eursampl-tra.beancount /tmp/eursampl-tra.beancount"
}

test_eur_bean_convertbuy() {
    ctra_convert resources/eursampl-buy.csv resources/meu-buy.mlr /tmp/
    assert "diff resources/eursampl-buy_im.csv /tmp/eursampl-buy_im.csv"
}

test_eur_bean_convertint() {
    ctra_convert resources/eursampl-int.csv resources/meu-int.mlr /tmp/
    assert "diff resources/eursampl-int_im.csv /tmp/eursampl-int_im.csv"
}

setup_suite() {
  source ../bin/beangen.sh

}
