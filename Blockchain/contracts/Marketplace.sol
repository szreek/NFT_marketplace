
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./NFTcollection.sol";

contract Marketplace is Ownable {

    
    struct CollectionDO {
        string name;
        string symbol;
        address creatorAddress;
        address nftsAddress;
    }
    
    
    mapping (address => CollectionDO[]) public userToCollections;
    mapping (uint => uint) public idToNumberLeft;
    mapping( address => bool ) public collectionAvailability;
    mapping( address => uint256 ) public userToFunds;
    

    event CollectionCreated( string collectionName, string collectionSymbol, address collectionAddress, address user );
    event NFTminted( uint _tokenId, string collectionName, string collectionSymbol, address collectionAddress, address userAddress );
    event FundsDeposited( uint funds, address userAddress );
    event FundsReturned( uint funds, address userAddress );


    modifier onlyRegisteredCollection( NFTcollection _collection ) {
        require( collectionAvailability[ address( _collection ) ], "Address is not a Marketplace Collection." );
        _;
    }

    receive() external payable {
        userToFunds[ msg.sender ] += msg.value;
        emit FundsDeposited( msg.value, msg.sender );
    }
    
    fallback() external payable {
        userToFunds[ msg.sender ] += msg.value;
        emit FundsDeposited( msg.value, msg.sender );
    }

    function returnFunds( uint256 amount ) external {
        require( userToFunds[ msg.sender ] >= amount, "Not enough funds." );
        userToFunds[ msg.sender ] = userToFunds[ msg.sender ] - amount;
        ( bool sent, ) = msg.sender.call{ value: amount }("");
        require( sent, "Could not send Ether. Please try again :)" );

        emit FundsReturned( amount,  msg.sender );
    }

    function createCollection(string memory _name, string memory _symbol) public {
        NFTcollection nfts = new NFTcollection(_name, _symbol);
        address nftColAddress = address(nfts);
        CollectionDO memory newCollection = CollectionDO(_name, _symbol, msg.sender, nftColAddress);
        userToCollections[msg.sender].push(newCollection);
        collectionAvailability[nftColAddress] = true;

        emit CollectionCreated( _name, _symbol, nftColAddress, msg.sender ); 
    } 

    function mint(NFTcollection _collection, string memory _uri) onlyRegisteredCollection(_collection) public {
        uint tokenId = _collection.safeMint(msg.sender, _uri);
        emit NFTminted( tokenId, _collection.name(), _collection.symbol(), address(_collection), msg.sender); 
    }


    function createListing(uint _tokenId, uint _price, NFTcollection _collection ) onlyRegisteredCollection(_collection) public {

    }


    function removeListing(uint _tokenId, uint _price, NFTcollection _collection ) onlyRegisteredCollection(_collection) public {

    }

    
    function createOffer(uint _tokenId, uint _price, NFTcollection _collection) public {

    }

    function removeOffer(uint _tokenId, uint _price, NFTcollection _collection) public {

    }

    function buy(uint _nftId) public {

    }
}
