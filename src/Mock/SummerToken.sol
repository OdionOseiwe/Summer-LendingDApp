pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SummerToken is ERC20("SummerToken", "ST"){
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

}