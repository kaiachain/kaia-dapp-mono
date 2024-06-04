// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import { VRFConsumerBase } from "@bisonai/orakl-contracts/src/v0.1/VRFConsumerBase.sol";
import { IVRFCoordinator } from "@bisonai/orakl-contracts/src/v0.1/interfaces/IVRFCoordinator.sol";

contract CoinFlip is VRFConsumerBase {

    enum CoinFlipChoice {
        HEADS,
        TAILS
    }

    struct CoinFlipStatus {
        uint256 fees;
        uint256 randomWord;
        address player;
        bool didWin;
        bool fulfilled;
        CoinFlipChoice choice;
    }

    error CoinFlip__EntryFeesNotEnough();
    error CoinFlip__RequestNotFound();

    mapping (uint256 => CoinFlipStatus) public s_status;

    uint256 public s_entryFees = 1 ether;

    uint256 private sRandomWord;
    IVRFCoordinator immutable i_vrfCoordinator;

    address private constant vrfAddress = 0xDA8c0A00A372503aa6EC80f9b29Cc97C454bE499;
    address private constant s_refundRecipient = 0x5664eeeE3C63431eF1981f2bDBaB2690ee33f1e8;
    uint32 private constant s_gasLane = 500000;
    uint32 private constant s_numWords = 1;
    bytes32 private constant s_keyHash =
        0xd9af33106d664a53cb9946df5cd81a30695f5b72224ee64e798b278af812779c;

    constructor() VRFConsumerBase(vrfAddress) {
        i_vrfCoordinator = IVRFCoordinator(vrfAddress);
    }

    function flip(CoinFlipChoice choice) external payable returns(uint256 requestId){
        if(msg.value < s_entryFees) {
            revert CoinFlip__EntryFeesNotEnough();
        }

        requestId = i_vrfCoordinator.requestRandomWords(
            s_keyHash,
            s_gasLane,
            s_numWords,
            s_refundRecipient
        );

        s_status[requestId] = CoinFlipStatus(
            {
            fees: s_gasLane,
            randomWord: 0,
            player: msg.sender,
            didWin: false,
            fulfilled: false,
            choice: choice
            }
        );
        
        return requestId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        if(s_status[requestId].fees < 0) {
            revert CoinFlip__RequestNotFound();
        }

        s_status[requestId].fulfilled = true;
        s_status[requestId].randomWord = randomWords[0];

        CoinFlipChoice result = CoinFlipChoice.HEADS;

        if(randomWords[0] % 2 == 0) {
            result = CoinFlipChoice.TAILS; // If the random Word is even, it is tails
        }

        if(s_status[requestId].choice == result) {
            s_status[requestId].didWin = true;
            (bool success, ) = payable(s_status[requestId].player).call{value: s_entryFees * 2}("");
            require(success, "Transation failed");
        }
    }

    function getStatus(uint256 requestId) public view returns(CoinFlipStatus memory) {
        return s_status[requestId];
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }
}
