// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

// Define constants for the name, symbol, and other properties of the token.
bytes32 constant nameData = 0x4164616D00000000000000000000000000000000000000000000000000000000;
bytes32 constant nameLength = 0x0000000000000000000000000000000000000000000000000000000000000004;

bytes32 constant symbolData = 0x4144580000000000000000000000000000000000000000000000000000000000;
bytes32 constant symbolLength = 0x0000000000000000000000000000000000000000000000000000000000000003;

//AllowanceError()
bytes32 constant allowanceError = 0x689c22716bc6f868769c9f108f2504c1a1115ab4db66410e8a48bd8797222bb7;
//TransferError()
bytes32 constant transferError = 0x4ffddc7cd3d35a21977f8035daee75dcf80dc6f05d181b97b2492a7f85bc4a0d;

bytes32 constant transferHash = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;
bytes32 constant approvalHash = 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;

/// @title YulERC20 - An example of a token contract using Yul assembly for low-level EVM interactions.
contract YulERC20 {

    // Internal mappings to store balances and allowances
    mapping(address => uint256) internal _balances;
    mapping(address => uint256) internal _allowances;

    uint internal _totalSupply;

    /// @notice Constructor initializes the contract, setting the initial balance for the deployer.
    constructor() {
        assembly {
            mstore(0x00, caller())
            mstore(0x20, 0x00)
            let slot := keccak256(0x00, 0x40)
            sstore(slot, not(0))
            sstore(0x02, not(0))
            mstore(0x00, not(0))
            log3(0x00, 0x20, transferHash, 0x00, caller())
        }

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
