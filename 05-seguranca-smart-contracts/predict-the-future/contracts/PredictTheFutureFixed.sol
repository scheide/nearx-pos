// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title PredictTheFutureChallengeFixed
 * @notice Fixed version of PredictTheFutureChallenge with security improvements
 * @dev Implements commit-reveal scheme to prevent predictable randomness attacks
 */
contract PredictTheFutureChallengeFixed {
    struct GuessCommitment {
        address guesser;
        bytes32 commitment; // keccak256(guess, secret)
        uint256 settlementBlockNumber;
        bool revealed;
    }

    mapping(address => GuessCommitment) public commitments;
    uint256 public constant COMMITMENT_PERIOD = 3; // Blocks to wait before revealing
    uint256 public constant SETTLEMENT_DELAY = 2; // Blocks after reveal before settlement

    event GuessCommitted(address indexed guesser, bytes32 commitment, uint256 settlementBlock);
    event GuessRevealed(address indexed guesser, uint8 guess, bool revealed);
    event SettlementAttempted(address indexed guesser, uint8 guess, uint8 answer, bool won);
    event PaymentMade(address indexed recipient, uint256 amount);

    constructor() payable {
        require(msg.value == 1 ether, "Must send exactly 1 ether");
    }

    /**
     * @notice Check if challenge is complete
     */
    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    /**
     * @notice Commit to a guess with a secret
     * @param commitment Hash of (guess, secret) - keccak256(abi.encodePacked(guess, secret))
     * @dev User commits to a hash, preventing them from knowing the answer beforehand
     */
    function commitGuess(bytes32 commitment) public payable {
        require(msg.value == 1 ether, "Must send exactly 1 ether");
        require(commitments[msg.sender].guesser == address(0), "Already committed");
        require(commitment != bytes32(0), "Invalid commitment");

        commitments[msg.sender] = GuessCommitment({
            guesser: msg.sender,
            commitment: commitment,
            settlementBlockNumber: block.number + COMMITMENT_PERIOD + SETTLEMENT_DELAY,
            revealed: false
        });

        emit GuessCommitted(msg.sender, commitment, commitments[msg.sender].settlementBlockNumber);
    }

    /**
     * @notice Reveal the guess and secret
     * @param guess The actual guess (0-9)
     * @param secret The secret used to create the commitment
     * @dev Must be called after COMMITMENT_PERIOD blocks
     */
    function revealGuess(uint8 guess, bytes32 secret) public {
        GuessCommitment storage commitment = commitments[msg.sender];
        require(commitment.guesser == msg.sender, "No commitment found");
        require(!commitment.revealed, "Already revealed");
        require(block.number >= commitment.settlementBlockNumber - SETTLEMENT_DELAY, "Too early to reveal");
        require(block.number < commitment.settlementBlockNumber, "Too late to reveal");

        // Verify the commitment
        bytes32 calculatedCommitment = keccak256(abi.encodePacked(guess, secret));
        require(calculatedCommitment == commitment.commitment, "Invalid commitment");

        commitment.revealed = true;
        emit GuessRevealed(msg.sender, guess, true);
    }

    /**
     * @notice Settle the challenge after the settlement block
     * @dev Can only be called after settlement block and if guess was revealed
     */
    function settle() public {
        GuessCommitment storage commitment = commitments[msg.sender];
        require(commitment.guesser == msg.sender, "No commitment found");
        require(commitment.revealed, "Guess must be revealed first");
        require(block.number >= commitment.settlementBlockNumber, "Settlement block not reached");

        // Calculate answer from block data (now unpredictable at commitment time)
        // Use blockhash from settlement block, not predictable blocks
        bytes32 blockHash = blockhash(commitment.settlementBlockNumber - 1);
        require(blockHash != bytes32(0), "Block hash not available");
        
        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockHash, block.timestamp))) % 10);

        // Get the guess from the commitment (we need to recalculate or store it)
        // For simplicity, we'll require the guesser to pass it again, or store it during reveal
        // This is a simplified version - in production, store guess during reveal
        
        // Clear the commitment
        delete commitments[msg.sender];

        emit SettlementAttempted(msg.sender, 0, answer, false); // Simplified for demo
    }

    /**
     * @notice Settle with guess verification
     * @param guess The guess that was revealed
     * @dev Extended version that verifies guess and pays out
     */
    function settleWithGuess(uint8 guess) public {
        GuessCommitment storage commitment = commitments[msg.sender];
        require(commitment.guesser == msg.sender, "No commitment found");
        require(commitment.revealed, "Guess must be revealed first");
        require(block.number >= commitment.settlementBlockNumber, "Settlement block not reached");

        // Calculate answer from block data
        bytes32 blockHash = blockhash(commitment.settlementBlockNumber - 1);
        require(blockHash != bytes32(0), "Block hash not available");
        
        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockHash, block.timestamp))) % 10);

        bool won = (guess == answer);

        // Clear the commitment before external call (checks-effects-interactions)
        delete commitments[msg.sender];

        emit SettlementAttempted(msg.sender, guess, answer, won);

        // Transfer funds if guess was correct
        if (won) {
            uint256 amount = 2 ether;
            require(address(this).balance >= amount, "Insufficient balance");
            
            (bool success, ) = payable(msg.sender).call{value: amount}("");
            require(success, "Transfer failed");
            
            emit PaymentMade(msg.sender, amount);
        }
    }

    /**
     * @notice Get commitment info for an address
     */
    function getCommitment(address guesser) public view returns (
        address,
        bytes32,
        uint256,
        bool
    ) {
        GuessCommitment memory commitment = commitments[guesser];
        return (
            commitment.guesser,
            commitment.commitment,
            commitment.settlementBlockNumber,
            commitment.revealed
        );
    }
}

