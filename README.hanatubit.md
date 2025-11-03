# HanatuBit (HBT)

A minimal SIP-010-style fungible token implemented in Clarity and managed with Clarinet.

## Token Details

- Name: HanatuBit
- Symbol: HBT
- Decimals: 6

## Quickstart

- Check the contract:
  ```bash
  clarinet check
  ```
- Open console and query:
  ```clarity
  (contract-call? .hanatubit get-name)
  (contract-call? .hanatubit get-symbol)
  (contract-call? .hanatubit get-decimals)
  (contract-call? .hanatubit get-total-supply)
  ```

## Mint, Transfer, Burn

- Mint (deployer only):
  ```clarity
  (contract-call? .hanatubit mint u1000000 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5)
  ```
- Transfer (sender must be tx-sender):
  ```clarity
  (contract-call? .hanatubit transfer u500000 'ST1SJ3DTE5DN7X54YDH5D64R3BCB6A2AG2ZQ8YPD5 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
  ```
- Transfer with memo:
  ```clarity
  (contract-call? .hanatubit transfer-memo u1 tx-sender 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM (some 0x68656c6c6f))
  ```
- Burn (caller burns own tokens):
  ```clarity
  (contract-call? .hanatubit burn u100)
  ```

## Notes

- The contract owner (deployer) is set at deployment time and is the only one who can mint.
- Balances and total supply are tracked with unsigned integers; amounts must be > 0.
