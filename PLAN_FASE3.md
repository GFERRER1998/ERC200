# Plan Fase 3: Crear tests para MyToken

## Archivos a crear

| # | Archivo | Accion |
|---|---|---|
| 1 | `test/MyToken.t.sol` | Crear (13 tests) |
| 2 | `test/MyToken.t.sol.md` | Crear (documentacion) |

---

## Funciones a testear

| Funcion | Tipo | Que testear |
|---|---|---|
| Constructor | Propia | name, symbol, decimals, totalSupply, owner, balance |
| `mint` | Propia | Owner mint, no-owner revert |
| `pause` | Propia | Owner pausa, no-owner revert |
| `unpause` | Propia | Owner despausa, no-owner revert |
| `transfer` | Heredada | Transferencia exitosa, revert sin balance |
| `approve` | Heredada | Aprobacion exitosa, allowance correcto |
| `transferFrom` | Heredada | Transferencia con allowance, revert sin allowance |
| `burn` | Heredada | Holder quema, totalSupply reduce |
| `burnFrom` | Heredada | Quema con allowance, revert sin allowance |
| Pausa | Propia | Transfer falla cuando pausado |

---

## Tests (13)

| # | Test | Que verifica |
|---|---|---|
| 1 | `test_NameAndSymbol` | Nombre y simbolo correctos |
| 2 | `test_Decimals` | 18 decimales |
| 3 | `test_InitialSupply` | Supply al deployer |
| 4 | `test_Owner` | Deployer es owner |
| 5 | `test_Mint` | Owner puede mint |
| 6 | `test_MintRevertNonOwner` | No-owner no puede mint |
| 7 | `test_Transfer` | Transferencia funciona |
| 8 | `test_TransferRevertInsufficientBalance` | Revert sin balance |
| 9 | `test_Approve` | Allowance correcto |
| 10 | `test_TransferFrom` | Transfer con allowance |
| 11 | `test_Burn` | Quema reduce supply |
| 12 | `test_PauseRevertTransfer` | Transfer falla pausado |
| 13 | `test_Unpause` | Despues de unpause funciona |

---

## Orden de Ejecucion

```
Paso 1 (PLAN) → Pasos 2-15 (tests) → Paso 16 (.md) → Paso 17 (build) → Paso 18 (test)
```
