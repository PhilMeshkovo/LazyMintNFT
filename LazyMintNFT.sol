// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract LazyMintNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct NFTVoucher {
        uint256 price;
        string uri;
    }

    mapping(uint256 => NFTVoucher) public vouchers;

    constructor() ERC721("LazyMintNFT", "LMN") Ownable(msg.sender) {}

    function createVoucher(uint256 tokenId, uint256 price, string memory uri) public onlyOwner {
        vouchers[tokenId] = NFTVoucher({
            price: price,
            uri: uri
        });
    }

    function buyNFT(uint256 tokenId) public payable {
        NFTVoucher memory voucher = vouchers[tokenId];
        require(msg.value >= voucher.price, "Insufficient payment");
        require(bytes(voucher.uri).length > 0, "Voucher does not exist");

        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, voucher.uri);

        // Transfer the payment to the owner
        payable(owner()).transfer(msg.value);

        // Remove the voucher to prevent reuse
        delete vouchers[tokenId];
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }
}