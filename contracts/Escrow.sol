// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Escrow {
    address public marketplace;

    struct Payment {
        address seller;
        address buyer;
        uint256 amount;
        bool released;
    }

    mapping(uint256 => Payment) public payments;

    modifier onlyMarketplace() {
        require(msg.sender == marketplace, "Only marketplace allowed");
        _;
    }

    constructor(address _marketplace) {
        marketplace = _marketplace;
    }

    function deposit(uint256 listingId, address seller, address buyer) external payable onlyMarketplace {
        require(payments[listingId].amount == 0, "Already paid");

        payments[listingId] = Payment(seller, buyer, msg.value, false);
    }

    function releaseFunds(uint256 listingId) external onlyMarketplace {
        Payment storage payment = payments[listingId];
        require(!payment.released, "Already released");

        payment.released = true;
        payable(payment.seller).transfer(payment.amount);
    }

    function refund(uint256 listingId) external onlyMarketplace {
        Payment storage payment = payments[listingId];
        require(!payment.released, "Already released");

        payment.released = true;
        payable(payment.buyer).transfer(payment.amount);
    }
}