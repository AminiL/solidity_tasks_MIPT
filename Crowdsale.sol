// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.10;

import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract Crowdsale is ERC20, Ownable {
    uint private immutable _hardCap;
    uint private immutable _priceInWei;
    uint private immutable _startTime;
    uint private immutable _endTime;

    bool _mintActive;

    constructor(uint duration_, uint hardCap_, uint priceInWei_, string memory name_, string memory symbol_) ERC20(name_, symbol_)  {
        _hardCap = hardCap_;
        _priceInWei = priceInWei_;
        _mintActive = true;
        _startTime = block.timestamp;
        _endTime = _startTime + duration_;
    }

    function _cappedMint(address account, uint256 amount) internal {
        require(totalSupply() + amount <= _hardCap, "Hard cap reached");
        _mint(account, amount);
    }

    function buy() external payable {
        require(_mintActive, "ICO closed");
        uint token_amount = msg.value / _priceInWei;
        uint odd_wei = msg.value - token_amount * _priceInWei;
        uint to_owner_wei = msg.value - odd_wei;
        require(odd_wei + to_owner_wei == msg.value, "arithmetic error");
        _cappedMint(msg.sender, token_amount);
        payable(msg.sender).transfer(odd_wei);
    }

    function refund() external {
        require(_mintActive, "ICO closed");
        uint token_amount = balanceOf(msg.sender);
        uint wei_to_return = token_amount * _priceInWei;
        payable(msg.sender).transfer(wei_to_return);
        _burn(msg.sender, token_amount);
    }

    function closeICO() public onlyOwner {
        require(_mintActive, "ICO already closed");
        require(block.timestamp > _endTime); // can not close earlier
        _mintActive = false;
        _mint(msg.sender, totalSupply() / 10); // 10 %
    }
}