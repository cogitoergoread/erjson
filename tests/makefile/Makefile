SCRIPTS ?= /tmp/cica

all: pre.bean

%.bean: %.tra.beancount %.buy.beancount %.int.beancount
	cat  $^ > $@

%.tra.beancount: %.tra.csv %.tra.mlr
	$(SCRIPTS)/beangen.sh bcg $^

%.buy.beancount: %.buy.csv %.buy.mlr
	$(SCRIPTS)/beangen.sh bcg $^

%.int.beancount: %.int.csv %.int.mlr
	$(SCRIPTS)/beangen.sh bcg $^

%.tra.csv  %.buy.csv %.int.csv: %.json
	$(SCRIPTS)/jsonproc.sh j2s $^
clean:
	rm -f *.csv *.beancount *.im *.bean