/**
 * @title PredictTheFutureChallengeImproved
 * @notice Further improved version that stores guess during reveal
 */
contract PredictTheFutureChallengeImproved {
    struct GuessData {
        address guesser;
        bytes32 commitment;
        uint8 guess; // Stored after reveal
        uint256 settlementBlockNumber;
        bool revealed;
    }

    mapping(address => GuessData) public guesses;
    uint256 public constant COMMITMENT_PERIOD = 3;
    uint256 public constant SETTLEMENT_DELAY = 2;

    event GuessCommitted(address indexed guesser, bytes32 commitment, uint256 settlementBlock);
    event GuessRevealed(address indexed guesser, uint8 guess);
    event Settled(address indexed guesser, uint8 guess, uint8 answer, bool won, uint256 payout);

    constructor() payable {
        require(msg.value == 1 ether, "Must send exactly 1 ether");
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function commitGuess(bytes32 commitment) public payable {
        require(msg.value == 1 ether, "Must send exactly 1 ether");
        require(guesses[msg.sender].guesser == address(0), "Already committed");
        require(commitment != bytes32(0), "Invalid commitment");

        guesses[msg.sender] = GuessData({
            guesser: msg.sender,
            commitment: commitment,
            guess: 0, // Will be set during reveal
            settlementBlockNumber: block.number + COMMITMENT_PERIOD + SETTLEMENT_DELAY,
            revealed: false
        });

        emit GuessCommitted(msg.sender, commitment, guesses[msg.sender].settlementBlockNumber);
    }

    function revealGuess(uint8 guess, bytes32 secret) public {
        GuessData storage guessData = guesses[msg.sender];
        require(guessData.guesser == msg.sender, "No commitment found");
        require(!guessData.revealed, "Already revealed");
        require(block.number >= guessData.settlementBlockNumber - SETTLEMENT_DELAY, "Too early");
        require(block.number < guessData.settlementBlockNumber, "Too late");
        require(guess < 10, "Guess must be 0-9");

        bytes32 calculatedCommitment = keccak256(abi.encodePacked(guess, secret));
        require(calculatedCommitment == guessData.commitment, "Invalid commitment");

        guessData.guess = guess;
        guessData.revealed = true;

        emit GuessRevealed(msg.sender, guess);
    }

    function settle() public {
        GuessData storage guessData = guesses[msg.sender];
        require(guessData.guesser == msg.sender, "No commitment found");
        require(guessData.revealed, "Must reveal first");
        require(block.number >= guessData.settlementBlockNumber, "Settlement block not reached");

        bytes32 blockHash = blockhash(guessData.settlementBlockNumber - 1);
        require(blockHash != bytes32(0), "Block hash not available");

        uint8 answer = uint8(uint256(keccak256(abi.encodePacked(blockHash, block.timestamp))) % 10);
        uint8 userGuess = guessData.guess;
        bool won = (userGuess == answer);

        // Clear state before external call
        delete guesses[msg.sender];

        if (won) {
            uint256 amount = 2 ether;
            require(address(this).balance >= amount, "Insufficient balance");

            (bool success, ) = payable(msg.sender).call{value: amount}("");
            require(success, "Transfer failed");

            emit Settled(msg.sender, userGuess, answer, true, amount);
        } else {
            emit Settled(msg.sender, userGuess, answer, false, 0);
        }
    }
}

