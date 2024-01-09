pragma solidity ^0.8.13;

import "./interface/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract LendingDApp is Ownable, ReentrancyGuard{

    ///@dev to store the priceFeed for the whiteListed tokens
    mapping(address => address) public tokenToChainlinkPriceFeed;

    ///@dev only owner can update this
    mapping(address => bool) whiteListedTokens;

    mapping(address => userBorrowContainer) public userBorrow;

    mapping(address => mapping(address => userDepositContainer)) public userDeposit;

    uint256 public liquidationFactor = 9_000;

    uint256 public collateralFactor = 8_000;

    uint256 public minimumBorrow;

    struct userBorrowContainer{
        uint256 amount;
    }

    ///@dev blockNumber is to calculate user incentive from the time he deposit
    struct userDepositContainer{
        uint256 amount;
        uint256 depositTime;
    }

    event deposited(address  indexed asset_, address indexed user_, uint256 amount_);
    event borrowed(address indexed user_, uint256 amount_);
    event liquidated(address indexed asset_, address indexed user_, uint256 amount_);
    event repayed(address indexed asset_, address indexed user_, uint256 amount_);
    event withdrawed(address indexed asset_, address indexed user_, uint256 amount_);

    /////////////////////////////// MAIN FUNCTIONS /////////////////////////////////////

    function deposit(address _asset , uint256 _amount) external  
        tokenallowed(_asset) notZero(_amount){
            userDeposit[msg.sender][_asset].amount += _amount;
            userDeposit[msg.sender][_asset].depositTime = block.timestamp;

    }

    function borrow(uint256 _amount) external{

    }

    function repay(uint256 _amount) external{

    }

    function liquidate(address _asset ,address _account, uint256 _amount) external{

    }


    ///@dev withdraw deposits with incentives
    function withdraw(address _asset, uint256 _amount) external{

    }

    function whitelistToken(address _token) external {

    }

    ///////////////////////////////////// MODIFIERS /////////////////////////////////

    modifier tokenallowed(address _token){
        require(whiteListedTokens[_token], "not whitelisted");
        _;
    }

    modifier notZero(uint256 _amount){
        require(_amount > 0, "Revert:zero amount");
        _;
    }
}