# Plan de Continuidad — Proyecto ERC-200

## Resumen de Decisiones
- **Token**: Completo (Mint + Burn + Pausable + Permit + ReentrancyGuard)
- **Despliegue**: Local (Anvil) + Sepolia testnet
- **Nombre**: MyToken / MTK
- **Objetivo**: Learning, preparado para producción futura

---

## Estado Actual

| Fase | Descripción | Estado |
|------|-------------|--------|
| 1 | MyToken.sol (contrato completo) | ✅ Completada |
| 2 | foundry.toml (configuración) | ✅ Completada |
| 3 | Tests (13/13 pasando) | ✅ Completada |
| 4 | Script de despliegue | ✅ Completada |
| 5 | .env.example | ✅ Completada |
| 6 | .gitignore | ✅ Completada |
| 7 | Testing local (Anvil) | ✅ Completada |
| 8 | Configurar Sepolia | ❌ Pendiente |
| 9 | Desplegar en Sepolia | ❌ Pendiente |
| 10 | Verificación y prueba final | ❌ Pendiente |
| 11 | Análisis de gas | ❌ Pendiente |
| 12 | Testing avanzado | ❌ Pendiente |
| 13 | Documentación de producción | ❌ Pendiente |
| 14 | Análisis de seguridad (Slither) | ❌ Pendiente |
| 15 | README personalizado | ❌ Pendiente |
| 16 | Checklist de producción | ❌ Pendiente |

---

## Fase 8: Configurar Sepolia

**Objetivo**: Preparar todas las variables de entorno para desplegar en Sepolia testnet.

### Pasos

#### 8.1 Obtener API Key de Alchemy (ya configurada)
- Tu URL de Alchemy ya está en `.env`: `SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/TU_API_KEY`
- Si necesitas una nueva API key, ve a https://dashboard.alchemy.com/

#### 8.2 Crear wallet MetaMask
1. Instalar MetaMask extension en tu navegador
2. Crear una nueva wallet o importar existente
3. Ir a **Settings > Advanced > Account Details > Show Private Key**
4. Copiar la llave privada (sin `0x`)
5. **NUNCA commitear esta llave a git**

#### 8.3 Obtener ETH de Sepolia
Opciones de faucet:
- **Alchemy Faucet**: https://sepoliafaucet.com (requiere cuenta Alchemy)
- **Google Cloud Faucet**: https://cloud.google.com/application/web3/faucet/ethereum/sepolia
- **QuickNode Faucet**: https://faucet.quicknode.com/ethereum/sepolia
- **PoW Faucet**: https://sepolia-faucet.pk910.de (minería PoW)

Necesitas al menos **0.01 ETH** de Sepolia para cubrir gas de despliegue.

#### 8.4 Actualizar `.env`
Agregar las credenciales reales:

```env
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/TU_API_KEY
PRIVATE_KEY=tu_llave_privada_de_metamask_sin_0x
ETHERSCAN_API_KEY=tu_api_key_de_etherscan
INITIAL_SUPPLY=1000000000000000000000000
```

#### 8.5 Verificar conexión
1. Abrir MetaMask
2. Cambiar a red **Sepolia testnet**
3. Verificar que aparece el balance de ETH

### Archivos a modificar
| Archivo | Cambio |
|---------|--------|
| `.env` | Reemplazar `PRIVATE_KEY` placeholder con llave real |
| `.env` | Agregar `ETHERSCAN_API_KEY` |

### Verificación
```bash
# Verificar que .env tiene valores reales
cat .env

# Verificar que forge puede leer las variables
forge script script/Deploy.s.sol --rpc-url sepolia
```

---

## Fase 9: Desplegar en Sepolia

**Objetivo**: Desplegar MyToken en la testnet Sepolia y verificarlo en Etherscan.

### Comando de despliegue
```bash
forge script script/Deploy.s.sol --rpc-url sepolia --broadcast --verify -vvvv
```

### Qué hace este comando
1. Compila el contrato con optimizador
2. Simula el despliegue
3. Despliega en Sepolia (requiere PRIVATE_KEY real + ETH)
4. Verifica automáticamente en Etherscan (requiere ETHERSCAN_API_KEY)
5. Imprime la dirección del contrato desplegado

