# Kaia faucet and useful tips

## Public faucet
You can get testnet `KLAY` on here: https://baobab.wallet.klaytn.foundation/faucet (URL will be updated at some point)

**Note:**
- `50 KLAY` per request per wallet per 24 hours

## Faucet API

You can also make a `POST` request to the faucet API with the following format (substitute the `<insert_wallet>` with a valid Kaia wallet)

```bash
https://api-baobab.wallet.klaytn.com/faucet/run?address=<insert_wallet>
```

### Return objects

- Successful request from faucet with the transaction hash of the token delivery

HTTP Code - `200 OK`
```bash
{
    "code": 0,
    "target": "api",
    "result": "SUCCESS",
    "data": "\"0x61984f4f95da59ce900ae4360e407d910312dcaefed94e264b438418800ecb57\""
}
```

- Address already requested within 24 hours (yes! I don't like the HTTP code of `200` either but I didn't design this API)

HTTP Code - `200 OK`
```bash
{
    "code": 993,
    "target": "api",
    "result": "ADDRESS ERROR",
    "data": ""
}
```