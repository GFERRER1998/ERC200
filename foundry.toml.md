# Documentacion: foundry.toml

## Proposito

Archivo de configuracion principal de Foundry. Define como se compilan los contratos, que librerias se usan, y como conectar a redes Ethereum.

---

## Estructura del Archivo

```
foundry.toml
├── [profile.default]    # Configuracion principal de compilacion
│   ├── src              # Directorio de contratos fuente
│   ├── out              # Directorio de artefactos compilados
│   ├── libs             # Directorios de librerias
│   ├── solc_version     # Version del compilador
│   ├── remappings       # Mapeo de imports
│   ├── optimizer        # Activa optimizador
│   ├── optimizer_runs   # Runs de optimizacion
│   └── via_ir           # Compilador IR
├── [rpc_endpoints]      # URLs de redes Ethereum
└── [etherscan]          # Configuracion de verificacion
```

---

## Seccion: [profile.default]

### src

```toml
src = "src"
```

- **Que hace**: Define el directorio donde estan los contratos fuente
- **Default**: `src`
- **Uso**: `forge build` compila todos los `.sol` de esta carpeta

### out

```toml
out = "out"
```

- **Que hace**: Define donde se guardan los artefactos compilados (ABI, bytecode)
- **Default**: `out`
- **Uso**: Se crea automaticamente al ejecutar `forge build`

### libs

```toml
libs = ["lib"]
```

- **Que hace**: Define donde buscar librerias externas
- **Default**: `["lib"]`
- **Uso**: Forge busca los contratos importados en estas carpetas

### solc_version

```toml
solc_version = "0.8.28"
```

- **Que hace**: Fija la version del compilador Solidity
- **Default**: La ultima estable
- **Uso**: Forge descarga y gestiona esta version automaticamente

### remappings

```toml
remappings = [
    "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
    "forge-std/=lib/forge-std/src/",
]
```

- **Que hace**: Mapea rutas de importacion a carpetas reales
- **Sin remappings**: `import "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";`
- **Con remappings**: `import "@openzeppelin/contracts/token/ERC20/ERC20.sol";`
- **Uso**: Permite imports limpios y portables

---

## Seccion: Optimizer

### optimizer

```toml
optimizer = true
```

- **Que hace**: Activa el optimizador del compilador Solidity
- **Default**: `false`
- **Efecto**: Reduce el tamano del bytecode y el gas de ejecucion
- **Trade-off**: Incrementa ligeramente el tiempo de compilacion

### optimizer_runs

```toml
optimizer_runs = 200
```

- **Que hace**: Indica cuantas veces se espera que cada funcion sea llamada
- **Default**: `200`
- **Valores recomendados**:
  - `200` - Balance general (tokens, contratos medianos)
  - `10000` - Funciones muy frecuentes (DEX, lending)
  - `1` - Funciones raramente usadas
- **Efecto**:
  - Valor bajo → bytecode pequeno, deployment barato
  - Valor alto → bytecode grande, ejecucion barata

### via_ir

```toml
via_ir = true
```

- **Que hace**: Activa la compilacion via IR (Intermediate Representation)
- **Default**: `false`
- **Que es IR**: Una nueva pipeline de compilacion introducida en Solidity 0.8.13
- **Ventajas**:
  - Optimizaciones mas agresivas
  - Menor gas de ejecucion
  - Mejor manejo de memoria
- **Desventajas**:
  - Tiempo de compilacion mas lento
  - Debug mas dificil
- **Recomendado**: `true` para contratos en produccion

---

## Seccion: [rpc_endpoints]

```toml
[rpc_endpoints]
sepolia = "${SEPOLIA_RPC_URL}"
```

- **Que hace**: Define aliases para URLs RPC de redes Ethereum
- **Variable de entorno**: `SEPOLIA_RPC_URL` (se define en `.env`)
- **Uso**:
  ```bash
  # En lugar de:
  forge script ... --rpc-url https://eth-sepolia.g.alchemy.com/v2/abc123
  
  # Puedes usar:
  forge script ... --rpc-url sepolia
  ```
- **Redes comunes**: sepolia, holesky, mainnet, localhost

---

## Seccion: [etherscan]

```toml
[etherscan]
sepolia = { key = "${ETHERSCAN_API_KEY}", url = "https://api-sepolia.etherscan.io/api" }
```

- **Que hace**: Configura la verificacion de contratos en Etherscan
- **Variable de entorno**: `ETHERSCAN_API_KEY` (se define en `.env`)
- **Uso**:
  ```bash
  # Verificar un contrato
  forge verify-contract <direccion> src/MyToken.sol:MyToken --chain sepolia
  
  # O durante el despliegue
  forge script ... --verify
  ```
- **Beneficio**: Muestra el codigo fuente publicamente en Etherscan

---

## Ejemplo de Uso Completo

### Compilar con optimizer
```bash
forge build
```

### Desplegar en Sepolia
```bash
forge script script/Deploy.s.sol --rpc-url sepolia --broadcast --verify
```

### Verificar un contrato
```bash
forge verify-contract 0x1234...abcd src/MyToken.sol:MyToken --chain sepolia
```

### Iniciar nodo local
```bash
anvil
# Luego en otra terminal:
forge script script/Deploy.s.sol --rpc-url localhost --broadcast
```

---

## Errores Comunes de Configuracion

| Error | Causa | Solucion |
|---|---|---|
| `Solc version not found` | solc_version invalida | Usar una version existente (0.8.28) |
| `Remapping not found` | Import no mapeado | Agregar remapping en foundry.toml |
| `RPC URL not set` | Variable de entorno vacia | Definir en `.env` |
| `Compilation timeout` | via_ir en proyecto grande | Desactivar via_ir o esperar |
| `Optimizer error` | Configuracion invalida | Verificar optimizer_runs > 0 |

---

## Variables de Entorno Requeridas

Para que foundry.toml funcione completamente, define en `.env`:

```env
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/TU_API_KEY
ETHERSCAN_API_KEY=tu_api_key_de_etherscan
```

**Nunca commitear el archivo `.env` a git.**
