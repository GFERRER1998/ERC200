# MyToken (MTK) — ERC-20 Token

Token ERC-20 completo desplegado en **Sepolia testnet** usando **Foundry** y **OpenZeppelin v5**.

## Características

- **ERC-20** — Estándar de tokens fungibles
- **Burnable** — Cualquier holder puede quemar sus tokens
- **Pausable** — Switch de emergencia para pausar transferencias
- **Permit** — Aprobaciones sin gas vía firmas EIP-2612
- **ReentrancyGuard** — Protección contra ataques de reentrancia
- **Ownable** — Control de acceso para funciones críticas

## Contrato Desplegado (Sepolia)

| Campo | Valor |
|-------|-------|
| Dirección | [`0xba8eE7106c788A8981Fd0E7A39956B605Db47ca7`](https://sepolia.etherscan.io/address/0xba8eE7106c788A8981Fd0E7A39956B605Db47ca7) |
| Red | Sepolia (Chain ID: 11155111) |
| Supply | 1,000,000 MTK |
| Decimales | 18 |
| Verificado | Etherscan ✅ |

## Instalación

```bash
# Clonar el repositorio
git clone https://github.com/TU_USUARIO/ERC200.git
cd ERC200

# Instalar dependencias
forge install

# Compilar
forge build

# Ejecutar tests
forge test
```

## Configuración

```bash
# Copiar plantilla de variables de entorno
cp .env.example .env

# Editar .env con tus credenciales
# - SEPOLIA_RPC_URL: URL de Alchemy o Infura
# - PRIVATE_KEY: Llave privada del wallet de despliegue
# - ETHERSCAN_API_KEY: API key de Etherscan
```

## Funciones del Contrato

### Públicas (solo owner)
- `mint(address to, uint256 amount)` — Acunar nuevos tokens
- `pause()` — Pausar transferencias
- `unpause()` — Reanudar transferencias

### Públicas (cualquiera)
- `transfer(address to, uint256 value)` — Enviar tokens
- `approve(address spender, uint256 value)` — Aprobar gasto
- `burn(uint256 value)` — Quemar propios tokens
- `permit(...)` — Aprobación vía firma EIP-2612

### Lectura
- `name()`, `symbol()`, `decimals()`
- `totalSupply()`, `balanceOf(address)`
- `allowance(address, address)`

## Despliegue

```bash
# Desplegar en Sepolia
forge create src/MyToken.sol:MyToken \
  --rpc-url sepolia \
  --broadcast --verify \
  --constructor-args "MyToken" "MTK" 1000000000000000000000000
```

## Tests

```bash
# Ejecutar todos los tests
forge test

# Con verbose
forge test -vvv

# Reporte de gas
forge test --gas-report

# Fuzz testing
forge test --fuzz-runs 10000
```

## Seguridad

- ⚠️ **NUNCA** commitear el archivo `.env` (contiene llaves privadas)
- ✅ `.gitignore` excluye `.env`, `out/`, `cache/`, `broadcast/`
- ✅ Usar wallet dedicada para despliegues (no la principal de MetaMask)
- ✅ Rotar llaves privadas después de compartirlas

## Licencia

MIT
