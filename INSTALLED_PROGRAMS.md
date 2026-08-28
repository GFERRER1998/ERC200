# Programas Instalados - Stack ERC-20

## Herramientas Foundry (v1.8.0)

Ubicacion: `foundry/bin/`

| Programa | Version | Descripcion |
|----------|---------|-------------|
| **forge** | 1.8.0 | Framework de testing y compilacion para Ethereum. Equivalente a Hardhat/Truffle. Ejecuta tests, compila contratos, genera snapshots de gas y despliega scripts. |
| **cast** | 1.8.0 | Herramienta CLI para interactuar con contratos inteligentes. Permite enviar transacciones, leer estado, verificar funciones y ejecutar llamadas RPC. |
| **anvil** | 1.8.0 | Nodo Ethereum local para testing. Equivalente a Ganache/Hardhat Network. Permite desplegar y probar contratos sin gastar ETH real. |
| **chisel** | 1.8.0 | REPL (Read-Eval-Print Loop) para Solidity. Permite escribir y ejecutar fragmentos de codigo Solidity en tiempo real para pruebas rapidas. |
| **solar** | 1.8.0 | Compilador Solidity de alto rendimiento. Usado internamente por forge para compilaciones optimizadas. |

## Librerias (lib/)

| Libreria | Uso |
|----------|-----|
| **forge-std** | Biblioteca estandar de Foundry. Proporciona helpers para tests (`Test.sol`, `console.sol`), utilidades de scripting y funciones de cheatcodes. |
| **openzeppelin-contracts** | Contratos Solidity auditos y reutilizables. Incluye implementaciones de ERC20, ERC721, Ownable, AccessControl, ReentrancyGuard, etc. |

## Compilador Solidity

| Componente | Version | Descripcion |
|------------|---------|-------------|
| **solc** | 0.8.28 | Compilador oficial de Solidity. Gestionado automaticamente por forge. Compila codigo Solidity a bytecode EVM. |

## Configuracion del Proyecto (foundry.toml)

- **Solc version**: 0.8.28
- **Source**: `src/`
- **Output**: `out/`
- **Librerias**: `lib/`
- **Remappings**: OpenZeppelin y forge-std configurados

## Comandos Utiles

```bash
# Compilar contratos
forge build

# Ejecutar tests
forge test

# Ejecutar tests con verbosidad
forge test -vvv

# Iniciar nodo local
anvil

# Desplegar en nodo local
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast

# Interactuar con contratos
cast call <CONTRACT> "balanceOf(address)(uint256)" <WALLET> --rpc-url <RPC_URL>

# Verificar gas
forge snapshot

# Formatear codigo
forge fmt
```
