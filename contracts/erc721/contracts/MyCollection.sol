// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyCollection is ERC721 {
    constructor() ERC721("MyCollection", "MCN") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://mycollection.com/";
    }
}
