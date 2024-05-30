// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract PlayBackToken is ERC20, Ownable, ERC20Permit {
    // Contract that decrypts signed message and extracts `recipient` and `amount`
    address signedMinter;

    modifier onlyManager() {
        require(msg.sender == signedMinter, "Caller is not manager");
        _;
    }

    constructor(address _signedMinter)
        ERC20("PlayBackToken", "BACK")
        Ownable(msg.sender)
        ERC20Permit("PlayBackToken")
    {
        signedMinter = _signedMinter;
    }

    function setSignedMinter(address addr) external onlyOwner {
        signedMinter = addr;
    }

    function mint(address to, uint256 amount) public onlyManager {
        _mint(to, amount);
    }
}
