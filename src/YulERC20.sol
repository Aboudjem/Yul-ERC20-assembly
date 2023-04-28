// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

bytes32 constant nameData = 0x4164616D00000000000000000000000000000000000000000000000000000000;
bytes32 constant nameLength = 0x0000000000000000000000000000000000000000000000000000000000000004;

bytes32 constant symbolData = 0x4144580000000000000000000000000000000000000000000000000000000000;
bytes32 constant symbolLength = 0x0000000000000000000000000000000000000000000000000000000000000003;

bytes32 constant error = 0xaabbccdd00000000000000000000000000000000000000000000000000000000;

bytes32 constant transferHash = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

contract YulERC20 {


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
            mstore(add(memptr, 0x20), symbolLength)
            mstore(add(memptr, 0x40), symbolData)

            return(memptr, 0x60)
        }
    }

    function decimals() public pure returns(uint8) {
        assembly {
            mstore(0, 18)
            return(0x00, 0x20)
        }
    }

    function balanceOf(address) public view returns(uint256) {
        assembly {
            mstore(0x00, calldataload(0x04))
            mstore(0x20, 0x00)
            mstore(0x00, sload(keccak256(0x00, 0x40)))
            return(0x00, 0x20)
        }
    }

    function transfer(address, uint256) public returns(bool) {
        assembly {
            let memptr := mload(0x40)
            mstore(memptr, caller())
            mstore(add(memptr, 0x20), 0x00)

            let callerBalanceSlot := keccak256(memptr, 0x40)
            let callerBalance := sload(callerBalanceSlot)

            let value := calldataload(0x24)
            let receiver := calldataload(0x04)
            if lt(callerBalance, value) {
                revert(0x00, 0x00) }

            let newCallerBalance := sub(callerBalance, value)
            sstore(callerBalanceSlot, newCallerBalance)

            mstore(memptr, receiver)
            mstore(add(memptr, 0x20), 0x00)


            let receiverBalanceSlot := keccak256(memptr, 0x40)
            let receiverBalance := sload(receiverBalanceSlot)

            let newReceiverBalance := add(receiverBalance, value)

            sstore(receiverBalanceSlot, newReceiverBalance)

            mstore(0x00, value)
            log3(0x00, 0x20, transferHash, caller(), receiver)



            mstore(0x00, 0x01)
            return(0x00,0x20)
        }
    }
}
