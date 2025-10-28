// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

contract auction {
    address highestBidder;
    uint highestBid;

    // Add mapping to save bids amount
    mapping(address => uint) refunds;

    function bid() payable public {
        require(msg.value >= highestBid);

        // Add the previous highestBid to the mapping
        if (highestBidder != address(0)) {
            refunds[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
    }

    function withdrawBids() public {
        require(refunds[msg.sender] > 0);
        uint refund = refunds[msg.sender];
        refunds[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value:refund}("");
        require(success);
    }
}