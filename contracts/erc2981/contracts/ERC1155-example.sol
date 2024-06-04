//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract ERC1155Example is ERC1155, ERC2981 {
    constructor() ERC1155("ipfs://example/{id}.json") {
        // set royalty of all NFTs to 5%
        _setDefaultRoyalty(_msgSender(), 500);
    }

    function mint(
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) public {
        _mint(to, tokenId, amount, data);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
