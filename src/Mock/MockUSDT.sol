pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDT is ERC20("MockUSDC", "USDC"){
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

}