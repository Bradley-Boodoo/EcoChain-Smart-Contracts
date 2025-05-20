// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "remix_tests.sol";          // Remix testing library
import "../contracts/Escrow.sol";  // Escrow contract

contract EscrowTest {
    Escrow escrow;

    // Dummy addresses to simulate seller and buyer
    address dummySeller = address(0x123);
    address dummyBuyer = address(0x456);

    // Set up the escrow contract before tests
    function beforeAll() public {
        escrow = new Escrow(address(this));  // Deploy escrow, test contract acts as the Marketplace
    }

    // Test depositing funds into escrow
    function testDeposit() public {
        escrow.deposit{value: 1 ether}(0, dummySeller, dummyBuyer); // Simulate deposit

        // Read payment info
        (address storedSeller, address storedBuyer, uint amount, bool released) = escrow.payments(0);

        // Validate fields
        Assert.equal(storedSeller, dummySeller, "Seller should match");
        Assert.equal(storedBuyer, dummyBuyer, "Buyer should match");
        Assert.equal(amount, 1 ether, "Amount should match");
        Assert.equal(released, false, "Should not be released yet");
    }

    // Test releasing funds to the seller
    function testReleaseFunds() public {
        escrow.releaseFunds(0);   // Trigger release for listing ID 0

        (, , , bool released) = escrow.payments(0); // Check release flag
        Assert.equal(released, true, "Funds should be released");
    }

    // Test refunding the buyer
    function testRefund() public {
        escrow.deposit{value: 0.5 ether}(1, dummySeller, dummyBuyer); // Simulate second deposit
        escrow.refund(1);                                             // Refund buyer

        (, , , bool released) = escrow.payments(1); // Check release flag
        Assert.equal(released, true, "Funds should be refunded");
    }

    // Enable this contract to receive ether from refunds/releases
    receive() external payable {}
}
