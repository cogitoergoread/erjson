# Banki év fájl generálás


A konverter meghatározott alkönyvtár szerkezetben várja a fájlokat, és ebből tud dolgozni.

Terv:

```text
.
└── 2025
    ├── config
    │   ├── map-buy.mlr
    │   ├── map-int.mlr
    │   └── map-tra.mlr
    ├── input
    │   └── premium-tosplit.json
    └── wrk

```

Kifejtve:

 - `input`: A JSON fájlok helye
 - `wrk`: intermediate fájlok, nem kellenek `git` alá.
 - `config`: scriptek által használt fájlok, miller számára.


# Minta könyvtár készítése

```shell
mkdir -p /tmp/cica
cd  /tmp/cica

mkdir -p 2025/config 2025/input 2025/wrk

cp ~/gwork/erjson/tests/resources/map* 2025/config
cp ~/gwork/erjson/tests/resources/premium-tosplit.json 2025/input
```