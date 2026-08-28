
# Estado Actual del Proyecto — ERC-200

> Snapshot del estado del proyecto en `c:\Users\gnzlf\Desktop\ERC200`.
> Última verificación: 28/08/2026.

---

## 1. Resumen Ejecutivo

| Ítem | Estado |
|---|---|
| Tipo de proyecto | Foundry + Solidity (token ERC-20 completo) |
| Compilador | `solc 0.8.28` (gestionado por forge) |
| Toolchain Foundry | v1.8.0 (`foundry/bin/forge.exe`, `cast`, `anvil`, `chisel`) |
| Compilación | ✅ OK (`forge build` sin errores) |
| Tests | ✅ 13/13 pasando (suite `MyToken.t.sol`) |
| Despliegue local (Anvil) | ✅ Verificado — `broadcast/Deploy.s.sol/31337/run-latest.json` existe |
| Despliegue Sepolia | ❌ NO realizado (falta `PRIVATE_KEY` real y ETH de testnet) |
| Verificación Etherscan | ❌ NO realizada |

---

## 2. Estructura del Proyecto (verificada)

```
ERC200/
├── .env                       # Variables de entorno reales (NO commitear)
├── .env.example               # Plantilla pública
├── .gitignore                 # Excluye .env, out/, cache/, lib/, broadcast/, foundry/
├── foundry.toml               # Config Foundry (optimizer, via_ir, RPC, Etherscan)
├── foundry.toml.md            # Documentación de foundry.toml
├── foundry/                   # Binarios de Foundry (forge, cast, anvil, chisel, solar)
├── lib/
│   ├── forge-std/             # Biblioteca estándar de Foundry
│   └── openzeppelin-contracts/  # OpenZeppelin v5 (instalado como submodule)
├── src/
│   └── MyToken.sol            # Contrato ERC-20 principal
├── test/
│   └── MyToken.t.sol          # 13 tests (unitarios)
├── script/
│   └── Deploy.s.sol           # Script de despliegue (lee .env)
├── out/                       # Artefactos compilados (ignorado por git)
├── cache/                     # Cache de forge (ignorado)
├── broadcast/                 # Logs de despliegue (ignorado)
│   └── Deploy.s.sol/
│       └── 31337/             # Chain ID 31337 = Anvil (local)
│           └── run-latest.json
├── README.md                  # README estándar de Foundry (sin customizar)
├── INSTALLED_PROGRAMS.md      # Inventario de herramientas
├── ESTADO_PROYECTO.md         # Estado detallado (versión previa de este doc)
├── PLAN.md                    # Plan maestro original (referencia)
├── PLAN_CONTINUACION.md       # Plan de fases detallado
├── PLAN_FASE2.md              # Plan específico: foundry.toml
├── PLAN_FASE3.md              # Plan específico: tests
├── PLAN_FASE4.md              # Plan específico: deploy script
├── ESTADO.md                  # ← Este archivo
└── PLAN.md                    # ← Plan de próximos pasos
```

---

## 3. Configuración (`foundry.toml`)

| Sección | Clave | Valor | Estado |
|---|---|---|---|
| `[profile.default]` | `src` | `"src"` | ✅ |
| `[profile.default]` | `out` | `"out"` | ✅ |
| `[profile.default]` | `libs` | `["lib"]` | ✅ |
| `[profile.default]` | `solc_version` | `"0.8.28"` | ✅ |
| `[profile.default]` | `optimizer` | `true` | ✅ |
| `[profile.default]` | `optimizer_runs` | `200` | ✅ |
| `[profile.default]` | `via_ir` | `true` | ✅ |
| `[profile.default]` | `remappings` | OZ + forge-std | ✅ |
| `[rpc_endpoints]` | `sepolia` | `${SEPOLIA_RPC_URL}` | ✅ |
| `[etherscan]` | `sepolia` | key + url configurados | ✅ |

---

## 4. Contrato Principal — `src/MyToken.sol`

**Herencia:**
```solidity
contract MyToken is ERC20, ERC20Burnable, ERC20Pausable, ERC20Permit, Ownable, ReentrancyGuard
```

**Constructor:**
```solidity
constructor(uint256 initialSupply_)
    ERC20("MyToken", "MTK")
    Ownable(msg.sender)
    ERC20Permit("MyToken")
{
    _mint(msg.sender, initialSupply_);
}
```

**Funciones propias:**
- `mint(address to, uint256 amount)` — `onlyOwner` + `nonReentrant`
- `pause()` — `onlyOwner`
- `unpause()` — `onlyOwner`
- `_update(...)` override — resuelve colisión `ERC20` / `ERC20Pausable`

**Funciones heredadas disponibles:** `name()`, `symbol()`, `decimals()`, `totalSupply()`, `balanceOf()`, `transfer()`, `approve()`, `allowance()`, `transferFrom()`, `burn()`, `burnFrom()`, `permit()`, `nonces()`, `DOMAIN_SEPARATOR()`, `owner()`, `transferOwnership()`, `renounceOwnership()`.

**Licencia:** MIT.

---

## 5. Tests — `test/MyToken.t.sol` (13/13 ✅)

