// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ITokenWithSanctions
 * @dev Interface for TokenWithSanctions contract.
 */
interface ITokenWithSanctions {
    /**
     * @dev Emitted when an address is banned or unbanned.
     * @param account The address that was banned or unbanned.
     * @param banned True if the address is banned, false otherwise.
     */
    event BanStatusChanged(address indexed account, bool banned);

    // Custom errors for more specific revert messages
    error AddressAlreadyBanned(address account);
    error AddressNotBanned(address account);
    error SenderAddressBanned(address account);
    error RecipientAddressBanned(address account);

    /**
     * @notice Checks if an address is banned.
     * @param account The address to check.
     * @return True if the address is banned, false otherwise.
     */
    function isBanned(address account) external view returns (bool);

    /**
     * @notice Bans an address from sending and receiving tokens.
     * @dev Only the owner can call this function.
     * @param account The address to be banned.
     */
    function banAddress(address account) external;

    /**
     * @notice Unbans an address, allowing it to send and receive tokens again.
     * @dev Only the owner can call this function.
     * @param account The address to be unbanned.
     */
    function unbanAddress(address account) external;
}
