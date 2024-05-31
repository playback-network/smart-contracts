// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "forge-std/StdJson.sol";
import "../../lib/forge-std/src/console2.sol";
import "../../src/FileCoin/SignedMinter.sol";
import "../../src/FileCoin/PlayBackToken.sol";

contract OpenAiChatGptVisionTest is Test {
    using stdJson for string;

    address public deployer;
    address public testUser;
    address public manager;
    address public payloadSigner;
    SignedMinter public signedMinter;
    PlayBackToken public playBackToken;

    // Used to create addresses
    uint256 _addressSeed = 123456789;

    // Fork Identifiers
    uint256 public fork;

    function makeAddress(string memory label) public returns (address) {
        address addr = vm.addr(_addressSeed);
        vm.label(addr, label);
        _addressSeed++;
        return addr;
    }

    function setUp() public {
        // NOTE: You must update the fork value to the correct fork number after each deployment
        // TODO: Set blocknumber
        fork = vm.createFork(vm.envString("FILECOIN_TESTNET_RPC"), 1656200);
        vm.selectFork(fork);

        testUser = makeAddress("TestUser");
        vm.deal(testUser, 1000 ether);

        deployer = makeAddress("Owner");
        vm.deal(deployer, 1000 ether);

        manager = makeAddress("Manager");
        vm.deal(manager, 1000 ether);

        payloadSigner = vm.envAddress("PAYLOAD_SIGNER_ADDRESS");

        vm.startPrank(deployer, deployer);

        // Deploy Token
        playBackToken = new PlayBackToken(deployer);

        // Deploy SignedMinter
        signedMinter = new SignedMinter(address(playBackToken), payloadSigner);

        // Set signed minter on PBT
        playBackToken.setSignedMinter(address(signedMinter));
        vm.stopPrank();
    }

    function test_Verify() external {
        vm.startPrank(deployer);

        bytes memory rawSig =
            hex"eb3d55a8155dc3beb09e8f70712a6f0d5ea81a8fdfca4191bf4c48c0b7a70433414e077e72e328e36a5e3bada66bc908c585f47f8703edd1c117c20b4f0710b61b";

        uint256 tokenAmount = 100;
        address recipient = 0x2dC8Bc53ECf1A59188e4c7fAB0c7bB57339F85e7;

        bytes32 message = keccak256(abi.encodePacked(tokenAmount, recipient));
        address recoveredAddress = signedMinter.recoverStringFromRaw(message, rawSig);
        console2.log("Recovered Address:", recoveredAddress);

        assertEq(recoveredAddress, vm.envAddress("PAYLOAD_SIGNER_ADDRESS"));

        vm.stopPrank();
    }

    function test_Mint() external {
        vm.startPrank(deployer);

        bytes memory rawSig =
            hex"eb3d55a8155dc3beb09e8f70712a6f0d5ea81a8fdfca4191bf4c48c0b7a70433414e077e72e328e36a5e3bada66bc908c585f47f8703edd1c117c20b4f0710b61b";

        uint256 tokenAmount = 100;
        address recipient = 0x2dC8Bc53ECf1A59188e4c7fAB0c7bB57339F85e7;

        uint256 balBefore = playBackToken.balanceOf(recipient);
        signedMinter.mint(rawSig, tokenAmount, recipient);
        uint256 balAfter = playBackToken.balanceOf(recipient);

        assertEq(balBefore + tokenAmount, balAfter);

        vm.stopPrank();
    }
}
