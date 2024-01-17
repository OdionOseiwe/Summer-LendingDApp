// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interface/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract LendingDApp is Ownable(msg.sender), ReentrancyGuard{

    ///@dev to store the priceFeed for the whiteListed tokens
    mapping(address => address) public tokenToChainlinkPriceFeed;

    ///@dev only owner can update this
    mapping(address => bool) whiteListedTokens;

    mapping(address => mapping(address => userBorrowContainer)) public userBorrow;

    mapping(address => mapping(address => userDepositContainer)) public userDeposit;

    mapping(address => mapping(address => uint256)) UserRewards;

    uint256 public constant LIQUIDATIONFACTOR = 90;

    uint256 public constant COLLATERALFACTOR = 80;

    ///@dev the 4% discount for liquidation
    uint256 public LIQUIDATIONREWARDS = 4;

    uint256 public constant MINIMUMDEPOSIT = 0.005 ether;

    ///@dev the rewardPerToken is hardcoded because the duration is not for a period of time
    uint256 public constant REWARD_PER_SECOND = 10000000; // 0.0000001

    IERC20 public immutable USDtoken;

    IERC20 public immutable SummerToken;

    ///@dev blockNumber is to calculate user incentive from the time he deposit
    struct userDepositContainer{
        uint256 amount;
        uint256 depositTime;
    }

    struct userBorrowContainer{
        uint256 amount;
        uint256 collateralUSDAtBorrowTime;
        bool borrowed;
        bool liquidated;
    }
    error BorrowNotallowed(uint256 _amount);


    constructor(address _USDtoken, address _summerToken){
        USDtoken = IERC20(_USDtoken);
        SummerToken = IERC20(_summerToken);
    }

    //////////////////////////////////////// EVENTS /////////////////////////////////////

    event deposited(address  indexed token_, address indexed user_, uint256 amount_);
    event borrowed(address indexed user_, uint256 amount_);
    event liquidated(address indexed token_, address indexed user_, uint256 amount_);
    event repayed(address indexed token_, address indexed user_, uint256 amount_);
    event withdrawed(address indexed token_, address indexed user_, uint256 amount_);
    event whiteListed(address token_);

    /////////////////////////////// MAIN FUNCTIONS /////////////////////////////////////

    function deposit(address _token , uint256 _amount) public  
        tokenallowed(_token) notZeroAmount(_amount) updateRewards(_token, msg.sender){
        userDeposit[msg.sender][_token].amount += _amount;
        bool success = IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        require(success, "Revert: Deposit Failed");
        emit deposited(_token, msg.sender, _amount);

    }

    ///@dev the token to borrow is USD so no need to convert
    /// stores the collateral amount in USD for furture use
    function borrow(uint256 _amount, address _token) external
        notZeroAmount(_amount) tokenallowed(_token){
        uint256 collateral = userDeposit[msg.sender][_token].amount;
        require(collateral > 0, "Revert: insufficient funds");
        require(!userBorrow[_token][msg.sender].borrowed, "Revert: borrowed before pay back");
        bool allow = borrowAllowed(collateral,_token,_amount);
        require(allow, "Revert: borrowed not allowed");
        userBorrow[_token][msg.sender].amount = _amount;
        bool success = USDtoken.transfer(msg.sender , _amount);
        require(success, "Revert: Deposit Failed");
        emit borrowed(msg.sender,_amount);
        uint256 collateralValueInUSDAtTimeOfBorrow = getUSDvalue(collateral, _token);
        userBorrow[_token][msg.sender].collateralUSDAtBorrowTime = collateralValueInUSDAtTimeOfBorrow;
        userBorrow[_token][msg.sender].borrowed = true;
        userBorrow[_token][msg.sender].liquidated = false;
    }

    ///@dev when you repay, the user repays in full
    function repay(uint256 _amount, address _token) external{
        require(userBorrow[_token][msg.sender].liquidated, "Revert: has been liquidated before");
        require(userBorrow[_token][msg.sender].amount == _amount, "Revert: User must repay in full");
        userBorrow[_token][msg.sender].amount = 0;
        bool success = USDtoken.transferFrom(msg.sender, address(this) ,_amount);
        require(success, "Revert: transfer Failed");
        emit repayed(_token,msg.sender,_amount);
        userBorrow[_token][msg.sender].borrowed = false;
    }

    function liquidate(address _token ,address _account) external
        tokenallowed(_token){
        uint256 collateral = userDeposit[_account][_token].amount;
        require(collateral > 0, "choose another token to liqudate");
        bool allow = liquidateAllowed(collateral,_token, _account);
        require(allow, "account cant be liquidated");
        uint256 discount = (userBorrow[_token][_account].amount * LIQUIDATIONREWARDS)/ 100;
        uint256 pay = userBorrow[_token][_account].amount - discount;
        userBorrow[_token][_account].amount = 0;
        bool success = USDtoken.transferFrom(msg.sender, address(this) ,pay);
        require(success, "Revert: transfer Failed");
        emit liquidated(_token, _account, pay);
        transferFunds(_token, collateral);
        userBorrow[_token][_account].liquidated = true;
        userBorrow[_token][_account].borrowed = false;
    }


    ///@dev withdraw deposits with all the rewards accomulated 
    function withdraw(address _token, uint256 _amount) external  
        tokenallowed(_token) notZeroAmount(_amount) updateRewards(_token, msg.sender){
        require(!userBorrow[_token][msg.sender].borrowed, "Revert: You borrowed reapy first");
        require(userDeposit[msg.sender][_token].amount > 0, "Revert: did not deposit");
        userDeposit[msg.sender][_token].amount -= _amount;
        transferFunds(_token,_amount);
        uint256 rewards =  UserRewards[msg.sender][_token];
        UserRewards[msg.sender][_token] = 0;
        require(SummerToken.balanceOf(address(this)) >= rewards, "insuffient rewards");
        bool done = SummerToken.transfer(msg.sender , rewards);
        require(done, "Revert: transfer Failed");
        emit withdrawed(_token, msg.sender, _amount);
    }

    function whitelistToken(address _token, address _priceFeed) external onlyOwner addressZero(_priceFeed) addressZero(_token){
        require(!whiteListedTokens[_token], "Revert: Token already exists");
        whiteListedTokens[_token] = true;
        tokenToChainlinkPriceFeed[_token] = _priceFeed;
        emit whiteListed(_token);
    }

    ////////////////////////////////////// HELPERS //////////////////////////////////

    function getUSDvalue(uint256 _collateralValue, address _token) view private returns(uint256 ){
        AggregatorV3Interface  dataFeed = AggregatorV3Interface(tokenToChainlinkPriceFeed[_token]);
        (,int256 price,,,) = dataFeed.latestRoundData();
        return (uint256(price) * _collateralValue) / 1e18;
    }

    ///@return uint256 80% of the collateral 
    function calculateCollateralThreshold(uint256 collateral) pure private returns(uint256){
        return (collateral * COLLATERALFACTOR) / 100;
    }

    function transferFunds(address _token,uint256 _amount) private{
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "insuffient funds");
        bool done = IERC20(_token).transfer(msg.sender , _amount);
        require(done, "Revert: transfer Failed");
    }

    function liquidateAllowed(uint256 _collateralValue ,address _token, address borrower) view private returns(bool allow){
        uint256 currentCollateralPrice = getUSDvalue(_collateralValue,_token);
        uint256 previousCollateralPrice = userBorrow[_token][borrower].collateralUSDAtBorrowTime;
        uint256 threshold = (previousCollateralPrice * LIQUIDATIONFACTOR) / 100;
        require(threshold <= currentCollateralPrice);
        return true;
    }

    function borrowAllowed(uint256 _collateralValue, address _token, uint amountToBorrow) view private returns(bool allow){
        uint256 collateral = getUSDvalue(_collateralValue,_token);
        uint256 threshold = calculateCollateralThreshold(collateral);
        require(amountToBorrow <= threshold, "Revert: Reduce amount to borrow");
        return true;
    }

    ///@dev the the rewards is calculated in terms of dollar
    function getRewards(address _token) view private returns(uint256){
        uint256 duration = userDeposit[msg.sender][_token].depositTime;
        uint256 borrowForAParticularToken = userDeposit[msg.sender][_token].amount;     
        uint256 amount = getUSDvalue(borrowForAParticularToken, _token); 
        uint256 rewards = ((block.timestamp - duration) * amount)/REWARD_PER_SECOND ;
        return rewards;
    }

    ///////////////////////////////////// MODIFIERS /////////////////////////////////

    modifier tokenallowed(address _token){
        require(whiteListedTokens[_token], "Revert: not whitelisted");
        _;
    }

    modifier notZeroAmount(uint256 _amount){
        require(_amount > 0, "Revert:zero amount");
        _;
    }

    modifier addressZero(address _address){
        require(_address != address(0), "Revert address zero not allowed");
        _;
    }

    modifier updateRewards(address _token, address owner){
        uint256 rewards = getRewards(_token);
        UserRewards[owner][_token] += rewards;
        userDeposit[msg.sender][_token].depositTime = block.timestamp;
        _;
    }
}