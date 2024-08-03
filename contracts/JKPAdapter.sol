// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./IJoKenPo.sol";
import "./JKPLibrary.sol";

/**
 * @title JKPAdapter
 * @dev A contract adapter for upgrading the implementation of the IJoKenPo interface.
 * Allows changing the implementation address while ensuring only the owner can perform the upgrade.
 */
contract JKPAdapter {
    IJoKenPo private joKenPo;
    address public immutable owner;

    /**
     * @dev Sets the contract deployer as the owner of the contract.
     * The constructor is called only once when the contract is deployed.
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Retrieves the current address of the JoKenPo implementation contract.
     * @return The address of the current JoKenPo implementation contract.
     */
    function getImplementationAddress() external view returns (address) {
        return address(joKenPo);
    }

    /**
     * @dev Retrieves the result of the most recent game from the current JoKenPo implementation.
     * This function is marked as `upgraded` to ensure it can only be used after the contract has been upgraded.
     * @return A string representing the result of the most recent game.
     */
    function getResult() external view upgraded returns (string memory) {
        return joKenPo.getResult();
    }

    /**
     * @dev Retrieves the current bid amount from the JoKenPo implementation.
     * @return The current bid amount as a uint256 value.
     */
    function getBid() external view upgraded returns (uint256) {
        return joKenPo.getBid();
    }

    /**
     * @dev Retrieves the current commission percentage for the game.
     * @return The commission percentage as a uint8 value.
     */
    function getCommission() external view upgraded returns (uint8) {
        return joKenPo.getCommission();
    }

    /**
     * @dev Retrieves the current balance from the JoKenPo implementation.
     * This function is restricted to only the owner.
     * @return The current balance as a uint256 value.
     */
    function getBalance() external view upgraded restricted returns (uint256) {
        return joKenPo.getBalance();
    }

    /**
     * @dev Sets a new bid amount in the JoKenPo implementation.
     * This function is restricted to only the owner.
     * @param newBid The new bid amount to be set, as a uint256 value.
     */
    function setBid(uint256 newBid) external upgraded restricted {
        return joKenPo.setBid(newBid);
    }

    /**
     * @dev Sets a new commission percentage in the JoKenPo implementation.
     * This function is restricted to only the owner.
     * @param newCommission The new commission percentage to be set, as a uint8 value.
     */
    function setCommission(uint8 newCommission) external upgraded restricted {
        return joKenPo.setCommission(newCommission);
    }
    /**
     * @dev Allows a player to make a choice and participate in the game.
     * This function is marked as `upgraded` to ensure it can only be used after the contract has been upgraded.
     * @param newChoice The choice made by the player, represented as an `Options` enum value from the JKPLibrary.
     * @notice This function accepts Ether, which will be forwarded to the JoKenPo implementation.
     */
    function play(JKPLibrary.Options newChoice) external payable upgraded {
        return joKenPo.play{value: msg.value}(newChoice);
    }

    /**
     * @dev Retrieves the leaderboard from the current JoKenPo implementation.
     * @return An array of Player structs representing the current leaderboard.
     */
    function getLeaderboard()
        external
        view
        upgraded
        returns (JKPLibrary.Player[] memory)
    {
        return joKenPo.getLeaderboard();
    }

    /**
     * @dev Upgrades the implementation of the IJoKenPo interface to a new contract.
     * This function is restricted to only the owner.
     * @param newImplementation The address of the new contract implementing the IJoKenPo interface.
     * @notice The newImplementation address must be non-zero.
     */
    function upgrade(address newImplementation) external restricted {
        require(
            newImplementation != address(0),
            "Empty address is not permited"
        );
        joKenPo = IJoKenPo(newImplementation);
    }

    /**
     * @dev Modifier that ensures the contract has been upgraded with a valid implementation address.
     * If the `joKenPo` address is zero (indicating that it has not been upgraded), the function call will revert.
     * This is used to enforce that certain functions can only be called after a valid upgrade.
     */
    modifier upgraded() {
        require(address(joKenPo) != address(0), "You must upgrade first");
        _;
    }

    /**
     * @dev Modifier that restricts access to certain functions to only the contract owner.
     * If the caller is not the owner, the function call will revert.
     */
    modifier restricted() {
        require(owner == msg.sender, "You do not have permission");
        _;
    }
}
