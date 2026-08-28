# Plan Fase 4: Crear script de despliegue

## Archivos a crear

| # | Archivo | Accion |
|---|---|---|
| 1 | `script/Deploy.s.sol` | Crear (script de despliegue) |
| 2 | `script/Deploy.s.sol.md` | Crear (documentacion) |
| 3 | `.env.example` | Crear (plantilla de variables) |

---

## Pasos

### Paso 1: Crear script/Deploy.s.sol

- Importar Script de forge-std
- Importar MyToken de src/
- Leer PRIVATE_KEY e INITIAL_SUPPLY de .env
- Desplegar MyToken con vm.startBroadcast/stopBroadcast
- Imprimir direccion con console.log

### Paso 2: Crear .env.example

Plantilla con SEPOLIA_RPC_URL, PRIVATE_KEY, ETHERSCAN_API_KEY, INITIAL_SUPPLY.

### Paso 3: Crear script/Deploy.s.sol.md

Documentacion completa del script.

### Paso 4: forge build

Verificar compilacion.

### Paso 5: Test en Anvil

Probar despliegue local con anvil.

---

## Orden

```
Paso 1 → Paso 2 → Paso 3 → Paso 4 → Paso 5
```
