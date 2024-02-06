// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interface/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/safeERC20.sol";



contract LendingDApp is Ownable(msg.sender), ReentrancyGuard{

    ///@dev to store the priceFeed for the whiteListed tokens
    mapping(address => address) public tokenToChainlinkPriceFeed;

    ///@dev only owner can update this
    mapping(address => bool) whiteListedTokens;

    ///@dev borrowerAddress => CollateralAddress => amount
    mapping(address => mapping(address => uint256)) public userBorrow;

    mapping(address => mapping(address => userDepositContainer)) public userDeposit;

    uint256 public constant LIQUIDATIONFACTOR = 90;

    uint256 public constant COLLATERALFACTOR = 80;

    ///@dev the 4% discount for liquidation
    uint256 public LIQUIDATIONREWARDS = 4;

    uint256 public BorowRate = 4; // 4%

    IERC20 public immutable USDtoken;

    IERC20 public immutable SummerToken;

    using SafeERC20 for IERC20;

    struct ChainlinkResponse {
        uint80 roundId;
        int256 price;
        uint256 updatedAt;
        bool success;
    }

    ///@dev blockNumber is to calculate user incentive from the time he deposit
    struct userDepositContainer{
        uint256 amount;
        uint256 rewardDebt;
    }

    struct RewardContainer{
        uint256 allInterestInUSD;
        uint256 rewardPerToken;
    }

    RewardContainer public rewards;

    error ChainLinkFailed(string failed);

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

    ///@param _token the collateral address
    function deposit(address _token , uint256 _amount) public  
        tokenallowed(_token) notZeroAmount(_amount){
        userDeposit[msg.sender][_token].amount += _amount;
        if(_token == address(USDtoken)){
            userDeposit[msg.sender][_token].rewardDebt = userDeposit[msg.sender][_token].amount * rewards.rewardPerToken;
        }
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        emit deposited(_token, msg.sender, _amount);

    }

    /// stores the collateral amount in USD for furture use
    /// The users inputs the amount of USD he wants to borrow and its compared to the collateral value in USD
    ///@param _token the collateral address
    function borrow(uint256 _amount, address _token) external
        notZeroAmount(_amount) tokenallowed(_token){
            require(_token != address(USDtoken), "you cant borrow USD");
            uint256 collateral = userDeposit[msg.sender][_token].amount;
            require(collateral > 0, "Revert: insufficient funds");
            // consider collateral factor 
            // require(!userBorrow[msg.sender][_token].borrowed, "Revert: borrowed before pay back");
            bool allow = borrowAllowed(collateral,_token,_amount);
            require(allow, "Revert: borrowed not allowed"); // this line is not really needed
            userBorrow[msg.sender][_token] = _amount;
            USDtoken.safeTransfer(msg.sender , _amount);
            emit borrowed(msg.sender,_amount);   
    }

    ///@dev when you repay, the user repays in full with interest
    ///@param _token the collateral address
    function repay(uint256 _amount, address _token) external 
        notZeroAmount(_amount) tokenallowed(_token){
        require(userBorrow[msg.sender][_token] > 0, "Revert: has been liquidated before");
        uint256 amountBorrowed = userBorrow[msg.sender][_token];
        uint256 interest = (amountBorrowed * BorowRate)/ 100;
        require((amountBorrowed + interest) >= _amount, "Revert: User must repay in full");
        userBorrow[msg.sender][_token] = 0;
        USDtoken.safeTransferFrom(msg.sender, address(this), _amount);
        updateRewards(interest);
        emit repayed(_token,msg.sender,_amount);
    }

    ///@param _token the collateral address of the _account
    function liquidate(address _token ,address _account) external
        tokenallowed(_token) addressZero(_account){
        require(userBorrow[_account][_token] > 0, "choose another token to liqudate");
        uint256 collateral = userDeposit[_account][_token].amount;
        bool allow = liquidateAllowed(collateral,_token, _account);
        require(allow, "account can't be liquidated");
        uint256 discount = (userBorrow[_account][_token] * LIQUIDATIONREWARDS)/ 100;
        uint256 pay = userBorrow[_account][_token] - discount;
        userBorrow[_account][_token] = 0;
        userDeposit[_account][_token].amount = 0;
        USDtoken.safeTransferFrom(msg.sender, address(this), pay);
        emit liquidated(_token, _account, pay);
        transferFunds(_token, collateral);
    }


    ///@dev withdraw deposits with all the rewards accomulated 
    ///@param _token the collateral address
    function withdraw(address _token, uint256 _amount) external  
        tokenallowed(_token) notZeroAmount(_amount){

        // consider collateral factor
        // require(!userBorrow[msg.sender][_token].borrowed, "Revert: You borrowed repay first");

        require(userDeposit[msg.sender][_token].amount >=_amount, "Revert: Amount to withdraw in high");
        if(_token == address(USDtoken)){
            uint256 pending =
            (userDeposit[msg.sender][_token].amount * (rewards.rewardPerToken)) - userDeposit[msg.sender][_token].rewardDebt;
            transferFunds(address(USDtoken), pending);
            userDeposit[msg.sender][_token].rewardDebt = userDeposit[msg.sender][_token].amount * rewards.rewardPerToken;
        }
        userDeposit[msg.sender][_token].amount -= _amount;
        transferFunds(_token,_amount);
        emit withdrawed(_token, msg.sender, _amount);
    }

    function whitelistToken(address _token, address _priceFeed) external onlyOwner addressZero(_priceFeed) addressZero(_token){
        require(!whiteListedTokens[_token], "Revert: Token already exists");
        whiteListedTokens[_token] = true;
        tokenToChainlinkPriceFeed[_token] = _priceFeed;
        emit whiteListed(_token);
    }

    ////////////////////////////////////// HELPERS //////////////////////////////////

    //the protocol whitelistens any token to collect as collateral and only gives USDC tokens
    // the protocol gets its price for any token from chainlink price oracle
    function getUSDvalue(uint256 _collateralValue, address _token) view  public returns(uint256 ){
        ChainlinkResponse memory  cl;
        AggregatorV3Interface  dataFeed = AggregatorV3Interface(tokenToChainlinkPriceFeed[_token]);
        try dataFeed.latestRoundData() returns (
            uint80 roundId,
            int256 price,
            uint256 /* startedAt */,
            uint256 updatedAt,
            uint80 /* answeredInRound */
        ) {
            cl.success = true;
            cl.roundId = roundId;
            cl.price = price;
            cl.updatedAt = updatedAt;

            if (
                cl.success == true &&
                cl.roundId != 0 &&
                cl.price >= 0 &&
                cl.updatedAt != 0 && 
                cl.updatedAt <= block.timestamp
            ) {
                /// the figures from chainlink price oracle is divided by 1e8 to make all the tokens in 1e18 to easy conversions
                return (uint256(price) * _collateralValue)/ 1e8;
            }

        }catch  {
            revert ChainLinkFailed("ChainkLink data not safe");
        }
    }

    ///@return uint256 80% of the collateral 
    function calculateCollateralThreshold(uint256 collateral) pure private returns(uint256){
        return (collateral * COLLATERALFACTOR) / 100;
    }

    function transferFunds(address _token,uint256 _amount) private{
        require(IERC20(_token).balanceOf(address(this)) >= _amount, "insuffient funds");
        IERC20(_token).safeTransfer(msg.sender , _amount);
    }

    function liquidateAllowed(uint256 _collateralValue ,address _token, address borrower) view  public returns(bool allow){
        uint256 currentCollateralPrice = getUSDvalue(_collateralValue,_token);
        uint256 threshold = (currentCollateralPrice * LIQUIDATIONFACTOR) / 100;
        uint256 borrowmount = userBorrow[borrower][_token];
        if(threshold <= borrowmount){
            return true;
        }else {
            return false;
        }
    }

    function borrowAllowed(uint256 _collateralValue, address _token, uint256 amountToBorrow)view  public returns(bool allow){
        uint256 collateral = getUSDvalue(_collateralValue,_token);
        uint256 threshold = calculateCollateralThreshold(collateral);
        require(amountToBorrow <= threshold, "Revert: Reduce amount to borrow");
        return true;
    }

    ///@dev the the rewards is calculated in terms of dollar
    function updateRewards(uint256 newRewards)  private{
            uint256 lpSupply = USDtoken.balanceOf(address(this));
            if (lpSupply == 0) {
                return ;
            }
            rewards.allInterestInUSD = rewards.allInterestInUSD + newRewards;
            rewards.rewardPerToken = (rewards.allInterestInUSD / lpSupply);

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
}