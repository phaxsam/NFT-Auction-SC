pragma solidity 0.8.17;

interface IERC721 {
    function safeTransferFrom(address from, address to, uint tokenId) external;

    function transferFrom(address, address, uint) external;
}


contract auctionDeal{

   IERC721 public NFT;
   uint public NFTId;

    //struct Auction{
        address payable public seller;
        uint public auctionDuration;
        bool public  started;
        bool public  ended;
    
      //Auction[] public auction;

        
            address public highestBidder;
            uint public  highestBidAmount;
            mapping(address => uint) public bids;
      

      constructor(address _NFT, uint _NFTId, uint _startingBid) {
          NFT = IERC721(_NFT);
          NFTId = _NFTId;

          seller = payable(msg.sender);
          highestBidAmount = _startingBid;
      }


    function start() external{
        require(!started, "auction already started");
        require(msg.sender == seller, "not right seller");

        NFT.transferFrom(msg.sender, address(this), NFTId);
        started = true;
       auctionDuration = block.timestamp + 9 days;

    }
    
    function bid() external payable{
        require(started, "not started");
        require(block.timestamp < auctionDuration, "already ended");
        require(msg.value > highestBidAmount, "increase amount");

           if(highestBidder != address(0)) {
              bids[highestBidder] += highestBidAmount;
           }

          highestBidder = msg.sender;
          highestBidAmount = msg.value;
    }


    function withdraw() external{
        uint bal = bids[msg.sender];
       bids[msg.sender] = 0;
        payable(msg.sender).transfer(bal);
    }


function endAuction() external{
    require(started, "not started");
    require(block.timestamp >= auctionDuration, "auction still ongoing");
    require(!ended, "it's ended already");

  ended = true;
    if (highestBidder != address(0)) {
        NFT.safeTransferFrom(address(this), highestBidder, NFTId);
       seller.transfer(highestBidAmount);
    } else {
        NFT.safeTransferFrom(address(this), seller, NFTId);
    }
}


}