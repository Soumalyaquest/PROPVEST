// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";


contract NFTMarketplace is  ERC1155{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 listingPrice = 0.01 ether;
    address payable owner;

    mapping(uint256 => City) public TokenCity;
    mapping(uint => mapping(address => MarketItem)) public Person;
    mapping(address =>  uint) private Withdrawals;
    
    struct City{
        string CityName;
       uint256 totalLiquidity;
        uint256 price;
    }

    struct MarketItem {
      uint256 tokenId;
      address  seller;
      address  owner;
      uint256 amount;
      bool sold;
    }

    constructor() ERC1155("https://token-cdn-domain/{id}.json") {
      owner = payable(msg.sender);
    }

    /* Updates the listing price of the contract */
    function updateListingPrice(uint _listingPrice) public payable {
      require(owner == msg.sender, "Only marketplace owner can update listing price.");
      listingPrice = _listingPrice;
    }

    function TokenCityMint(uint _tokenId, string memory _cityName, uint256 _price) public {
        require(msg.sender == owner,"You are not the Owner");
        TokenCity[_tokenId].CityName = _cityName;
        TokenCity[_tokenId].price = _price;
         _mint(owner,_tokenId,0,"");

    }

    /* Mints a token*/
    function createToken(uint256 _amount,uint256 _tokenId) public{
        Person[_tokenId][msg.sender] = MarketItem(_tokenId,msg.sender,address(this),_amount,true);
        Withdrawals[msg.sender] = _amount * TokenCity[_tokenId].price ;
        TokenCity[_tokenId].totalLiquidity += _amount; 
        _mint(owner,_tokenId,TokenCity[_tokenId].totalLiquidity,"");
    }

    /* Creates the sale  item */
    /* Transfers ownership of the item, as well as funds between parties */
    function createMarketBuy(
      uint256 tokenId,
      uint256 _amount
      ) public payable {
      uint _price = TokenCity[tokenId].price;
      //address seller = idToMarketItem[tokenId].seller;
      uint Price_to_pay = (_amount * _price) + listingPrice; 
      require(msg.value >= Price_to_pay, "Please submit the asking price in order to complete the purchase");
      TokenCity[tokenId].totalLiquidity -= _amount;
      safeTransferFrom(address(this),msg.sender,tokenId,_amount,"");
      payable(owner).transfer(listingPrice);
    }

    function Withdraw() external  {
        
        require(Withdrawals[msg.sender] > 0, "Error, You already withdrawed");
        require(address(this).balance >= Withdrawals[msg.sender],"Token isn't Sold");
        payable(msg.sender).transfer(Withdrawals[msg.sender]);
        Withdrawals[msg.sender] = 0;
    }

  



    
}