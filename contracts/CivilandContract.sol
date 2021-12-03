// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./utils/Ownable.sol";
import "./token/erc721/ERC721Enumerable.sol";
import "./token/erc20/ERC20.sol";
import "./CurrencyContract.sol";
import "./AttributeContract.sol";


contract Civiland is ERC721Enumerable, Ownable
{

    uint8 feeRate;
    Currency currency;
    Attribute attribute;

    mapping (uint256 => uint256[]) public attrs;
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function breed(address to, uint256 tokenId) external onlyOwner()
    {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) external 
    {
        require(_msgSender() == ownerOf(tokenId), "Can not burn other's token");
        _burn(tokenId);
    }

    function transfer(address to, uint256 tokenId) external 
    {
        transferFrom(_msgSender(), to, tokenId);
    }

    function bindAttribute(uint256 tokenId, uint256 attrId) public 
    {
        address caller = _msgSender();
        require(caller == ownerOf(tokenId));
        attrs[tokenId].push(attrId);

        attribute.bindToCiviland(ownerOf(tokenId), tokenId, attrId);
    }

    function setCurrency(address addr) public onlyOwner()
    {
        currency = Currency(addr);
    }

    function setFeeRate(uint8 rate) public onlyOwner()
    {
        feeRate = rate;
    }

}

