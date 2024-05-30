// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../../lib/forge-std/src/Script.sol";
import "../../lib/forge-std/src/console2.sol";
import "../../src/FileCoin/SignedMinter.sol";

contract VerifySignature is Script {
    function run() external {
        address deployer = vm.envAddress("PK1_ADDRESS");
        uint256 deployerPrivKey = vm.envUint("PK1");
        address payloadSigner = vm.envAddress("PAYLOAD_SIGNER_ADDRESS");

        vm.startBroadcast(deployerPrivKey);

        // NOTE: Deployer address is used here as otherwise we have to deploy a token contract (saves time)
        SignedMinter sM = new SignedMinter(deployer, payloadSigner);

        bytes memory rawSig =
            hex"eb3d55a8155dc3beb09e8f70712a6f0d5ea81a8fdfca4191bf4c48c0b7a70433414e077e72e328e36a5e3bada66bc908c585f47f8703edd1c117c20b4f0710b61b";

        uint256 tokenAmount = 100;
        address recipient = 0x2dC8Bc53ECf1A59188e4c7fAB0c7bB57339F85e7;

        // NOTE: Used to call `recoverStringFromRaw` directly
        // bytes32 message = keccak256(abi.encodePacked(tokenAmount, recipient));
        // address recoveredAddress = sM.recoverStringFromRaw(message, rawSig);
        // console2.log("Recovered Address:", recoveredAddress);

        bool recoveredAddress = sM._verify(rawSig, tokenAmount, recipient);

        vm.stopBroadcast();
    }
}
