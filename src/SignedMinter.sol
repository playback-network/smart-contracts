pragma solidity ^0.8.23;

import "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "./PlayBackToken.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

contract SignedMinter is Ownable {
    event SignatureVerified(address indexed recipient, bytes signature, uint256 tokenAmount, address payloadSigner);

    PlaybackToken token;
    address payloadSigner;
    // TODO: Nonces

    constructor(address _tokenAddress, address _payloadSigner) Ownable(msg.sender) {
        token = PlaybackToken(_tokenAddress);
    }

    function mint(bytes memory signature, uint256 tokenAmount, address recipient) public {
        // Ensure the signer is authorised
        require(_verify(signature, tokenAmount, recipient), "Invalid signature");

        emit SignatureVerified(recipient, signature, tokenAmount, payloadSigner);
        // Mint tokens
        token.mint(recipient, tokenAmount);
    }

    function _verify(bytes memory signature, uint256 tokenAmount, address recipient) public view returns (bool) {
        bytes32 messageHash = keccak256(abi.encodePacked(tokenAmount, recipient));
        bytes32 signedMessageHash = MessageHashUtils.toEthSignedMessageHash(messageHash);
        // (address recoveredAddress, ECDSA.RecoverError errorReason, bytes32 errorMessage) =
        //     ECDSA.tryRecover(signedMessageHash, signature);

        // if (errorReason == ECDSA.RecoverError.NoError) {
        //     return recoveredAddress == payloadSigner;
        // } else {

        // }
        // return false;

        recoverSignerFromSignature(signedMessageHash, signature);
    }

    function recoverSignerFromSignature(bytes32 message, bytes memory sig) internal pure returns (address) {
        require(sig.length == 65);

        uint8 v;
        bytes32 r;
        bytes32 s;

        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        return ecrecover(message, v, r, s);
    }

    // --------------------------------------------------------------------

    function recoverStringFromRaw(string memory message, bytes memory sig) public pure returns (address) {
        require(sig.length == 65, "invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        // Divide the signature into r, s, and v variables
        assembly {
            r := mload(add(sig, 0x20))
            s := mload(add(sig, 0x40))
            v := byte(0, mload(add(sig, 0x60)))
        }

        if (v < 27) {
            v += 27;
        }

        bytes32 messageHash =
            keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", uintToStr(bytes(message).length), message));

        return ecrecover(messageHash, v, r, s);
    }

    function uintToStr(uint256 v) internal pure returns (string memory str) {
        uint256 maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint256 i = 0;
        while (v != 0) {
            uint256 remainder = v % 10;
            v = v / 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i);
        for (uint256 j = 0; j < i; j++) {
            s[j] = reversed[i - j - 1];
        }
        str = string(s);
    }
}
