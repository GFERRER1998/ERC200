// SPDX-License-Identifier: MIT
// Licencia: MIT

// pragma: Requiere Solidity 0.8.28 o superior.
pragma solidity ^0.8.28;

// ============================================================
// IMPORTS
// ============================================================

// Test: Framework de testing de Foundry.
// Provee: assertEq, assertGt, vm.prank, vm.expectRevert, makeAddr, etc.
import {Test} from "forge-std/Test.sol";

// MyToken: El contrato que vamos a testear.
import {MyToken} from "../src/MyToken.sol";

// ============================================================
// CONTRATO DE TESTS
// ============================================================

/// @title MyTokenTest
/// @notice Suite de tests completa para el contrato MyToken.
/// @dev    Hereda de Test (forge-std) para acceder a utilidades de testing.
///         Cada funcion que empieza con `test_` es ejecutada automaticamente
///         por `forge test`. Se crean 13 tests que cubren todas las funciones
///         del contrato: constructor, mint, pause, unpause, transfer, approve,
///         transferFrom, burn y burnFrom.
contract MyTokenTest is Test {
    // ============================================================
    // VARIABLES DE TEST
    // ============================================================

    // Instancia del contrato MyToken que se despliega en cada setUp().
    MyToken public token;

    // Direcciones de test.
    // address(this) es el deployer (owner) del contrato.
    // alice y bob son direcciones creadas con makeAddr() para simular usuarios.
    address public owner = address(this);
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    // Supply inicial constante para los tests.
    // 1,000,000 tokens con 18 decimales.
    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 1e18;

    // ============================================================
    // setUp - Se ejecuta ANTES de cada test
    // ============================================================

    /// @notice Configuracion que se ejecuta antes de cada test.
    /// @dev    Despliega una instancia limpia de MyToken con supply inicial.
    ///         Cada test empieza con un estado conocido y aislado.
    function setUp() public {
        // Despliega MyToken con nombre "MyToken", simbolo "MTK"
        // y supply inicial de 1,000,000 tokens.
        token = new MyToken("MyToken", "MTK", INITIAL_SUPPLY);
    }

    // ============================================================
    // TESTS DEL CONSTRUCTOR
    // ============================================================

    /// @notice Test: Verifica que el nombre del token es "MyToken".
    /// @dev    El nombre se configura en el constructor via ERC20(name_, symbol_).
    ///         Es importante porque los wallets y exploradores usan el nombre
    ///         para mostrar informacion al usuario.
    function test_NameAndSymbol() public view {
        // Verifica que name() retorna "MyToken"
        assertEq(token.name(), "MyToken");
        // Verifica que symbol() retorna "MTK"
        assertEq(token.symbol(), "MTK");
    }

    /// @notice Test: Verifica que los decimales son 18.
    /// @dev    18 decimales es el estandar ERC20. Permite representar
    ///         fracciones de token (ej: 0.001 tokens = 1000000000000000 wei).
    ///         Si los decimales fueran diferentes, las cantidades serian incorrectas.
    function test_Decimals() public view {
        // Verifica que decimals() retorna 18
        assertEq(token.decimals(), 18);
    }

    /// @notice Test: Verifica que el supply inicial se acuna al deployer.
    /// @dev    El constructor ejecuta _mint(msg.sender, initialSupply_).
    ///         Esto significa que el deployer recibe todos los tokens iniciales.
    ///         totalSupply() debe ser igual a INITIAL_SUPPLY.
    ///         balanceOf(owner) debe ser igual a INITIAL_SUPPLY.
    function test_InitialSupply() public view {
        // Verifica que el supply total es el supply inicial
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        // Verifica que el balance del deployer es el supply inicial
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    /// @notice Test: Verifica que el deployer es el owner.
    /// @dev    El constructor ejecuta Ownable(msg.sender), que establece
    ///         al deployer como owner. Solo el owner puede mint y pausar.
    function test_Owner() public view {
        // Verifica que owner() retorna la direccion del deployer
        assertEq(token.owner(), owner);
    }

    // ============================================================
    // TESTS DE MINT
    // ============================================================

    /// @notice Test: Verifica que el owner puede acunar tokens.
    /// @dev    La funcion mint() tiene el modifier onlyOwner.
    ///         El owner puede acunar tokens a cualquier direccion.
    ///         Despues del mint, el balance del destinatario y el totalSupply
    ///         deben incrementarse.
    function test_Mint() public {
        // Cantidad a acunar: 1000 tokens
        uint256 mintAmount = 1000 * 1e18;

        // Owner acuna 1000 tokens a alice
        token.mint(alice, mintAmount);

        // Verifica que alice recibio los tokens
        assertEq(token.balanceOf(alice), mintAmount);
        // Verifica que el totalSupply aumento
        assertEq(token.totalSupply(), INITIAL_SUPPLY + mintAmount);
    }

    /// @notice Test: Verifica que no-owner no puede acunar tokens.
    /// @dev    La funcion mint() tiene el modifier onlyOwner.
    ///         Si un usuario que no es owner intenta mintear, debe fallar
    ///         con el error OwnableUnauthorizedAccount.
    function test_MintRevertNonOwner() public {
        // alice intenta acunar tokens (no es owner)
        vm.prank(alice);
        vm.expectRevert();  // Espera que la transaccion falle
        token.mint(bob, 100 * 1e18);
    }

    // ============================================================
    // TESTS DE TRANSFER
    // ============================================================

    /// @notice Test: Verifica que transfer() funciona correctamente.
    /// @dev    transfer() es la funcion basica de ERC20.
    ///         El owner envia tokens a alice. Despues de la transferencia,
    ///         alice debe tener los tokens y el owner debe tener menos.
    function test_Transfer() public {
        // Cantidad a transferir: 100 tokens
        uint256 transferAmount = 100 * 1e18;

        // Owner transfiere 100 tokens a alice
        token.transfer(alice, transferAmount);

        // Verifica que alice recibio los tokens
        assertEq(token.balanceOf(alice), transferAmount);
        // Verifica que el balance del owner bajo
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - transferAmount);
    }

    /// @notice Test: Verifica que transfer() falla si no hay suficiente balance.
    /// @dev    alice no tiene tokens, asi que si intenta transferir,
    ///         debe fallar con el error ERC20InsufficientBalance.
    function test_TransferRevertInsufficientBalance() public {
        // alice no tiene tokens, intenta transferir 100
        vm.prank(alice);
        vm.expectRevert();  // Espera revert (ERC20InsufficientBalance)
        token.transfer(bob, 100 * 1e18);
    }

    // ============================================================
    // TESTS DE APPROVE Y TRANSFERFROM
    // ============================================================

    /// @notice Test: Verifica que approve() configura el allowance correctamente.
    /// @dev    approve() permite a un spender gastar tokens en nombre del owner.
    ///         Despues de approve, allowance(owner, alice) debe ser igual al monto.
    function test_Approve() public {
        // Cantidad aprobada: 500 tokens
        uint256 approveAmount = 500 * 1e18;

        // Owner aprueba a alice para gastar 500 tokens
        token.approve(alice, approveAmount);

        // Verifica que el allowance es correcto
        assertEq(token.allowance(owner, alice), approveAmount);
    }

    /// @notice Test: Verifica que transferFrom() funciona con allowance.
    /// @dev    Primero se aprueba a alice para gastar tokens del owner.
    ///         Luego alice usa transferFrom para mover tokens del owner a bob.
    ///         El allowance se reduce automaticamente.
    function test_TransferFrom() public {
        // Cantidad aprobada y a transferir
        uint256 approveAmount = 500 * 1e18;
        uint256 transferAmount = 200 * 1e18;

        // Owner aprueba a alice para gastar 500 tokens
        token.approve(alice, approveAmount);

        // alice transfiere 200 tokens del owner a bob
        vm.prank(alice);
        token.transferFrom(owner, bob, transferAmount);

        // Verifica que bob recibio los tokens
        assertEq(token.balanceOf(bob), transferAmount);
        // Verifica que el allowance se redujo (500 - 200 = 300)
        assertEq(token.allowance(owner, alice), approveAmount - transferAmount);
    }

    // ============================================================
    // TESTS DE BURN
    // ============================================================

    /// @notice Test: Verifica que burn() reduce el supply y el balance.
    /// @dev    burn() es de ERC20Burnable. Cualquier holder puede quemar
    ///         sus propios tokens. Despues del burn, totalSupply y balance
    ///         deben reducirse.
    function test_Burn() public {
        // Cantidad a quemar: 50 tokens
        uint256 burnAmount = 50 * 1e18;
        // Balance antes del burn
        uint256 balanceBefore = token.balanceOf(owner);

        // Owner quema 50 tokens
        token.burn(burnAmount);

        // Verifica que el balance bajo
        assertEq(token.balanceOf(owner), balanceBefore - burnAmount);
        // Verifica que el totalSupply se redujo
        assertEq(token.totalSupply(), INITIAL_SUPPLY - burnAmount);
    }

    // ============================================================
    // TESTS DE PAUSA
    // ============================================================

    /// @notice Test: Verifica que transfer() falla cuando el contrato esta pausado.
    /// @dev    El owner pausa el contrato. Despues,任何 transfer debe fallar
    ///         con el error EnforcedPause. Esto es util como switch de emergencia.
    function test_PauseRevertTransfer() public {
        // Owner pausa el contrato
        token.pause();

        // alice intenta transferir (debe fallar porque esta pausado)
        vm.prank(alice);
        vm.expectRevert();  // Espera revert (EnforcedPause)
        token.transfer(bob, 100 * 1e18);
    }

    /// @notice Test: Verifica que despues de unpause(), las transferencias funcionan.
    /// @dev    Primero se pausa, luego se despausa. Despues de unpause,
    ///         las transferencias deben funcionar normalmente.
    function test_Unpause() public {
        // Owner pausa el contrato
        token.pause();

        // Owner despausa el contrato
        token.unpause();

        // Primero el owner transfiere tokens a alice (owner tiene tokens)
        uint256 transferAmount = 100 * 1e18;
        token.transfer(alice, transferAmount);

        // Verifica que alice recibio los tokens
        assertEq(token.balanceOf(alice), transferAmount);
    }
}
