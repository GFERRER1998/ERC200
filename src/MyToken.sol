// SPDX-License-Identifier: MIT
// Licencia: MIT (permite uso libre, copia, modificacion y distribucion)

// pragma: Requiere Solidity 0.8.28 o superior.
pragma solidity ^0.8.28;

// ============================================================
// IMPORTS - Librerias de OpenZeppelin que hereda este contrato
// ============================================================

// ERC20: Implementacion estandar del token ERC-20.
// Provee: name, symbol, decimals, totalSupply, balanceOf,
// transfer, approve, allowance, transferFrom y eventos Transfer/Approval.
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// ERC20Burnable: Extension que permite a los holders quemar (destruir) sus propios tokens.
// Provee: burn(uint256) y burnFrom(address, uint256).
// Util para reducir el supply total de tokens de forma voluntaria.
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

// ERC20Pausable: Extension que permite pausar todas las transferencias del token.
// Provee: _update() override con modifier whenNotPaused.
// Util como switch de emergencia si se detecta un bug o ataque.
// NOTA: No incluye funciones pause()/unpause() publicas; debemos crearlas nosotros.
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

// ERC20Permit: Extension que permite aprobaciones (approve) sin gas via firmas EIP-2612.
// Provee: permit(), nonces(), DOMAIN_SEPARATOR().
// Los usuarios firman un mensaje off-chain y cualquiera puede enviar la transaccion.
// Ahorra gas porque el usuario no necesita enviar la transaccion de approve.
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

// Ownable: Control de acceso basado en una unica direccion (owner).
// Provee: owner(), transferOwnership(), renounceOwnership(), modifier onlyOwner.
// Restringe funciones criticas (mint, pause) solo al propietario del contrato.
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// ReentrancyGuard: Proteccion contra ataques de reentrancia.
// Provee: modifier nonReentrant.
// Evita que una funcion sea llamada recursivamente si aun no ha terminado.
// Se usa en mint para prevenir que un contrato malicioso reentre durante la acuñacion.
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// ============================================================
// CONTRATO PRINCIPAL
// ============================================================

