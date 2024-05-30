// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "forge-std/StdJson.sol";
import "../lib/forge-std/src/console2.sol";
import "../src/OpenAiChatGptVision_responseHC.sol";

import "../src/interfaces/IChatGpt.sol";
import "../src/interfaces/IOracle.sol";
import "./mocks/ChatOracleMock.sol";

// forge test -vvvvv --match-path '*/OpenAiChatGptVision_responseHC.t.sol' --via-ir
contract OpenAiChatGptVisionTest is Test {
    using stdJson for string;

    address public deployer;
    address public testUser;
    address public manager;
    OpenAiChatGptVision public openAiChatGptVision;
    // Oracle mock located in this repo
    ChatOracleMock public oracleMock;
    // Used with oracle mock to simulate returning the response
    address public offchainOracle;

    // Actual oracle contract deployed on Galadriel Network
    IOracle galOracle;

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
        fork = vm.createFork(vm.envString("GALADRIEL_DEVNET_RPC"), 14004168);
        vm.selectFork(fork);

        testUser = makeAddress("TestUser");
        vm.deal(testUser, 1000 ether);

        deployer = makeAddress("Owner");
        vm.deal(deployer, 1000 ether);

        manager = makeAddress("Manager");
        vm.deal(manager, 1000 ether);

        offchainOracle = makeAddress("offchainOracle");
        vm.deal(offchainOracle, 1000 ether);

        vm.startPrank(deployer, deployer);

        // Deploy mock oracle
        oracleMock = new ChatOracleMock();

        // Deploy Vision
        openAiChatGptVision = new OpenAiChatGptVision(address(oracleMock), manager);

        // NOTE: Update oracle whitelist so off-chain oracle can call
        oracleMock.updateWhitelist(address(offchainOracle), true);

        // NOTE: Update oracle whitelist, so off-chain vision contract can call
        oracleMock.updateWhitelist(address(openAiChatGptVision), true);
        vm.stopPrank();
    }

    // BASIC TEST
    function test_startChat() external {
        vm.startPrank(manager, manager);
        string[] memory images = new string[](3);
        images[0] = "i1";
        images[1] = "i2";
        images[2] = "i3";
        openAiChatGptVision.startChat(testUser, "systemMessage", "message", images);

        vm.stopPrank();
    }
}
