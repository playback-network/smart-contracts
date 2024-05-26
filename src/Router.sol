// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./interfaces/IOracle.sol";

contract OpenAiChatGptVision {
    struct ChatRun {
        address caller;
        IOracle.Message[] messages;
        uint256 messagesCount;
    }

    struct Response {
        address caller;
        bool success;
        string response;
    }

    mapping(uint256 => ChatRun) public chatRuns;
    uint256 private chatRunsCount;

    event ChatCreated(address indexed caller, uint256 indexed chatId);

    mapping(uint256 => Response) public responses;

    event ResponseReceived(address caller, uint256 indexed chatId, bool indexed success, string response);

    address private owner;
    address public oracleAddress;

    event OracleAddressUpdated(address indexed newOracleAddress);

    IOracle.OpenAiRequest private config;

    constructor(address initialOracleAddress) {
        owner = msg.sender;
        oracleAddress = initialOracleAddress;
        chatRunsCount = 0;

        config = IOracle.OpenAiRequest({
            model: "gpt-4-turbo",
            frequencyPenalty: 21, // > 20 for null
            logitBias: "", // empty str for null
            maxTokens: 1000, // 0 for null
            presencePenalty: 21, // > 20 for null
            responseFormat: "{\"type\":\"text\"}",
            seed: 0, // null
            stop: "", // null
            temperature: 10, // Example temperature (scaled up, 10 means 1.0), > 20 means null
            topP: 101, // Percentage 0-100, > 100 means null
            tools: "",
            toolChoice: "", // "none" or "auto"
            user: "" // null
        });
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    modifier onlyOracle() {
        require(msg.sender == oracleAddress, "Caller is not oracle");
        _;
    }

    function setOracleAddress(address newOracleAddress) public onlyOwner {
        oracleAddress = newOracleAddress;
        emit OracleAddressUpdated(newOracleAddress);
    }

    function copyContentArray(IOracle.Content[] memory source) internal pure returns (IOracle.Content[] memory) {
        IOracle.Content[] memory result = new IOracle.Content[](source.length);

        for (uint256 i = 0; i < source.length; i++) {
            result[i] = source[i];
        }
        return result;
    }

    function startChat(address caller, string memory message, string[] memory imageUrls) public returns (uint256 i) {
        ChatRun storage run = chatRuns[chatRunsCount];

        run.caller = caller;
        IOracle.Message memory newMessage =
            IOracle.Message({role: "user", content: new IOracle.Content[](imageUrls.length + 1)});
        newMessage.content[0] = IOracle.Content({contentType: "text", value: message});
        for (uint256 u = 0; u < imageUrls.length; u++) {
            newMessage.content[u + 1] = IOracle.Content({contentType: "image_url", value: imageUrls[u]});
        }

        // Manually copy the message content to storage
        run.messages.push();
        run.messages[run.messages.length - 1].role = newMessage.role;
        run.messages[run.messages.length - 1].content = new IOracle.Content[](newMessage.content.length);
        for (uint256 j = 0; j < newMessage.content.length; j++) {
            run.messages[run.messages.length - 1].content[j] = newMessage.content[j];
        }

        run.messagesCount = 1;

        uint256 currentId = chatRunsCount;
        chatRunsCount = chatRunsCount + 1;

        IOracle(oracleAddress).createOpenAiLlmCall(currentId, config);
        emit ChatCreated(msg.sender, currentId);

        return currentId;
    }

    function onOracleOpenAiLlmResponse(
        uint256 runId,
        IOracle.OpenAiResponse memory response,
        string memory errorMessage
    ) public onlyOracle {
        ChatRun storage run = chatRuns[runId];
        require(
            keccak256(abi.encodePacked(run.messages[run.messagesCount - 1].role)) == keccak256(abi.encodePacked("user")),
            "No message to respond to"
        );

        address caller = chatRuns[runId].caller;
        if (!compareStrings(errorMessage, "")) {
            responses[runId] = Response({caller: caller, success: false, response: errorMessage});

            emit ResponseReceived(caller, runId, false, errorMessage);
        } else {
            responses[runId] = Response({caller: caller, success: true, response: response.content});

            emit ResponseReceived(caller, runId, true, response.content);
        }
    }

    function getMessageHistory(uint256 chatId) public view returns (IOracle.Message[] memory) {
        return chatRuns[chatId].messages;
    }

    function compareStrings(string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}
