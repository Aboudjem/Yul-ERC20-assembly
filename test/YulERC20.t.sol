// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/YulERC20.sol";

contract YulERC20Test is Test {
    YulERC20 public token;

    address owner;

    function setUp() public {
        vm.startPrank(owner);
        token = new YulERC20();
    }

    function testName() public {
        assertEq(token.name(), "Adam");
    }

    function testSymbol() public {
        assertEq(token.symbol(), "ADX");
    }

    function testDecimals() public {
        assertEq(token.decimals(), 18);
    }

    function testBalanceOf(address) public {
        assertEq(token.balanceOf(owner), type(uint).max);
    }


    function testTransfer(address acc) public {
        assertEq(token.balanceOf(owner), type(uint).max);
        vm.assume(acc != owner);
        assertEq(token.transfer(acc, 100), true);
        assertEq(token.balanceOf(owner), type(uint).max - 100);
    }

    function testApprove(address spender, uint amount) public {
        assertEq(token.approve(spender, amount), true);
        assertEq(token.allowance(owner, spender), amount);
    }

    function testTransferFrom(address spenderAcc, uint amount) public {
        vm.assume(spenderAcc != owner);

        assertEq(token.approve(spenderAcc, amount), true, "Failing approval");
        uint allowance = token.allowance(owner, spenderAcc);
        assertEq(allowance, amount);

        uint ownerBalanceBefore = token.balanceOf(owner);
        uint spenderAccBalanceBefore = token.balanceOf(spenderAcc);

        assertEq(ownerBalanceBefore, type(uint).max, "Balance of Owner should be uintMax");
        assertEq(spenderAccBalanceBefore, 0, "Balance of Spender should be 0");

        vm.stopPrank();
        vm.prank(spenderAcc);
        assertEq(token.transferFrom(owner, spenderAcc, amount), true, "TransferFrom Failed");

        uint ownerBalanceAfter = token.balanceOf(owner);
        uint spenderAccBalanceAfter = token.balanceOf(spenderAcc);

        assertEq(token.allowance(owner, spenderAcc), allowance - amount, "Incorrect allowance");

        assertEq(ownerBalanceAfter, ownerBalanceBefore - amount, "Incorrect owner balance");
        assertEq(spenderAccBalanceAfter, spenderAccBalanceBefore + amount, "Incorrect spender balance");

    }

    function testTotalSupply() public {
        assertEq(token.totalSupply(), type(uint).max);
    }
}
