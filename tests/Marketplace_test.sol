// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "remix_tests.sol";                      // Remix test assertion library
import "../contracts/Escrow.sol";              // Import Escrow contract
import "../contracts/Marketplace.sol";         // Import Marketplace contract

contract MarketplaceTest {

    Marketplace marketplace;                   // Marketplace instance
    Escrow escrow;                              // Escrow instance

    // Setup: runs once before all tests
    function beforeAll() public {
        escrow = new Escrow(address(this));                // Deploy Escrow with test contract as marketplace
        marketplace = new Marketplace(address(escrow));    // Deploy Marketplace with escrow address
    }

    // Test listing an item
    function testListItem() public {
        marketplace.listItem(1 ether, "product-001");      // List an item with 1 ether price

        // Fetch listing details
        (address seller,, string memory productId, bool active) = marketplace.listings(0);

        // Check expected values
        Assert.equal(seller, address(this), "Seller should be test contract");
        Assert.equal(productId, "product-001", "Product ID should match");
        Assert.equal(active, true, "Listing should be active");
    }

    // Test purchasing a listed item
    function testPurchaseItem() public {
        marketplace.purchaseItem{value: 1 ether}(0);       // Purchase the first listing with 1 ether

        (, , , bool active) = marketplace.listings(0);     // Check that the listing is now inactive
        Assert.equal(active, false, "Listing should be inactive after purchase");

        // Check escrow values stored
        (address escSeller, address escBuyer, uint amount, bool released) = escrow.payments(0);
        Assert.equal(escSeller, address(this), "Escrow seller mismatch");
        Assert.equal(escBuyer, address(this), "Escrow buyer mismatch");
        Assert.equal(amount, 1 ether, "Escrow amount mismatch");
        Assert.equal(released, false, "Should not be released yet");
    }

    // Test cancelling a listing
    function testCancelListing() public {
        marketplace.listItem(2 ether, "product-002");      // Add another listing
        marketplace.cancelListing(1);                      // Cancel the new listing

        (, , , bool active) = marketplace.listings(1);     // Ensure it's marked as inactive
        Assert.equal(active, false, "Listing should be inactive after cancellation");
    }

    // Allow contract to receive ether during test
    receive() external payable {}
}
