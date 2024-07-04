// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Explicitly importing only the required contracts from OpenZeppelin
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// Importing the interface
import {ITokenWithSanctions} from "./ITokenWithSanctions.sol";

/**
 * @title TokenWithSanctions
 * @dev ERC20 token with administrative sanctions capability to ban specified addresses.
 */
contract TokenWithSanctions is ERC20, Ownable(msg.sender), ITokenWithSanctions {
    // Mapping to track banned addresses
    mapping(address => bool) private _banned;

    /**
     * @dev Initializes the token with a name and symbol, and mints an initial supply to the deployer.
     * @param name The name of the token.
     * @param symbol The symbol of the token.
     * @param initialSupply The initial supply of tokens to be minted.
     */
    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }

    /**
     * @notice Checks if an address is banned.
     * @param account The address to check.
     * @return True if the address is banned, false otherwise.
     */
    function isBanned(address account) external view override returns (bool) {
        return _banned[account];
    }

    /**
     * @notice Bans an address from sending and receiving tokens.
     * @dev Only the owner can call this function.
     * @param account The address to be banned.
     */
    function banAddress(address account) external override onlyOwner {
        if (_banned[account]) {
            revert AddressAlreadyBanned(account);
        }
        _banned[account] = true;
        emit BanStatusChanged(account, true);
    }

    /**
     * @notice Unbans an address, allowing it to send and receive tokens again.
     * @dev Only the owner can call this function.
     * @param account The address to be unbanned.
     */
    function unbanAddress(address account) external override onlyOwner {
        if (!_banned[account]) {
            revert AddressNotBanned(account);
        }
        _banned[account] = false;
        emit BanStatusChanged(account, false);
    }

    /**
     * @dev Overrides the transfer function to include ban checks.
     * @param to The address receiving tokens.
     * @param amount The amount of tokens being transferred.
     */
    function transfer(address to, uint256 amount) public override returns (bool) {
        if (_banned[msg.sender]) {
            revert SenderAddressBanned(msg.sender);
        }
        if (_banned[to]) {
            revert RecipientAddressBanned(to);
        }
        return super.transfer(to, amount);
    }

    /**
     * @dev Overrides the transferFrom function to include ban checks.
     * @param from The address sending tokens.
     * @param to The address receiving tokens.
     * @param amount The amount of tokens being transferred.
     */
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        if (_banned[from]) {
            revert SenderAddressBanned(from);
        }
        if (_banned[to]) {
            revert RecipientAddressBanned(to);
        }
        return super.transferFrom(from, to, amount);
    }
}
