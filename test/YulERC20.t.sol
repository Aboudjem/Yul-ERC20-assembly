// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/YulERC20.sol";

contract YulERC20Test is Test {
    YulERC20 public token;

    function setUp() public {
        token = new YulERC20();
    }

    function testName() public {
        assertEq(token.name(), "Adam");
    }

}
