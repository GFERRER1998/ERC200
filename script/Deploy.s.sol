// SPDX-License-Identifier: MIT
// Licencia: MIT

// pragma: Requiere Solidity 0.8.28 o superior.
pragma solidity ^0.8.28;

// ============================================================
// IMPORTS
// ============================================================

// Script: Framework de scripts de Foundry.
// Provee: vm.startBroadcast(), vm.stopBroadcast(), vm.envUint(), vm.envString(), etc.
// Permite crear scripts de despliegue que pueden ejecutarse en local o en redes reales.
import {Script} from "forge-std/Script.sol";

// console: Utilidad para imprimir valores en la consola durante la ejecucion.
// Se usa con console.log("mensaje", valor).
import {console} from "forge-std/console.sol";

// MyToken: El contrato que vamos a desplegar.
import {MyToken} from "../src/MyToken.sol";

// ============================================================
// SCRIPT DE DESPLIEGUE
// ============================================================

/// @title DeployScript
/// @notice Script de despliegue para el contrato MyToken.
/// @dev    Los scripts de Foundry se ejecutan con `forge script`.
///         No gastan gas real cuando se ejecutan localmente (solo simulacion).
///         Con `--broadcast` se envia la transaccion real a la red.
///
///         Ejecucion local (simulacion):
///         forge script script/Deploy.s.sol --rpc-url localhost
///
///         Ejecucion real en Anvil:
///         forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast
///
///         Ejecucion real en Sepolia:
///         forge script script/Deploy.s.sol --rpc-url sepolia --broadcast --verify
contract DeployScript is Script {
    // ============================================================
    // FUNCION run - Funcion principal del script
    // ============================================================

    /// @notice Funcion principal que ejecuta el despliegue.
    /// @dev    1. Lee las variables de entorno del archivo .env
    ///         2. Inicia la transmision de transacciones con la llave privada
    ///         3. Despliega una nueva instancia de MyToken
    ///         4. Finaliza la transmision
    ///         5. Imprime la direccion del contrato desplegado
    ///
    ///         vm.envUint("PRIVATE_KEY") lee la llave privada del .env
    ///         y la usa para firmar la transaccion de despliegue.
    ///
    ///         vm.envUint("INITIAL_SUPPLY") lee el supply inicial del .env
    ///         para configurar cuantos tokens se acunan al desplegar.
    function run() external {
        // ============================================================
        // PASO 1: Leer variables de entorno
        // ============================================================

        // Lee la llave privada del archivo .env.
        // Esta llave firma la transaccion de despliegue.
        // El owner del contrato sera la direccion derivada de esta llave.
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Lee el supply inicial del archivo .env.
        // 1000000000000000000000000 = 1,000,000 tokens (con 18 decimales).
        uint256 initialSupply = vm.envUint("INITIAL_SUPPLY");

        // ============================================================
        // PASO 2: Desplegar el contrato
        // ============================================================

        // vm.startBroadcast() marca el inicio de transacciones que seran
        // firmadas y enviadas. Todo lo que se haga entre start y stop
        // se ejecutara como transacciones reales (cuando se use --broadcast).
        vm.startBroadcast(deployerPrivateKey);

        // Despliega una nueva instancia de MyToken.
        // Parametros: nombre "MyToken", simbolo "MTK", supply inicial.
        // El deployer (direccion de deployerPrivateKey) sera el owner.
        MyToken token = new MyToken("MyToken", "MTK", initialSupply);

        // vm.stopBroadcast() marca el fin de las transacciones.
        // Desde aqui, no se envian mas transacciones.
        vm.stopBroadcast();

        // ============================================================
        // PASO 3: Imprimir resultados
        // ============================================================

        // Imprime la direccion del contrato desplegado en la consola.
        // Util para copiar la direccion y verificar en Etherscan.
        console.log("MyToken desplegado en:", address(token));
        console.log("Supply inicial:", initialSupply);
        console.log("Owner:", msg.sender);
    }
}
