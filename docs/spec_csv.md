# CSV file format specification

## BeanCount generation CSV

Sample BeanCount transaction:

```beancount
2023-01-05 * "RUBIN INFORMATIKAI ZRT" "Bér"
  Assets:Erste:Pre  601574 HUF
  Income:Rubin  
```

In order to build the BeanCount transaction, the following output CSV is essential:

```csv
date,payee,narration,account,amount,account2
2023-01-05,"RUBIN INFORMATIKAI ZRT","Bér","Assets:Erste:Pre",601574,"Income:Rubin"
```

## Common part

Must have fields from the JSON structure:

| Field              | Example                        |
|--------------------|--------------------------------|
| booking            | "2025-09-24T00:00:00.000+0200" |
| ownerAccountNumber | "11991119-94328510-00000000"   |
| amount.value       | -100000                        |
| partnerName        | "Éva OTP Varga"                |
| senderReference    | "Éva kért pénzt"               |

## TRA: Account -> Account Transactions

Additional fields:

| Field                 | Example                                     |
|-----------------------|---------------------------------------------|
| partnerAccount.iban   | "HU07117731400086902300000000"              |
| partnerAccount.number | "117731400086902300000000"                  |
| reference             | "20250924 Trn: F0HO240920250052012 Oth.---" |
| referenceNumber       | "F0HO240920250052012"                       |

One ore both fields may contain data: `partnerAccount.iban` and `partnerAccount.number`. The first one has preference over the latter.

## BUY: Buy something with Credit or Debit Card

Case:

 - `partnerAccount.iban`: Not present / NUll
 - `partnerAccount.number`: Not present / NUll
 - Last characters of reference: `vásár.`


| Field                 | Example                                                                  |
|-----------------------|--------------------------------------------------------------------------|
| partnerName           | "TESCO 41019 O:NKISZOLG"                                                 |
| reference             | "554533xxxxxx8795 00187860 TESCO 41019 O:N BALASSAGY 25022213:52 vásár." |
| cardNumber            | "554533******8795"                                                       |
## INT: Intra bank transactionsCase:

 - `partnerAccount.iban`: Not present / NUll
 - `partnerAccount.number`: Not present / NUll

| Field                 | Example                                                                  |
|-----------------------|--------------------------------------------------------------------------|
| reference             | "5227738 VARGA JÓZSEF FRONT Átvezetés befektetési számlára."             |