// pragma solidity ^0.8.23;

import "../../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "./PlayBackToken.sol";
import "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../../lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

contract SignedMinter is Ownable {
    event SignatureVerified(address indexed recipient, bytes signature, uint256 tokenAmount, address payloadSigner);

    PlayBackToken token;
    address payloadSigner;
    // TODO: Nonces

    constructor(address _tokenAddress, address _payloadSigner) Ownable(msg.sender) {
        token = PlayBackToken(_tokenAddress);
        payloadSigner = _payloadSigner;
    }

    function setTokenAddress(address addr) external onlyOwner {
        token = PlayBackToken(addr);
    }

    function mint(bytes memory signature, uint256 tokenAmount, address recipient) public {
        // Ensure the signer is authorised
        require(_verify(signature, tokenAmount, recipient), "Invalid signature");

        emit SignatureVerified(recipient, signature, tokenAmount, payloadSigner);
        // Mint tokens
        token.mint(recipient, tokenAmount);
    }

    function _verify(bytes memory signature, uint256 tokenAmount, address recipient) public view returns (bool) {
        bytes32 message = keccak256(abi.encodePacked(tokenAmount, recipient));
        address recoveredAddress = recoverStringFromRaw(message, signature);

        return recoveredAddress == payloadSigner;
    }

    function recoverStringFromRaw(bytes32 message, bytes memory sig) public pure returns (address) {
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

        bytes32 signedMessageHash = MessageHashUtils.toEthSignedMessageHash(message);

        return ecrecover(signedMessageHash, v, r, s);
    }
}