### Después del despliegue
1. Copiar la dirección del contrato desplegado
2. Buscar en https://sepolia.etherscan.io/
3. Verificar que el contrato está verificado (código fuente visible)
4. Guardar la dirección para uso futuro

### Archivos generados
- `broadcast/Deploy.s.sol/11155111/run-latest.json` (logs del despliegue)

---

## Fase 10: Verificación y Prueba Final

**Objetivo**: Confirmar que el token funciona correctamente en Sepolia.

### Pasos

#### 10.1 Verificar en Etherscan
1. Ir a `https://sepolia.etherscan.io/address/TU_DIRECCION`
2. Pestaña **Contract > Read/Write Contract**
3. Verificar funciones: `name()`, `symbol()`, `decimals()`, `totalSupply()`

#### 10.2 Probar con Cast
```bash
# Leer nombre
cast call <DIRECCION> "name()(string)" --rpc-url sepolia

# Leer balance
cast call <DIRECCION> "balanceOf(address)(uint256)" <TU_WALLET> --rpc-url sepolia

# Transferir (necesita PRIVATE_KEY)
cast send <DIRECCION> "transfer(address,uint256)" <DESTINATARIO> 1000000000000000000 --rpc-url sepolia --private-key $PRIVATE_KEY
```

#### 10.3 Agregar token a MetaMask
1. Abrir MetaMask
2. **Assets > Import tokens > Custom token**
3. Pegar la dirección del contrato
4. Symbol: `MTK`
5. Decimals: `18`
6. Confirmar importación

#### 10.4 Probar transferencia
1. Enviar una pequeña cantidad de MTK desde MetaMask
2. Verificar que el balance se actualiza
3. Verificar la transacción en Etherscan

---

## Fase 11: Análisis de Gas

**Objetivo**: Identificar costos de gas y oportunidades de optimización.

### Comandos
```bash
# Reporte de gas completo
forge test --gas-report

# Gas específico por test
forge test --gas-report --match-test test_Transfer

# Comparar con y sin optimizador
forge test --gas-report --no-match-path ".*"
```

### Métricas a documentar
| Función | Gas Estimado | Gas Real | Notas |
|---------|--------------|----------|-------|
| `transfer()` | ~50,000 | - | Transferencia estándar |
| `mint()` | ~60,000 | - | Con nonReentrant |
| `burn()` | ~30,000 | - | Quema de tokens |
| `approve()` | ~45,000 | - | Aprobación |
| Deployment | ~2,000,000 | - | Costo total de despliegue |

### Optimizaciones aplicadas
- `optimizer = true` con 200 runs (ya configurado)
- `via_ir = true` para mejor optimización (ya configurado)

---

## Fase 12: Testing Avanzado

**Objetivo**: Cubrir edge cases y propiedades invariantes del token.

### 12.1 Fuzz Tests
```solidity
function testFuzz_Transfer(uint256 amount) public {
    vm.assume(amount > 0 && amount <= token.balanceOf(address(this)));
    token.transfer(alice, amount);
    assertEq(token.balanceOf(alice), amount);
}
```

### 12.2 Invariant Tests
```solidity
function invariant_TotalSupplyNeverExceedsMax() public {
    assertLe(token.totalSupply(), type(uint256).max);
}

function invariant_BalancesSumToTotalSupply() public {
    // Verificar que la suma de balances == totalSupply
}
```

### 12.3 Edge Cases
- Transferir `0` tokens
- Transferir `type(uint256).max`
- Mint `0` tokens
- Burn más de lo que se tiene
- Aprobar `type(uint256).max` (infinite allowance)
- Operaciones con `address(0)`

### 12.4 Tests de Rendimiento
```bash
# Fuzz testing con muchas iteraciones
forge test --fuzz-runs 10000

# Invariant testing
forge test --match-contract InvariantTest --fuzz-runs 1000
```

---

## Fase 13: Documentación de Producción

**Objetivo**: Crear documentación profesional para futuros proyectos.

### Archivos a crear

#### `SECURITY.md`
```markdown
# Security Policy

## Reporting Vulnerabilities
- Email: security@tu-dominio.com
- Bounty: [detalles]

## Audited By
- Auditor: Pendiente
- Date: Pendiente
- Report: [link]

## Known Limitations
- Owner tiene control total sobre mint y pause
- No hay timelock para operaciones criticas
```

