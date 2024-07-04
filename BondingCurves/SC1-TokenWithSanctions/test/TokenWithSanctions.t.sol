// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {TokenWithSanctions} from "../src/TokenWithSanctions.sol";
import {ITokenWithSanctions} from "../src/ITokenWithSanctions.sol";

contract TokenWithSanctionsTest is Test {
    TokenWithSanctions token;
    address owner = address(0x123);
    address user1 = address(0x456);
    address user2 = address(0x789);

    function setUp() public {
        // Deploy the contract
        token = new TokenWithSanctions("SanctionToken", "STK", 1000 ether);
        token.transfer(user1, 100 ether);
        token.transfer(user2, 100 ether);
    }

    function testInitialSupply() public view {
        // Check initial supply
        assertEq(token.totalSupply(), 1000 ether);
        assertEq(token.balanceOf(owner), 0 ether);
        assertEq(token.balanceOf(user1), 100 ether);
        assertEq(token.balanceOf(user2), 100 ether);
    }

    function testTransfer() public {
        // Transfer tokens between users
        vm.prank(user1);
        token.transfer(user2, 10 ether);

        assertEq(token.balanceOf(user1), 90 ether);
        assertEq(token.balanceOf(user2), 110 ether);
    }

    function testBanSenderAddress() public {
        // Ban an address
        token.banAddress(user1);
        assertTrue(token.isBanned(user1));

        // Try to transfer tokens from a banned address
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(ITokenWithSanctions.SenderAddressBanned.selector, user1));
        token.transfer(user2, 10 ether);
    }

    function testBanRecipientAddress() public {
        // Ban a recipient address
        token.banAddress(user2);
        assertTrue(token.isBanned(user2));

        // Try to transfer tokens to a banned address
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(ITokenWithSanctions.RecipientAddressBanned.selector, user2));
        token.transfer(user2, 10 ether);
    }

    function testUnbanAddress() public {
        // Ban and then unban an address
        token.banAddress(user1);
        assertTrue(token.isBanned(user1));

        token.unbanAddress(user1);
        assertFalse(token.isBanned(user1));

        // Transfer should succeed after unbanning
        vm.prank(user1);
        token.transfer(user2, 10 ether);
        assertEq(token.balanceOf(user1), 90 ether);
        assertEq(token.balanceOf(user2), 110 ether);
    }

    function testBanAndUnbanMultipleAddresses() public {
        // Ban multiple addresses
        token.banAddress(user1);
        token.banAddress(user2);
        assertTrue(token.isBanned(user1));
        assertTrue(token.isBanned(user2));

        // Unban multiple addresses
        token.unbanAddress(user1);
        token.unbanAddress(user2);
        assertFalse(token.isBanned(user1));
        assertFalse(token.isBanned(user2));
    }

    function testBanAndUnbanSameAddress() public {
        // Ban and then unban the same address
        token.banAddress(user1);
        assertTrue(token.isBanned(user1));

        token.unbanAddress(user1);
        assertFalse(token.isBanned(user1));
    }

    function testTransferFromRevert() public {
        // Ban the sender address
        token.banAddress(user1);
        assertTrue(token.isBanned(user1));

        // TransferFrom should revert when sender address is banned
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(ITokenWithSanctions.SenderAddressBanned.selector, user1));
        token.transferFrom(user1, user2, 10 ether);
    }
}
