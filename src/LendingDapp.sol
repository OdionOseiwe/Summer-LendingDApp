pragma solidity ^0.8.21;

import "./interface/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract LendingDApp is Ownable(msg.sender), ReentrancyGuard{

    ///@dev to store the priceFeed for the whiteListed tokens
    mapping(address => address) public tokenToChainlinkPriceFeed;

    ///@dev only owner can update this
    mapping(address => bool) whiteListedTokens;

    mapping(address => uint256) public userBorrow;

    mapping(address => mapping(address => userDepositContainer)) public userDeposit;

    mapping(address => mapping(address => uint256)) UserRewards;

    uint256 public constant LIQUIDATIONFACTOR = 90;

    uint256 public constant COLLATERALFACTOR = 80;

    uint256 public constant MINIMUMDEPOSIT = 0.005 ether;

    ///@dev the rewardPerToken is hardcoded because the duration is not for a period of time
    uint256 public constant REWARD_PER_SECOND = 1000000; // 0.000001

    IERC20 public immutable USDtoken;

    IERC20 public immutable SummerToken;

    ///@dev blockNumber is to calculate user incentive from the time he deposit
    struct userDepositContainer{
        uint256 amount;
        uint256 depositTime;
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

    function deposit(address _token , uint256 _amount) external  
        tokenallowed(_token) notZeroAmount(_amount) updateRewards(_token, msg.sender){
        userDeposit[msg.sender][_token].amount += _amount;
        bool success = IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        require(success, "Revert: Deposit Failed");
        emit deposited(_token, msg.sender, _amount);

    }

    ///@dev the token to borrow is USD so no need to convert
    function borrow(uint256 _amount, address _token) external notZeroAmount(_amount){
        uint256 collateral = userDeposit[msg.sender][_token].amount;
        bool allow = borrowAllowed(collateral,_token,_amount);
        if(allow){
            userBorrow[msg.sender] += _amount;
            bool success = USDtoken.transferFrom(address(this),msg.sender , _amount);
            require(success, "Revert: Deposit Failed");
        }else{
            revert BorrowNotallowed(_amount);
        }
        emit borrowed(msg.sender,_amount);

    }

    function repay(uint256 _amount) external{

    }

    function liquidate(address _token ,address _account, uint256 _amount) external{

    }


    ///@dev withdraw deposits with all the rewards accomulated 
    function withdraw(address _token, uint256 _amount) external  
        tokenallowed(_token) notZeroAmount(_amount) updateRewards(_token, msg.sender){
        userDeposit[msg.sender][_token].amount -= _amount;
        bool done = IERC20(_token).transfer(msg.sender , _amount);
        require(done, "Revert: transfer for deposits Failed");
        uint256 rewards =  UserRewards[msg.sender][_token];
        UserRewards[msg.sender][_token] = 0;
        bool success = SummerToken.transfer(msg.sender, rewards);
        require(success, "Revert: transfer for Reward tokens Failed");
    }

    function whitelistToken(address _token, address _priceFeed) external onlyOwner addressZero(_priceFeed) addressZero(_token){
        require(!whiteListedTokens[_token], "Revert: Token already exists");
        whiteListedTokens[_token] = true;
        tokenToChainlinkPriceFeed[_token] = _priceFeed;
        emit whiteListed(_token);
    }

    ////////////////////////////////////// HELPERS //////////////////////////////////

    function getUSDvalue(uint256 _collateralValue, address _token) view internal returns(uint256 ){
        AggregatorV3Interface  dataFeed = AggregatorV3Interface(tokenToChainlinkPriceFeed[_token]);
        (,int256 price,,,) = dataFeed.latestRoundData();
        return (uint256(price) * _collateralValue) / 1e18;
    }

    ///@return uint256 80% of the collateral 
    function calculateCollateralThreshold(uint256 collateral) pure public returns(uint256){
        return (collateral * COLLATERALFACTOR) / 100;
    }

    function borrowAllowed(uint256 _collateralValue, address _token, uint amountToBorrow) view internal returns(bool allow){
        uint256 collateral = getUSDvalue(_collateralValue,_token);
        uint256 threshold = calculateCollateralThreshold(collateral);
        if(amountToBorrow <= threshold){
            return true;
        }
    }

    ///@dev the the rewards is calculated in terms of dollar
    function getRewards(address _token) view internal returns(uint256){
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
        require(_address != address(0), "Revert address zero not allowes");
        _;
    }

    modifier updateRewards(address _token, address owner){
        uint256 rewards = getRewards(_token);
        UserRewards[owner][_token] += rewards;
        userDeposit[msg.sender][_token].depositTime = block.timestamp;
        _;
    }
}