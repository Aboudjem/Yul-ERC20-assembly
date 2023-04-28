// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/YulERC20.sol";

contract YulERC20Test is Test {
    YulERC20 public token;

    address owner;

    function setUp() public {
        vm.prank(owner);
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
        assertEq(token.balanceOf(owner), 10000);
    }


    function testTransfer(address acc) public {

        assertEq(token.balanceOf(owner), 10000);
        vm.prank(owner);
        vm.assume(acc != owner);
        assertEq(token.transfer(acc, 100), true);

        assertEq(token.balanceOf(owner), 9900);

//        assertEq(token.transfer(acc, amount), true);
    }
}
