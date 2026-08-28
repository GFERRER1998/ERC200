# Plan de Continuacion - Proyecto ERC-20

## Resumen de Decisiones
- **Token**: Completo (Mint + Burn + Pausable + Permit + ReentrancyGuard)
- **Despliegue**: Local (Anvil) + Sepolia testnet
- **Nombre**: MyToken / MTK

---

## Fase 1: Actualizar MyToken.sol con funcionalidades completas

**Archivo**: `src/MyToken.sol`

Cambios necesarios:
- Agregar import de `ERC20Burnable` (quemar tokens)
- Agregar import de `ERC20Pausable` (pausar transferencias)
- Agregar import de `ERC20Permit` (aprobaciones sin gas via firmas EIP-2612)
- Agregar import de `ReentrancyGuard` (proteccion contra reentrancia en mint)
- Agregar import de `Pausable` (control de pausa)
- Agregar constructor con `name_`, `symbol_`, `initialSupply_` para acunar tokens iniciales
- Modificar `mint` para incluir `nonReentrant`
- Agregar funcion `pause()` y `unpause()` con `onlyOwner`
- Agregar funcion `burn()` para que cualquier holder queme sus tokens

Resultado:
```
MyToken is ERC20, ERC20Burnable, ERC20Pausable, ERC20Permit, Ownable, ReentrancyGuard
```

---

## Fase 2: Actualizar foundry.toml

**Archivo**: `foundry.toml`

Cambios:
- Agregar `[rpc_endpoints]` con Sepolia RPC
- Agregar `[etherscan]` para verificacion
- Agregar `optimizer = true` y `optimizer_runs = 200` (compilacion optimizada)
- Agregar `via_ir = true` (compilador IR para mejor optimizacion)

---

## Fase 3: Crear tests para MyToken

**Archivo**: `test/MyToken.t.sol` (nuevo)

Tests a crear:

| Test | Que verifica |
|---|---|
| `test_NameAndSymbol` | Nombre es "MyToken", simbolo es "MTK" |
| `test_InitialSupply` | Supply inicial se acuna al deployer |
| `test_Mint` | Owner puede acunar tokens |
| `test_MintRevertNonOwner` | No-owner no puede acunar (revert) |
| `test_Transfer` | Transferencia entre cuentas funciona |
| `test_TransferFrom` | Aprobacion + transferFrom funciona |
| `test_Approve` | Allowance se actualiza correctamente |
| `test_Burn` | Holder puede quemar sus tokens |
| `test_BurnReducesSupply` | Burn reduce totalSupply |
| `test_Pause` | Owner puede pausar |
| `test_PauseRevertTransfer` | Transfer falla cuando esta pausado |
| `test_Unpause` | Owner puede despausar |
| `test_TransferRevertZeroAddress` | No se puede transferir a address(0) |

---

## Fase 4: Crear script de despliegue

**Archivo**: `script/Deploy.s.sol` (nuevo, reemplaza Counter.s.sol)

Funcionalidad:
- Leer `PRIVATE_KEY` del archivo `.env`
- Leer `INITIAL_SUPPLY` del archivo `.env`
- Desplegar MyToken con nombre, symbol y supply iniciales
- Imprimir direccion del contrato desplegado

---

## Fase 5: Crear archivo .env.example

**Archivo**: `.env.example` (nuevo)

Contenido:
```
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/TU_API_KEY
PRIVATE_KEY=tu_llave_privada_sin_0x
ETHERSCAN_API_KEY=tu_api_key_de_etherscan
INITIAL_SUPPLY=1000000000000000000000000
```

---

## Fase 6: Crear .gitignore

**Archivo**: `.gitignore` (nuevo)

Excluir:
- `.env` (nunca commitear llaves privadas)
- `out/` (artefactos compilados)
- `cache/` (cache de forge)
- `foundry/` (binarios descargados)
- `broadcast/` (logs de despliegue)

---

## Fase 7: Testing local con Anvil

Pasos:
1. Ejecutar `forge test -vvv` para verificar todos los tests
2. Ejecutar `anvil` en terminal separada
3. Ejecutar `forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast`
4. Verificar con `cast call <DIRECCION> "name()(string)" --rpc-url http://localhost:8545`
5. Probar transferencia con `cast send`

---

## Fase 8: Configuracion para Sepolia

Pasos (requieren accion del usuario):
1. Crear cuenta en Alchemy y obtener API key de Sepolia
2. Instalar MetaMask y crear wallet
3. Obtener ETH de Sepolia via faucet (Alchemy faucet o Google Cloud faucet)
4. Crear archivo `.env` con las credenciales reales
5. Verificar que MetaMask esta conectado a red Sepolia

---

## Fase 9: Despliegue en Sepolia

Comando:
```bash
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
```

Esto:
- Despliega el contrato en Sepolia
- Verifica automaticamente en Etherscan (si se proporciona ETHERSCAN_API_KEY)

---

## Fase 10: Verificacion y prueba final

Pasos:
1. Buscar contrato en https://sepolia.etherscan.io/
2. Verificar funcionamiento con `cast call` y `cast send`
3. Agregar token a MetaMask usando la direccion del contrato
4. Probar transferencia desde MetaMask

---

## Orden de Ejecucion

```
Fase 1 ──→ Fase 2 ──→ Fase 3 ──→ Fase 4 ──→ Fase 5 ──→ Fase 6
(MyToken)   (config)   (tests)    (deploy)    (.env)     (.gitignore)
                                                         │
                                                         ▼
Fase 7 ──────────────────→ Fase 8 ──→ Fase 9 ──→ Fase 10
(test local Anvil)         (config    (deploy     (verificar
                            Sepolia)   Sepolia)     final)
```

**Tiempo estimado total**: ~45-60 minutos
