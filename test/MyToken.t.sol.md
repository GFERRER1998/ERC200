# Documentacion: test/MyToken.t.sol

## Proposito

Suite de tests completa para el contrato MyToken. Verifica todas las funcionalidades: constructor, mint, pause, unpause, transfer, approve, transferFrom, burn.

---

## Imports

| Import | De donde viene | Para que sirve |
|---|---|---|
| `Test` | `forge-std/Test.sol` | Framework de testing: assertEq, vm.prank, vm.expectRevert, makeAddr |
| `MyToken` | `../src/MyToken.sol` | El contrato que se esta testeando |

---

## Variables de Test

| Variable | Tipo | Descripcion |
|---|---|---|
| `token` | MyToken | Instancia del contrato (se recrea en cada setUp) |
| `owner` | address | Deployer del contrato (address(this)) |
| `alice` | address | Usuario de test creado con makeAddr |
| `bob` | address | Usuario de test creado con makeAddr |
| `INITIAL_SUPPLY` | uint256 | 1,000,000 * 1e18 (supply inicial) |

---

## setUp()

Se ejecuta ANTES de cada test. Despliega una instancia limpia de MyToken.

---

## Tabla de Tests

| # | Test | Que verifica | Tipo |
|---|---|---|---|
| 1 | `test_NameAndSymbol` | name() == "MyToken", symbol() == "MTK" | Unitario |
| 2 | `test_Decimals` | decimals() == 18 | Unitario |
| 3 | `test_InitialSupply` | totalSupply y balance del deployer | Unitario |
| 4 | `test_Owner` | owner() == deployer | Unitario |
| 5 | `test_Mint` | Owner puede mintear tokens | Unitario |
| 6 | `test_MintRevertNonOwner` | No-owner no puede mintear | Revert |
| 7 | `test_Transfer` | Transferencia exitosa | Unitario |
| 8 | `test_TransferRevertInsufficientBalance` | Revert sin balance suficiente | Revert |
| 9 | `test_Approve` | Allowance se configura correctamente | Unitario |
| 10 | `test_TransferFrom` | Transfer con allowance funciona | Unitario |
| 11 | `test_Burn` | Burn reduce supply y balance | Unitario |
| 12 | `test_PauseRevertTransfer` | Transfer falla cuando pausado | Revert |
| 13 | `test_Unpause` | Despues de unpause funciona | Unitario |

---

## Herramientas de Foundry Utilizadas

### assertEq(a, b)
Verifica que `a` es igual a `b`. Si no son iguales, el test falla.

### vm.prank(address)
Simula que la siguiente transaccion viene de `address`. Permite testear funciones con `onlyOwner`.

### vm.expectRevert()
Espera que la siguiente transaccion falle (revert). Se usa para testear que funciones restringidas fallan correctamente.

### makeAddr(string)
Crea una direccion nueva con un nombre descriptivo. Util para identificar usuarios en tests.

### view
Las funciones marcadas con `view` no modifican estado. Se usan para testear getters.

---

## Ejecucion

```bash
# Ejecutar todos los tests
forge test

# Ejecutar con verbosidad (ver cada test)
forge test -vvv

# Ejecutar solo este archivo
forge test --match-path test/MyToken.t.sol

# Ejecutar un test especifico
forge test --match-test test_Mint
```

---

## Coverage (Cobertura)

| Funcion | Test | Cobertura |
|---|---|---|
| constructor | test_NameAndSymbol, test_Decimals, test_InitialSupply, test_Owner | 100% |
| mint | test_Mint, test_MintRevertNonOwner | 100% |
| pause | test_PauseRevertTransfer | 100% |
| unpause | test_Unpause | 100% |
| transfer | test_Transfer, test_TransferRevertInsufficientBalance | 100% |
| approve | test_Approve | 100% |
| transferFrom | test_TransferFrom | 100% |
| burn | test_Burn | 100% |
