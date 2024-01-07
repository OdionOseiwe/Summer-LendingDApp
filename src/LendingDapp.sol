pragma solidity ^0.8.13;

import "./interface/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract LendingDApp is Ownable, ReentrancyGuard{

    /////////////////////////////// MAIN FUNCTIONS /////////////////////////////////////

    function deposit(address _Asset , uint256 _amount) external   {

    }

    function borrow(uint256 _amount) external{

    }

    function repay(uint256 _amount) external{

    }

    function liquidate(address _asset ,address _account, uint256 _amount) external{

    }

    function whitelistToken(address _token) external {

    }

    ///////////////////////////////////// MODIFIERS /////////////////////////////////
}