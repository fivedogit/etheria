// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface Etheria{
	function getOwner(uint8 col, uint8 row) external view returns(address);
	function setOwner(uint8 col, uint8 row, address newowner) external;
}

interface MapElevationRetriever{
    function getElevation(uint8 col, uint8 row) external view returns (uint8);
}

contract EtheriaExchangeV1pt1 is Ownable {
 	using SafeMath for uint256;

	string public name = "EtheriaExchangeV1pt1";

	Etheria public constant etheria = Etheria(0x169332Ae7D143E4B5c6baEdb2FEF77BFBdDB4011);
	MapElevationRetriever public constant mapElevationRetriever = MapElevationRetriever(0x68549D7Dbb7A956f955Ec1263F55494f05972A6b);

	uint256 public feeRate = 25; // 2.5%, max 5%
	uint256 public withdrawalPenaltyRate = 1; // 0.1%, max 5%
	uint256 public collectedFees = 0;
	uint16 public constant mapSize = 33;

    struct Bid {
        address bidder;
		uint256 amount;
    }

    // A record of the highest Etheria bid
    mapping (uint16 => Bid) public bids;
	mapping (address => uint256) public pendingWithdrawals;

    event EtheriaBidCreated(uint16 indexed index, address indexed bidder, uint256 indexed amount);
    event EtheriaGlobalBidCreated(address indexed bidder, uint256 indexed amount);
    event EtheriaBidWithdrawn(uint16 indexed index, address indexed bidder, uint256 indexed amount);
    event EtheriaBidAccepted(uint16 indexed index, address indexed seller, address indexed bidder, uint256 amount);
    event EtheriaGlobalBidAccepted(uint16 indexed index, address indexed seller, address indexed bidder, uint256 amount);

    constructor() {
    }
    
	function collectFees() external onlyOwner {
		payable(msg.sender).transfer(collectedFees);
		collectedFees = 0;
	}

	function setFeeRate(uint256 newFeeRate) external onlyOwner {
	    require(newFeeRate <= 50, "EtheriaEx: Invalid fee");
		feeRate = newFeeRate;
	}
	
	function setWithdrawalPenaltyRate(uint256 newWithdrawalPenaltyRate) external onlyOwner {
	    require(newWithdrawalPenaltyRate <= 50, "EtheriaEx: Invalid penalty rate");
		withdrawalPenaltyRate = newWithdrawalPenaltyRate;
	}

	function getIndex(uint8 col, uint8 row) public pure returns (uint16) {
		require(col < 33 && row < 33, "EtheriaEx: Invalid col and/or row");
		return uint16(col) * mapSize + uint16(row);
	}

    function getColRow(uint16 index) public pure returns (uint8 col, uint8 row) {
        require(index < 1089, "EtheriaEx: Invalid index");
        col = uint8(index / mapSize);
        row = uint8(index % mapSize);
	}
	
	function getBidDetails(uint8 col, uint8 row) public view returns (address, uint256) {
		Bid storage exitingBid = bids[getIndex(col, row)];
		return (exitingBid.bidder, exitingBid.amount);
	}
	
	function bid(uint8 col, uint8 row, uint256 amount) internal returns (uint16 index) {
	    require(msg.sender == tx.origin, "EtheriaEx: tx origin must be sender"); // etheria doesn't allow tile ownership by contracts, this check prevents blackholing
		require(amount > 0, "EtheriaEx: Invalid bid");
		
		index = getIndex(col, row);
		Bid storage existingbid = bids[index];
		require(amount >= existingbid.amount.mul(101).div(100), "EtheriaEx: bid not 1% higher"); // require higher bid to be at least 1% higher
		
		pendingWithdrawals[existingbid.bidder] += existingbid.amount; // new bid is good. add amount of old (stale) bid to pending withdrawals (incl previous stale bid amounts)
		
		existingbid.bidder = msg.sender;
		existingbid.amount = amount;
	}

	function makeBid(uint8 col, uint8 row) external payable {
		require(mapElevationRetriever.getElevation(col, row) >= 125, "EtheriaEx: Can't bid on water");
		uint16 index = bid(col, row, msg.value);
		emit EtheriaBidCreated(index, msg.sender, msg.value);
	}
	
	function makeGlobalBid() external payable {
		bid(0, 0, msg.value);
		emit EtheriaGlobalBidCreated(msg.sender, msg.value);
	}

    // withdrawal of a still-good bid by the owner
	function withdrawBid(uint8 col, uint8 row) external {
		uint16 index = getIndex(col, row);
		Bid storage existingbid = bids[index];
		require(msg.sender == existingbid.bidder, "EtheriaEx: not existing bidder");

        // to discourage bid withdrawal, take a cut
		uint256 fees = existingbid.amount.mul(withdrawalPenaltyRate).div(1000);
		collectedFees += fees;
		
		uint256 amount = existingbid.amount.sub(fees);
		
		existingbid.bidder = address(0);
		existingbid.amount = 0;
		
		payable(msg.sender).transfer(amount);
		
		emit EtheriaBidWithdrawn(index, msg.sender, existingbid.amount);
	}
	
	function accept(uint8 col, uint8 row, uint256 minPrice, uint16 index) internal returns(address bidder, uint256 amount) {
	    require(etheria.getOwner(col, row) == msg.sender, "EtheriaEx: Not tile owner");
		
        Bid storage existingbid = bids[index];
		require(existingbid.amount > 0, "EtheriaEx: No bid to accept");
		require(existingbid.amount >= minPrice, "EtheriaEx: min price not met");
		
		bidder = existingbid.bidder;
		
		etheria.setOwner(col, row, bidder);
		require(etheria.getOwner(col, row) == bidder, "EtheriaEx: setting owner failed");

		//collect fee
		uint256 fees = existingbid.amount.mul(feeRate).div(1000);
		collectedFees += fees;

        amount = existingbid.amount.sub(fees);
        
		existingbid.bidder = address(0);
		existingbid.amount = 0;
		
        pendingWithdrawals[msg.sender] += amount;
	}

	function acceptBid(uint8 col, uint8 row, uint256 minPrice) external {
	    uint16 index = getIndex(col, row);
		(address bidder, uint256 amount) = accept(col, row, minPrice, index);
		emit EtheriaBidAccepted(index, msg.sender, bidder, amount);
    }
    
    function acceptGlobalBid(uint8 col, uint8 row, uint256 minPrice) external {
        (address bidder, uint256 amount) = accept(col, row, minPrice, 0);
        emit EtheriaGlobalBidAccepted(getIndex(col, row), msg.sender, bidder, amount);
    }

    // withdrawal of funds on any and all stale bids that have been bested
	function withdraw(address payable destination) public {
		uint256 amount = pendingWithdrawals[msg.sender];
		require(amount > 0, "EtheriaEx: no amount to withdraw");
		
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        pendingWithdrawals[destination] = 0;
        payable(destination).transfer(amount);
	}
	
	function withdraw() external {
		withdraw(payable(msg.sender));
	}
}