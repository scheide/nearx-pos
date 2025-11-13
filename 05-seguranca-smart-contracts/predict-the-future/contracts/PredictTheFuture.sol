// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title PredictTheFutureChallenge
 * @notice A challenge contract where users attempt to predict a random number (0-9)
 * @dev This contract implements a prediction game where:
 *      1. User locks in a guess (0-9) by depositing 1 ETH
 *      2. After a settlement block, the contract calculates a random answer
 *      3. If the guess matches the answer, user wins 2 ETH (doubles their bet)
 * 
 * Game Flow:
 *   - Deployer funds contract with 1 ETH (constructor)
 *   - User calls lockInGuess(n) with 1 ETH to lock in guess 'n'
 *   - Settlement block is set to current block + 1
 *   - User waits for settlement block to pass
 *   - User calls settle() to check if their guess matches the answer
 *   - If match: user receives 2 ETH, contract balance decreases
 *   - If no match: user loses 1 ETH, state resets for next player
 * 
 * Answer Calculation:
 *   - Answer is derived from: keccak256(blockhash(block.number - 1), block.timestamp) % 10
 *   - This creates a pseudo-random number between 0-9
 *   - The answer depends on blockchain data that exists when settle() is called
 * 
 * Security Note: This contract has known vulnerabilities:
 *   - The answer can be predicted before calling settle() (predictable randomness)
 *   - State resets allow unlimited retry attempts without additional payment
 *   - Block timestamp manipulation by miners is possible
 */
