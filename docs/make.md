# Makefile 

Standard Makefile for generating a Beancount Output from a JSON input.

Sequence of generation:

 1. *.json : JSON Input
 2. *.bare.csv: Transformed from JSON to CSV
 3. *.tra.csv, *.buy.csv, *.int.csv: Split bare file to different types
 4. *.tra.mlr, *.buy.mlr, *.int.mlr: Miller put files configuring the output
 5. *.tra.im, *.buy.im, *.int.im: Immediate CSV files to 
 6. *.tra.beancount, *.buy.beancount, *.int.beancount: Beancount outputs splitted
 7. *.beancount: Jouned 


Skeleton of Makefile:

```makefile
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
```