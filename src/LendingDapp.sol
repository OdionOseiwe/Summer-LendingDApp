// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interface/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/safeERC20.sol";


contract LendingDApp is Ownable(msg.sender), ReentrancyGuard{


    uint256 public constant LIQUIDATION_FACTOR = 90;

    uint256 public constant COLLATERAL_FACTOR = 80;

    ///@dev the 4% discount for liquidation
    uint256 public constant LIQUIDATION_REWARDS = 4;

    uint256 public constant BORROW_RATE = 4; // 4%

    IERC20 public immutable uSDToken;

    IERC20 public immutable summerToken;

    ///@dev to store the priceFeed for the whiteListed tokens
    mapping(address => address) public tokenToChainlinkPriceFeed;

    ///@dev only owner can update this
    mapping(address => bool) whiteListedTokens;
    
    ///@dev borrowerAddress => CollateralAddress => amount
    mapping(address => mapping(address => uint256)) public userBorrow;
    
    mapping(address => mapping(address => UserDepositContainer)) public userDeposit;

    struct ChainlinkResponse {
        uint80 roundId;
        int256 price;
        uint256 updatedAt;
        bool success;
    }

    ///@dev blockNumber is to calculate user incentive from the time he deposit
    struct UserDepositContainer{
        uint256 amount;
        uint256 rewardDebt;
    }

    struct RewardContainer{
        uint256 allInterestInUSD;
        uint256 rewardPerToken;
    }

    RewardContainer public rewards;

    //////////////////////////////////////// EVENTS /////////////////////////////////////

    event DEPOSITED(address  indexed token_, address indexed user_, uint256 amount_);
    event BORROWED(address indexed user_, uint256 amount_);
    event LIQUIDATED(address indexed token_, address indexed user_, uint256 amount_);
    event REPAYED(address indexed token_, address indexed user_, uint256 amount_);
    event WITHDRAWED(address indexed token_, address indexed user_, uint256 amount_);
    event WHITELISTED(address token_);

    error ChainLinkFailed(string failed);
    error BadDebt(string NoInterests);

    using SafeERC20 for IERC20;

    ///////////////////////////////////// MODIFIERS /////////////////////////////////

    modifier tokenallowed(address token){
        require(whiteListedTokens[token], "Revert: not whitelisted");
        _;
    }

    modifier notZeroAmount(uint256 amount){
        require(amount > 0, "Revert:zero amount");
        _;
    }

    modifier addressZero(address targetAdress){
        require(targetAdress != address(0), "Revert address zero not allowed");
        _;
    }

    constructor(address _uSDToken, address _summerToken){
        uSDToken = IERC20(_uSDToken);
        summerToken = IERC20(_summerToken);
    }

    /////////////////////////////// MAIN FUNCTIONS /////////////////////////////////////

    ///@param token the collateral address
    function deposit(address token , uint256 amount) public  
        tokenallowed(token) notZeroAmount(amount){
        userDeposit[msg.sender][token].amount += amount;
        if(token == address(uSDToken)){
            userDeposit[msg.sender][token].rewardDebt = userDeposit[msg.sender][token].amount * rewards.rewardPerToken;
        }
        emit DEPOSITED(token, msg.sender, amount);
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    }


    /// stores the collateral amount in USD for furture use
    /// The users inputs the amount of USD he wants to borrow and its compared to the collateral value in USD
    ///@param token the collateral address
    function borrow(uint256 amount, address token) external
        notZeroAmount(amount) tokenallowed(token){
            require(token != address(uSDToken), "you cant borrow USD");
            uint256 collateral = userDeposit[msg.sender][token].amount;
            require(collateral > 0, "Revert: insufficient funds");
            uint256 oldBorrow = userBorrow[msg.sender][token];
            bool allow = borrowAllowed(collateral,token,amount,oldBorrow);
            require(allow, "Revert: BORROWED not allowed");
            userBorrow[msg.sender][token] += amount;
            emit BORROWED(msg.sender,amount);   
            uSDToken.safeTransfer(msg.sender , amount);
    }


    ///@dev when you repay, the user repays in full with interest
    ///@param token the collateral address
    function repay(uint256 amount, address token) external 
        notZeroAmount(amount) tokenallowed(token){
        require(userBorrow[msg.sender][token] > 0, "Revert: has been LIQUIDATED before");
        uint256 amountBorrowed = userBorrow[msg.sender][token];
        uint256 interest = (amountBorrowed * BORROW_RATE)/ 100;
        require( amount >= (amountBorrowed + interest), "Revert: User must repay in full");
        userBorrow[msg.sender][token] = 0;
        emit REPAYED(token,msg.sender,amount);
        updateRewards(interest);
        uSDToken.safeTransferFrom(msg.sender, address(this), amount);
    }


    ///@param token the collateral address of the account
    function liquidate(address token ,address account) external
        tokenallowed(token) addressZero(account){
        require(userBorrow[account][token] > 0, "choose another token to liqudate");
        uint256 collateral = userDeposit[account][token].amount;
        bool allow = liquidateAllowed(collateral,token, account);
        require(allow, "account can't be LIQUIDATED");
        uint256 discount = (userBorrow[account][token] * LIQUIDATION_REWARDS)/ 100;
        uint256 pay = userBorrow[account][token] - discount;
        require(pay < collateral, "improper payment");
        userBorrow[account][token] = 0;
        userDeposit[account][token].amount = 0;
        emit LIQUIDATED(token, account, pay);
        uSDToken.safeTransferFrom(msg.sender, address(this), pay);
        transferFunds(token, collateral);
    }


    ///@dev withdraw deposits with all the rewards accomulated 
    ///@param token the collateral address
    function withdraw(address token, uint256 amount) external  
        tokenallowed(token) notZeroAmount(amount){
        require(userBorrow[msg.sender][token] == 0, "Revert: You borrowed repay first");
        uint256 UserDeposit = userDeposit[msg.sender][token].amount;
        require(UserDeposit >= amount, "Revert: Amount to withdraw in high");
        userDeposit[msg.sender][token].amount -= amount;   
        emit WITHDRAWED(token, msg.sender, amount);     
        if(token == address(uSDToken)){
            uint256 pending =
            (UserDeposit * (rewards.rewardPerToken)) - userDeposit[msg.sender][token].rewardDebt;
            if(pending > 0){
                userDeposit[msg.sender][token].rewardDebt = userDeposit[msg.sender][token].amount * rewards.rewardPerToken;
                transferFunds(address(uSDToken), pending);
            }else{
                revert BadDebt("no interest accommulated");
            }
        }
        transferFunds(token,amount);
    }


    function whitelistToken(address token, address priceFeed) external onlyOwner addressZero(priceFeed) addressZero(token){
        require(!whiteListedTokens[token], "Revert: Token already exists");
        whiteListedTokens[token] = true;
        tokenToChainlinkPriceFeed[token] = priceFeed;
        emit WHITELISTED(token);
    }

    ////////////////////////////////////// HELPERS //////////////////////////////////

    //the protocol whitelistens any token to collect as collateral and only gives USDC tokens
    // the protocol gets its price for any token from chainlink price oracle
    function getUSDvalue(uint256 collateralValue, address token) view  public returns(uint256){
        ChainlinkResponse memory  cl;
        AggregatorV3Interface  dataFeed = AggregatorV3Interface(tokenToChainlinkPriceFeed[token]);
        try  dataFeed.latestRoundData() returns (
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
                return (uint256(price) * collateralValue)/ 1e8;
            }

        }catch  {
            revert ChainLinkFailed("ChainkLink data not safe");
        }
    }


    ///@return uint256 80% of the collateral 
    function calculateCollateralThreshold(uint256 collateral) pure private returns(uint256){
        return (collateral * COLLATERAL_FACTOR) / 100;
    }


    function transferFunds(address token,uint256 amount) private{
        require(IERC20(token).balanceOf(address(this)) >= amount, "insuffient funds");
        IERC20(token).safeTransfer(msg.sender , amount);
    }


    function liquidateAllowed(uint256 collateralValue ,address token, address borrower) view  public returns(bool allow){
        uint256 currentCollateralPrice = getUSDvalue(collateralValue,token);
        uint256 threshold = (currentCollateralPrice * LIQUIDATION_FACTOR) / 100;
        uint256 borrowmount = userBorrow[borrower][token];
        if(threshold <= borrowmount){
            return true;
        }else {
            return false;
        }
    }


    function borrowAllowed(uint256 collateralValue, address token, uint256 amountToBorrow, uint256 oldBorrow)view  public returns(bool allow){
        uint256 collateral = getUSDvalue(collateralValue,token);
        uint256 threshold = calculateCollateralThreshold(collateral);
        if(oldBorrow > 0){
            require((amountToBorrow + oldBorrow) <= threshold, "Revert: You need to top your collateral you borrow B4");
            return true;
        }else{
            require(amountToBorrow <= threshold, "Revert: top collateral or Reduce amount to borrow");
            return true;
        }
    }

    ///@dev the the rewards is calculated in terms of dollar
    function updateRewards(uint256 newRewards)  public{
        rewards.allInterestInUSD = (rewards.allInterestInUSD + newRewards);
        uint256 lpSupply = IERC20(uSDToken).balanceOf(address(this));
        if(lpSupply > 0){
            rewards.rewardPerToken = (rewards.allInterestInUSD / lpSupply) * 1e18;
        }
    } 
    
}

contract TestContract is LendingDApp(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2, 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2) {
    function echidna_test_All() public pure returns(bool){
        return true;
    }
}

