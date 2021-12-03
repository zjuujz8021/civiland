// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./utils/Ownable.sol";
import "./token/erc721/ERC721Enumerable.sol";
import "./token/erc20/ERC20.sol";
import "./CurrencyContract.sol";


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

    function setAttribute(address addr) public onlyOwner()
    {
        attribute = Attribute(addr);
    }

    function setFeeRate(uint8 rate) public onlyOwner()
    {
        feeRate = rate;
    }

}

contract Attribute is ERC721Enumerable, Ownable
{
    struct AttrInfo
    {
        bool binded;
        uint256 bindTo;
    }
    address constant public BLOCK_ADDRESS = address(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF);
    Civiland public civiland;
    mapping (uint256 => AttrInfo) public attrs;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

    function mint(address to, uint256 tokenId) external onlyOwner()
    {
        _mint(to, tokenId);
    }

    // function burn(uint256 tokenId) external 
    // {
    //     require(_msgSender() == ownerOf(tokenId), "Can not burn other's token");
    //     _burn(tokenId);
    // }

    function transfer(address to, uint256 tokenId) external 
    {
        transferFrom(_msgSender(), to, tokenId);
    }

    function bindToCiviland(address civilandOwner, uint256 civilandId, uint256 attrId) public 
    {
        require(_msgSender() == address(civiland));
        require(!attrs[attrId].binded);
        require(civilandOwner == ownerOf(attrId));
        _transfer(ownerOf(attrId), BLOCK_ADDRESS, attrId);

        AttrInfo storage attr = attrs[attrId];
        attr.binded = true;
        attr.bindTo = civilandId;
    }

    // function setCurrency(address addr) public onlyOwner()
    // {
    //     currency = CurrencyContract(addr);
    // }

    function setCiviland(address addr) public onlyOwner()
    {
        civiland = Civiland(addr);
    }

}