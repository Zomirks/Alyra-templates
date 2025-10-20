// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

error NumberOutOfRange();

contract SimpleStorage2 {
    event NumberChanged(address indexed by, uint256 number);

    mapping(address => uint) private addressToNumber;

    function setNumber(uint256 number) external {
        if(number >= 10) {
            revert NumberOutOfRange();
        }
        addressToNumber[msg.sender] = number;
        emit NumberChanged(msg.sender, number);
    }
    
    function getNumber() external view returns(uint) {
        return addressToNumber[msg.sender];
    }
}