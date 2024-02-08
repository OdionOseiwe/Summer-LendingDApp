pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDT is ERC20("MockUSDC", "USDC"){
    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }

}