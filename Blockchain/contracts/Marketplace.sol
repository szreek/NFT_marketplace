
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

    struct ListingDO {
        uint price;
        uint tokenId;
        uint feeAmount;
        boolean isFeePaid;
    }

    struct OfferDO {
        uint price;
        uint tokenId;
        address offerOwner;
    }
    
    uint public fee;

    mapping (address => CollectionDO[]) public userToCollections;
    mapping( address => bool ) public collectionAvailability;
    mapping (uint => uint) public idToNumberLeft;
    mapping( address => mapping( uint => ListingDO) ) public listings;
    mapping( address => mapping( uint => bool) ) public listingAvailability;
    mapping( address => mapping( uint => mapping( address => OfferDO ) ) ) public offers;
    mapping( address => mapping( uint => mapping( address => bool ) ) ) public offerAvailability;
    mapping( address => uint256 ) public userToFunds;
    

    event CollectionCreated( string collectionName, string collectionSymbol, address collectionAddress, address user );
    event NFTminted( uint tokenId, string collectionName, string collectionSymbol, address collectionAddress, address userAddress );
    event FundsDeposited( uint funds, address userAddress );
    event FundsReturned( uint funds, address userAddress );
    event ListingCreated( uint tokenId, address colectionAddress, uint price );
    event ListingRemoved( uint tokenId, address colectionAddress);
    event OfferCreated( uint tokenId, address colectionAddress, uint price );
    event OfferRemoved( uint tokenId, address colectionAddress);
    event TokenSold( uint price, uint tokenId, address collecionAddress, address fromUser, address toUser );



    modifier processingFeeMustBePaid( uint _fee ) {
        require( _fee >= fee, "Deposited fee is not enought to approved an offer." );
        _;
    }

    modifier onlyRegisteredCollection( NFTcollection _collection ) {
        require( collectionAvailability[ address( _collection ) ], "Address is not a Marketplace Collection." );
        _;
    }

    modifier onlyListedCollection( NFTcollection _collection ) {
        require( offersAvailability[ address( _collection ) ], "Address is not a Marketplace's Listed Collection." );
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

    
    function setFee( uint _fee ) onlyOwner external {
        fee = _fee;
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


    function createListing(uint _tokenId, uint _price, NFTcollection _collection ) onlyRegisteredCollection(_collection) processingFeeMustBePaid(_collection) public {
        
        if( msg.value > fee ) {
            userToFunds[ msg.sender ] += msg.value - fee;
        }

        listings[ address( _collection ) ] [ _tokenId ] = Listing( _price, _tokenId, fee, true );
        listingAvailability[ address( _collection ) ] [ _tokenId ] = true;

        emit ListingCreated( _tokenId, address( _collection ), _price );
    }


    function removeListing(uint _tokenId, NFTcollection _collection ) onlyRegisteredCollection( _collection ) public {
        listingAvailability[ address( _collection ) ] [ _tokenId ] = false;
        userToFunds[ msg.sender ] += listings[ address( _collection ) ] [ _tokenId ].feeAmount;
        delete listings[ address( _collection ) ] [ _tokenId ];
        
        emit ListingRemoved( _tokenId, address( _collection ) );
    }

    
    function buyListedNft(uint _tokenId, NFTcollection _collection )  onlyRegisteredCollection( _collection ) onlyListedCollection( _collection ) public {
        uint price = listings[ address( collection ) ] [ _tokenId ].price;
        
        if( msg.value > price ) {
            userToFunds[ msg.sender ] += msg.value - price;
        }

        address marketplace = owner()
        userToFunds[ marketplace ] += listings[ address( _collection ) ] [ _tokenId ].feeAmount;
        
        address tokenOwner = _collection.ownerOf( _tokenId );
        userToFunds[ tokenOwner ] += price;

        _collection.safeTransferFrom( tokenOwner, msg.sender, _tokenId );
        delete listings[ address( _collection ) ] [ _tokenId ];
        emit TokenSold( price, _tokenId, address( _collection ), tokenOwner, msg.sender );
    }

    
    function createOffer(uint _tokenId, uint _price, NFTcollection _collection) onlyRegisteredCollection( collection ) public {
        offers[ address( _collection ) ] [ _tokenId ] [msg.sender] = OfferDO(_price, _tokenId, msg.sender);
        offersAvailability[ address( _collection) ] [ _tokenId ] [ msg.sender ] = true;

        emit OfferCreated( _tokenId, address( _collection ), _price );
    }

    function removeOffer(uint _tokenId, uint _price, NFTcollection _collection) public {
        offerAvailability[ address( _collection ) ] [ _tokenId ] = false;
        delete offers[ address( _collection ) ] [ _tokenId ];
        
        emit OfferRemoved( _tokenId, address( _collection ) );
    }

    function acceptOffer(uint _tokenId, NFTcollection _collection, address _offererAddress) onlyRegisteredCollection(_collection) processingFeeMustBePaid( msg.value ) public {
        if( msg.value > fee ) {
            userToFunds[ msg.sender ] += msg.value - fee;
        }

        userToFunds[ owner() ] += fee;
        
        uint price = offers[ address( _collection) ] [ _tokenId ] [ _offererAddress ].price;
        userToFunds[ msg.sender ] += price;

        
        _collection.safeTransferFrom( msg.sender, _offererAddress, _tokenId );

        emit TokenSold( price, _tokenId, address( _collection ), msg.sender, _offererAddress );
    }

    function rejectOffer(uint _tokenId, NFTcollection _collection, address _offererAddress) onlyRegisteredCollection(_collection) public {
        offers[ address( _collection) ] [ _tokenId ] [ offerersAddress ].active = false;
        offerAvailability[ address( _collection) ] [ _tokenId ] [ offerersAddress ] = false;
        userToFunds[ offerersAddress ] += offers[ address( _collection) ] [ _tokenId ] [ offerersAddress ].price;

        emit OfferRejected( _tokenId, address( _collection ), offererAddress );
    }


}
