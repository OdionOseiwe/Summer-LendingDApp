// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SummerToken is ERC20("SummerToken", "ST"){
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

}