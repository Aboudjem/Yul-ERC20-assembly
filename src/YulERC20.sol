// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

bytes32 constant nameData = 0x4164616D00000000000000000000000000000000000000000000000000000000;
bytes32 constant nameLength = 0x0000000000000000000000000000000000000000000000000000000000000004;

bytes32 constant symbolData = 0x4144580000000000000000000000000000000000000000000000000000000000;
bytes32 constant symbolLength = 0x0000000000000000000000000000000000000000000000000000000000000003;

bytes32 constant error = 0xaabbccdd00000000000000000000000000000000000000000000000000000000;

contract YulERC20 {

    event Transfer(address indexed sender, address indexed receiver, uint256 amount);

    mapping(address => uint256) internal _balances;
    mapping(address => uint256) internal _allowances;

    constructor() {
        _balances[msg.sender] = 10000;
    }

    function name() public pure returns(string memory) {
        assembly {
            let memptr := mload(0x40)
            mstore(memptr, 0x20)
            mstore(add(memptr, 0x20), nameLength)
            mstore(add(memptr, 0x40), nameData)

            return(memptr, 0x60)
        }
    }

    function symbol() public pure returns(string memory) {
        assembly {
            let memptr := mload(0x40)
            mstore(memptr, 0x20)
            mstore(add(memptr, 0x20), nameLength)
            mstore(add(memptr, 0x40), nameData)

            return(memptr, 0x60)
        }
    }
}
