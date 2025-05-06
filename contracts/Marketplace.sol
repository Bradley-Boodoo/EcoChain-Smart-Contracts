// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Escrow.sol";

contract Marketplace {
    struct Listing {
        address seller;
        uint256 price;
        string productId;
        bool active;
    }

    uint256 public listingCounter;
    mapping(uint256 => Listing) public listings;
    address public escrowAddress;

    event ItemListed(uint256 indexed listingId, address indexed seller, uint256 price, string productId);
    event ItemPurchased(uint256 indexed listingId, address indexed buyer);
    event ListingCancelled(uint256 indexed listingId);

    constructor(address _escrowAddress) {
        escrowAddress = _escrowAddress;
    }

    function listItem(uint256 price, string calldata productId) external {
        listings[listingCounter] = Listing(msg.sender, price, productId, true);
        emit ItemListed(listingCounter, msg.sender, price, productId);
        listingCounter++;
    }

    function purchaseItem(uint256 listingId) external payable {
        Listing storage item = listings[listingId];
        require(item.active, "Item not active");
        require(msg.value == item.price, "Incorrect price");

        item.active = false;
        Escrow(escrowAddress).deposit{value: msg.value}(listingId, item.seller, msg.sender);

        emit ItemPurchased(listingId, msg.sender);
    }

    function cancelListing(uint256 listingId) external {
        Listing storage item = listings[listingId];
        require(msg.sender == item.seller, "Only seller can cancel");
        require(item.active, "Listing not active");

        item.active = false;
        emit ListingCancelled(listingId);
    }
}

