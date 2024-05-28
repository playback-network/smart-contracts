// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract FeedbackToken is ERC20, Ownable, ERC20Permit {
    // Contract that decrypts signed message and extracts `to` and `amount`
    address manager;

    modifier onlyManager() {
        require(msg.sender == manager, "Caller is not manager");
        _;
    }

    constructor(address _manager) ERC20("PlaybackToken", "PBT") Ownable(msg.sender) ERC20Permit("FeedbackToken") {
        manager = _manager;
    }

    function mint(address to, uint256 amount) public onlyManager {
        _mint(to, amount);
    }
}
