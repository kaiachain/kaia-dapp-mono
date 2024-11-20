// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

contract KaiaConsumerContract {
    IPyth pyth;

    /**
     * Network: Kaia Kairos aka klatyn-testnet
     * Address: 0x2880ab155794e7179c9ee2e38200202908c17b43
     * https://docs.pyth.network/price-feeds/contract-addresses/evm#testnets
     */
    constructor() {
        pyth = IPyth(0x2880ab155794e7179c9ee2e38200202908c17b43);
    }

    function getPrice() public view returns (PythStructs.Price memory) {
        // KLAY/USD priceID
        bytes32 priceID = 0xde5e6ef09931fecc7fdd8aaa97844e981f3e7bb1c86a6ffc68e9166bb0db3743;
        return pyth.getPrice(priceID);
    }

    function updatePrice(bytes[] calldata priceUpdateData) public payable {
        uint fee = pyth.getUpdateFee(priceUpdateData);
        pyth.updatePriceFeeds{value: fee}(priceUpdateData);
    }

    function getLatestPrice(
        bytes[] calldata priceUpdateData
    ) external payable returns (PythStructs.Price memory) {
        updatePrice(priceUpdateData);
        return getPrice();
    }
}
