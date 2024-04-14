// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/LendingDapp.sol";
import "../src/Mock/ChainLinkMock.sol";
import "../src/Mock/MockUSDT.sol";
import "../src/Mock/SummerToken.sol";

contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        MockPriceFeed mockPriceFeed = new MockPriceFeed();
        MockUSDT mockUSDT = new MockUSDT();
        SummerToken summerToken = new SummerToken();
        LendingDApp lendingDapp = new LendingDApp(address(mockUSDT));

        vm.stopBroadcast();
    }
}
// forge script script/deploy.s.sol:MyScript --rpc-url https://bsc-testnet.publicnode.com \ --etherscan-api-key	ZFKEJHY63XQX835Z3C7MIWVZ5W343EYT5H \ --broadcast --verify --multi -vvvv


