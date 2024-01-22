// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MockPriceFeed{

    int256 price = 31781040000;
    function latestRoundData()
    public
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ){
        return (0,price,0,0,0);
    }

    function changePrice(int256 _price) public returns(int256){
        price = _price;
    }
}

