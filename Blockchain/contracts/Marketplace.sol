
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
    

    event CollectionCreated( string collectionName, string collectionSymbol, address collectionAddress, address user );
    event NFTminted( uint _tokenId, string collectionName, string collectionSymbol, address collectionAddress, address userAddress );


    modifier onlyRegisteredCollection( NFTcollection _collection ) {
        require( collectionAvailability[ address( _collection ) ], "Address is not a Marketplace Collection." );
        _;
    }

    function createCollection(string memory _name, string memory _symbol) public {
        NFTcollection nfts = new NFTcollection(_name, _symbol);
        CollectionDO memory newCollection = CollectionDO(_name, _symbol, msg.sender, address(nfts));
        userToCollections[msg.sender].push(newCollection);
        collectionAvailability[address(nfts)] = true;

        emit CollectionCreated( _name, _symbol, address(nfts), msg.sender ); 
    } 

    function mint(NFTcollection _collection, string memory _uri) onlyRegisteredCollection(_collection) public {
        uint tokenId = _collection.safeMint(msg.sender, _uri);
        emit NFTminted( tokenId, _collection.name(), _collection.symbol(), address(_collection), msg.sender); 
    }


    function createListing(uint _nftId) public {

    }

    function buy(uint _nftId) public {

    }

    function makeOffer(uint _nftId) public {

    }

    function getAllOffersForUser() public {

    }

}
