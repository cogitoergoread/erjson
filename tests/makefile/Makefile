SCRIPTS := /usrdata/home/muszi/gwork/erjson/bin

all: pre.beancount

pre.beancount: pre.tra.beancount pre.buy.beancount pre.int.beancount
	cat  $^ $@

pre.tra.beancount: pre.tra.csv pre.tra.mlr
	$(SCRIPTS)/beangen.sh bcg $^

pre.buy.beancount: pre.buy.csv
	$(SCRIPTS)/beangen.sh bcg $^

pre.int.beancount: pre.int.csv
	$(SCRIPTS)/beangen.sh bcg $^

pre.tra.csv  pre.buy.csv pre.int.csv: pre.json
	$(SCRIPTS)/jsonproc.sh j2s $^
clean:
	rm -f *.csv *.beancount *.im
