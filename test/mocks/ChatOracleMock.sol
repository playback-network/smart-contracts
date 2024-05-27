pragma solidity ^0.8.23;

import "../../src/interfaces/IOracle.sol";

interface IOpenAiChatGptVision {
    function onOracleOpenAiLlmResponse(
        uint256 runId,
        IOracle.OpenAiResponse memory response,
        string memory errorMessage
    ) 
}

contract OracleMock is IOracle {

    address openAiChatGptVision

    constructor(address _openAiChatGptVision) {
        openAiChatGptVision = _openAiChatGptVision
    }

    function createLlmCall(uint256 promptId) external returns (uint256) {
        return promptId;
    }

    function createGroqLlmCall(uint256 promptId, GroqRequest memory request) external returns (uint256) {
        return promptId;
    }

    function createOpenAiLlmCall(uint256 promptId, OpenAiRequest memory request) external returns (uint256) {
        
        
        return promptId;
    }

    function addOpenAiResponse(
        uint promptId,
        uint promptCallBackId,
        IOracle.OpenAiResponse memory response,
        string memory errorMessage
    ) public onlyWhitelisted {
        require(!isPromptProcessed[promptId], "Prompt already processed");
        isPromptProcessed[promptId] = true;
        IChatGpt(callbackAddresses[promptId]).onOracleOpenAiLlmResponse(
            promptCallBackId,
            response,
            errorMessage
        );
    }

    function createFunctionCall(uint256 functionCallbackId, string memory functionType, string memory functionInput)
        external
        returns (uint256 i)
    {
        return promptId;
    }

    function createKnowledgeBaseQuery(
        uint256 kbQueryCallbackId,
        string memory cid,
        string memory query,
        uint32 num_documents
    ) external returns (uint256 i) {
        return promptId;
    }
}
