// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "../../lib/forge-std/src/Script.sol";
import "../../lib/forge-std/src/console2.sol";
import "../../src/FileCoin/SignedMinter.sol";
import "../../src/FileCoin/PlayBackToken.sol";

// forge script script/FileCoin/getUserBalance.s.sol:GetUserBalance --rpc-url https://api.calibration.node.glif.io/rpc/v1 -vvvv --optimize --optimizer-runs 200 --via-ir -g 100000
contract GetUserBalance is Script {
    function run() external {
        uint256 deployerPrivKey = vm.envUint("PK1");
        address signedMinter = vm.envAddress("SIGNEDMINTER_ADDRESS");
        address playbackToken = vm.envAddress("PLAYBACKTOKEN_ADDRESS");

        vm.startBroadcast(deployerPrivKey);

        PlayBackToken pT = PlayBackToken(playbackToken);
        address recipient = 0x2dC8Bc53ECf1A59188e4c7fAB0c7bB57339F85e7;

        // Recipient balance before
        uint balance = pT.balanceOf(recipient);
        console2.log("Balance:", balance);

        vm.stopBroadcast();
    }
}
