# Documentacion: src/MyToken.sol

## Proposito

Token ERC-20 completo construido sobre OpenZeppelin v5. Incluye todas las funcionalidades estandar de un token mas extensiones de seguridad y comodidad.

---

## Imports

| Import | Ruta | Que provee |
|---|---|---|
| `ERC20` | `@openzeppelin/contracts/token/ERC20/ERC20.sol` | Base del token: nombre, simbolo, transfer, approve, balanceOf |
| `ERC20Burnable` | `@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol` | burn(), burnFrom() - quemar tokens |
| `ERC20Pausable` | `@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol` | _update() con whenNotPaused - pausar transferencias |
| `ERC20Permit` | `@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol` | permit(), nonces() - aprobaciones sin gas |
| `Ownable` | `@openzeppelin/contracts/access/Ownable.sol` | owner, onlyOwner, transferOwnership, renounceOwnership |
| `ReentrancyGuard` | `@openzeppelin/contracts/utils/ReentrancyGuard.sol` | nonReentrant - proteccion contra reentrancia |

---

## Diagrama de Herencia

```
                    ┌─────────────┐
                    │   Context   │
                    └──────┬──────┘
                           │
            ┌──────────────┼──────────────┐
            │              │              │
     ┌──────┴──────┐ ┌────┴────┐  ┌──────┴──────┐
     │  Ownable    │ │Pausable │  │ Reentrancy  │
     │             │ │         │  │   Guard     │
     └──────┬──────┘ └────┬────┘  └──────┬──────┘
            │              │              │
            │    ┌─────────┴─────────┐    │
            │    │       ERC20       │    │
            │    │  (base token)     │    │
            │    └─────────┬─────────┘    │
            │         ┌────┼────┐         │
            │         │    │    │         │
            │    ┌────┴──┐ │ ┌──┴────┐    │
            │    │Burnable│ │ │Permit │    │
            │    └────┬──┘ │ └──┬────┘    │
            │         │    │    │         │
            │         │ ┌──┴────┐         │
            │         │ │Pausable│        │
            │         │ │(ERC20) │        │
            │         │ └──┬────┘         │
            │         │    │              │
            └─────────┼────┼──────────────┘
                      │    │
                 ┌────┴────┴────┐
                 │   MyToken    │
                 │  (contract)  │
                 └──────────────┘
```

---

## Constructor

```solidity
constructor(
    string memory name_,
    string memory symbol_,
    uint256 initialSupply_
) ERC20(name_, symbol_) Ownable(msg.sender) ERC20Permit(name_)
```

| Parametro | Tipo | Descripcion | Ejemplo |
|---|---|---|---|
| `name_` | string | Nombre completo del token | "MyToken" |
| `symbol_` | string | Simbolo/ticker | "MTK" |
| `initialSupply_` | uint256 | Supply inicial en unidades base (18 dec) | 1000000 * 1e18 |

**Que hace el constructor:**
1. `ERC20(name_, symbol_)` - Configura nombre y simbolo
2. `Ownable(msg.sender)` - Establece al deployer como owner
3. `ERC20Permit(name_)` - Configura dominio EIP-712 para firmas
4. `_mint(msg.sender, initialSupply_)` - Acuna supply inicial al deployer

---

## Funciones Propias

### mint

```solidity
function mint(address to, uint256 amount) external nonReentrant onlyOwner
```

| Parametro | Tipo | Descripcion |
|---|---|---|
| `to` | address | Destinatario de los tokens |
| `amount` | uint256 | Cantidad a acunar (en unidades base) |

- **Quien puede llamarla**: Solo el owner
- **Seguridad**: nonReentrant (previene reentrancia)
- **Emite**: evento `Transfer(address(0), to, amount)`

### pause

```solidity
function pause() public onlyOwner
```

- **Quien puede llamarla**: Solo el owner
- **Que hace**: Pausa todas las transferencias
- **Emite**: evento `Paused(account)`
- **Error si falla**: `EnforcedPause` (si ya esta pausado)

### unpause

```solidity
function unpause() public onlyOwner
```

- **Quien puede llamarla**: Solo el owner
- **Que hace**: Despausa las transferencias
- **Emite**: evento `Unpaused(account)`
- **Error si falla**: `ExpectedPause` (si no esta pausado)

### _update (override)

```solidity
function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Pausable)
```

- **Visibilidad**: Internal (no accesible desde fuera)
- **Proposito**: Resuelve conflicto entre ERC20 y ERC20Pausable
- **Que hace**: Ejecuta `super._update()` que aplica `whenNotPaused`

---

## Funciones Heredadas

### De ERC20