/// @title MyToken
/// @notice Token ERC-20 completo con burn, pausa, permit y proteccion contra reentrancia.
/// @dev    Hereda de 6 contratos de OpenZeppelin v5.
///         El deployer se convierte en el owner inicial y recibe el supply inicial.
///         El owner puede acunar nuevos tokens y pausar/despausar el contrato.
///         Cualquier holder puede quemar sus propios tokens.
///         Los usuarios pueden hacer aprobaciones sin gas via firmas EIP-2612.
contract MyToken is ERC20, ERC20Burnable, ERC20Pausable, ERC20Permit, Ownable, ReentrancyGuard {
    // ============================================================
    // CONSTRUCTOR
    // ============================================================

    /// @notice Despliega el token con nombre, simbolo y supply inicial.
    /// @dev    Los constructores de los contratos padres se inicializan en la linea
    ///         de herencia. Aqui solo se acuna el supply inicial al deployer.
    ///         ERC20(name_, symbol_) -> configura nombre y simbolo del token
    ///         Ownable(msg.sender) -> establece al deployer como owner
    ///         ERC20Permit(name_) -> configura el dominio EIP-712 para firmas
    /// @param name_       Nombre completo del token (ej: "MyToken")
    /// @param symbol_     Simbolo/ticker del token (ej: "MTK")
    /// @param initialSupply_ Cantidad inicial a acunar al deployer (en unidades base, 18 decimales)
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_
    ) ERC20(name_, symbol_) Ownable(msg.sender) ERC20Permit(name_) {
        // Acuna el supply inicial al deployer (msg.sender).
        // _mint es una funcion interna de ERC20 que incrementa totalSupply
        // y el balance del destinatario.
        _mint(msg.sender, initialSupply_);
    }

    // ============================================================
    // FUNCIONES PROPIAS (definidas en este contrato)
    // ============================================================

    /// @notice Permite al propietario acunar (crear) nuevos tokens.
    /// @dev    Solo puede ser llamada por el owner (onlyOwner).
    ///         Usa nonReentrant para prevenir reentrancia durante la acuñacion.
    ///         El modificador nonReentrant viene de ReentrancyGuard y verifica
    ///         que no haya una llamada en curso a esta funcion.
    /// @param to      Direccion del destinatario que recibira los tokens.
    /// @param amount  Cantidad a acunar en unidades base (con 18 decimales).
    ///                Ejemplo: 1000 * 1e18 = 1000 tokens.
    function mint(address to, uint256 amount) external nonReentrant onlyOwner {
        _mint(to, amount);
    }

    /// @notice Pausa todas las transferencias del token (switch de emergencia).
    /// @dev    Solo puede ser llamada por el owner.
    ///         Cuando esta pausado, transfer, transferFrom, approve y mint
    ///         falliran con el error EnforcedPause.
    ///         La funcion _pause() viene de Pausable y emite el evento Paused.
    function pause() public onlyOwner {
        _pause();
    }

    /// @notice Despausa las transferencias del token.
    /// @dev    Solo puede ser llamada por el owner.
    ///         Solo funciona si el contrato esta pausado; si no lo esta,
    ///         fallira con el error ExpectedPause.
    ///         La funcion _unpause() viene de Pausable y emite el evento Unpaused.
    function unpause() public onlyOwner {
        _unpause();
    }

    // ============================================================
    // OVERRIDE - Resuelve conflicto entre ERC20 y ERC20Pausable
    // ============================================================

    /// @notice Override de _update para resolver el conflicto entre ERC20 y ERC20Pausable.
    /// @dev    Ambos contratos (ERC20 y ERC20Pausable) definen _update().
    ///         Solidity requiere que el contrato hijo defina explicitamente cual usar.
    ///         Aqui llamamos a super._update() que ejecuta la version de ERC20Pausable,
    ///         la cual a su vez llama a ERC20._update() con el modifier whenNotPaused.
    ///         Esto garantiza que TODAS las transferencias fallen si el contrato esta pausado.
    /// @param from   Direccion origen (address(0) si es un mint)
    /// @param to     Direccion destino (address(0) si es un burn)
    /// @param value  Cantidad de tokens a transferir
    function _update(address from, address to, uint256 value) internal override(ERC20, ERC20Pausable) {
        super._update(from, to, value);
    }

    // ============================================================
    // FUNCIONES HEREDADAS (no redefinidas, vienen de OpenZeppelin)
    // ============================================================

    // --- De ERC20 (base) ---
    // name() -> retorna "MyToken"
    // symbol() -> retorna "MTK"
    // decimals() -> retorna 18
    // totalSupply() -> retorna la cantidad total de tokens existentes
    // balanceOf(address) -> retorna el balance de una direccion
    // transfer(address, uint256) -> envia tokens a otra direccion
    // approve(address, uint256) -> aprueba a un spender para gastar tokens
    // allowance(address, address) -> consulta cuantos tokens puede gastar un spender
    // transferFrom(address, address, uint256) -> transfiere usando una aprobacion

    // --- De ERC20Burnable ---
    // burn(uint256) -> destruye tokens del caller (ya disponible por herencia)
    // burnFrom(address, uint256) -> destruye tokens de otro (requiere allowance)

    // --- De ERC20Pausable ---
    // _update(address, address, uint256) -> override interno que agrega
    //   el modifier whenNotPaused a todas las transferencias y mints

    // --- De ERC20Permit ---
    // permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
    //   -> permite aprobaciones via firma EIP-2612 (sin gas para el usuario)
    // nonces(address) -> retorna el nonce actual de un usuario (para prevent replay)
    // DOMAIN_SEPARATOR() -> retorna el hash del dominio EIP-712

    // --- De Ownable ---
    // owner() -> retorna la direccion del propietario actual
    // transferOwnership(address) -> transfiere la propiedad a otra direccion
    // renounceOwnership() -> renuncia a la propiedad (irreversible)

    // --- De ReentrancyGuard ---
    // _reentrancyGuardEntered() -> retorna true si hay una llamada nonReentrant en curso
}
