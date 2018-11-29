pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';

contract StarNotary is ERC721 { 

    struct Coordinates {
        string ra;
        string dec;
        string mag;
    }

    struct Star { 
        string name;
        string story;
        Coordinates coordinates;
    }

    mapping(uint256 => Star) public tokenIdToStarInfo; 
    mapping(uint256 => uint256) public starsForSale;
    mapping(bytes32 => bool) public starHashMap;

    function createStar(string name, string story, string ra, string dec, string mag, uint256 tokenId) public { 

        require(keccak256(abi.encodePacked(tokenIdToStarInfo[tokenId].coordinates.dec)) == keccak256(""));

        require(keccak256(abi.encodePacked(ra)) != keccak256(""));
        require(keccak256(abi.encodePacked(dec)) != keccak256(""));
        require(keccak256(abi.encodePacked(mag)) != keccak256(""));
        require(!checkIfStarExist(ra, dec, mag));
        
        Coordinates memory newCoordinates = Coordinates(ra, dec, mag);
        Star memory newStar = Star(name, story, newCoordinates);

        tokenIdToStarInfo[tokenId] = newStar;

        bytes32 hash = generateStarHash(ra, dec, mag);
        starHashMap[hash] = true;

        _mint(msg.sender, tokenId);
    }

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public { 
        require(this.ownerOf(_tokenId) == msg.sender);

        starsForSale[_tokenId] = _price;
    }

    function buyStar(uint256 _tokenId) public payable { 
        require(starsForSale[_tokenId] > 0);
        
        uint256 starCost = starsForSale[_tokenId];
        address starOwner = this.ownerOf(_tokenId);
        require(msg.value >= starCost);

        _removeTokenFrom(starOwner, _tokenId);
        _addTokenTo(msg.sender, _tokenId);
        
        starOwner.transfer(starCost);

        if(msg.value > starCost) { 
            msg.sender.transfer(msg.value - starCost);
        }
    }

    function mint(uint256 tokenId) public {
        super._mint(msg.sender, tokenId);
    }

    function checkIfStarExist(string ra, string dec, string mag) public view returns(bool) {
        return starHashMap[generateStarHash(ra, dec, mag)];
    }

    function generateStarHash(string ra, string dec, string mag) private pure returns(bytes32) {
        return keccak256(abi.encodePacked(ra, dec, mag));
    }

    function tokenIdToStarInfo(uint256 tokenId) public view returns(string, string, string, string, string) {
        return (tokenIdToStarInfo[tokenId].name, tokenIdToStarInfo[tokenId].story, tokenIdToStarInfo[tokenId].coordinates.ra, tokenIdToStarInfo[tokenId].coordinates.dec, tokenIdToStarInfo[tokenId].coordinates.mag);
    }
}