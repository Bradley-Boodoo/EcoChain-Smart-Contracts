// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; 

contract Escrow {
     address public marketplace; // Will be set after deployment

    // Payment Details Struct
    struct Payment {
        address seller;     // Seller to receive funds
        address buyer;      // Buyer who sent funds
        uint256 amount;     // Amount held in escrow
        bool released;      // Whether the funds have been released or refunded
    }

    // Mapping from listing ID to its payment information
    mapping(uint256 => Payment) public payments;

    // Modifier to restrict access to the Marketplace contract only
    modifier onlyMarketplace() {
        require(msg.sender == marketplace, "Only marketplace allowed");
        _; // Continue execution
    }

    constructor() {
        // Empty constructor, marketplace will be set later
    }

     // Set Marketplace address once deployed
    function setMarketplace(address _marketplace) external {
        require(marketplace == address(0), "Marketplace already set");
        marketplace = _marketplace;
    }

    // Function to deposit funds into escrow
    // Only callable by the Marketplace contract
    function deposit(uint256 listingId, address seller, address buyer) external payable onlyMarketplace {
        require(payments[listingId].amount == 0, "Already paid"); // Prevent double deposits

        // Store payment information for the listing
        payments[listingId] = Payment(seller, buyer, msg.value, false);
    }

    // Function to release funds to the seller
    // Can only be triggered by the Marketplace contract
    function releaseFunds(uint256 listingId) external onlyMarketplace {
        Payment storage payment = payments[listingId]; // Load payment from storage
        require(!payment.released, "Already released"); // Ensure funds haven't already been sent

        payment.released = true; // Mark as released
        payable(payment.seller).transfer(payment.amount); // Transfer funds to seller
    }

    // Function to refund the buyer
    // Only callable by the Marketplace
    function refund(uint256 listingId) external onlyMarketplace {
        Payment storage payment = payments[listingId]; // Load payment from storage
        require(!payment.released, "Already released"); // Ensure funds haven't already been sent

        payment.released = true; // Mark as released
        payable(payment.buyer).transfer(payment.amount); // Refund the buyer
    }
}
