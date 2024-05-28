pragma solidity ^0.8.23;

import "../../src/interfaces/IOracle.sol";
import "../../src/interfaces/IChatGpt.sol";
import "../../lib/forge-std/src/console2.sol";

interface IOpenAiChatGptVision {
    function onOracleOpenAiLlmResponse(
        uint256 runId,
        IOracle.OpenAiResponse memory response,
        string memory errorMessage
    ) external;
}

contract ChatOracleMock is IOracle {
    mapping(address => bool) public whitelistedAddresses;
    mapping(uint256 => address) public callbackAddresses;

    address private owner;

    IOracle.OpenAiResponse public successResponse;
    IOracle.OpenAiResponse public errorResponse;

    constructor() {
        owner = msg.sender;

        // Mock Oracle response
        successResponse = IOracle.OpenAiResponse({
            id: "0",
            content: "7.34",
            functionName: "",
            functionArguments: "",
            created: 222,
            model: "",
            systemFingerprint: "",
            object: "",
            completionTokens: 1,
            promptTokens: 1,
            totalTokens: 2
        });

        errorResponse = IOracle.OpenAiResponse({
            id: "0",
            content: "error",
            functionName: "",
            functionArguments: "",
            created: 222,
            model: "",
            systemFingerprint: "",
            object: "",
            completionTokens: 1,
            promptTokens: 1,
            totalTokens: 2
        });
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    modifier onlyWhitelisted() {
        require(whitelistedAddresses[msg.sender], "Caller is not whitelisted");
        _;
    }

    function updateWhitelist(address _addressToWhitelist, bool isWhitelisted) public onlyOwner {
        whitelistedAddresses[_addressToWhitelist] = isWhitelisted;
    }

    function createLlmCall(uint256 promptId) external pure returns (uint256) {
        return promptId;
    }

    function createGroqLlmCall(uint256 promptId, GroqRequest memory request) external pure returns (uint256) {
        // silence warning
        string memory m = request.model;
        m = "";
        return promptId;
    }

    function createOpenAiLlmCall(uint256 promptId, OpenAiRequest memory request) external returns (uint256) {
        // silence warning
        string memory m = request.model;
        m = "";

        callbackAddresses[promptId] = msg.sender;

        return promptId;
    }

    function addOpenAiResponse(
        uint256 promptId,
        uint256 promptCallBackId,
        IOracle.OpenAiResponse memory response,
        string memory errorMessage
    ) public onlyWhitelisted {
        // require(!isPromptProcessed[promptId], "Prompt already processed");
        // isPromptProcessed[promptId] = true;

        IChatGpt(callbackAddresses[promptCallBackId]).onOracleOpenAiLlmResponse(
            promptCallBackId, response, errorMessage
        );
    }

    function createFunctionCall(uint256 functionCallbackId, string memory functionType, string memory functionInput)
        external
        pure
        returns (uint256 i)
    {
        // silence warning
        uint256 id = functionCallbackId;
        id = 1;
        string memory m = functionType;
        string memory f = functionInput;
        m = f;
        return i;
    }

    function createKnowledgeBaseQuery(
        uint256 kbQueryCallbackId,
        string memory cid,
        string memory query,
        uint32 num_documents
    ) external pure returns (uint256 i) {
        // silence warnings
        uint256 k = kbQueryCallbackId;
        k = 1;
        string memory c = cid;
        string memory q = query;
        c = q;
        uint32 n = num_documents;
        n = 5;
        return i;
    }

    function getSuccessResponse() public view returns (IOracle.OpenAiResponse memory) {
        return successResponse;
    }

    function getErrorResponse() public view returns (IOracle.OpenAiResponse memory) {
        return errorResponse;
    }
}
