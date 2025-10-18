// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract SimpleStorage is Ownable {
    uint256 private number;
    
    constructor(uint256 _number) Ownable(msg.sender){
        number = _number;
    }
    
    function setNumber(uint256 _number) external {
        number = _number;
    }
    
    function getNumber() external view returns(uint256) {
        return number;
    }
}