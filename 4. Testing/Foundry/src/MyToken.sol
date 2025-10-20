// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract AlyraIsERC20 is ERC20 {
    constructor(uint initialSupply) ERC20("Alyra","ALY") {
        _mint(msg.sender, initialSupply);
    }
}