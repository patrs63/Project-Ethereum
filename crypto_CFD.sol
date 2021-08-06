// SPDX-License-Identifier: CC-BY-SA-4.0

// Version of Solidity compiler this program was written for

pragma solidity ^0.8.0;

import "./LinkedList.sol";
import "./coinInfo.sol";
import "./DateTime.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";



contract CryptoCFD {
    LinkTokenInterface private LINK;
    address payable owner;
    event time(uint8 errorMessage,string name);
    uint time2;
    event test(uint256 node_id, string name);
    event test3(string name, int val);
    event test2(uint256 node_id, address addr);
    AggregatorV3Interface internal priceFeed; //delete later
    
    event success(string message,uint256 value);

    mapping(string => coinInfo) coinsList; //mapping form coin index (for example bitcoin = 1 )
    mapping(string => bool) existingCoins;
    DateTime public timeLibrary;
    
    constructor() {
        LINK = LinkTokenInterface(0xa36085F69e2889c224210F603D836748e7dC0088);
        owner = payable(msg.sender);
        priceFeed = AggregatorV3Interface(0x8e67A0CFfbbF6A346ce87DFe06daE2dc782b3219);
        timeLibrary = new DateTime();
        //BTC
        coinInfo coin = new coinInfo("BTC", 0x6135b13325bfC4B00278B4abC5e20bbce2D6580e,address(timeLibrary));
        coinsList["BTC"] = coin;
        existingCoins["BTC"] = true;

        //XRP
        coinInfo coin2 = new coinInfo("XRP", 0x3eA2b7e3ed9EA9120c3d6699240d1ff2184AC8b3,address(timeLibrary));
        coinsList["XRP"] = coin2;
        existingCoins["XRP"] = true;

        //BAT
        coinInfo coin3 = new coinInfo("BAT", 0x8e67A0CFfbbF6A346ce87DFe06daE2dc782b3219,address(timeLibrary));
        coinsList["BAT"] = coin3;
        existingCoins["BAT"] = true;
    }
 
    
    function doStuff() public {
        uint256 val =1;
        string memory coin = "BTC";
        if (existingCoins[coin] == false) {
            string memory fail = "FAILURE";
            emit test(val, fail);
            return;
        }
        string memory name = coinsList[coin].getName();
        address addr = coinsList[coin].getAddress();
        emit test(val, name);
        val = 2;
        emit test2(val, addr);

    }
    
    function executeBet(string memory coin) public payable{
        //msg.sender // msg.value
        require(existingCoins[coin] != false, "The coin you are trying to bet on doesn't exist");
        require(msg.value > 0 ether, "you need to add a positive ether value to make a bet");
        uint256 betID = coinsList[coin].placeBet(msg.sender, msg.value);
        emit success("Your bet was placed successfully, please reedem your winnings after 24h using for the follwing betID",betID);
        
    }
    
    function redeemBet(string memory coin,uint256 betID) public{
        require(existingCoins[coin] != false, "The coin you are trying to bet on doesn't exist");
        coinsList[coin].redeemBet(betID);
    }
    
    function getThePrice() public {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        emit test3("BAT",price);
        
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    // Accept any incoming amount - I guess if anyone want to donate :) 
    receive() external payable {}

    // Contract destructor
    function destroy() public onlyOwner {
        /*add withdraw link back to my address aswell or I'll lose the link*/
        LINK.transfer(owner, LINK.balanceOf(address(this)));
        selfdestruct(owner);
    }
    
}
