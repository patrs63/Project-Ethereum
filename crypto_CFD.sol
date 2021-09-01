// SPDX-License-Identifier: CC-BY-SA-4.0

// Version of Solidity compiler this program was written for

pragma solidity ^0.8.0;

import "./coinInfo.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";



contract CryptoCFD {
    LinkTokenInterface private LINK;
    address payable owner;


    event success(string message,uint256 value);

    mapping(string => coinInfo) coinsList; //mapping form coin index (for example bitcoin = 1 )
    mapping(string => bool) existingCoins;


    constructor() {
        LINK = LinkTokenInterface(0xa36085F69e2889c224210F603D836748e7dC0088);
        owner = payable(msg.sender);

        //BAT
        // coinInfo coin3 = new coinInfo("BAT", 0x8e67A0CFfbbF6A346ce87DFe06daE2dc782b3219);
        // coinsList["BAT"] = coin3;
        // existingCoins["BAT"] = true;

        /*
        //BTC
        coinInfo coin = new coinInfo("BTC", 0x6135b13325bfC4B00278B4abC5e20bbce2D6580e,address(timeLibrary));
        coinsList["BTC"] = coin;
        existingCoins["BTC"] = true;
        //XRP
        coinInfo coin2 = new coinInfo("XRP", 0x3eA2b7e3ed9EA9120c3d6699240d1ff2184AC8b3,address(timeLibrary));
        coinsList["XRP"] = coin2;
        existingCoins["XRP"] = true;
        */

    }


    modifier onlyOwner {
        require(msg.sender == owner, "Sorry you dont have permission to execute this function");
        _;
    }

    function addCoin(string memory coinName, address coinAddress) public onlyOwner{
        coinsList[coinName] = new coinInfo(coinName,coinAddress);
        existingCoins[coinName] = true;
    }

    // function rechargeLink(address subContractAddress) private{
    //     if(LINK.balanceOf(subContractAddress) == 0){
    //         require(LINK.balanceOf(address(this)) > 4, "No sufficient LINK tokens."); // we assume the CFD contract has enough LINKs
    //         LINK.transfer(subContractAddress, 4); // send 4 tokens to the coinInfo Subcontract
    //     }
    // }

    function executeBet(string memory coin,uint decision) public payable{//maybe later change decision to string = long or short and internal change to bool
        //msg.sender // msg.value
        require(existingCoins[coin] != false, "The coin you are trying to bet on doesnt exist");
        require(msg.value > 0 ether, "you need to add a positive ether value to make a bet");

        // rechargeLink(address(coinsList[coin]));//could be optimized

        uint256 betID = coinsList[coin].placeBet(msg.sender, msg.value, decision);
        emit success("Your bet was placed successfully, please reedem your winnings after 24h using for the follwing betID",betID);
    }

    function redeemBet(string memory coin,uint256 betID) public{
        require(existingCoins[coin] != false, "The coin you are trying to bet on doesnt exist");

        // rechargeLink(address(coinsList[coin])); // could be optimized

        (uint256[] memory values, address[] memory addresses) = coinsList[coin].redeemBet(betID);

        for (uint i=0; i< values.length ; i++){
            payable(addresses[i]).transfer(values[i]);
        }
        // delete addresses;
        // delete values;
    }


    // Accept any incoming amount - I guess if anyone want to donate :)
    receive() external payable {}

    // Contract destructor
    function destroy() public onlyOwner {
        /*add withdraw link back to my address aswell or I'll lose the link*/
        LINK.transfer(owner, LINK.balanceOf(address(this)));
        /*let this contract destroy inner ones to reedem inner link*/
        selfdestruct(owner);
    }

}
