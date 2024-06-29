# JoKenPo Smart Contract

This Solidity smart contract implements a game of Rock, Paper, Scissors (JoKenPo) with the ability to play against another player and determine the winner based on the traditional rules of the game.

## Rules of the Game

- **Rock** beats **Scissors**
- **Scissors** beats **Paper**
- **Paper** beats **Rock**

If both players choose the same option, the game results in a draw.

## Contract Details

### Contract Address
- Not published yet😑

### Contract Owner
The contract owner is set during deployment and manages the contract's operations.

### State Variables
- **result**: Public variable indicating the result of the latest game.
- **player1**: Address of the first player who initiates the game.
- **choice1**: Private variable storing the choice of the first player.
- **owner**: Immutable address of the contract owner who receives the ether from the game.

### Functions

#### `constructor()`
- Initializes the contract and sets the owner to the deployer's address.

#### `play(Options newChoice) public payable`
- Allows a player to choose an option (`ROCK`, `PAPER`, `SCISSORS`) and place a bet of at least 0.01 ether.
- Checks if it's the first player's turn or the second player's turn and determines the winner based on the choices.
- Transfers the ether balance to the winner and the contract owner according to the game outcome.

#### `finishGame(string memory newResult, address winner) private`
- Internal function to finalize the game, update the result, reset player state, and transfer ether to the winner and the contract owner.

### Usage
To interact with this contract:
1. Deploy it on a supported Ethereum network.
2. Use a compatible Ethereum wallet (e.g., MetaMask) to play the game by calling the `play` function with the desired choice and the correct amount of ether.
3. Alternatively, you can use [Remix](https://remix.ethereum.org/) — an online Solidity IDE — to deploy and interact with the contract directly from your web browser.
   
### Development
- Solidity Version: 0.8.12
- SPDX License Identifier: MIT

### Disclaimer
This contract is provided as-is with no warranties or guarantees. Use it at your own risk.
