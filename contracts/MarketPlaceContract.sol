// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./utils/Ownable.sol";
import "./CurrencyContract.sol";
import "./CivilandContract.sol";
import "./utils/Context.sol";

contract MarketPlace is Context, Ownable
{
    struct Sale
    {
        address seller;
        uint256 currPrice;
        bool isAuction; // or fixed-price
        address lastBidder;
        address specifiedBuyer;
        uint64 startTime; //to judge a valid sale
        uint64 duration;
    }

    mapping (address => mapping (uint256 => Sale)) public sales;
    // Civiland public civiland;
    Currency public currency;

    event SaleCreation
    (
        address indexed seller,
        address indexed asset,
        uint256 indexed tokenId,
        uint256 price,
        bool isAuction,
        address specifiedBuyer,
        uint64 startTime,
        uint64 endTime
    );

    event SaleCancellation
    (
        address indexed seller,
        address indexed asset,
        uint256 indexed tokenId
    );

    event SaleSuccess
    (
        address indexed seller,
        address indexed asset,
        uint256 indexed tokenId,
        uint256 price,
        bool isAuction,
        address buyer
    );
    
    function createSale(uint256 tokenId, address asset, uint256 price, bool isAuction, address buyer, uint64 duration) public
    {
        address seller = _msgSender();
        require(sales[asset][tokenId].startTime == 0, "sale has existed");
        require(!(isAuction == true && buyer != address(0)), "specifying buyer is not allowed when sale mode is auction");
        require(block.timestamp + duration > block.timestamp, "duration overflow"); 

        IERC721(asset).transferFrom(seller, address(this), tokenId);
        sales[asset][tokenId] = Sale(seller, price-1, isAuction, address(0), buyer, uint64(block.timestamp), duration);

        emit SaleCreation(seller, asset, tokenId, price, isAuction, buyer, uint64(block.timestamp), uint64(block.timestamp) + duration);
    }

    function revokeSale(address asset, uint256 tokenId) public 
    {
        Sale storage sale = sales[asset][tokenId];
        address seller = _msgSender();
        require(sale.startTime != 0, "sale does not exist");
        require(seller == sale.seller, "can not revoke other user's sale");
        require(sale.lastBidder == address(0), "sale has been ordered, can not revoke");
        IERC721(asset).transferFrom(address(this), seller, tokenId);
        delete sales[asset][tokenId];

        emit SaleCancellation(seller, asset, tokenId);
    } 

    // for fixed-price mode
    function buy(address asset, uint256 tokenId) public
    {
        Sale storage sale = sales[asset][tokenId];
        address buyer = _msgSender();
        require(sale.startTime + sale.duration > block.timestamp, "sale does not exits or is out of date");
        require(!sale.isAuction, "sale in auction mode");

        currency.transferFrom(buyer, sale.seller, sale.currPrice);
        IERC721(asset).transferFrom(address(this), buyer, tokenId);

        emit SaleSuccess(sale.seller, asset, tokenId, sale.currPrice, sale.isAuction, buyer);
        delete sales[asset][tokenId];
    }

    // for auction mode
    function bid(address asset, uint256 tokenId, uint256 price) public
    {
        Sale storage sale = sales[asset][tokenId];
        address bidder = _msgSender();
        require(sale.startTime + sale.duration > block.timestamp, "sale does not exits or is out of date");
        require(sale.isAuction, "sale in fixed-price mode");
        require(price > sale.currPrice);

        if(sale.lastBidder != address(0))
        {
            currency.transferFrom(address(this), sale.lastBidder, sale.currPrice);
        }
        sale.currPrice = price;
        sale.lastBidder = bidder;
    }

    // for auction mode, after auction, withdraw the nft
    function endBid(address asset, uint256 tokenId) public
    {
        Sale storage sale = sales[asset][tokenId];
        //address caller = _msgSender();
        require(sale.startTime != 0, "sale does not exist");
        require(sale.isAuction, "sale in fixed-price mode");
        require(sale.startTime + sale.duration < block.timestamp, "sale has not been closed");
        // require(sale.lastBidder == caller || sale.seller == caller, "you can not end the bid");
        if (sale.lastBidder != address(0))
        {
            currency.transferFrom(address(this), sale.seller, sale.currPrice);
            IERC721(asset).transferFrom(address(this), sale.lastBidder, tokenId);
            emit SaleSuccess(sale.seller, asset, tokenId, sale.currPrice, sale.isAuction, sale.lastBidder);
        }
        else
        {
            IERC721(asset).transferFrom(address(this), sale.seller, tokenId);
            emit SaleCancellation(sale.seller, asset, tokenId);
        }

        delete sales[asset][tokenId];
    }


    // function setCiviland(address addr) public onlyOwner()
    // {
    //     civiland = Civiland(addr);
    // }

    function setCurrency(address addr) public onlyOwner()
    {
        currency = Currency(addr);
    }
}