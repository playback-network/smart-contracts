// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../../lib/forge-std/src/Script.sol";
import "../../lib/forge-std/src/console2.sol";
import "../../src/Galadriel/OpenAiChatGptVision.sol";

// forge script script/queryOracle.s.sol:QueryOracle --rpc-url https://devnet.galadriel.com -vvvv --via-ir --legacy
contract QueryOracle is Script {
    function run() external {
        // deploy vision contract
        // update oracle contract whitelist so vision contract can call it

        // Get the privKey from the env var testnet values
        address deployer = vm.envAddress("PK1_ADDRESS");
        uint256 deployerPrivKey = vm.envUint("PK1");

        // Get the Galadriel oracle contract address
        address oracleAddress = vm.envAddress("GALADRIEL_ORACLE_ADDRESS");

        // Get the vision address
        address visionAddress = vm.envAddress("VISION_ADDRESS");

        // // Tell F to send txs to the BC
        vm.startBroadcast(deployerPrivKey);

        // // Deploy the contract and set deployer as manager address
        OpenAiChatGptVision openAiChatGptVision = OpenAiChatGptVision(visionAddress);

        // Setup query
        string[] memory images = new string[](3);
        images[0] = "https://evm-poc-images.s3.eu-central-1.amazonaws.com/royal-tang/1.png";
        images[1] = "https://evm-poc-images.s3.eu-central-1.amazonaws.com/royal-tang/2.png";
        images[2] = "https://evm-poc-images.s3.eu-central-1.amazonaws.com/royal-tang/3.png";

        openAiChatGptVision.startChat(
            deployer, "You help users identify animals in images", "what animal is in these images", images
        );

        vm.stopBroadcast();
    }
}
