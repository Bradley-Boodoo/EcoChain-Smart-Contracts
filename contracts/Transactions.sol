// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TransactionLedger {
    struct Transaction {
        address buyer;
        address seller;
        string productId;
        uint256 amount;
        uint256 timestamp;
    }

    Transaction[] public transactions;

    event TransactionRecorded(uint256 indexed id, address indexed buyer, address indexed seller, string productId, uint256 amount);

    function recordTransaction(address buyer, address seller, string calldata productId, uint256 amount) external {
        transactions.push(Transaction(buyer, seller, productId, amount, block.timestamp));
        emit TransactionRecorded(transactions.length - 1, buyer, seller, productId, amount);
    }

    function getTransaction(uint256 id) external view returns (Transaction memory) {
        return transactions[id];
    }

    function getAllTransactions() external view returns (Transaction[] memory) {
        return transactions;
    }
}
