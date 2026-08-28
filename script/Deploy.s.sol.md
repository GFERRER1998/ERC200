# Documentacion: script/Deploy.s.sol

## Proposito

Script de despliegue para el contrato MyToken. Lee las variables de entorno del archivo `.env` y despliega el token en la red configurada.

---

## Imports

| Import | De donde viene | Para que sirve |
|---|---|---|
| `Script` | `forge-std/Script.sol` | Framework de scripts: vm.startBroadcast, vm.envUint, etc. |
| `console` | `forge-std/console.sol` | Imprimir valores en consola (console.log) |
| `MyToken` | `../src/MyToken.sol` | El contrato a desplegar |

---

## Funciones

### run()

Funcion principal del script. Ejecuta el despliegue completo:

1. **Lee PRIVATE_KEY** del `.env` - Usa `vm.envUint("PRIVATE_KEY")`
2. **Lee INITIAL_SUPPLY** del `.env` - Usa `vm.envUint("INITIAL_SUPPLY")`
3. **Inicia broadcast** - `vm.startBroadcast(deployerPrivateKey)`
4. **Despliega MyToken** - `new MyToken("MyToken", "MTK", initialSupply)`
5. **Detiene broadcast** - `vm.stopBroadcast()`
6. **Imprime resultados** - `console.log` con direccion, supply y owner

---

## Variables de Entorno Requeridas

| Variable | Tipo | Descripcion |
|---|---|---|
| `PRIVATE_KEY` | uint256 | Llave privada del deployer (sin 0x) |
| `INITIAL_SUPPLY` | uint256 | Supply inicial en unidades base (18 dec) |

---

## Funciones de Foundry Utilizadas

### vm.envUint("VAR")
Lee una variable de entorno del archivo `.env` y la retorna como `uint256`.

### vm.startBroadcast(key)
Marca el inicio de transacciones que seran firmadas con `key`.
Todo lo que se ejecute despues sera una transaccion real (con --broadcast).

### vm.stopBroadcast()
Marca el fin de las transacciones. No se envian mas transacciones despues.

### console.log()
Imprime valores en la consola. Util para depuracion y ver resultados.

---

## Ejecucion

### Local (simulacion sin gas)
```bash
forge script script/Deploy.s.sol --rpc-url http://localhost:8545
```

### Local con Anvil (transaccion real en nodo local)
```bash
# Terminal 1: Iniciar Anvil
anvil

# Terminal 2: Ejecutar script
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
```

### Sepolia (transaccion real en testnet)
```bash
forge script script/Deploy.s.sol --rpc-url sepolia --broadcast --verify
```

---

## Errores Comunes

| Error | Causa | Solucion |
|---|---|---|
| `PRIVATE_KEY not set` | No existe .env o variable no definida | Crear .env con PRIVATE_KEY |
| `INITIAL_SUPPLY not set` | Variable no definida en .env | Agregar INITIAL_SUPPLY al .env |
| `insufficient funds` | Wallet sin ETH para gas | Obtener ETH de faucet |
| `nonce too high` |Nonce desactualizado | Reiniciar nodo o esperar |

---

## Resultado Esperado

Al ejecutar correctamente, la consola muestra:

```
Script ran successfully.
MyToken desplegado en: 0x1234...abcd
Supply inicial: 1000000000000000000000000
Owner: 0x5678...ef01
```
