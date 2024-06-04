//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ERC721Example is ERC721, ERC2981 {
    constructor() ERC721("Name", "Symbol") {
        // set royalty of all NFTs to 5%
        _setDefaultRoyalty(_msgSender(), 500);
    }

    function mint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
