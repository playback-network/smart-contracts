// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "../lib/forge-std/src/interfaces/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

contract SignedMinter is Ownable {
    using MessageHashUtils for bytes32;

    IERC20 token;
    address payloadSigner;
    // TODO: Nonces

    constructor(address _tokenAddress, address _payloadSigner) Ownable(msg.sender) {
        token = IERC20(_tokenAddress);
    }

    function mint(bytes32 signature, uint256 tokenAmount, address recipient) public {
        // Recover sig
        bytes32 messageHash = getMessageHash(tokenAmount, recipient);
        address signer = messageHash.toEthSignedMessageHash().recover(signature);

        // Ensure the signer is authorised
        require(signer == payloadSigner, "Invalid signature");

        // Mint tokens
        token.mint(recipient, tokenAmount);
    }

    function getMessageHash(uint256 tokenAmount, address recipient) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(tokenAmount, recipient));
    }

    function verify(bytes32 messageHash, bytes32 signature) internal pure returns (address) {}
}
