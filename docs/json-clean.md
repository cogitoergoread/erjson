# JSON file cleaning

Multiple whitespaces are to be removed.

```shell
tr -s ' ' < 11991119-94328510-00000000_2025-01-01_2025-12-31.json > 119.json
```

## EUR account

jq ".[0]" < ~/gwork/pu/beancount/2025/eur.json

EUR 2 tizees jegy:

jq ".[].amount.precision" < ~/gwork/pu/beancount/2025/eur.json
