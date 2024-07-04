// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {TokenWithGodMode} from "../src/TokenWithGodMode.sol";
import {ITokenWithGodMode} from "../src/ITokenWithGodMode.sol";

contract TokenWithGodModeTest is Test {
    TokenWithGodMode private token;
    address private godModeAddress = address(0x1);
    address private user1 = address(0x2);
    address private user2 = address(0x3);

    function setUp() public {
        token = new TokenWithGodMode("TestToken", "TTK", godModeAddress, 1000, user1);
    }

    function testInitialSupply() public {
        uint256 user1Balance = token.balanceOf(user1);
        assertEq(user1Balance, 1000, "User1 initial balance should be 1000");
    }

    function testGodModeTransfer() public {
        vm.prank(godModeAddress);
        token.godModeTransfer(user1, user2, 500);

        uint256 user1Balance = token.balanceOf(user1);
        uint256 user2Balance = token.balanceOf(user2);

        assertEq(user1Balance, 500, "User1 balance should be 500 after godModeTransfer");
        assertEq(user2Balance, 500, "User2 balance should be 500 after godModeTransfer");
    }

    function testGodModeTransferNotAuthorized() public {
        vm.expectRevert(abi.encodeWithSignature("NotGodModeAddress()"));
        token.godModeTransfer(user1, user2, 500);
    }

    function testEmitGodModeTransferEvent() public {
        vm.prank(godModeAddress);
        vm.expectEmit(true, true, true, true);
        emit ITokenWithGodMode.GodModeTransfer(user1, user2, 500);
        token.godModeTransfer(user1, user2, 500);
    }

    bytes4 constant ERC20InvalidReceiverSelector = bytes4(keccak256("ERC20InvalidReceiver(address)"));

    function testTransferFailed() public {
        vm.prank(godModeAddress);
        vm.expectRevert(abi.encodeWithSelector(ERC20InvalidReceiverSelector, address(0)));
        token.godModeTransfer(user1, address(0), 500); // Invalid transfer to address(0)
    }
}
