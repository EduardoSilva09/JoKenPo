// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

/**
 * @title JoKenPo
 * @dev A smart contract for a Rock-Paper-Scissors game with betting and leaderboard functionality.
 */
contract JoKenPo {
    enum Options {
        NONE,
        ROCK,
        PAPER,
        SCISSORS
    }

    Options private choice1 = Options.NONE;
    address private player1;
    string private result = "";
    address payable private immutable owner;
    uint256 private bid = 0.01 ether;
    uint8 private comission = 10;

    struct Player {
        address wallet;
        uint32 wins;
    }

    Player[] public players;

    /**
     * @dev Constructor that sets the contract owner.
     */
    constructor() {
        owner = payable(msg.sender);
    }

    /**
     * @dev Private function to finish the game and distribute winnings.
     * @param newResult The result message of the game.
     * @param winner The address of the winner.
     */
    function finishGame(string memory newResult, address winner) private {
        address contractAddress = address(this);
        payable(winner).transfer(
            (contractAddress.balance / 100) * (100 - comission)
        );
        owner.transfer(contractAddress.balance);

        updateWinner(winner);

        result = newResult;
        player1 = address(0);
        choice1 = Options.NONE;
    }

    /**
     * @dev Private function to update the winner's win count or add new player.
     * @param winner The address of the winner.
     */
    function updateWinner(address winner) private {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i].wallet == winner) {
                players[i].wins++;
                return;
            }
        }

        players.push(Player(winner, 1));
    }

    /**
     * @dev External function to get the current bid amount.
     * @return The current bid amount in wei.
     */
    function getBid() external view returns (uint256) {
        return bid;
    }

    /**
     * @dev External function to get the current commission percentage.
     * @return The current commission percentage.
     */
    function getCommission() external view returns (uint8) {
        return comission;
    }

    /**
     * @dev External function to get the result of the last game played.
     * @return The result message of the last game.
     */
    function getResult() external view returns (string memory) {
        return result;
    }

    /**
     * @dev External function to set a new bid amount.
     * @param newBid The new bid amount in wei.
     */
    function setBid(uint256 newBid) external restricted {
        require(
            player1 == address(0),
            "You cannot change the bid with a game in progress"
        );
        bid = newBid;
    }

    /**
     * @dev External function to set a new commission percentage.
     * @param newCommission The new commission percentage.
     */
    function setCommission(uint8 newCommission) external restricted {
        require(
            player1 == address(0),
            "You cannot change the commission with a game in progress"
        );
        comission = newCommission;
    }

    /**
     * @dev External function for a player to play the game.
     * @param newChoice The choice (Rock, Paper, Scissors) made by the player.
     */
    function play(Options newChoice) external payable {
        require(msg.sender != owner, "The owner cannot play");
        require(newChoice != Options.NONE, "Invalid choice");
        require(player1 != msg.sender, "Wait for the other player");
        require(msg.value >= bid, "Invalid bid");

        if (choice1 == Options.NONE) {
            player1 = msg.sender;
            choice1 = newChoice;
            result = "Player 1 chose their option. Waiting for player 2.";
        } else if (choice1 == Options.ROCK && newChoice == Options.SCISSORS) {
            finishGame("Rock breaks scissors. Player 1 won.", player1);
        } else if (choice1 == Options.PAPER && newChoice == Options.ROCK) {
            finishGame("Paper wraps rock. Player 1 won.", player1);
        } else if (choice1 == Options.SCISSORS && newChoice == Options.PAPER) {
            finishGame("Scissors cuts paper. Player 1 won.", player1);
        } else if (newChoice == Options.ROCK && choice1 == Options.SCISSORS) {
            finishGame("Rock breaks scissors. Player 2 won.", msg.sender);
        } else if (newChoice == Options.PAPER && choice1 == Options.ROCK) {
            finishGame("Paper wraps rock. Player 2 won.", msg.sender);
        } else if (newChoice == Options.SCISSORS && choice1 == Options.PAPER) {
            finishGame("Scissors cuts paper. Player 2 won.", msg.sender);
        } else {
            result = "Draw game. The prize was doubled.";
            player1 = address(0);
            choice1 = Options.NONE;
        }
    }

    /**
     * @dev Modifier that allows only the contract owner to execute the function.
     */
    modifier restricted() {
        require(owner == msg.sender, "You do not have permission.");
        _;
    }

    /**
     * @dev External function to get the leaderboard of players based on their wins.
     * @return An array of Player structs sorted in descending order of wins.
     */
    function getLeaderboard() external view returns (Player[] memory) {
        if (players.length < 2) return players;

        Player[] memory arr = new Player[](players.length);
        for (uint256 i = 0; i < players.length; i++) arr[i] = players[i];

        for (uint256 i = 0; i < arr.length - 1; i++) {
            for (uint256 j = i + 1; j < arr.length; j++) {
                if (arr[i].wins < arr[j].wins) {
                    Player memory temp = arr[i];
                    arr[i] = arr[j];
                    arr[j] = temp;
                }
            }
        }

        return arr;
    }
}
