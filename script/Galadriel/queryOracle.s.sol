// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../../lib/forge-std/src/Script.sol";
import "../../lib/forge-std/src/console2.sol";
import "../../src/Galadriel/OpenAiChatGptVision.sol";

// forge script script/Galadriel/queryOracle.s.sol:QueryOracle --rpc-url https://devnet.galadriel.com -vvvv --via-ir --legacy
contract QueryOracle is Script {
    function run() external {
        // deploy vision contract
        // update oracle contract whitelist so vision contract can call it

        // Get the privKey from the env var testnet values
        address deployer = vm.envAddress("PK1_ADDRESS");
        uint256 deployerPrivKey = vm.envUint("PK1");

        // Get the vision address
        address visionAddress = vm.envAddress("VISION_ADDRESS_V2");

        // // Tell F to send txs to the BC
        vm.startBroadcast(deployerPrivKey);

        // // Deploy the contract and set deployer as manager address
        OpenAiChatGptVision openAiChatGptVision = OpenAiChatGptVision(visionAddress);

        // Setup query
        string[] memory images = new string[](9);
        images[0] =
            "https://amplify-db6s1roouv0tm-dev-bra-mediasbucket5fdfde77-bktlwbdhkr1y.s3.ap-southeast-2.amazonaws.com/public/0x590A1ADd90cbC6a0B53346b2CF8a78ebdaC24f02/9b7018a5-b5f4-462f-9063-0b158d5c78ba/raw-images/frame_1.jpeg";
        images[1] =
            "https://amplify-db6s1roouv0tm-dev-bra-mediasbucket5fdfde77-bktlwbdhkr1y.s3.ap-southeast-2.amazonaws.com/public/0x590A1ADd90cbC6a0B53346b2CF8a78ebdaC24f02/9b7018a5-b5f4-462f-9063-0b158d5c78ba/raw-images/frame_2.jpeg";
        images[2] =
            "https://amplify-db6s1roouv0tm-dev-bra-mediasbucket5fdfde77-bktlwbdhkr1y.s3.ap-southeast-2.amazonaws.com/public/0x590A1ADd90cbC6a0B53346b2CF8a78ebdaC24f02/9b7018a5-b5f4-462f-9063-0b158d5c78ba/raw-images/frame_3.jpeg";
        images[3] =
            "https://amplify-db6s1roouv0tm-dev-bra-mediasbucket5fdfde77-bktlwbdhkr1y.s3.ap-southeast-2.amazonaws.com/public/0x590A1ADd90cbC6a0B53346b2CF8a78ebdaC24f02/9b7018a5-b5f4-462f-9063-0b158d5c78ba/raw-images/frame_4.jpeg";
        images[4] =
            "https://amplify-db6s1roouv0tm-dev-bra-mediasbucket5fdfde77-bktlwbdhkr1y.s3.ap-southeast-2.amazonaws.com/public/0x590A1ADd90cbC6a0B53346b2CF8a78ebdaC24f02/9b7018a5-b5f4-462f-9063-0b158d5c78ba/raw-images/frame_5.jpeg";
        images[5] =
            "https://amplify-db6s1roouv0tm-dev-bra-mediasbucket5fdfde77-bktlwbdhkr1y.s3.ap-southeast-2.amazonaws.com/public/0x590A1ADd90cbC6a0B53346b2CF8a78ebdaC24f02/9b7018a5-b5f4-462f-9063-0b158d5c78ba/raw-images/frame_6.jpeg";
        images[6] =
            "https://amplify-db6s1roouv0tm-dev-bra-mediasbucket5fdfde77-bktlwbdhkr1y.s3.ap-southeast-2.amazonaws.com/public/0x590A1ADd90cbC6a0B53346b2CF8a78ebdaC24f02/9b7018a5-b5f4-462f-9063-0b158d5c78ba/raw-images/frame_7.jpeg";
        images[7] =
            "https://amplify-db6s1roouv0tm-dev-bra-mediasbucket5fdfde77-bktlwbdhkr1y.s3.ap-southeast-2.amazonaws.com/public/0x590A1ADd90cbC6a0B53346b2CF8a78ebdaC24f02/9b7018a5-b5f4-462f-9063-0b158d5c78ba/raw-images/frame_8.jpeg";
        images[8] =
            "https://amplify-db6s1roouv0tm-dev-bra-mediasbucket5fdfde77-bktlwbdhkr1y.s3.ap-southeast-2.amazonaws.com/public/0x590A1ADd90cbC6a0B53346b2CF8a78ebdaC24f02/9b7018a5-b5f4-462f-9063-0b158d5c78ba/raw-images/frame_9.jpeg";
        uint256 taskId = 13;

        string memory systemMessage =
            "You are an expert at analyzing images extracted from screen recordings and understanding the actions being performed at an image and overall level to understand the task being completed in a given set of images. You effortlessly understand the actions by looking at the frames and can reflect on these to produce a description of the task being performed based on the input images.Once you understand the task(s) being performed in a set of input images, you are able to accurately estimate the relevancy of the input images relative to a given task and calculate how many tokens should be rewarded for the submission.";

        string memory message =
            "TASK = \"Visit x.com, find Daniel Huynh's profile and repost his latest post\" the attached images are video frames extracted from a recording SUBMISSION depicting a person doing a TASK on their computer to contribute to a dataset showing how to do different tasks on computers the filename of each image correlates to its timestamp Respond in the following way: First re-state the TASK that *should* be depicted in the SUBMISSION frames (note that the submitted video frames could be totally irrelevant and therefore the submission should be ignored). analyse and reflect on these frames by constructing a table outlining each action that goes into completing the task then return a 10 word description of the task finally, estimate how many tokens you would give someone for submitting this recording to a database of recordings of every possible human task. the points rewarded should depend both on complexity and how well it was executed relative the TASK above. If the frames from the video submitted are completely unrelated to the TASK then 0 tokens should be awarded. If it is a perfect depiction of the required TASK and nothing else then it should be rewarded near 100 points. Calculate {tokens} as an estimated reward for this submission - integer between 0 and 100. Remember that SUBMISSION frames that are depicting a different task than the given TASK should be rewarded 0 tokens even if part of the actions are similar. Estimate the difficulty of this task relative to every possible task that a human can complete on a computer in under 3 minutes and adjust the awarded tokens relative to the difficulty of this task. A perfectly completed and relevant SUBMISSION for a difficult task should receive 100 tokens while a perfectly completed submission for an easy task should only be awarded 10 or so tokens and a medium task should receive around 50 tokens. Summarize your steps in deciding how many tokens to award this SUBMISSION relative to the required TASK that the submission should match Write your reasoning then end your answer with the final line after a blank line: \"Valuation: {tokens}\"";

        openAiChatGptVision.startChat(deployer, taskId, systemMessage, message, images);

        vm.stopBroadcast();
    }
}
