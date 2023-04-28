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

    /// @notice Returns the name of the token.
    /// @return The name of the token as a string.
    function name() public pure returns(string memory) {
        assembly {
            // Get the free memory pointer
            let memptr := mload(0x40)

            // Store the length of the name
            mstore(memptr, 0x20)

            // Store the name length
            mstore(add(memptr, 0x20), nameLength)

            // Store the name data
            mstore(add(memptr, 0x40), nameData)

            // Return the memory containing the name
            return(memptr, 0x60)
        }
    }

    /// @notice Returns the symbol of the token.
    /// @return The symbol of the token as a string.
    function symbol() public pure returns(string memory) {
        assembly {
            // Get the free memory pointer
            let memptr := mload(0x40)

            // Store the length of the symbol
            mstore(memptr, 0x20)

            // Store the symbol length
            mstore(add(memptr, 0x20), symbolLength)

            // Store the symbol data
            mstore(add(memptr, 0x40), symbolData)

            // Return the memory containing the symbol
            return(memptr, 0x60)
        }
    }

    /// @notice Returns the number of decimals for the token.
    /// @return The number of decimals as a uint8.
    function decimals() public pure returns(uint8) {
        assembly {
            mstore(0, 18)
            return(0x00, 0x20)
        }
    }

    function balanceOf(address) public view returns(uint256) {
        assembly {
            // Load the input address into memory
            mstore(0x00, calldataload(0x04))
            // Set the second memory word to zero
            mstore(0x20, 0x00)
            // Load the balance from storage using the hash of slot and the input address
            mstore(0x00, sload(keccak256(0x00, 0x40)))
            // Return the memory containing the balance
            return(0x00, 0x20)
        }
    }

    /// @notice Transfers tokens from the caller to the specified address.
    /// @return A boolean indicating whether the transfer was successful.
    function transfer(address, uint256) public returns(bool) {
        assembly {
        // Get the free memory pointer
            let memptr := mload(0x40)
        // Store the caller's address in memory
            mstore(memptr, caller())
        // Set the second memory word to zero
            mstore(add(memptr, 0x20), 0x00)

        // Calculate the storage slot for the caller's balance
            let callerBalanceSlot := keccak256(memptr, 0x40)
        // Load the caller's balance from storage
            let callerBalance := sload(callerBalanceSlot)

        // Load the input transfer value
            let value := calldataload(0x24)
        // Load the input receiver address
        let receiver := calldataload(0x04)
            if lt(callerBalance, value) {
            // Revert if the caller's balance is less than the transfer value
                revert(0x00, 0x00)
            }

        // Calculate the new caller balance
            let newCallerBalance := sub(callerBalance, value)
        // Store the new caller balance
            sstore(callerBalanceSlot, newCallerBalance)

        // Store the receiver address in memory
            mstore(memptr, receiver)
        // Set the second memory word to zero
            mstore(add(memptr, 0x20), 0x00)

        // Calculate the storage slot for the receiver's balance
            let receiverBalanceSlot := keccak256(memptr, 0x40)
        // Load the receiver's balance from storage
            let receiverBalance := sload(receiverBalanceSlot)

        // Calculate the new receiver balance
            let newReceiverBalance := add(receiverBalance, value)
        // Store the new receiver balance
            sstore(receiverBalanceSlot, newReceiverBalance)

            // Store the transfer value in memory
            mstore(0x00, value)

        // Log the transfer event with the transfer hash, caller address, and receiver address
        log3(0x00, 0x20, transferHash, caller(), receiver)


        // Store a "true" value in the first memory word
            mstore(0x00, 0x01)

        // Return the memory containing "true" (0x01) value, indicating a successful transfer
            return(0x00,0x20)
        }
    }
}
