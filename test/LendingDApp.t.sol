// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {LendingDApp} from "../src/LendingDapp.sol";
import  "../src/Mock/MockUSDT.sol";
import  "../src/Mock/SummerToken.sol";
import "../src/interface/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract LendDAppTest is Test {
    LendingDApp public lendingDApp;
    MockUSDT public mockUSDT;
    SummerToken public summerToken;
    address public WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address public RichGuy = 0x192D4064ec4645d1A3ea86F6f6BeEd237f102173;
    address public BNB_USDPriceFeed = 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526;
    address depositor1 = mkaddr("depositor1");
    address depositor2 = mkaddr("depositor2");
    address owner = mkaddr("owner");

    // tests are ran on binance testnet
    function setUp() public {
        mockUSDT = new MockUSDT();
        summerToken = new SummerToken();
        lendingDApp = new LendingDApp(address(mockUSDT), address(summerToken));
        lendingDApp.transferOwnership(owner);
    }

    function test_ShouldRevertNotOwnerwhiteListToken() public {
        vm.startPrank(RichGuy);
        vm.expectRevert();
        lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
        vm.stopPrank();
    }

    function test_RevertAddressZero() public {
        vm.prank(owner);
        vm.expectRevert(bytes("Revert address zero not allowed"));
        lendingDApp.whitelistToken(address(0), BNB_USDPriceFeed);
    }

    function test_RevertWhitelistTokenTwice() public {
        vm.startPrank(owner);
        lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
        vm.expectRevert(bytes("Revert: Token already exists"));
        lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
        vm.stopPrank();
    }

    function test_WhitelistToken() public {
        vm.prank(owner);
        lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
    }

    function test_DepositRevertNotWhitelisted() public {
       vm.startPrank(RichGuy);
       vm.expectRevert(bytes("Revert: not whitelisted"));
       lendingDApp.deposit(WBNB,1e18);
       vm.stopPrank(); 
    }

    function test_Deposit() public {
        vm.prank(owner);
        lendingDApp.whitelistToken(WBNB, BNB_USDPriceFeed);
        vm.startPrank(depositor1);
        deal(WBNB,depositor1,10e18);
        IERC20(WBNB).approve(address(lendingDApp),1e18);
        lendingDApp.deposit(WBNB, 1e18);
        uint256 bal = IERC20(WBNB).balanceOf(address(lendingDApp));
        console.log(bal);
        vm.stopPrank(); 

     }

    // function testFuzz_SetNumber(uint256 x) public {
    //     LendingDApp.setNumber(x);
    //     assertEq(LendingDApp.number(), x);
    // }
    function mkaddr(string memory name) public returns (address) {
        address addr = address(uint160(uint256(keccak256(abi.encodePacked(name)))));
        vm.label(addr, name);
        return addr;
    }

}
