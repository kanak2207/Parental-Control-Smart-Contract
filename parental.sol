// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ParentalControl {
    address public parent;
    address public child;
    uint256 public spendingLimit;
    uint256 public lastWithdrawalTime;
    uint256 public withdrawalCooldown = 1 days;

    modifier onlyParent() {
        require(msg.sender == parent, "Only parent can perform this action");
        _;
    }

    modifier onlyChild() {
        require(msg.sender == child, "Only child can perform this action");
        _;
    }

    constructor(address _child, uint256 _limit) {
        parent = msg.sender;
        child = _child;
        spendingLimit = _limit;
    }

    // Allow parent to deposit funds
    receive() external payable {}

    // Allow parent to update child
    function setChild(address _child) external onlyParent {
        child = _child;
    }

    // Allow parent to set a spending limit
    function setSpendingLimit(uint256 _limit) external onlyParent {
        spendingLimit = _limit;
    }

    // Child can withdraw within spending limit and time restrictions
    function withdraw(uint256 amount) external onlyChild {
        require(amount <= spendingLimit, "Exceeds spending limit");
        require(address(this).balance >= amount, "Insufficient contract balance");
        require(block.timestamp >= lastWithdrawalTime + withdrawalCooldown, "Withdrawal cooldown in effect");

        lastWithdrawalTime = block.timestamp;
        payable(child).transfer(amount);
    }

    // Parent can withdraw all funds if needed
    function emergencyWithdraw() external onlyParent {
        payable(parent).transfer(address(this).balance);
    }

    // View contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
