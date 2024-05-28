// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "../lib/forge-std/src/interfaces/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol" as HashUtils;

contract SignedMinter is Ownable {
    IERC20 token;
    address payloadSigner;
    // TODO: Nonces

    constructor(address _tokenAddress, address _payloadSigner) Ownable(msg.sender) {
        token = IERC20(_tokenAddress);
    }

    function mint(bytes32 signature, uint256 tokenAmount, address recipient) public {
        // Ensure the signer is authorised
        require(signer == payloadSigner, "Invalid signature");

        // Mint tokens
        token.mint(recipient, tokenAmount);
    }

    function _verify(bytes32 signature, uint256 tokenAmount, address recipient) internal pure returns (bool) {
        bytes32 messageHash = keccak256(abi.encodePacked(tokenAmount, recipient));
        bytes32 signedMessageHash = HashUtils.toEthSignedMessageHash(messageHash);
        (address recoveredAddress, ECDSA.RecoverError errorReason, bytes32 errorMessage) =
            ECDSA.tryRecover(signedMessageHash, signature);
    }

    function verify(bytes32 messageHash, bytes32 signature) internal pure returns (address) {}
}
