// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/SimpleStorage2.sol";

contract SimpleStorage2Test is Test {
    event NumberChanged(address indexed by, uint256 number);

    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");
    SimpleStorage2 simpleStorage;
    
    function setUp() public {
        simpleStorage = new SimpleStorage2();
    }
    
    function test_NumberIs0() public view {
        uint256 expectedNumber = simpleStorage.getNumber();
        assertEq(expectedNumber, 0);
    }

    function testRevertWhenNumberOutOfRange() public {
        vm.expectRevert(NumberOutOfRange.selector);
        simpleStorage.setNumber(99);
    }

    function test__SetNumberTo7() public {
        simpleStorage.setNumber(7);
        uint256 expectedNumber = simpleStorage.getNumber();
        assertEq(expectedNumber, 7);
    }

    function test_SetNumberWithDifferentUsers() public {
        vm.startPrank(user2);
        simpleStorage.setNumber(6);
        uint expectedNumberUser2 = simpleStorage.getNumber();
        assertEq(expectedNumberUser2, 6);
        vm.stopPrank();
        uint expectedNumberUser1 = simpleStorage.getNumber();
        assertEq(expectedNumberUser1, 0);
    }

    function test_ExpectEmit() public {
        vm.expectEmit(true, false, false, true);
        emit NumberChanged(address(user2), 5);
        vm.startPrank(user2);
        simpleStorage.setNumber(5);
        vm.stopPrank();
    }
}