// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "forge-std/StdJson.sol";
import "../src/OpenAiChatGptVision.sol";
import "../../../lib/forge-std/src/console2.sol";

contract OpenAiChatGptVisionTest is Test {
    using stdJson for string;

    OpenAiChatGptVision public openAiChatGptVision;
    address public deployer;
    address public testUser;
    address public manager;
    address payable public oracle;

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
        vm.deal(deployer, 1000 ether);

        // Get Aura contract address
        auraContractAddress = vm.envAddress("AURA_CONTRACTv2_15v1_1500v2");
        console2.log("auraContractAddress:", auraContractAddress);

        // vm.startPrank(auraOwner);
        // console2.log("Transferring ownership of aura contract...");
        // auraContract.transferOwnership(auraAdmin);
        // vm.stopPrank();

        vm.startPrank(deployer, deployer);

        openAiChatGptVision = new OpenAiChatGptVision(
            "https://leela.mypinata.cloud/ipfs/QmQY5wF3AmBTkPbeVCH7Q5Bm5HZActeKRxHCppmr3dskvC/",
            ROYALTY_BASIS_POINTS,
            auraContractAddress,
            manager
        );
        openAiChatGptVision.setIsOpen(true);
        vm.stopPrank();

        // Set Aura contract using sepolia address
        auraContract = IAura.AuraInterface(auraContractAddress);
        // Get aura contrct owner
        address owner = auraContract.owner();
        // log owner
        console2.log("owner", owner);

        // Get auraAdmin of Aura contract
        // address auraOwner = auraContract.owner();

        vm.startPrank(manager);
        auraContract.setApprovalForAll(address(openAiChatGptVision), true);
        vm.stopPrank();
    }
}
