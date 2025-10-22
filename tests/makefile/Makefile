SCRIPTS := /usrdata/home/muszi/gwork/erjson/bin

all: pre.bean

pre.bean: pre.tra.beancount pre.buy.beancount pre.int.beancount
	cat  $^ > $@

pre.tra.beancount: pre.tra.csv pre.tra.mlr
	$(SCRIPTS)/beangen.sh bcg $^

pre.buy.beancount: pre.buy.csv pre.buy.mlr
	$(SCRIPTS)/beangen.sh bcg $^

pre.int.beancount: pre.int.csv pre.int.mlr
	$(SCRIPTS)/beangen.sh bcg $^

pre.tra.csv  pre.buy.csv pre.int.csv: pre.json
	$(SCRIPTS)/jsonproc.sh j2s $^
clean:
	rm -f *.csv *.beancount *.im
