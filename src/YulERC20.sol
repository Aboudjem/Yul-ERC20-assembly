// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

// The name of the token.
bytes32 constant nameData = 0x4164616D00000000000000000000000000000000000000000000000000000000;
bytes32 constant nameLength = 0x0000000000000000000000000000000000000000000000000000000000000004;

// The symbol of the token.
bytes32 constant symbolData = 0x4144580000000000000000000000000000000000000000000000000000000000;
bytes32 constant symbolLength = 0x0000000000000000000000000000000000000000000000000000000000000003;

// The error message for insufficient allowance.
bytes32 constant allowanceError = 0x689c22716bc6f868769c9f108f2504c1a1115ab4db66410e8a48bd8797222bb7;

// The error message for insufficient balance to transfer.
bytes32 constant transferError = 0x4ffddc7cd3d35a21977f8035daee75dcf80dc6f05d181b97b2492a7f85bc4a0d;

// The hash of the Transfer event signature.
bytes32 constant transferHash = 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef;

// The hash of the Approval event signature.
bytes32 constant approvalHash = 0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925;

/// @author Aboudjem - Adam BOUDJEMAA
/// @title YulERC20 - An example of a token contract using Yul assembly for low-level EVM interactions.
contract YulERC20 {
    /// Mapping to store token balances for each address no need to implement it
    // mapping(address => uint256) internal _balances;

    /// Mapping to store token allowances for each pair of owner and spender addresses no need to implement it
    // mapping(address=> mapping(address => uint256)) internal _allowances;

    /// The total supply of the token.
    uint internal _totalSupply;

    /// @notice Constructor initializes the contract, setting the initial balance for the deployer.
    constructor() {
        assembly {
            // Store the initial balance for the deployer (caller) in the balances mapping
            mstore(0x00, caller())
            mstore(0x20, 0x00)
            let slot := keccak256(0x00, 0x40)
            sstore(slot, not(0))

            // Set the total supply to the maximum possible value (not(0))
            sstore(0x02, not(0))

            // Emit Transfer event for the initial token distribution
            mstore(0x00, not(0))
            log3(0x00, 0x20, transferHash, 0x00, caller())
        }
    }

    /// @notice Transfers tokens from the caller to the specified address.
    /// @return A boolean indicating whether the transfer was successful.
    function transfer(address, uint256) public returns (bool) {
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
                // Store the transferError hash
                mstore(0x00, transferError)
                // Revert if the caller's balance is less than the transfer value
                revert(0x00, 0x20)
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
            return(0x00, 0x20)
        }
    }

    /// @notice Approves `spender` to spend `amount` tokens on behalf of the `caller()`.
    /// @param spender The address of the spender who is allowed to spend tokens on behalf of the caller.
    /// @param amount The number of tokens that the spender is allowed to spend.
    /// @return A boolean value indicating whether the operation succeeded.
    function approve(address spender, uint256 amount) public returns (bool) {
        assembly {
            // Calculate allowance storage slot for spender
            mstore(0x00, caller())
            mstore(0x20, 0x01)
            let innerHash := keccak256(0x00, 0x40)
            mstore(0x00, spender)
            mstore(0x20, innerHash)
            let allowanceSlot := keccak256(0x00, 0x40)

            // Update allowance value
            sstore(allowanceSlot, amount)

            // Emit Approval event
            mstore(0x00, amount)
            log3(0x00, 0x20, approvalHash, caller(), spender)

            // Set return value to true (success) and return
            mstore(0x00, 0x01)
            return(0x00, 0x20)
        }
    }

    /// @notice Transfers `amount` tokens from `sender` to `receiver` on behalf of the `caller()`.
    /// @param sender The address of the token holder.
    /// @param receiver The address of the token recipient.
    /// @param amount The number of tokens to transfer.
    /// @return A boolean value indicating whether the operation succeeded.
    function transferFrom(
        address sender,
        address receiver,
        uint256 amount
    ) public returns (bool) {
        assembly {
            // Set memory pointer for error messages
            let memptr := mload(0x40)

            // Calculate allowance storage slot for caller
            mstore(0x00, sender)
            mstore(0x20, 0x01)
            let innerHash := keccak256(0x00, 0x40)
            mstore(0x00, caller())
            mstore(0x20, innerHash)
            let allowanceSlot := keccak256(0x00, 0x40)

            // Load allowance value
            let callerAllowance := sload(allowanceSlot)

            // Check if allowance is sufficient
            if lt(callerAllowance, amount) {
                mstore(memptr, allowanceError)
                mstore(add(memptr, 0x04), sender)
                mstore(add(memptr, 0x24), caller())
                revert(memptr, 0x44)
            }

            // If allowance is not unlimited, decrease allowance
            if not(eq(callerAllowance, not(0))) {
                sstore(allowanceSlot, sub(callerAllowance, amount))
            }

            // Calculate sender's balance storage slot
            mstore(memptr, sender)
            mstore(add(memptr, 0x20), 0x00)
            let senderBalanceSlot := keccak256(memptr, 0x40)

            // Load sender's balance
            let senderBalance := sload(senderBalanceSlot)

            // Check if sender's balance is sufficient
            if lt(senderBalance, amount) {
                mstore(0x00, transferError)
                revert(0x00, 0x04)
            }

            // Update sender's balance
            sstore(senderBalanceSlot, sub(senderBalance, amount))

            // Calculate receiver's balance storage slot
            mstore(memptr, receiver)
            mstore(add(memptr, 0x20), 0x00)
            let receiverBalanceSlot := keccak256(memptr, 0x40)

            // Load receiver's balance
            let receiverBalance := sload(receiverBalanceSlot)

            // Update receiver's balance
            sstore(receiverBalanceSlot, add(receiverBalance, amount))

            // Emit Transfer event
            mstore(0x00, amount)
            log3(0x00, 0x20, transferHash, sender, receiver)

            // Set return value to true (success) and return
            mstore(0x00, 0x01)
            return(0x00, 0x20)
        }
    }

    /// @notice Returns the balance of the given address.
    /// @return The balance of the given address as a uint256.
    function balanceOf(address) public view returns (uint256) {
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

    function allowance(
        address owner,
        address spender
    ) public view returns (uint) {
        assembly {
            // Load the owner address into memory at position 0x00
            mstore(0x00, owner)
            // Load the constant value 0x01 into memory at position 0x20
            mstore(0x20, 0x01)
            // Compute the inner hash by hashing the memory contents at positions 0x00 and 0x20 (64 bytes)
            let innerHash := keccak256(0x00, 0x40)

            // Load the spender address into memory at position 0x00
            mstore(0x00, spender)
            // Load the inner hash into memory at position 0x20
            mstore(0x20, innerHash)

            // Compute the allowance storage slot by hashing the memory contents at positions 0x00 and 0x20 (64 bytes)
            let allowanceSlot := keccak256(0x00, 0x40)

            // Load the allowance value from the computed storage slot
            let allowanceValue := sload(allowanceSlot)

            // Store the allowance value in memory at position 0x00
            mstore(0x00, allowanceValue)

            // Return the allowance value stored in memory at position 0x00
            // The second argument, 0x20, specifies the size of the returned data (32 bytes)
            return(0x00, 0x20)
        }
    }

    /// @notice Returns the total supply of tokens.
    /// @return The total supply of tokens.
    function totalSupply() public view returns (uint) {
        assembly {
            // Load the value stored at storage slot 0x02 into memory at position 0x00
            mstore(0x00, sload(0x02))
            // Return the value stored in memory at position 0x00
            // The second argument, 0x20, specifies the size of the returned data (32 bytes)
            return(0x00, 0x20)
        }
    }

    /// @notice Returns the name of the token.
    /// @return The name of the token as a string.
    function name() public pure returns (string memory) {
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
    function symbol() public pure returns (string memory) {
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
    function decimals() public pure returns (uint8) {
        assembly {
            // Store the number of decimals
            mstore(0, 18)
            // Return the memory containing the decimals value
            return(0x00, 0x20)
        }
    }
}
