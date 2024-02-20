// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockPriceFeed{

    int256  price = 31781040000;
    function latestRoundData()
    public
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ){
        return (0,price,0,0,0);
    }

    function changePrice(int256 pricce)  public returns(int256){
        return price = pricce;
    }
}

