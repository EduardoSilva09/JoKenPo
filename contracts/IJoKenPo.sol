// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @title IJoKenPo
 * @dev Interface for a JoKenPo (Rock-Paper-Scissors) game contract.
 * Defines the structure and functions needed for the game.
 */
interface IJoKenPo {
    enum Options {
        NONE,
        ROCK,
        PAPER,
        SCISSORS
    }

    struct Player {
        address wallet;
        uint32 wins;
    }

    /**
     * @dev Retrieves the current bid amount for the game.
     * @return The current bid amount as a uint256 value.
     */
    function getBid() external view returns (uint256);

    /**
     * @dev Retrieves the current balance of the game contract.
     * @return The current balance of the contract as a uint256 value.
     */
    function getBalance() external view returns (uint256);

    /**
     * @dev Retrieves the current commission percentage for the game.
     * @return The commission percentage as a uint8 value.
     */
    function getCommission() external view returns (uint8);

    /**
     * @dev Retrieves the result of the last game played.
     * @return A string describing the result of the last game played.
     */
    function getResult() external view returns (string memory);

    /**
     * @dev Sets a new bid amount for the game.
     * @param newBid The new bid amount to be set, as a uint256 value.
     */
    function setBid(uint256 newBid) external;

    /**
     * @dev Sets a new commission percentage for the game.
     * @param newCommission The new commission percentage to be set, as a uint8 value.
     */
    function setCommission(uint8 newCommission) external;

    /**
     * @dev Allows a player to make a choice and participate in the game.
     * @param newChoice The choice made by the player, represented as an Options enum value.
     */
    function play(Options newChoice) external payable;

    /**
     * @dev Retrieves the leaderboard, which lists players and their wins.
     * @return An array of Player structs representing the current leaderboard.
     */
    function getLeaderboard() external view returns (Player[] memory);
}