contract PredictTheFutureChallenge {
    /// @notice Address of the user who has locked in a guess
    /// @dev Set to address(0) when no guess is locked or after settlement
    address guesser;

    /// @notice The guess (0-9) that was locked in by the guesser
    /// @dev Valid values are 0-9 (uint8 range, but only 0-9 are used)
    uint8 guess;

    /// @notice The block number after which settlement can occur
    /// @dev Set to block.number + 1 when guess is locked
    ///      settle() can only be called when block.number > settlementBlockNumber
    uint256 settlementBlockNumber;

    /**
     * @notice Constructor that initializes the contract with initial funding
     * @dev The deployer must send exactly 1 ETH to fund the contract
     *      This ETH becomes the prize pool for the first winner
     *      The contract balance should be 1 ETH after deployment
     */
    constructor() payable {
        require(msg.value == 1 ether, "Must send exactly 1 ether to fund the contract");
    }

    /**
     * @notice Checks if the challenge is complete
     * @return true if contract balance is 0 (all funds have been paid out)
     * @dev Used to determine if the challenge has been solved/completed
     *      Returns true when contract balance reaches 0 (winner has been paid)
     */
    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    /**
     * @notice Locks in a guess by depositing 1 ETH
     * @param n The guess (0-9) that the user wants to lock in
     * @dev Function is payable and requires exactly 1 ETH
     * 
     * Requirements:
     *   - No guess must be currently locked (guesser == address(0))
     *   - Must send exactly 1 ETH with the transaction
     *   - Guess 'n' should be between 0-9 (not enforced, but expected)
     * 
     * Effects:
     *   - Sets guesser to msg.sender
     *   - Stores the guess 'n'
     *   - Sets settlementBlockNumber to current block + 1
     *   - Adds 1 ETH to contract balance
     * 
     * After this function:
     *   - The guesser must wait for at least 1 block before calling settle()
     *   - The settlement will use data from the block after the guess was locked
     */
    function lockInGuess(uint8 n) public payable {
        // Ensure no guess is currently locked
        // This allows only one guesser at a time
        require(guesser == address(0), "A guess is already locked in");

        // Require exactly 1 ETH deposit
        // This is the bet amount - if user wins, they get 2 ETH back (2x return)
        require(msg.value == 1 ether, "Must deposit exactly 1 ether");

        // Store the guesser's address
        // This ensures only the guesser can call settle() later
        guesser = msg.sender;

        // Store the guess (0-9)
        // This is the number the user is betting on
        guess = n;

        // Set the settlement block to the next block
        // This means settle() can be called starting from block.number + 2
        // (block.number must be > settlementBlockNumber, so minimum is settlementBlockNumber + 1)
        settlementBlockNumber = block.number + 1;
    }

    /**
     * @notice Settles the challenge by calculating the answer and checking if guess matches
     * @dev This function calculates a pseudo-random answer and compares it to the locked guess
     * 
     * Answer Calculation Process:
     *   1. Gets the blockhash of the previous block (block.number - 1)
     *   2. Gets the current block's timestamp
     *   3. Hashes them together: keccak256(blockhash, timestamp)
     *   4. Takes modulo 10 to get a number between 0-9
     * 
     * Security Considerations:
     *   - blockhash(block.number - 1) is publicly known once that block is mined
     *   - block.timestamp is known when the current block is mined
     *   - This means the answer can be calculated before calling settle()
     *   - An attacker could predict the answer and only call settle() when they win
     * 
     * Requirements:
     *   - Only the guesser can call this function
     *   - Current block number must be greater than settlementBlockNumber
     * 
     * Effects:
     *   - Resets guesser to address(0) (allows new guesses)
     *   - If guess matches answer: transfers 2 ETH to the guesser
     *   - If guess doesn't match: no transfer, guesser loses 1 ETH (already deposited)
     * 
     * State Reset Issue:
     *   - guesser is reset even if the guess was wrong
     *   - This allows the same user to immediately lock in a new guess
     *   - Combined with predictable randomness, this enables exploitation
     */
    function settle() public {
        // Ensure only the guesser can call this function
        // This prevents others from settling on behalf of the guesser
        require(msg.sender == guesser, "Only the guesser can settle");

        // Ensure we've passed the settlement block
        // This gives at least 1 block between locking the guess and settling
        // The answer calculation uses block.number - 1, so we need that block to exist
        require(block.number > settlementBlockNumber, "Settlement block not reached yet");

        // Calculate the answer using blockchain data
        // Formula: keccak256(blockhash(previous_block), current_timestamp) % 10
        //
        // Step-by-step:
        //   1. blockhash(block.number - 1): Gets the hash of the previous block
        //      - This is a deterministic value that's publicly known once that block is mined
        //      - blockhash() returns bytes32 (256 bits)
        //   2. block.timestamp: Current block's timestamp (seconds since Unix epoch)
        //      - Set by miners, must be within ±15 seconds of actual time
        //      - Known when the block is mined
        //   3. abi.encodePacked(): Concatenates the two values into a byte array
        //      - Creates a single bytes array from blockhash and timestamp
        //   4. keccak256(): Hashes the concatenated data
        //      - Produces a deterministic but seemingly random 32-byte hash
        //   5. uint256(): Converts the bytes32 hash to a uint256 integer
        //   6. % 10: Takes modulo 10 to get a number between 0-9
        //   7. uint8(): Converts to uint8 (though the value is already 0-9)
        //
        // The result is a pseudo-random number between 0-9
        // However, since both inputs are known/predictable, the answer can be calculated beforehand
        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))) % 10);

        // Reset the guesser to allow new guesses
        // NOTE: This happens regardless of whether the guess was correct or not
        // This allows the same user (or anyone) to immediately lock in a new guess
        // Combined with the predictable answer, this creates a vulnerability
        guesser = address(0);

        // Check if the guess matches the calculated answer
        if (guess == answer) {
            // Winner! Transfer 2 ETH to the guesser
            // This doubles their bet (they deposited 1 ETH, get 2 ETH back)
            // The contract should have at least 2 ETH (1 ETH from deployer + 1 ETH from guesser)
            payable(msg.sender).transfer(2 ether);
            // After this transfer, if contract had exactly 2 ETH, balance becomes 0
            // This would make isComplete() return true
        }
        // If guess doesn't match answer:
        //   - No transfer occurs
        //   - The guesser's 1 ETH remains in the contract
        //   - The contract balance increases by 1 ETH (from the losing guess)
        //   - State is reset, allowing a new guess to be locked
    }
}
