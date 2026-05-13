// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

contract GoodVault {
    mapping(address => uint) public balances;
    address public immutable owner;
    bool private locked;

    modifier nonReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    constructor() {
        owner = msg.sender;
    }

    // Fix tx.origin → msg.sender
    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // Fix CEI pattern + nonReentrant
    function withdraw() public nonReentrant {
        uint amount = balances[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        balances[msg.sender] = 0;        // EFFECT trước

        (bool success, ) = msg.sender.call{value: amount}(""); // INTERACT sau
        require(success, "Transfer failed");
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}