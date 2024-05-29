// pragma solidity ^0.8.17;

// import "../lib/forge-std/src/Script.sol";
// import "../lib/forge-std/src/console2.sol";
// import "../src/SignedMinter.sol";

// // forge script script/verifySignature.s.sol:VerifySignature --rpc-url https://devnet.galadriel.com -vvvv --via-ir --legacy
// contract VerifySignature is Script {
//     function run() external {
//         // deploy vision contract
//         // update oracle contract whitelist so vision contract can call it

//         // Get the privKey from the env var testnet values
//         address deployer = vm.envAddress("PK1_ADDRESS");
//         uint256 deployerPrivKey = vm.envUint("PK1");

//         // // Tell F to send txs to the BC
//         vm.startBroadcast(deployerPrivKey);

//         // // Deploy the contract and set deployer as manager address
//         SignedMinter sM = new SignedMinter(deployer, deployer);

//         // bytes memory sig =
//         //     "0x55b68c02c2a1f4e12b2bb864298a3b0d5c63e1a462c710da70bf47f34d0555f64d1f8c52a105f8f9d71272e295eedf483053cf16dc3c7764b0f4084381ff539e1b";
//         // uint256 tokenAmount = 100;
//         // address recipient = 0x2dC8Bc53ECf1A59188e4c7fAB0c7bB57339F85e7;

//         bytes memory rawSig =
//             "0x254bad3fa03c1e3d5aa9441bce4f5c1182351a04e270ee138c73f05424831c980793e53a567b81cfbe07adf71e86e891ee3b0b9e89d8b69fac1c476a3ad4a0041c";

//         string memory message = "Hello World";

//         sM.recoverStringFromRaw(message, rawSig);

//         vm.stopBroadcast();
//     }
// }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/console2.sol";
import "../src/SignedMinter.sol";

contract VerifySignature is Script {
    function run() external {
        address deployer = vm.envAddress("PK1_ADDRESS");
        uint256 deployerPrivKey = vm.envUint("PK1");

        vm.startBroadcast(deployerPrivKey);

        SignedMinter sM = new SignedMinter(deployer, deployer);

        bytes memory rawSig =
            hex"254bad3fa03c1e3d5aa9441bce4f5c1182351a04e270ee138c73f05424831c980793e53a567b81cfbe07adf71e86e891ee3b0b9e89d8b69fac1c476a3ad4a0041c";

        string memory message = "Hello World";

        address recoveredAddress = sM.recoverStringFromRaw(message, rawSig);
        console2.log("Recovered Address:", recoveredAddress);

        vm.stopBroadcast();
    }
}
