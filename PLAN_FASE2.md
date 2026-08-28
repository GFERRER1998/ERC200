# Plan Fase 2: Actualizar foundry.toml

## Archivos a crear/modificar

| # | Archivo | Accion |
|---|---|---|
| 1 | `foundry.toml` | Modificar (agregar optimizer, RPC, etherscan) |
| 2 | `foundry.toml.md` | Crear (documentacion del archivo) |

---

## Paso 1: Agregar optimizer al `[profile.default]`

| Linea nueva | Valor | Que hace |
|---|---|---|
| `optimizer = true` | true | Activa el optimizador del compilador |
| `optimizer_runs = 200` | 200 | Numero de runs de optimizacion |

**Por que optimizer:**
- `optimizer = true` le dice a solc que optimice el bytecode generado
- `optimizer_runs = 200` indica cuantas veces se espera que cada funcion sea llamada
- Valor bajo (200) = bytecode mas pequeno, deployment mas barato
- 200 es el balance recomendado para tokens

---

## Paso 2: Agregar `via_ir = true`

| Linea nueva | Valor | Que hace |
|---|---|---|
| `via_ir = true` | true | Usa el compilador IR (Intermediate Representation) |

**Por que via_ir:**
- Activa la nueva pipeline de compilacion IR de Solidity
- Permite optimizaciones mas agresivas
- Reduce el gas de ejecucion
- Recomendado para contratos en produccion

---

## Paso 3: Agregar `[rpc_endpoints]`

```toml
[rpc_endpoints]
sepolia = "${SEPOLIA_RPC_URL}"
```

**Por que rpc_endpoints:**
- Permite usar `--rpc-url sepolia` en lugar de escribir la URL completa
- Lee la URL de la variable de entorno `SEPOLIA_RPC_URL`
- Se usa con: `forge script ... --rpc-url sepolia`

---

## Paso 4: Agregar `[etherscan]`

```toml
[etherscan]
sepolia = { key = "${ETHERSCAN_API_KEY}", url = "https://api-sepolia.etherscan.io/api" }
```

**Por que etherscan:**
- Permite verificar contratos automaticamente con `forge verify-contract`
- Lee la API key de la variable de entorno `ETHERSCAN_API_KEY`
- Se usa con: `forge script ... --verify`

---

## Paso 5: Crear `foundry.toml.md`

Contenido del .md:
- Proposito del archivo
- Tabla de cada seccion con su funcion
- Explicacion de cada linea nueva
- Que es optimizer y via_ir
- Que son rpc_endpoints y etherscan
- Ejemplo de como se usa cada opcion

---

## Paso 6: `forge build`

Verificar que optimizer y via_ir no rompen nada.

---

## Paso 7: `forge test`

Verificar que los tests siguen pasando.

---

## Orden de Ejecucion

```
Paso 1 → Paso 2 → Paso 3 → Paso 4 → Paso 5 → Paso 6 → Paso 7
```
