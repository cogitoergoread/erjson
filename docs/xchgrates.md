# Exchange rates

MNB-ről éves fájlt lehet letölteni.

## Extract

Így lehet EUR / USD kibányászni:

```shell
mlr -csv rename "Dátum/ISO",date then cut -f date,EUR,USD then put '$date=sub(gsub($date, "\. ","-"),"\.","")' then filter '$EUR > 1'  ~/Documents/arfolyam-letoltes-202?.csv > ~/Documents/arfolyam.csv
```

## Minden napra

Ez csak munkanapokat tartalmaz. Minden nap:

```shell
echo date,one >  ~/Documents/dates.csv
for i in {0..731}; do 
    # ISO 8601 (e.g. 2020-02-20) using -I
	export dtestr=$(date -I -d "2024-01-01 +$i days")
    echo $dtestr,1 >>  ~/Documents/dates.csv
done
```

## Generálás

Join:

```shell
mlr -csv --from arfolyam.csv  join --ul -u -f dates.csv -j date  then sort -f date then fill-down -f EUR,USD then sort -r date then fill-down -f EUR,USD  then sort  -f date then cut -f date,EUR,HUF > exchangerates.csv
```

