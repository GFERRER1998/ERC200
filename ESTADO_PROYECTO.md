# Estado Actual del Proyecto ERC-20

## Estructura del Proyecto

```
ERC200/
├── foundry.toml           # Configuracion de Foundry
├── foundry/               # Binarios de Foundry (forge, cast, anvil, chisel)
├── lib/                   # Librerias externas (git submodules)
│   ├── forge-std/         # Biblioteca estandar de Foundry
│   └── openzeppelin-contracts/  # Contratos auditados de OpenZeppelin v5
├── src/                   # Contratos fuente
│   ├── Counter.sol        # Contrato de ejemplo (generado por forge init)
│   └── MyToken.sol        # Token ERC-20 personalizado
├── test/                  # Tests
│   └── Counter.t.sol      # Tests del contrato Counter
├── script/                # Scripts de despliegue
│   └── Counter.s.sol      # Script para desplegar Counter
├── PLAN.md                # Plan de desarrollo del proyecto
├── README.md              # Documentacion de Foundry
└── INSTALLED_PROGRAMS.md  # Documentacion de programas instalados
```

---

## Herramientas Instaladas y Funcionando

| Herramienta | Version | Estado | Funcion |
|---|---|---|---|
| forge | 1.8.0 | OK | Compilar, testear y desplegar contratos |
| cast | 1.8.0 | OK | Interactuar con contratos via CLI |
| anvil | 1.8.0 | OK | Nodo Ethereum local para testing |
| chisel | 1.8.0 | OK | REPL para Solidity |
| solc | 0.8.28 | OK | Compilador Solidity (gestionado por forge) |

---

## Contratos Existentes

### 1. Counter.sol (Ejemplo)

**Proposito**: Contrato de ejemplo generado automaticamente por `forge init`.

**Funciones**:
- `setNumber(uint256 newNumber)` - Establece el valor del contador
- `increment()` - Incrementa el contador en 1
- `number()` - Getter a  |utomatico que lee el valor actual

**Estado**: Compila y pasa tests.

### 2. MyToken.sol (Token ERC-20)

**Proposito**: Token ERC-20 minimo basado en OpenZeppelin v5.

**Funciones heredadas de ERC20**:
- `name()` - Nombre del token: "MyToken"
- `symbol()` - Simbolo del token: "MTK"
- `decimals()` - Decimales: 18 (estandar)
- `totalSupply()` - Suministro total actual
- `balanceOf(address)` - Balance de una direccion
- `transfer(address, uint256)` - Enviar tokens
- `approve(address, uint256)` - Aprobar gasto de terceros
- `allowance(address, address)` - Consultar aprobacion
- `transferFrom(address, address, uint256)` - Transferir usando aprobacion

**Funciones heredadas de Ownable**:
- `owner()` -Direccion del propietario actual
- `transferOwnership(address)` - Transferir propiedad
- `renounceOwnership()` - Renunciar a la propiedad

**Funciones propias**:
- `mint(address to, uint256 amount)` - Acunar nuevos tokens (solo owner)

**Estado**: Compila correctamente. **Sin tests ni script de despliegue aun.**

---

## Tests

### Counter.t.sol

| Test | Tipo | Descripcion | Estado |
|---|---|---|---|
| `test_Increment()` | Unitario | Verifica que increment() suma 1 | PASS |
| `testFuzz_SetNumber(uint256)` | Fuzzing | Verifica setNumber() con 256 valores aleatorios | PASS |

**Total**: 2 tests, 0 fallos

### MyToken

**Sin tests creados aun.**

---

## Que Se Logra Hasta Ahora

### Completado

- Entorno de desarrollo Foundry instalado y funcionando
- Proyecto inicializado con `forge init`
- OpenZeppelin v5 instalado como dependencia
- Counter.sol: contrato de ejemplo compilado y testeado
- MyToken.sol: contrato ERC-20 compilado correctamente
- Remappings configurados para imports de OpenZeppelin y forge-std
- Documentacion creada (INSTALLED_PROGRAMS.md, PLAN.md)

### Pendiente

- [ ] Crear tests para MyToken (test/MyToken.t.sol)
- [ ] Crear script de despliegue para MyToken (script/Deploy.s.sol)
- [ ] Configurar `.env` con RPC URL y llave privada
- [ ] Obtener ETH de Sepolia via faucet
- [ ] Desplegar MyToken en Sepolia testnet
- [ ] Verificar contrato en Etherscan
- [ ] Agregar funcionalidades opcionales (Burnable, Pausable, Permit, Votes)

---

## Comandos Disponibles

```bash
# Compilar todos los contratos
forge build

# Ejecutar todos los tests
forge test

# Ejecutar tests con verbosidad (ver detalles)
forge test -vvv

# Ejecutar tests solo de un archivo
forge test --match-path test/Counter.t.sol

# Iniciar nodo local (Terminal separada)
anvil

# Desplegar en nodo local
forge script script/Counter.s.sol --rpc-url http://localhost:8545 --broadcast

# Desplegar en Sepolia (requiere .env configurado)
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast

# Consultar balance de un contrato
cast balance <DIRECCION_CONTRATO> --rpc-url <RPC_URL>

# Formatear codigo Solidity
forge fmt
```

---

## Arquitectura Actual

```
┌─────────────────────────────────────────────┐
│              foundry.toml                    │
│  (Config: solc 0.8.28, remappings, paths)   │
└─────────────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
   ┌─────────┐  ┌──────────┐  ┌──────────┐
   │  src/   │  │  test/   │  │ script/  │
   │         │  │          │  │          │
   │Counter  │  │Counter.t │  │Counter.s │
   │MyToken  │  │          │  │          │
   └────┬────┘  └────┬─────┘  └────┬─────┘
        │             │             │
        └─────────────┼─────────────┘
                      ▼
            ┌──────────────────┐
            │      lib/        │
            │  forge-std       │
            │  openzeppelin    │
            └──────────────────┘
```
