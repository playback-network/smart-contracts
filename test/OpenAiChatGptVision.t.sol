// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "forge-std/StdJson.sol";
import "../lib/forge-std/src/console2.sol";
import "../src/OpenAiChatGptVision.sol";

import "../src/interfaces/IChatGpt.sol";
import "../src/interfaces/IOracle.sol";
import "./mocks/ChatOracleMock.sol";

contract OpenAiChatGptVisionTest is Test {
    using stdJson for string;

    address public deployer;
    address public testUser;
    address public manager;
    address public offchainOracle;
    OpenAiChatGptVision public openAiChatGptVision;
    ChatOracleMock public oracleMock;

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
        fork = vm.createFork(vm.envString("GALADRIEL_DEVNET_RPC"), 5524873);
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

        // NOTE: Update oracle whitelist, setting it to vision contract
        oracleMock.updateWhitelist(address(openAiChatGptVision), true);
        vm.stopPrank();
    }

    function test_callOracleContract() external {
        vm.startPrank(manager, manager);
        string[] memory images = new string[](3);
        images[0] = "i1";
        images[1] = "i2";
        images[2] = "i3";
        openAiChatGptVision.startChat(testUser, "systemMessage", "message", images);

        vm.stopPrank();
        // Get success response from oracleMock
        IOracle.OpenAiResponse memory response = oracleMock.getSuccessResponse();

        // Act as off-chain oracle providing response
        vm.startPrank(offchainOracle, offchainOracle);
        // Simulate oracle calling back into vision contract
        oracleMock.addOpenAiResponse(0, 0, response, "");
    }
}
