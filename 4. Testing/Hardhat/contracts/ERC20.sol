// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract mytoken is ERC20 {

    uint rate = 100;
    address mechant;

    constructor() ERC20("alyratoken","atn"){
        _mint(msg.sender, 10* 10^18);
    }

    function buyToken () payable external {
        uint totaltoken= rate* msg.value; 
        _mint(msg.sender,totaltoken);
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        require(to != mechant);
        return super.transfer(to, value);
    }
 
}