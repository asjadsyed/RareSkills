// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ITokenWithGodMode} from "./ITokenWithGodMode.sol";

/// @title Token with God Mode
/// @notice ERC20 token with god mode functionality allowing a special address to transfer tokens between addresses
contract TokenWithGodMode is ERC20, ITokenWithGodMode {
    /// @notice The address with god mode privileges
    address public godModeAddress;

    /// @notice Constructor to initialize the token with name, symbol, god mode address, and initial supply
    /// @param name The name of the token
    /// @param symbol The symbol of the token
    /// @param _godModeAddress The address with god mode privileges
    /// @param initialSupply The initial supply of tokens to be minted to the initial recipient
    /// @param initialRecipient The address receiving the initial supply of tokens
    constructor(
        string memory name,
        string memory symbol,
        address _godModeAddress,
        uint256 initialSupply,
        address initialRecipient
    ) ERC20(name, symbol) {
        godModeAddress = _godModeAddress;
        _mint(initialRecipient, initialSupply);
    }

    /// @inheritdoc ITokenWithGodMode
    function godModeTransfer(address from, address to, uint256 amount) external override {
        if (msg.sender != godModeAddress) {
            revert NotGodModeAddress();
        }
        _transfer(from, to, amount);
        emit GodModeTransfer(from, to, amount);
    }
}
