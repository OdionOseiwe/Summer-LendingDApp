// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {LendingDApp} from "../src/LendingDapp.sol";
import  "../src/Mock/MockUSDT.sol";
import  "../src/Mock/SummerToken.sol";
import "../src/Mock/ChainLinkMock.sol";
import "../src/interface/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract LendDAppTest is Test {
    LendingDApp public lendingDApp;
    MockUSDT public mockUSDT;
    SummerToken public summerToken;
    MockPriceFeed public mockPriceFeed;
    address public WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address public BNB_USDPriceFeed = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526;
    address depositor1 = mkaddr("depositor1");
    address depositor2 = mkaddr("depositor2");
    address owner = mkaddr("owner");

    struct userDepositContainer{
        uint256 amount;
        uint256 depositTime;
    }

    // tests are ran on binance testnet
    function setUp() public {
        mockUSDT = new MockUSDT();
        summerToken = new SummerToken();
        mockPriceFeed = new MockPriceFeed();
        lendingDApp = new LendingDApp(address(mockUSDT), address(summerToken));
        vm.label(address(mockUSDT), "mockUSDT");
        vm.label(address(mockPriceFeed), "mockPriceFeed");
        vm.label(address(lendingDApp), "lendingDApp");
        vm.label(address(WBNB), "WBNB");
        lendingDApp.transferOwnership(owner);
    }

    // function test_ShouldRevertNotOwnerwhiteListToken() public {
    //     vm.startPrank(depositor1);
    //     vm.expectRevert();
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    //     vm.stopPrank();
    // }

    // function test_RevertAddressZero() public {
    //     vm.prank(owner);
    //     vm.expectRevert(bytes("Revert address zero not allowed"));
    //     lendingDApp.whitelistToken(address(0), BNB_USDPriceFeed);
    // }

    // function test_RevertWhitelistTokenTwice() public {
    //     vm.startPrank(owner);
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    //     vm.expectRevert(bytes("Revert: Token already exists"));
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    //     vm.stopPrank();
    // }

    // function test_WhitelistToken() public {
    //     vm.prank(owner);
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    // }

    // function test_DepositRevertNotWhitelisted() public {
    //    vm.startPrank(depositor1);
    //    vm.expectRevert(bytes("Revert: not whitelisted"));
    //    lendingDApp.deposit(WBNB,1e18);
    //    vm.stopPrank(); 
    // }

    // function test_Deposit() public {
    //     vm.prank(owner);
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    //     vm.startPrank(depositor1);
    //     deal(WBNB,depositor1,10e18);
    //     IERC20(WBNB).approve(address(lendingDApp),1e18);
    //     lendingDApp.deposit(WBNB, 1e18);
    //     uint256 bal = IERC20(WBNB).balanceOf(address(lendingDApp));
    //     console.log(bal);
    //     vm.stopPrank(); 

    // }

    // function test_RevertInsufficientFundsBorrow() public {
    //     vm.prank(owner);
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    //     vm.startPrank(depositor1);
    //     vm.expectRevert(bytes("Revert: insufficient funds"));  
    //     lendingDApp.borrow(0.5e18, WBNB);
    //     vm.stopPrank(); 
    // }

    // function test_CheckCollateralFactor() public {
    //     vm.prank(owner);
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    //     vm.startPrank(depositor1);
    //     deal(WBNB,depositor1,10e18);
    //     IERC20(WBNB).approve(address(lendingDApp),3e18);
    //     lendingDApp.deposit(WBNB, 2e18);
    //     uint256 bal = IERC20(WBNB).balanceOf(address(lendingDApp));
    //     console.log(bal);
    //     mockUSDT.mint(address(lendingDApp), 10000e18);
    //     lendingDApp.borrow(300e18, WBNB);
    //     deal(WBNB,depositor1,10e18);
    //     IERC20(WBNB).approve(address(lendingDApp),3e18);
    //     lendingDApp.deposit(WBNB, 2e18);
    //     lendingDApp.borrow(200e18, WBNB);
    //     vm.stopPrank(); 
    // }

    // function test_USDValue() public{
    //     vm.prank(owner);
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    //     vm.startPrank(depositor1);
    //     uint256 price =lendingDApp.getUSDvalue(1e18,WBNB);
    //     console.log(price);
    //     vm.stopPrank();
    // }

    // function test_RevertReduceAmounttoBorrow() public {
    //     vm.prank(owner);
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    //     vm.startPrank(depositor1);
    //     deal(WBNB,depositor1,10e18);
    //     IERC20(WBNB).approve(address(lendingDApp),3e18);
    //     lendingDApp.deposit(WBNB, 2e18);
    //     mockUSDT.mint(address(lendingDApp), 10000e18);
    //     vm.expectRevert(bytes("Revert: top collateral or Reduce amount to borrow"));  
    //     lendingDApp.borrow(600e18, WBNB);
    //     vm.stopPrank(); 
    // }

    // function test_RevertPayBorrowB4Withdrawal() public {
    //     vm.prank(owner);
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    //     vm.startPrank(depositor1);
    //     deal(WBNB,depositor1,10e18);
    //     IERC20(WBNB).approve(address(lendingDApp),3e18);
    //     lendingDApp.deposit(WBNB, 2e18);
    //     mockUSDT.mint(address(lendingDApp), 10000e18);
    //     summerToken.mint(address(lendingDApp), 10000e18);
    //     lendingDApp.borrow(200e18, WBNB);
    //     vm.expectRevert(bytes("Revert: You borrowed repay first"));
    //     lendingDApp.withdraw(WBNB,2e18);
    // }

    // function test_RevertDidNotDeposit() public {
    //     vm.prank(owner);
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    //     vm.startPrank(depositor1);
    //     mockUSDT.mint(address(lendingDApp), 10000e18);
    //     summerToken.mint(address(lendingDApp), 10000e18);
    //     vm.expectRevert(bytes("Revert: Amount to withdraw in high"));
    //     lendingDApp.withdraw(WBNB,2e18);
    // }

    // function test_WithrawDeposits() public {
    //     vm.prank(owner);
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    //     vm.startPrank(depositor1);
    //     deal(WBNB,depositor1,4e18);
    //     IERC20(WBNB).approve(address(lendingDApp),4e18);
    //     lendingDApp.deposit(WBNB, 2e18);
    //     lendingDApp.userDeposit(depositor1,WBNB);
    //     summerToken.mint(address(lendingDApp), 10000e18);
    //     skip(86400);
    //     lendingDApp.deposit(WBNB, 2e18);
    //     skip(1209600);
    //     lendingDApp.withdraw(WBNB,2e18);
    //     lendingDApp.userDeposit(depositor1,WBNB);
    //     uint256 balOfDepositor = IERC20(summerToken).balanceOf(depositor1);
    //     uint256 balOfLendingDApp = IERC20(WBNB).balanceOf(depositor1);
    // }    

    // function test_RevertDidNotDepositAmount() public {
    //     vm.prank(owner);
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    //     vm.startPrank(depositor1);
    //     deal(WBNB,depositor1,4e18);
    //     IERC20(WBNB).approve(address(lendingDApp),2e18);
    //     lendingDApp.deposit(WBNB, 2e18);
    //     summerToken.mint(address(lendingDApp), 10000e18);
    //     skip(1209600);
    //     vm.expectRevert(bytes("Revert: Amount to withdraw in high"));
    //     lendingDApp.withdraw(WBNB,3e18);
    // }

    // function test_RevertTokenNotAllowed() public{
    //     vm.prank(owner);
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    //     vm.startPrank(depositor1);
    //     deal(WBNB,depositor1,10e18);
    //     IERC20(WBNB).approve(address(lendingDApp),3e18);
    //     lendingDApp.deposit(WBNB, 2e18);
    //     mockUSDT.mint(address(lendingDApp), 10000e18);
    //     lendingDApp.borrow(200e18, WBNB);
    //     vm.expectRevert(bytes("Revert: not whitelisted"));
    //     lendingDApp.repay(200e18,BNB_USDPriceFeed);
    // }

    // function test_RevertShouldRepayTheFullAmountBorrowed() public{
    //     vm.prank(owner);
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    //     vm.startPrank(depositor1);
    //     deal(WBNB,depositor1,10e18);
    //     IERC20(WBNB).approve(address(lendingDApp),3e18);
    //     lendingDApp.deposit(WBNB, 2e18);
    //     mockUSDT.mint(address(lendingDApp), 10000e18);
    //     lendingDApp.borrow(200e18, WBNB);
    //     IERC20(mockUSDT).approve(address(lendingDApp), 100e18);
    //     vm.expectRevert(bytes("Revert: User must repay in full"));
    //     lendingDApp.repay(100e18,WBNB);
    // }

    // function test_Repay() public{
    //     vm.prank(owner);
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    //     vm.startPrank(depositor1);
    //     deal(WBNB,depositor1,2e18);
    //     IERC20(WBNB).approve(address(lendingDApp),2e18);
    //     lendingDApp.deposit(WBNB, 2e18);
    //     IERC20(WBNB).balanceOf(depositor1); //check if it left user wallet
    //     mockUSDT.mint(address(lendingDApp), 10000e18);
    //     lendingDApp.borrow(200e18, WBNB);
    //     IERC20(mockUSDT).balanceOf(depositor1); //check if the amount came into the user wallet
    //     skip(1209600);
        // IERC20(mockUSDT).approve(address(lendingDApp), 208e18);
    //     mockUSDT.mint(depositor1, 10e18);
    //     lendingDApp.repay(208e18,WBNB);
    //     IERC20(mockUSDT).balanceOf(address(lendingDApp)); //check if the USD is present in the contract
    // }

    // function test_liquidate() public{
    //     vm.prank(owner);
    //     lendingDApp.whitelistToken(WBNB, address(mockPriceFeed));
    //     vm.startPrank(depositor1);
    //     deal(WBNB,depositor1,2e18);
    //     IERC20(WBNB).approve(address(lendingDApp),2e18);
    //     lendingDApp.deposit(WBNB, 2e18);
    //     IERC20(WBNB).balanceOf(depositor1); //check if it left user wallet
    //     mockUSDT.mint(address(lendingDApp), 10000e18);
    //     lendingDApp.borrow(2e18, WBNB);
    //     IERC20(mockUSDT).balanceOf(depositor1); //check if the amount came into the user wallet
    //     skip(1209600);
    //     vm.startPrank(depositor2);
    //     mockUSDT.mint(depositor2, 1000e18);
    //     IERC20(mockUSDT).approve(address(lendingDApp), 500e18);
    //     mockPriceFeed.changePrice(11781040000); //mockChainlink changes the price of WETH for liquidation
    //     lendingDApp.liquidate(WBNB,address(depositor1));
    //     IERC20(WBNB).balanceOf(depositor2);
    //     mockUSDT.balanceOf(depositor2);
    //     lendingDApp.userBorrow(depositor1,WBNB);
    //     vm.stopPrank();
    // }

    // function test_accountCantBeliquidate() public{
    //     vm.prank(owner);
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    //     vm.startPrank(depositor1);
    //     deal(WBNB,depositor1,1e18);
    //     IERC20(WBNB).approve(address(lendingDApp),1e18);
    //     lendingDApp.deposit(WBNB, 1e18);
    //     IERC20(WBNB).balanceOf(depositor1); //check if it left user wallet
    //     mockUSDT.mint(address(lendingDApp), 10000e18);
    //     lendingDApp.borrow(200e18, WBNB);
    //     IERC20(mockUSDT).balanceOf(depositor1); //check if the amount came into the user wallet
    //     skip(1209600);
    //     vm.startPrank(depositor2);
    //     mockUSDT.mint(depositor2, 1000e18);
    //     IERC20(mockUSDT).approve(address(lendingDApp), 500e18);
        // vm.expectRevert(bytes("account can't be LIQUIDATED"));
    //     lendingDApp.liquidate(WBNB,depositor1);
    //     vm.stopPrank();
    // }

    // function test_chooseAnotherAccountToLiquidate() public{
    //     vm.prank(owner);
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    //     vm.startPrank(depositor1);
    //     deal(WBNB,depositor1,1e18);
    //     IERC20(WBNB).approve(address(lendingDApp),1e18);
        // lendingDApp.deposit(WBNB, 1e18);
    //     IERC20(WBNB).balanceOf(depositor1); //check if it left user wallet
    //     mockUSDT.mint(address(lendingDApp), 10000e18);
    //     lendingDApp.borrow(200e18, WBNB);
        // IERC20(mockUSDT).balanceOf(depositor1); //check if the amount came into the user wallet
    //     skip(1209600);
    //     vm.startPrank(depositor2);
    //     mockUSDT.mint(depositor2, 1000e18);
    //     IERC20(mockUSDT).approve(address(lendingDApp), 500e18);
    //     vm.expectRevert(bytes("choose another token to liqudate"));
    //     lendingDApp.liquidate(WBNB,owner);
    //     vm.stopPrank();
    // }

    function test_Lending() public {
        vm.startPrank(owner);
        lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
        lendingDApp.whitelistToken(address(mockUSDT), BNB_USDPriceFeed);
        vm.startPrank(depositor2);

        //lenders deposits
        mockUSDT.mint(depositor2, 10000e18);
        IERC20(mockUSDT).approve(address(lendingDApp),10000e18);
        lendingDApp.deposit(address(mockUSDT), 10000e18);
        IERC20(mockUSDT).balanceOf(depositor2); //check if it left user wallet

        //lenders deposits
        vm.startPrank(owner);
        mockUSDT.mint(owner, 10000e18);
        IERC20(mockUSDT).approve(address(lendingDApp),10000e18);
        lendingDApp.deposit(address(mockUSDT), 10000e18);
        IERC20(mockUSDT).balanceOf(owner); //check if it left user wallet

        // users comes to borrow
        vm.startPrank(depositor1);
        deal(WBNB,depositor1,1e18);
        IERC20(WBNB).approve(address(lendingDApp),1e18);
        lendingDApp.deposit(WBNB, 1e18);
        lendingDApp.borrow(200e18, WBNB);
        IERC20(mockUSDT).balanceOf(depositor1);
        skip(1209600);
        mockUSDT.mint(depositor1, 8e18);
        IERC20(mockUSDT).approve(address(lendingDApp), 208e18);
        lendingDApp.repay(208e18,WBNB);
        lendingDApp.withdraw(WBNB,1e18);

        //lenders deposits
        vm.startPrank(depositor1);
        mockUSDT.mint(depositor1, 10000e18);
        IERC20(mockUSDT).approve(address(lendingDApp),10000e18);
        lendingDApp.deposit(address(mockUSDT), 10000e18);
        IERC20(mockUSDT).balanceOf(depositor1); //check if it left user wallet

        // another borrow
        vm.startPrank(owner);
        deal(WBNB,owner,1e18);
        IERC20(WBNB).approve(address(lendingDApp),1e18);
        lendingDApp.deposit(WBNB, 1e18);
        lendingDApp.borrow(200e18, WBNB);
        IERC20(mockUSDT).balanceOf(owner);
        skip(1209600);
        mockUSDT.mint(owner, 8e18);
        IERC20(mockUSDT).approve(address(lendingDApp), 208e18);
        lendingDApp.repay(208e18,WBNB);
        lendingDApp.withdraw(WBNB,1e18);

        // another borrow
        vm.startPrank(owner);
        deal(WBNB,owner,1e18);
        IERC20(WBNB).approve(address(lendingDApp),1e18);
        lendingDApp.deposit(WBNB, 1e18);
        lendingDApp.borrow(200e18, WBNB);
        IERC20(mockUSDT).balanceOf(owner);
        skip(1209600);
        mockUSDT.mint(owner, 8e18);
        IERC20(mockUSDT).approve(address(lendingDApp), 208e18);
        lendingDApp.repay(208e18,WBNB);
        lendingDApp.withdraw(WBNB,1e18);
    

        // lenders withdraws 
        vm.startPrank(depositor1);
        lendingDApp.rewards();
        lendingDApp.userDeposit(depositor1, address(mockUSDT));
        lendingDApp.withdraw(address(mockUSDT),10000e18);
        IERC20(mockUSDT).balanceOf(depositor1); //check if the amount came into the user wallet

        // lenders withdraws 
        vm.startPrank(depositor2);
        lendingDApp.rewards();
        lendingDApp.userDeposit(depositor2, address(mockUSDT));
        lendingDApp.withdraw(address(mockUSDT),10000e18);
        IERC20(mockUSDT).balanceOf(depositor2); //check if the amount came into the user wallet

    }

    // function test_CantBorrowUSD() public {
    //     vm.startPrank(owner);
    //     lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    //     lendingDApp.whitelistToken(address(mockUSDT), BNB_USDPriceFeed);
    //     vm.startPrank(depositor2);

    //     //lenders deposits
    //     mockUSDT.mint(depositor2, 10000e18);
    //     IERC20(mockUSDT).approve(address(lendingDApp),10000e18);
    //     lendingDApp.deposit(address(mockUSDT), 10000e18);
    //     IERC20(mockUSDT).balanceOf(depositor2); //check if it left user wallet

    //     // users comes to borrow
    //     vm.startPrank(depositor1);
    //     mockUSDT.mint(depositor1, 1000e18);
    //     IERC20(mockUSDT).approve(address(lendingDApp),1000e18);
    //     lendingDApp.deposit(address(mockUSDT), 1000e18);
    //     vm.expectRevert(bytes("you cant borrow USD"));
    //     lendingDApp.borrow(200e18, address(mockUSDT));
       
    // }

    function mkaddr(string memory name) public returns (address) {
        address addr = address(uint160(uint256(keccak256(abi.encodePacked(name)))));
        vm.label(addr, name);
        return addr;
    }

}
