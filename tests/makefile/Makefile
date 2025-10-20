SCRIPTS := /usrdata/home/muszi/gwork/erjson/bin

all: pre.beancount

pre.beancount: pre.tra.beancount pre.buy.beancount pre.int.beancount
	cat  $^ $@

pre.tra.beancount: pre.tra.im
	$(SCRIPTS)/beangen.sh bcg $^

pre.tra.im: pre.tra.csv pre.tra.mlr
	$(SCRIPTS)/beangen.sh imm $^

pre.buy.im: pre.buy.csv pre.buy.mlr
	$(SCRIPTS)/beangen.sh imm $^

pre.int.im: pre.int.csv pre.int.mlr
	$(SCRIPTS)/beangen.sh imm $^

pre.tra.csv  pre.buy.csv pre.int.csv: pre.csv
	$(SCRIPTS)/jsonproc.sh csp $^

pre.csv: pre.json
	$(SCRIPTS)/jsonproc.sh j2c $^ $@

clean:
	rm -f *.csv *.beancount *.im
