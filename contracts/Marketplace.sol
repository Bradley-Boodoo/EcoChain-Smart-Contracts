// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20; 

import "./Escrow.sol"; 

contract Marketplace {

    // Product Listing Struct
    struct Listing {
        address seller;     // Seller Address
        uint256 price;      // Item Price in wei
        string productId;   // Product ID
        bool active;        // Whether the listing is active or not
    }

    uint256 public listingCounter; // Listing ID Counter
    mapping(uint256 => Listing) public listings; // Mapping from listing ID to Listing
    address public escrowAddress; // Address of the deployed Escrow contract

    // Event emitted when an item is listed
    event ItemListed(uint256 indexed listingId, address indexed seller, uint256 price, string productId);

    // Event emitted when an item is purchased
    event ItemPurchased(uint256 indexed listingId, address indexed buyer);

    // Event emitted when a listing is cancelled
    event ListingCancelled(uint256 indexed listingId);

    // Constructor to set the escrow contract address at deployment
    constructor(address _escrowAddress) {
        escrowAddress = _escrowAddress;
    }

    // Function to list an item for sale
    function listItem(uint256 price, string calldata productId) external {
        
        // Create a new listing and store it in the mapping
        listings[listingCounter] = Listing(msg.sender, price, productId, true);
        
        // Emit event for logging
        emit ItemListed(listingCounter, msg.sender, price, productId);
 
        listingCounter++;
    }

    // Function to purchase an item
    function purchaseItem(uint256 listingId) external payable {
        Listing storage item = listings[listingId]; // Load the listing from storage
        require(item.active, "Item not active"); // Ensure the item is available
        require(msg.value == item.price, "Incorrect price"); // Buyer must send exact price

        item.active = false; // Deactivate listing so it can't be purchased again

        // Forward the payment to the escrow contract with necessary metadata
        Escrow(escrowAddress).deposit{value: msg.value}(listingId, item.seller, msg.sender);

        // Emit event for logging
        emit ItemPurchased(listingId, msg.sender);
    }

    // Function to cancel an active listing
    function cancelListing(uint256 listingId) external {
        Listing storage item = listings[listingId]; // Load the listing from storage
        require(msg.sender == item.seller, "Only seller can cancel"); // Only the seller can cancel
        require(item.active, "Listing not active"); // Ensure listing is still active

        item.active = false; // Mark as inactive
        
        emit ListingCancelled(listingId); // Emit cancellation event
    }
}

