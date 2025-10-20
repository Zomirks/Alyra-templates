// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    string _name = "Alyra";
    string _symbol = "ALY";
    uint _initialSupply = 1000 * 10 ** 18;
    address _owner = makeAddr("User0");
    address _recipient = makeAddr("User1");
    uint256 _decimal = 18;

    AlyraIsERC20 _myToken;

    function setUp() public {
        vm.prank(_owner);
        _myToken = new AlyraIsERC20(_initialSupply);
    }

    function test_NameIsAlyra() public view {
        string memory name = _myToken.name();
        assertEq(name, _name);
    }
    
    function test_SymbolIsALY() public view {
        string memory symbol = _myToken.symbol();
        assertEq(symbol, _symbol);
    }

    function test_Decimals() public view {
        uint256 decimals = _myToken.decimals();
        assertEq(decimals, _decimal);
    }

    function test_CheckFirstBalance() public view {
        uint256 balanceOfOwner = _myToken.balanceOf(_owner);
        assertEq(balanceOfOwner, _initialSupply);
    }

    function test_CheckBalanceAfterTransfer() public {
        uint256 amountToTransfer = 100;
        // Get the balance of the owner and the recipient before the transfer
        uint256 balanceOwnerBeforeTransfert = _myToken.balanceOf(_owner);
        uint256 balanceRecipientBeforeTransfert = _myToken.balanceOf(_recipient);
        assertEq(balanceRecipientBeforeTransfert, 0);

        // Owner transfers 100 to recipient
        vm.prank(_owner);
        _myToken.transfer(_recipient, amountToTransfer);

        uint256 balanceOwnerAfterTransfert = _myToken.balanceOf(_owner);
        uint256 balanceRecipientAfterTransfert = _myToken.balanceOf(_recipient);

        uint256 expectedBalanceOwnerAfterTransfert = balanceOwnerBeforeTransfert - amountToTransfer;
        uint256 expectedBalanceRecipientAfterTransfert = balanceRecipientBeforeTransfert + amountToTransfer;
        
        assertEq(balanceOwnerAfterTransfert, expectedBalanceOwnerAfterTransfert);
        assertEq(balanceRecipientAfterTransfert, expectedBalanceRecipientAfterTransfert);
    }

    function test_CheckIfApprovalDone() public {
        uint256 amount = 100;
        uint256 allowanceBeforeApproval = _myToken.allowance(_owner, _recipient);
        assertEq(allowanceBeforeApproval, 0);

        vm.prank(_owner);
        _myToken.approve(_recipient, amount);

        uint256 allowanceAfterApproval = _myToken.allowance(_owner, _recipient);
        assertEq(allowanceAfterApproval, amount);
    }

    function test_CheckIfTransferFromDone() public {
        uint256 amount = 100;
        vm.prank(_owner);
        _myToken.approve(_recipient, amount);

        uint256 balanceOwnerBeforeTransfert = _myToken.balanceOf(_owner);
        uint256 balanceRecipientBeforeTransfert = _myToken.balanceOf(_recipient);
        assertEq(balanceOwnerBeforeTransfert, _initialSupply);
        assertEq(balanceRecipientBeforeTransfert, 0);

        uint256 expectedAllowance = _myToken.allowance(_owner, _recipient);
        assertEq(expectedAllowance, amount);

        vm.prank(_recipient);
        _myToken.transferFrom(_owner, _recipient, amount);

        uint256 balanceOwnerAfterTransfert = _myToken.balanceOf(_owner);
        uint256 balanceRecipientAfterTransfert = _myToken.balanceOf(_recipient);

        uint256 expectedBalanceOwnerAfterTransfert = balanceOwnerBeforeTransfert - amount;
        uint256 expectedBalanceRecipientAfterTransfert = balanceRecipientBeforeTransfert + amount;
        assertEq(balanceOwnerAfterTransfert, expectedBalanceOwnerAfterTransfert);
        assertEq(balanceRecipientAfterTransfert, expectedBalanceRecipientAfterTransfert);
    }
}
