// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Dai is ERC20 {
    constructor () ERC20('Dai Stable', 'DAI') {}

    function faucet (address recipient, uint amount) external {
        _mint(recipient, amount);
    }
}