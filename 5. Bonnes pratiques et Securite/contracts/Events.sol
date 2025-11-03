// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

contract Charity {
    // define event
    event LogDonate(uint _amount);

    mapping(address => uint) balances;

    function donate() payable public {
        balances[msg.sender] += msg.value;
        // emit event
        emit LogDonate(msg.value);
    }
}

contract Game {
    function buyCoins(Charity charity) payable public {
        // 5% goes to charity
        charity.donate{value:msg.value / 20}();
    }
}