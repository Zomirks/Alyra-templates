// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

contract auction {
    address highestBidder;
    uint highestBid;

    function bid() payable public {
        require(msg.value >= highestBid);

        if (highestBidder != address(0)) {
            (bool success, ) = highestBidder.call{value:highestBid}("");
            require(success); // if this call consistently fails, no one else can bid
        }

       highestBidder = msg.sender;
       highestBid = msg.value;
    }
}