// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title ITokenWithGodMode Interface for Token with God Mode
/// @notice Interface for a token with god mode functionality
interface ITokenWithGodMode {
    /// @notice Transfers tokens between addresses
    /// @param from The address to transfer tokens from
    /// @param to The address to transfer tokens to
    /// @param amount The amount of tokens to transfer
    function godModeTransfer(address from, address to, uint256 amount) external;

    /// @notice Event emitted when tokens are transferred using god mode
    /// @param from The address tokens are transferred from
    /// @param to The address tokens are transferred to
    /// @param amount The amount of tokens transferred
    event GodModeTransfer(address indexed from, address indexed to, uint256 amount);

    /// @notice Error thrown when caller is not the god mode address
    error NotGodModeAddress();
}
