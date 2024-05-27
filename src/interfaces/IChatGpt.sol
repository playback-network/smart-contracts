// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./IOracle.sol";

interface IChatGpt {
    function onOracleFunctionResponse(uint256 callbackId, string memory response, string memory errorMessage)
        external;

    function onOracleLlmResponse(uint256 callbackId, string memory response, string memory errorMessage) external;

    function onOracleKnowledgeBaseQueryResponse(
        uint256 callbackId,
        string[] memory documents,
        string memory errorMessage
    ) external;

    function getMessageHistory(uint256 callbackId) external view returns (IOracle.Message[] memory);

    function getMessageHistoryContents(uint256 callbackId) external view returns (string[] memory);

    function getMessageHistoryRoles(uint256 callbackId) external view returns (string[] memory);

    function onOracleOpenAiLlmResponse(
        uint256 callbackId,
        IOracle.OpenAiResponse memory response,
        string memory errorMessage
    ) external;

    function onOracleGroqLlmResponse(
        uint256 callbackId,
        IOracle.GroqResponse memory response,
        string memory errorMessage
    ) external;
}