| Funcion | Firma | Descripcion |
|---|---|---|
| `name()` | `name() view returns (string)` | Retorna "MyToken" |
| `symbol()` | `symbol() view returns (string)` | Retorna "MTK" |
| `decimals()` | `decimals() view returns (uint8)` | Retorna 18 |
| `totalSupply()` | `totalSupply() view returns (uint256)` | Supply total actual |
| `balanceOf()` | `balanceOf(address) view returns (uint256)` | Balance de una direccion |
| `transfer()` | `transfer(address, uint256) returns (bool)` | Enviar tokens |
| `approve()` | `approve(address, uint256) returns (bool)` | Aprobar gasto |
| `allowance()` | `allowance(address, address) view returns (uint256)` | Consultar aprobacion |
| `transferFrom()` | `transferFrom(address, address, uint256) returns (bool)` | Transferir con aprobacion |

### De ERC20Burnable

| Funcion | Firma | Descripcion |
|---|---|---|
| `burn()` | `burn(uint256)` | Quemar propios tokens |
| `burnFrom()` | `burnFrom(address, uint256)` | Quemar tokens de otro (requiere allowance) |

### De ERC20Permit

| Funcion | Firma | Descripcion |
|---|---|---|
| `permit()` | `permit(address, address, uint256, uint256, uint8, bytes32, bytes32)` | Aprobar via firma EIP-2612 |
| `nonces()` | `nonces(address) view returns (uint256)` | Nonce actual del usuario |
| `DOMAIN_SEPARATOR()` | `DOMAIN_SEPARATOR() view returns (bytes32)` | Hash del dominio EIP-712 |

### De Ownable

| Funcion | Firma | Descripcion |
|---|---|---|
| `owner()` | `owner() view returns (address)` | Direccion del owner actual |
| `transferOwnership()` | `transferOwnership(address)` | Transferir propiedad |
| `renounceOwnership()` | `renounceOwnership()` | Renunciar a la propiedad |

---

## Errores Posibles

| Error | Viene de | Cuando ocurre |
|---|---|---|
| `OwnableUnauthorizedAccount` | Ownable | No-owner llama mint/pause/unpause |
| `OwnableInvalidOwner` | Ownable | Se usa address(0) como owner |
| `EnforcedPause` | Pausable | Se intenta transferir con contrato pausado |
| `ExpectedPause` | Pausable | Se llama unpause() sin estar pausado |
| `ERC2612ExpiredSignature` | ERC20Permit | La firma de permit expiro |
| `ERC2612InvalidSigner` | ERC20Permit | La firma no coincide con el owner |
| `ReentrancyGuardReentrantCall` | ReentrancyGuard | Reentrancia detectada en mint |
| `ERC20InsufficientAllowance` | ERC20 | burnFrom sin allowance suficiente |
| `ERC20InsufficientBalance` | ERC20 | Transferir mas de lo que se tiene |
| `ERC20InvalidReceiver` | ERC20 | Enviar tokens a direccion invalida |

---

## Eventos Emocionados

| Evento | Parametros | Cuando se emite |
|---|---|---|
| `Transfer` | `from, to, value` | En transfer, mint, burn |
| `Approval` | `owner, spender, value` | En approve y permit |
| `Paused` | `account` | En pause() |
| `Unpaused` | `account` | En unpause() |
| `OwnershipTransferred` | `previousOwner, newOwner` | En transferOwnership y renounceOwnership |

---

## Ejemplo de Uso

### Despliegue

```solidity
// 1,000,000 tokens con 18 decimales
uint256 supply = 1_000_000 * 1e18;
MyToken token = new MyToken("MyToken", "MTK", supply);
```

### Mint

```solidity
// Owner acuna 1000 tokens a una direccion
token.mint(0xRecipient, 1000 * 1e18);
```

### Transferir

```solidity
// Holder envia 100 tokens
token.transfer(0xRecipient, 100 * 1e18);
```

### Aprobar y TransferFrom

```solidity
// Aprobar a un spender para gastar 500 tokens
token.approve(0xSpender, 500 * 1e18);

// Spender transfiere 200 tokens del holder
token.transferFrom(0xHolder, 0xRecipient, 200 * 1e18);
```

### Permit (sin gas)

```solidity
// 1. Holder firma un mensaje off-chain (fuera de la blockchain)
// 2. Cualquiera envia la transaccion con la firma
token.permit(holder, spender, 500 * 1e18, deadline, v, r, s);
```

### Quemar tokens

```solidity
// Holder quema 50 de sus propios tokens
token.burn(50 * 1e18);

// Owner quema 100 tokens de otro (requiere allowance)
token.burnFrom(0xHolder, 100 * 1e18);
```

### Pausar/Despausar

```solidity
// Owner pausa (emergencia)
token.pause();

// Owner despausa
token.unpause();
```
