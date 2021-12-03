// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./utils/Ownable.sol";
import "./token/erc20/ERC20.sol";
// import "./CivilandContract.sol";

contract Currency is ERC20, Ownable
{

    // Civiland public civiland;
    // address feeCollector;

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function mint(address account, uint256 amount) public onlyOwner()
    {
        _mint(account, amount);
    }

    // function transferFromCiviland(address sender, uint256 amount) public returns (bool) {
    //     require(_msgSender() == address(civiland), "Can only be invoked from civiland!");
    //     _transfer(sender, feeCollector, amount);
    //     return true;
    // }

    // function setCiviland(address addr) public onlyOwner()
    // {
    //     civiland = Civiland(addr);
    // }

    // function setFeeCollector(address addr) public onlyOwner()
    // {
    //     feeCollector = addr;
    // }
}