#### `CHANGELOG.md`
```markdown
# Changelog

## [1.0.0] - 2026-08-28
### Added
- ERC-20 token con burn, pause, permit
- ReentrancyGuard en mint
- Tests unitarios (13/13)
- Despliegue en Sepolia
```

---

## Fase 14: Análisis de Seguridad (Slither)

**Objetivo**: Ejecutar análisis estático para identificar vulnerabilidades.

### Instalación
```bash
pip install slither-analyzer
```

### Ejecución
```bash
# Análisis completo
slither src/MyToken.sol

# Solo detector de altas y medias
slither src/MyToken.sol --filter-output low

# Exportar reporte
slither src/MyToken.sol --json report.json
```

### Detectores a revisar
- `reentrancy-eth`
- `arbitrary-send`
- `suicidal`
- `uninitialized-state`
- `locked-ether`

### Archivo de resultados
Crear `SECURITY_AUDIT.md` con:
- Hallazgos encontrados
- Severidad de cada hallazgo
- Acciones tomadas
- Estado de resolución

---

## Fase 15: README Personalizado

**Objetivo**: Reemplazar el README estándar de Foundry con documentación específica del proyecto.

### Estructura del README
```markdown
# MyToken (MTK)

Token ERC-20 completo con funcionalidades de producción.

## Características
- ✅ ERC-20 estándar
- ✅ Burn (quemar tokens)
- ✅ Pausable (emergencia)
- ✅ Permit (EIP-2612, aprobaciones sin gas)
- ✅ ReentrancyGuard (protección contra reentrancia)
- ✅ Ownable (control de acceso)

## Instalación
[Instrucciones de fork/clone]

## Configuración
[Instrucciones de .env]

## Despliegue
[Comandos de despliegue]

## Testing
[Comandos de testing]

## Contrato Verificado
- Sepolia: [link a Etherscan]
- Address: [dirección]

## Licencia
MIT
```

---

## Fase 16: Checklist de Producción

**Objetivo**: Template reutilizable para futuros proyectos de tokens.

### Pre-Despliegue
- [ ] Contrato compilado sin errores (`forge build`)
- [ ] Todos los tests pasando (`forge test`)
- [ ] Gas report generado (`forge test --gas-report`)
- [ ] Slither sin hallazgos críticos (`slither src/`)
- [ ] Documentación completa (README, SECURITY, CHANGELOG)
- [ ] .env.example actualizado
- [ ] .gitignore excluye archivos sensibles

### Despliegue
- [ ] Testnet deployment exitoso
- [ ] Contrato verificado en Etherscan
- [ ] Funciones básicas probadas (transfer, approve, burn)
- [ ] Token agregado a MetaMask
- [ ] Dirección del contrato documentada

### Post-Despliegue
- [ ] Monitoreo de transacciones
- [ ] Alertas configuradas (opcional)
- [ ] Timelock para operaciones críticas (opcional)
- [ ] Multi-sig wallet para owner (recomendado)
- [ ] Bug bounty program (opcional)

---

## Comandos Rápidos

```bash
# Compilar
forge build

# Tests
forge test
forge test -vvv
forge test --gas-report
forge test --fuzz-runs 10000

# Deploy local
anvil
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast

# Deploy Sepolia
forge script script/Deploy.s.sol --rpc-url sepolia --broadcast --verify

# Cast
cast call <ADDR> "name()(string)" --rpc-url sepolia
cast call <ADDR> "balanceOf(address)(uint256)" <WALLET> --rpc-url sepolia
cast send <ADDR> "transfer(address,uint256)" <TO> <AMOUNT> --rpc-url sepolia --private-key $PRIVATE_KEY

# Seguridad
slither src/MyToken.sol

# Utilidades
forge fmt
forge clean
```

---

## Referencias

- [Foundry Book](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts v5](https://docs.openzeppelin.com/contracts/5.x/)
- [EIP-20: ERC-20 Token Standard](https://eips.ethereum.org/EIPS/eip-20)
- [EIP-2612: Permit Extension](https://eips.ethereum.org/EIPS/eip-2612)
- [Etherscan Sepolia](https://sepolia.etherscan.io/)
- [Slither Documentation](https://github.com/crytic/slither)
