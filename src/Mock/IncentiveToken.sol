pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDT is ERC20("SummerToken", "ST"){
    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }

}