| # | Test | Verifica |
|---|---|---|
| 1 | `test_NameAndSymbol()` | name="MyToken", symbol="MTK" |
| 2 | `test_Decimals()` | 18 decimales estándar |
| 3 | `test_InitialSupply()` | Supply acuñado al deployer |
| 4 | `test_Owner()` | `address(this)` es el owner |
| 5 | `test_Mint()` | Owner puede mintear |
| 6 | `test_MintRevertNonOwner()` | No-owner revierte (`OwnableUnauthorizedAccount`) |
| 7 | `test_Transfer()` | Transferencia entre cuentas |
| 8 | `test_TransferRevertInsufficientBalance()` | Revierte sin balance |
| 9 | `test_Approve()` | Allowance se actualiza |
| 10 | `test_TransferFrom()` | Transfer con allowance, allowance decrementa |
| 11 | `test_Burn()` | Holder quema, totalSupply y balance bajan |
| 12 | `test_PauseRevertTransfer()` | Transfer revierte cuando está pausado |
| 13 | `test_Unpause()` | Después de `unpause()` las transfers funcionan |

> Nota: `setUp()` despliega una instancia fresca de `MyToken` por test con `INITIAL_SUPPLY = 1_000_000 * 1e18`.

---

## 6. Script de Despliegue — `script/Deploy.s.sol`

Lee `PRIVATE_KEY` e `INITIAL_SUPPLY` del `.env`, despliega `MyToken("MyToken", "MTK", initialSupply)` con `vm.startBroadcast/stopBroadcast`, e imprime `address(token)`, `initialSupply` y `msg.sender`.

Comandos soportados:
```bash
forge script script/Deploy.s.sol --rpc-url localhost              # simulación
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast   # Anvil
forge script script/Deploy.s.sol --rpc-url sepolia --broadcast --verify       # Sepolia
```

---

## 7. Dependencias (`lib/`)

| Librería | Uso |
|---|---|
| `forge-std` | Framework de testing (`Test`, `console`, `Script`, cheatcodes) |
| `openzeppelin-contracts` | Implementaciones auditadas: `ERC20`, `ERC20Burnable`, `ERC20Pausable`, `ERC20Permit`, `Ownable`, `ReentrancyGuard` |

> **Atención:** `.gitignore` excluye `lib/`. Si se sube a un repo remoto, los colaboradores deben ejecutar:
> - `forge install OpenZeppelin/openzeppelin-contracts@v5.0.0 --no-commit`
> - `forge install foundry-rs/forge-std --no-commit`

---

## 8. Variables de Entorno (`.env` actual)

```env
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/TU_API_KEY
INITIAL_SUPPLY=1000000000000000000000000
PRIVATE_KEY=TU_LLAVE_PRIVADA_DE_METAMASK
```

| Variable | Estado |
|---|---|
| `SEPOLIA_RPC_URL` | ✅ Configurada (Alchemy) |
| `INITIAL_SUPPLY` | ✅ Configurada (1,000,000 tokens) |
| `PRIVATE_KEY` | ❌ PLACEHOLDER — todavía `TU_LLAVE_PRIVADA_DE_METAMASK` |
| `ETHERSCAN_API_KEY` | ❌ NO está en `.env` (necesaria para `--verify`) |

> El RPC de Alchemy que aparece arriba es un valor real (no un placeholder). Si esa clave no se está usando, debería rotarse desde el dashboard de Alchemy. **No commitear este `.env` accidentalmente.**

---

## 9. Despliegue Local — Verificado

Existe `broadcast/Deploy.s.sol/31337/run-latest.json` → se ejecutó `forge script ... --rpc-url http://localhost:8545 --broadcast` contra un nodo **Anvil** (chain ID `31337`) con éxito.

---

## 10. Lo que Falta (resumen)

1. `PRIVATE_KEY` real de MetaMask en `.env`.
2. `ETHERSCAN_API_KEY` añadida a `.env`.
3. ETH de Sepolia en esa wallet (faucet).
4. `forge script script/Deploy.s.sol --rpc-url sepolia --broadcast --verify`.
5. Verificar el contrato en `https://sepolia.etherscan.io`.
6. Probar añadir el token a MetaMask y enviar una transferencia.
7. (Opcional) Documentar el resultado en este archivo.

---

## 11. Comandos Rápidos

```bash
# Compilar
forge build

# Tests
forge test            # resumen
forge test -vvv       # trazas
forge test --fuzz-runs 10000

# Nodo local
anvil

# Deploy Anvil
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast

# Deploy Sepolia (cuando .env esté listo)
forge script script/Deploy.s.sol --rpc-url sepolia --broadcast --verify

# Cast: lectura
cast call <ADDR> "name()(string)" --rpc-url sepolia
cast call <ADDR> "balanceOf(address)(uint256)" <WALLET> --rpc-url sepolia

# Cast: envío
cast send <ADDR> "transfer(address,uint256)" <TO> <AMOUNT> --rpc-url sepolia --private-key $PRIVATE_KEY

# Utilidades
forge fmt
forge clean
```
